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
      echo "Refusing to replace non-symlink dotfile target: $target" >&2
      exit 1
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
}
