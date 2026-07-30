# Live-editable, out-of-store links shared by Home Manager on both platforms.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  repo = "${config.home.homeDirectory}/.dotfiles";
  linkSets = import ../symlinks.nix { };
  platformLinks =
    if pkgs.stdenv.isDarwin then
      linkSets.darwinLinks
    else if pkgs.stdenv.isLinux then
      linkSets.linuxLinks
    else
      { };
  links = linkSets.commonLinks // platformLinks;

  mkHomeFile = source: {
    source = config.lib.file.mkOutOfStoreSymlink "${repo}/${source}";
  };

  mkAdoptionCheck = target: source: ''
    target=${lib.escapeShellArg "${config.home.homeDirectory}/${target}"}
    source=${lib.escapeShellArg "${repo}/${source}"}

    if [ ! -e "$source" ]; then
      echo "Missing dotfile source: $source" >&2
      exit 1
    fi

    if [ -L "$target" ]; then
      current_target="$(${pkgs.coreutils}/bin/readlink "$target")"
      if [ "$current_target" = "$source" ]; then
        # Adopt links created by the previous activation implementation.
        rm "$target"
      else
        case "$current_target" in
          /nix/store/*-home-manager-files/*) ;;
          *)
            echo "Refusing to replace unexpected symlink: $target -> $current_target" >&2
            exit 1
            ;;
        esac
      fi
    elif [ -e "$target" ]; then
      files_match=false
      if [ -f "$target" ] && [ -f "$source" ]; then
        if ${pkgs.diffutils}/bin/cmp -s "$target" "$source"; then
          files_match=true
        elif [[ "$target" = *.json ]] \
          && [ "$(${pkgs.jq}/bin/jq -S -c . "$target" 2>/dev/null)" = "$(${pkgs.jq}/bin/jq -S -c . "$source" 2>/dev/null)" ]; then
          files_match=true
        fi
      fi

      if $files_match; then
        # Adopt an app-generated file once it matches the declared dotfile.
        rm "$target"
      else
        echo "Refusing to replace non-symlink dotfile target: $target" >&2
        exit 1
      fi
    fi
  '';
in
{
  home.file = lib.mapAttrs (_: mkHomeFile) links;

  # Remove only legacy links that already point to this checkout. Real files,
  # directories, and unrelated symlinks remain untouched and abort activation.
  home.activation.adoptDotfileSymlinks = config.lib.dag.entryBefore [ "checkLinkTargets" ] (
    lib.concatStringsSep "\n" (lib.mapAttrsToList mkAdoptionCheck links)
  );

  # Initialize account metadata outside Git and the Nix store. Never overwrite
  # a configured account or relax its permissions on subsequent activations.
  home.activation.bootstrapNeoMuttAccount = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    private_dir=${lib.escapeShellArg "${config.home.homeDirectory}/.config/neomutt/private"}
    account="$private_dir/account.neomuttrc"
    template=${lib.escapeShellArg "${repo}/neomutt/account.neomuttrc.example"}

    ${pkgs.coreutils}/bin/install -d -m 700 "$private_dir"
    if [ ! -e "$account" ]; then
      ${pkgs.coreutils}/bin/install -m 600 "$template" "$account"
    fi
  '';
}
