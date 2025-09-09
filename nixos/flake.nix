{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # bring your dotfiles in as a flake input (read-only, pure)
    dotfiles.url = "path:/Users/kamil/.dotfiles";
    dotfiles.flake = false;

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    rust-overlay.url = "github:oxalica/rust-overlay";
    stylix.url = "github:nix-community/stylix";

    # Add private fonts
    berkeley-font = {
      url = "path:///home/kamil/.local/share/fonts";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin
    , berkeley-font, neovim-nightly-overlay, dotfiles, rust-overlay, stylix, ... }:
    let
      # Define supported systems
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Auto-detect current system or fall back to aarch64-linux
      system = builtins.currentSystem or "aarch64-linux";

      # Helper function to create packages for a given system
      mkPkgs = system:
        import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config.allowUnfree = true;
        };

      pkgs = mkPkgs system;
      pkgsStable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      lib = nixpkgs.lib;

    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs; };
        modules = [
          ./configuration.nix
          stylix.nixosModules.stylix

          # enable HM as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            # Stylix configuration for NixOS
            stylix = {
              enable = true;
              image = dotfiles + "/wallpapers/kanagawa_bowl.jpg";
              polarity = "dark";
              base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
              
              fonts = {
                monospace = {
                  name = "Berkeley Mono";
                };
                sansSerif = {
                  package = pkgs.inter;
                  name = "Inter";
                };
                serif = {
                  package = pkgs.libertinus;
                  name = "Libertinus Serif";
                };
              };
            };

            # --- your user ---
            home-manager.users.kamil = { pkgs, config, ... }:
              {
                home.username = "kamil";
                home.homeDirectory = lib.mkForce "/home/kamil";
                home.stateVersion = "24.11";

                # if mako comes in, disable it since it crashes
                # home.disabledModules = ["services.mako.nix"];

                # packages you want at user scope
                home.packages = (with pkgs; [
                  wezterm
                  firefox
                  fzf
                  bat
                  delta
                  lazygit
                  lazydocker
                  docker

                  # C, Rust, Zig
                  gcc
                  cargo
                  rustc
                  rust-analyzer
                  rustfmt
                  clippy
                  (pkgs.rust-bin.nightly.latest.default.override {
                    extensions =
                      [ "rust-src" "cargo" "rustc" "rustfmt" "clippy" ];
                  })

                  # Nix formatters (instead of Mason building them)
                  nixpkgs-fmt
                  nixfmt-classic
                  alejandra
                ]) ++ [
                  # + the ones from `unstable` branch  
                  neovim-nightly-overlay.packages.${system}.default
                ];

                # fonts.fontconfig.defaultFonts.monospace = ["Berkeley Mono"];

                # programs.*: let HM manage app configs

                programs.zsh = {
                  enable = true;
                  autosuggestion.enable = true;
                  syntaxHighlighting.enable = true;
                  enableCompletion = true;

                  # Shell aliases
                  shellAliases = {
                    n = "nvim .";
                    y = "yazi .";
                    b = "browser";
                    c = "config";
                    hf = "his";
                    x = "exit";
                    q = "exit";
                    lg = "lazygit";
                    ldk = "lazydocker";
                    ls = "lsd";
                    finder = "open";
                    grep = "grep --color=auto";
                    reset_zsh = "source ~/.zshrc";
                    clear_nvim_cache = "rm -rf ~/.local/share/nvim";
                    cat = "bat";
                    jira = "~/bin/jira";
                    serpl = "~/bin/serpl";
                    json = "fx";
                    doom = "~/.config/emacs/bin/doom";
                    chsh = "~/.local/scripts/tmux-cht/tmux-cht.sh";
                    private_gitignore = "nvim .git/info/exclude";
                    git_log = "serie";

                    # Nix rebuild alias
                    nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos";

                    # Git aliases
                    gpom = "git pull origin master";
                    gpod = "git pull origin development";
                    gc = "git checkout";
                    gcb = "git checkout -b";
                    gags = "git add . && git stash";
                    gsp = "git stash pop";
                  };

                  # History configuration
                  history = {
                    size = 999;
                    save = 1000;
                    path = "$HOME/.zhistory";
                    ignoreDups = true;
                    ignoreSpace = true;
                    expireDuplicatesFirst = true;
                    share = true;
                  };

                  initContent =
                    "	export PATH=\"/run/current-system/sw/bin:$HOME/.nix-profile/bin:$HOME/.cargo/bin:$PATH\"\n	\n	# Cargo/Rust environment\n	export CARGO_TARGET_DIR=\"$HOME/.cache/cargo-target\"\n	export CARGO_HOME=\"$HOME/.cargo\"\n	export RUSTUP_HOME=\"$HOME/.rustup\"\n\n	# Disable auto update and title\n	DISABLE_AUTO_UPDATE=true\n	export DISABLE_AUTO_TITLE=true\n	export MANPAGER=\"nvim -c 'Man!' -\"\n	\n	# Editor configuration\n	if [[ -n $SSH_CONNECTION ]]; then\n		export EDITOR='vim'\n	else\n		export EDITOR='nvim'\n	fi\n	\n	# XDG config directory\n	export XDG_CONFIG_HOME=\"$HOME/.config\"\n	\n	# FZF configuration\n	export FZF_DEFAULT_OPTS=\" \\\n	--multi \\\n	--height=50% \\\n	--margin=5%,2%,2%,5% \\\n	--layout=reverse-list \\\n	--border=double \\\n	--info=inline \\\n	--prompt='$>' \\\n	--pointer='→' \\\n	--marker='♡' \\\n	--color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#7AA89F \\\n	--color=fg:-1,bg:-1,header:#DCD7BA,info:#7AA89F,pointer:#f5e0dc \\\n	--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#7AA89F,hl+:#7AA89F \\\n	--header='CTRL-c or ESC to quit' \\\n	--preview 'bat --style=numbers --color=always --line-range :500 {}' \\\n	--height 70% --layout reverse --border top\"\n	export FZF_DEFAULT_COMMAND='rg --files --hidden --glob \"!.git\"'\n	\n	# Node and package managers\n	export NVM_DIR=\"$HOME/.nvm\"\n	[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"\n	[ -s \"$NVM_DIR/bash_completion\" ] && \\. \"$NVM_DIR/bash_completion\"\n	\n	export BUN_INSTALL=\"$HOME/.bun\"\n	export PATH=\"$BUN_INSTALL/bin:$PATH\"\n	\n	if [[ \"$OSTYPE\" == \"darwin\"* ]]; then\n		export PNPM_HOME=\"/Users/kamil/Library/pnpm\"\n	else\n		export PNPM_HOME=\"$HOME/.local/share/pnpm\"\n	fi\n	case \":$PATH:\" in\n		*\":$PNPM_HOME:\"*) ;;\n		*) export PATH=\"$PNPM_HOME:$PATH\" ;;\n	esac\n	\n	# Homebrew\n	export HOMEBREW_NO_AUTO_UPDATE=1\n	\n	# Bat theme\n	export BAT_THEME=\"gruvbox-dark\"\n	\n	# Vi mode and key bindings\n	bindkey -v\n	export KEYTIMEOUT=1\n	export VI_MODE_SET_CURSOR=true\n	bindkey '^[[A' history-search-backward\n	bindkey '^[[B' history-search-forward\n	\n	# ZVM configuration\n	ZVM_VI_HIGHLIGHT_BACKGROUND=#A33FC4\n	ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL\n	\n	# FZF completion helper\n	_fzf_comprun() {\n		local command=$1\n		shift\n		case \"$command\" in\n			cd)           fzf \"$@\" --preview 'tree -C {} | head -200' ;;\n			*)            fzf \"$@\" ;;\n		esac\n	}\n	\n	# Powerline settings\n	USE_POWERLINE=\"true\"\n	HAS_WIDECHARS=\"false\"\n	\n	# Weather function\n	weather() {\n		curl \"wttr.in/$1?lang=pl\"\n	}\n	\n	# Directory search and navigation\n	sd() {\n		local dirs=()\n		if [ -f \"$HOME/.zsh_company_dirs\" ]; then\n			source \"$HOME/.zsh_company_dirs\"\n			dirs+=(\"\${COMPANY_DIRS[@]}\")\n		fi\n		if [ -f \"$HOME/.zsh_personal_dirs\" ]; then\n			source \"$HOME/.zsh_personal_dirs\"\n			dirs+=(\"\${PERSONAL_DIRS[@]}\")\n		fi\n		cd \"$(printf '%s\\n' \"\${dirs[@]}\" | fzf)\"\n	}\n	\n	# SSH fuzzy search\n	sshf() {\n		local ssh_hosts=$(grep \"^Host \" ~/.ssh/config | awk '{print $2}')\n		local selected_host=$(printf '%s\\n' \"\${ssh_hosts[@]}\" | fzf)\n		if [[ -n $selected_host ]]; then\n			ssh \"$selected_host\"\n		fi\n	}\n	\n	# Remote SSHFS mount\n	remote_sshfs() {\n		local ssh_alias=$(awk '/^Host / {print $2}' ~/.ssh/config | fzf)\n		if [ -z \"$ssh_alias\" ]; then\n			echo \"No alias selected!\"\n			return 1\n		fi\n		local remote_base_path=\"/\"\n		local remote_dir=$(ssh $ssh_alias \"find $remote_base_path -maxdepth 1 -type d\" | fzf)\n		if [ -z \"$remote_dir\" ]; then\n			echo \"No directory selected!\"\n			return 1\n		fi\n		local mount_point=\"$HOME/remote-repos/$ssh_alias\"\n		mkdir -p $mount_point\n		echo \"Mounting $remote_dir...\"\n		sshfs -F ~/.ssh/config $ssh_alias:$remote_dir $mount_point\n		echo \"Attaching to Docker container...\"\n		ssh $ssh_alias \"cd $remote_dir && docker-compose exec app bash\"\n		nvim $mount_point\n		echo \"Unmounting $remote_dir...\"\n		fusermount -u $mount_point\n	}\n	\n	# Search directory and open nvim\n	sdn() {\n		sd && nvim .\n	}\n	\n	# Config search\n	config() {\n		source \"$HOME/.zsh_config_aliases\"\n		local config_keys=(\"\${(k)CONFIG_ALIASES[@]}\")\n		local selected_key=$(printf '%s\\n' \"\${config_keys[@]}\" | fzf)\n		if [[ -n $selected_key ]]; then\n			eval \"\${CONFIG_ALIASES[$selected_key]}\"\n		fi\n	}\n	\n	# Database search\n	db() {\n		source \"$HOME/.zsh_db_configs\"\n		local config_keys=(\"\${(k)DB_CONFIGS[@]}\")\n		local selected_key=$(printf '%s\\n' \"\${config_keys[@]}\" | fzf)\n		if [[ -n $selected_key ]]; then\n			eval \"\${DB_CONFIGS[$selected_key]}\"\n		fi\n	}\n	\n	# Work sites browser\n	work_sites() {\n		source \"$HOME/.zsh_company_websites\"\n		local company_website_keys=(\"\${(k)COMPANY_WEBSITES[@]}\")\n		local selected_key=$(printf '%s\\n' \"\${company_website_keys[@]}\" | fzf)\n		if [[ -n $selected_key ]]; then\n			open \"\${COMPANY_WEBSITES[$selected_key]}\"\n		fi\n	}\n	\n	# Git branch switcher\n	switch_branch() {\n		git fetch -a\n		local selected_branch=$(git branch --list | fzf)\n		if [[ -n $selected_branch ]]; then\n			git checkout \"$selected_branch\"\n		fi\n	}\n	\n	# History fuzzy search\n	hisf() {\n		local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)\n		local selected_command_from_history=$(printf '%s\\n' \"\${commands_history_entries[@]}\" | fzf)\n		if [[ -n $selected_command_from_history ]]; then\n			eval \"$selected_command_from_history\"\n		fi\n	}\n	\n	# Process killer\n	killf() {\n		ps aux | fzf --preview=\"\" --prompt=\"Select process to kill: \" | awk '{print $2}' | xargs -r kill -9\n	}\n	\n	# Color palette display\n	color_palette() {\n		for i in {0..255}; do print -Pn \"%K{$i}  %k%F{$i}\${(l:3::0:)i}%f \" \${\${(M)$((i%6)):#3}:+$'\\n'}; done\n	}\n	\n	# Second brain shortcut\n	sb() {\n		cd ~/second-brain/ && nvim .\n	}\n	\n	# macOS clipboard copy\n	macos_copy_to_clipboard() {\n		pbcopy < $1\n	}\n	\n	# macOS key repeat settings\n	macos_set_proper_key_repeat() {\n		defaults write -g KeyRepeat -int 1 && defaults write -g InitialKeyRepeat -int 10\n	}\n	\n	# Source external files if they exist\n	[ -f \"$HOME/.config/broot/launcher/bash/br\" ] && source \"$HOME/.config/broot/launcher/bash/br\"\n	[ -f \"$HOME/.dotfiles/config/scripts/fzf-git.sh\" ] && source \"$HOME/.dotfiles/config/scripts/fzf-git.sh\"\n	\n	# Enable colors and prompt substitution\n	autoload -U colors && colors\n	setopt PROMPT_SUBST\n	\n	# Set up fzf key bindings and fuzzy completion\n	eval \"$(fzf --zsh)\"\n";
                };

                programs.starship = {
                  enable = true;
                  enableZshIntegration = true;
                  settings = {
                    format = "$directory$git_branch$character";
                    directory = {
                      style = "#7B958E"; # muted teal-green
                      format = "[$path]($style) ";
                    };
                    git_branch = {
                      style = "#958294"; # muted purple-grey
                      format = "on [$symbol$branch]($style) ";
                    };
                    character = {
                      success_symbol =
                        "[➜](#7B9A5B)"; # muted green with similar saturation
                      error_symbol = "[➜](#A95B58)"; # muted red-brown
                    };
                  };
                };

                programs.git = {
                  enable = true;
                  userName = "Kamil Ksen";
                  userEmail = "mccom_kks@mccom.pl";
                  extraConfig = {
                    core.editor = "nvim";
                    init.defaultBranch = "main";
                  };
                };

                # --- map your dotfiles repo into place ---
                # ~/.config/*
                xdg.configFile."nvim".source = dotfiles + "/nvim";
                xdg.configFile."wezterm".source = dotfiles + "/wezterm";
                xdg.configFile."lazygit".source = dotfiles + "/config/lazygit";
                xdg.configFile."lazydocker".source = dotfiles
                  + "/config/lazydocker";

                # Linux-specific configs
              }
              // lib.optionalAttrs (builtins.match ".*linux.*" system != null) {
                xdg.configFile."hypr".source = dotfiles + "/config/hypr";
                xdg.configFile."waybar".source = dotfiles + "/config/waybar";
                xdg.configFile."wofi".source = dotfiles + "/config/wofi";

                # macOS-specific configs  
              } // lib.optionalAttrs
              (builtins.match ".*darwin.*" system != null) {
                xdg.configFile."yabai".source = dotfiles + "/yabai";
                xdg.configFile."skhd".source = dotfiles + "/skhd";
                xdg.configFile."sketchybar".source = dotfiles + "/sketchybar";
                xdg.configFile."hammerspoon".source = dotfiles + "/hammerspoon";

                home.file."second-brain/.keep".text = "";

                # files in $HOME root (start with a dot)
                home.file.".local/share/fonts/BerkeleyMono-Regular.otf".source =
                  berkeley-font + "/BerkeleyMono-Regular.otf";
                home.file.".local/share/fonts/BerkeleyMono-Bold.otf".source =
                  berkeley-font + "/BerkeleyMono-Bold.otf";
                home.file.".local/share/fonts/BerkeleyMono-Oblique.otf".source =
                  berkeley-font + "/BerkeleyMono-Oblique.otf";
                home.file.".local/share/fonts/BerkeleyMono-Bold-Oblique.otf".source =
                  berkeley-font + "/BerkeleyMono-Bold-Oblique.otf";

                fonts.fontconfig.enable = true;
                fonts.fontconfig.defaultFonts.monospace = [ "Berkeley Mono" ];

                # alacritty examples (you have both toml & yml in repo)
                # home.file.".alacritty.toml".source = dotfiles + "/.alacritty.toml";
                # or choose one and ignore the other

                # optional: run your old bootstrap once on activation (idempotent)
                # home.activation.bootstrap = lib.hm.dag.entryAfter ["writeBoundary"] ''
                #   # e.g., migrate/clean legacy symlinks if needed
                # '';

                # Nice defaults
                xdg.enable = false;
                programs.home-manager.enable = true;
              };

            # Per-OS gating for files you only want on macOS / Linux
            # Example: only install yabai/skhd configs on macOS
            # (for later if you reuse the same flake on your Mac)
            # home-manager.sharedModules = [
            #   ({ pkgs, ... }: lib.mkIf pkgs.stdenv.isDarwin {
            #     xdg.configFile."yabai".source = dotfiles + "/yabai";
            #     xdg.configFile."skhd".source  = dotfiles + "/skhd";
            #   })
            # ];
          }
        ];
      };

      # Darwin configuration for macOS
      darwinConfigurations."MacBook-Pro-Kamil" = let
        darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs
        darwinPkgs = import nixpkgs {
          system = darwinSystem;
          overlays = [ rust-overlay.overlays.default ];
          config.allowUnfree = true;
        };
        darwinPkgsStable = import nixpkgs-stable {
          system = darwinSystem;
          config.allowUnfree = true;
        };
      in nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {
          inherit lib;
          pkgs = darwinPkgs;
          pkgsStable = darwinPkgsStable;
        };
        modules = [
          stylix.darwinModules.stylix
          # nix-darwin system configuration
          ({ config, pkgs, ... }: {
            # Let Determinate handle the module resolution
            nix.enable = false;
            # List packages installed in system profile
            environment.systemPackages = with pkgs; [
              vim
              git
              curl
              wget
              opencode
            ];

            # Nix configuration (nix-daemon is enabled by default when nix.enable = true)
            # nix.package = pkgs.nix;

            # Enable flakes
            # nix.settings.experimental-features = "nix-command flakes";

            # Create /etc/zshrc that loads the nix-darwin environment
            programs.zsh = {
              enable = true;
              enableCompletion = true;
              enableBashCompletion = true;
            };

            # Set Git commit hash for darwin-version
            system.configurationRevision = self.rev or self.dirtyRev or null;

            # Used for backwards compatibility
            system.stateVersion = 5;

            # The platform the configuration will be used on
            nixpkgs.hostPlatform = "aarch64-darwin";

            # Stylix configuration
            stylix = {
              enable = true;
              image = dotfiles + "/wallpapers/kanagawa_bowl.jpg";
              polarity = "dark";
              base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
              
              fonts = {
                monospace = {
                  name = "Berkeley Mono";
                };
                sansSerif = {
                  package = pkgs.inter;
                  name = "Inter";
                };
                serif = {
                  package = pkgs.libertinus;
                  name = "Libertinus Serif";
                };
              };
            };

            # Set primary user (required for system defaults and homebrew)
            system.primaryUser = "kamil";

            # Configure users and set shell
            users.users.kamil = {
              name = "kamil";
              home = "/Users/kamil";
              shell = pkgs.zsh;
            };

            # Ensure nix-darwin manages shells
            environment.shells = with pkgs; [ zsh ];

            # Add nix paths to zsh
            environment.variables = {
              EDITOR = "nvim";
              SHELL = "${pkgs.zsh}/bin/zsh";
            };

            # Ensure nix environment is loaded in all shells
            environment.interactiveShellInit =
              "	# Nix\n	if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then\n		. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'\n	fi\n	# End Nix\n";

            # macOS system defaults
            system.defaults = {
              dock = {
                autohide = true;
                show-recents = false;
                tilesize = 48;
              };
              finder = {
                AppleShowAllExtensions = true;
                ShowPathbar = true;
                ShowStatusBar = true;
              };
              NSGlobalDomain = {
                AppleShowAllExtensions = true;
                KeyRepeat = 2;
                InitialKeyRepeat = 15;
                ApplePressAndHoldEnabled = false;
              };
            };

            # Homebrew integration  
            homebrew = {
              enable = true;
              onActivation.cleanup = "uninstall";
               casks = [
                 # Keep these that aren't available in nixpkgs or ARM macOS
                 "vivaldi"
                 "love"
                 "stats"
                 "macs-fan-control"
                 "utm"
                 "podman-desktop"
                 "qmk-toolbox"
                 "ytmdesktop-youtube-music"
               ];
               taps = [
               ];
               brews = [
               ];
            };
          })

          # Home Manager for Darwin
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.users.kamil = { pkgs, config, ... }: {
              home.username = "kamil";
              home.homeDirectory = lib.mkForce "/Users/kamil";
              home.stateVersion = "24.11";

              # Reuse packages from your NixOS config but adapted for macOS
              home.packages = (with pkgs; [
                # Browsers and core apps
                wezterm
                firefox
                qutebrowser

                # Development tools
                vscode

                # Terminal tools
                fzf
                bat
                delta
                lazygit
                lazydocker
                docker
                ripgrep
                btop
                lsd
                yazi
                tmux

                # Shell and CLI utilities  
                starship
                zsh
                gh
                curl
                wget
                tree
                fd
                eza
                difftastic
                just
                jq
                yq

                # Development tools
                gcc
                go
                nodejs
                yarn
                pnpm
                deno
                lua
                luarocks
                python3
                php
                cargo
                rustc
                rust-analyzer

                # Nix formatters
                nixpkgs-fmt
                nixfmt-classic
                alejandra

                # Text processing and search
                gnugrep
                gnused
                coreutils

                # System monitoring and management
                htop
                fastfetch
                pfetch
                neofetch

                # File and archive tools
                unzip
                p7zip
                trash-cli

                # Network and system tools
                nmap
                wireshark-cli
                socat

                # Office/Documents moved to homebrew for ARM macOS

                # Development/Programming
                kitty # Terminal emulator

                # Container tools (CLI versions, GUI via homebrew)
                podman
                podman-compose

                # Media and graphics
                ffmpeg
                imagemagick

                # Database and data tools
                sqlite
                postgresql

                # Text editors and viewers
                helix

                # Version control extras
                git-extras
                tig

                # Virtualization and containers
                qemu
                lima
                colima

                # System utilities
                stow
                cowsay
                figlet
                fortune
                lolcat

                # Programming language tools
                zig
                stylua
                lua-language-server

                # Nix formatters
                nixpkgs-fmt
                nixfmt-classic
                alejandra

                # Terminal multiplexers and sessions
                zellij

                # File synchronization and transfer
                rsync
                openssh
                sshfs-fuse

                # Other useful tools
                tldr # Simplified man pages
                watchexec # File watching
              ]) ++ [
                # Add neovim from the overlay
                neovim-nightly-overlay.packages.${darwinSystem}.default
              ];

              # Reuse your zsh configuration with minor adaptations
              programs.zsh = {
                enable = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;
                enableCompletion = true;

                # Same shell aliases as NixOS
                shellAliases = {
                  n = "nvim .";
                  y = "yazi .";
                  b = "browser";
                  c = "config";
                  hf = "his";
                  x = "exit";
                  q = "exit";
                  lg = "lazygit";
                  ldk = "lazydocker";
                  ls = "lsd";
                  finder = "open";
                  grep = "grep --color=auto";
                  reset_zsh = "source ~/.zshrc";
                  clear_nvim_cache = "rm -rf ~/.local/share/nvim";
                  cat = "bat";
                  jira = "~/bin/jira";
                  serpl = "~/bin/serpl";
                  json = "fx";
                  doom = "~/.config/emacs/bin/doom";
                  chsh = "~/.local/scripts/tmux-cht/tmux-cht.sh";
                  private_gitignore = "nvim .git/info/exclude";
                  git_log = "serie";

                  # Nix rebuild alias
                  nrs = "sudo darwin-rebuild switch --flake ~/.dotfiles/nixos";

                  # Git aliases
                  gpom = "git pull origin master";
                  gpod = "git pull origin development";
                  gc = "git checkout";
                  gcb = "git checkout -b";
                  gags = "git add . && git stash";
                  gsp = "git stash pop";
                };

                # Same history configuration
                history = {
                  size = 999;
                  save = 1000;
                  path = "$HOME/.zhistory";
                  ignoreDups = true;
                  ignoreSpace = true;
                  expireDuplicatesFirst = true;
                  share = true;
                };

                initContent =
                  "	# Source nix-darwin environment first\n	if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then\n		. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'\n	fi\n	\n	# macOS-specific paths\n	export PATH=\"/opt/homebrew/bin:$PATH\"\n	export PNPM_HOME=\"/Users/kamil/Library/pnpm\"\n	export PATH=\"$PNPM_HOME:$HOME/.cargo/bin:$PATH\"\n	\n	# Cargo/Rust environment\n	export CARGO_TARGET_DIR=\"$HOME/.cache/cargo-target\"\n	export CARGO_HOME=\"$HOME/.cargo\"\n	export RUSTUP_HOME=\"$HOME/.rustup\"\n	\n	# Editor configuration\n	export EDITOR='nvim'\n	export XDG_CONFIG_HOME=\"$HOME/.config\"\n	export BAT_THEME=\"gruvbox-dark\"\n	\n	# Homebrew\n	export HOMEBREW_NO_AUTO_UPDATE=1\n	\n	# FZF configuration\n	export FZF_DEFAULT_OPTS=\" \\\n	--multi \\\n	--height=50% \\\n	--margin=5%,2%,2%,5% \\\n	--layout=reverse-list \\\n	--border=double \\\n	--info=inline \\\n	--prompt='$>' \\\n	--pointer='→' \\\n	--marker='♡' \\\n	--color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#7AA89F \\\n	--color=fg:-1,bg:-1,header:#DCD7BA,info:#7AA89F,pointer:#f5e0dc \\\n	--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#7AA89F,hl+:#7AA89F \\\n	--header='CTRL-c or ESC to quit' \\\n	--preview 'bat --style=numbers --color=always --line-range :500 {}' \\\n	--height 70% --layout reverse --border top\"\n	export FZF_DEFAULT_COMMAND='rg --files --hidden --glob \"!.git\"'\n	\n	# Vi mode and key bindings\n	bindkey -v\n	export KEYTIMEOUT=1\n	export VI_MODE_SET_CURSOR=true\n	bindkey '^[[A' history-search-backward\n	bindkey '^[[B' history-search-forward\n	\n	# FZF completion helper\n	_fzf_comprun() {\n		local command=$1\n		shift\n		case \"$command\" in\n			cd)           fzf \"$@\" --preview 'tree -C {} | head -200' ;;\n			*)            fzf \"$@\" ;;\n		esac\n	}\n	\n	# Weather function\n	weather() {\n		curl \"wttr.in/$1?lang=pl\"\n	}\n	\n	# Directory search and navigation\n	sd() {\n		local dirs=()\n		if [ -f \"$HOME/.zsh_company_dirs\" ]; then\n			source \"$HOME/.zsh_company_dirs\"\n			dirs+=(\"\${COMPANY_DIRS[@]}\")\n		fi\n		if [ -f \"$HOME/.zsh_personal_dirs\" ]; then\n			source \"$HOME/.zsh_personal_dirs\"\n			dirs+=(\"\${PERSONAL_DIRS[@]}\")\n		fi\n		cd \"$(printf '%s\\n' \"\${dirs[@]}\" | fzf)\"\n	}\n	\n	# SSH fuzzy search\n	sshf() {\n		local ssh_hosts=$(grep \"^Host \" ~/.ssh/config | awk '{print $2}')\n		local selected_host=$(printf '%s\\n' \"\${ssh_hosts[@]}\" | fzf)\n		if [[ -n $selected_host ]]; then\n			ssh \"$selected_host\"\n		fi\n	}\n	\n	# Search directory and open nvim\n	sdn() {\n		sd && nvim .\n	}\n	\n	# Config search\n	config() {\n		source \"$HOME/.zsh_config_aliases\"\n		local config_keys=(\"\${(k)CONFIG_ALIASES[@]}\")\n		local selected_key=$(printf '%s\\n' \"\${config_keys[@]}\" | fzf)\n		if [[ -n $selected_key ]]; then\n			eval \"\${CONFIG_ALIASES[$selected_key]}\"\n		fi\n	}\n	\n	# Database search\n	db() {\n		source \"$HOME/.zsh_db_configs\"\n		local config_keys=(\"\${(k)DB_CONFIGS[@]}\")\n		local selected_key=$(printf '%s\\n' \"\${config_keys[@]}\" | fzf)\n		if [[ -n $selected_key ]]; then\n			eval \"\${DB_CONFIGS[$selected_key]}\"\n		fi\n	}\n	\n	# Work sites browser\n	work_sites() {\n		source \"$HOME/.zsh_company_websites\"\n		local company_website_keys=(\"\${(k)COMPANY_WEBSITES[@]}\")\n		local selected_key=$(printf '%s\\n' \"\${company_website_keys[@]}\" | fzf)\n		if [[ -n $selected_key ]]; then\n			open \"\${COMPANY_WEBSITES[$selected_key]}\"\n		fi\n	}\n	\n	# Git branch switcher\n	switch_branch() {\n		git fetch -a\n		local selected_branch=$(git branch --list | fzf)\n		if [[ -n $selected_branch ]]; then\n			git checkout \"$selected_branch\"\n		fi\n	}\n	\n	# History fuzzy search\n	hisf() {\n		local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)\n		local selected_command_from_history=$(printf '%s\\n' \"\${commands_history_entries[@]}\" | fzf)\n		if [[ -n $selected_command_from_history ]]; then\n			eval \"$selected_command_from_history\"\n		fi\n	}\n	\n	# Process killer\n	killf() {\n		ps aux | fzf --preview=\"\" --prompt=\"Select process to kill: \" | awk '{print $2}' | xargs -r kill -9\n	}\n	\n	# Second brain shortcut\n	sb() {\n		cd ~/second-brain/ && nvim .\n	}\n	\n	# macOS clipboard copy\n	macos_copy_to_clipboard() {\n		pbcopy < $1\n	}\n	\n	# macOS key repeat settings\n	macos_set_proper_key_repeat() {\n		defaults write -g KeyRepeat -int 1 && defaults write -g InitialKeyRepeat -int 10\n	}\n	\n	# Source external files if they exist\n	[ -f \"$HOME/.config/broot/launcher/bash/br\" ] && source \"$HOME/.config/broot/launcher/bash/br\"\n	[ -f \"$HOME/.dotfiles/config/scripts/fzf-git.sh\" ] && source \"$HOME/.dotfiles/config/scripts/fzf-git.sh\"\n	\n	# Enable colors and prompt substitution\n	autoload -U colors && colors\n	setopt PROMPT_SUBST\n	\n	# Set up fzf key bindings and fuzzy completion\n	eval \"$(fzf --zsh)\"\n";
              };

              # Same starship config
              programs.starship = {
                enable = true;
                enableZshIntegration = true;
                settings = {
                  format = "$directory$git_branch$character";
                  directory = {
                    style = "#7B958E";
                    format = "[$path]($style) ";
                  };
                  git_branch = {
                    style = "#958294";
                    format = "on [$symbol$branch]($style) ";
                  };
                  character = {
                    success_symbol = "[➜](#7B9A5B)";
                    error_symbol = "[➜](#A95B58)";
                  };
                };
              };

              # Same git config
              programs.git = {
                enable = true;
                userName = "Kamil Ksen";
                userEmail = "mccom_kks@mccom.pl";
                extraConfig = {
                  core.editor = "nvim";
                  init.defaultBranch = "main";
                };
              };

              # Map your dotfiles for macOS
              xdg.configFile."nvim".source = dotfiles + "/nvim";
              xdg.configFile."wezterm".source = dotfiles + "/wezterm";
              xdg.configFile."lazygit".source = dotfiles + "/config/lazygit";

              # macOS-specific configs
              home.file.".hammerspoon".source = dotfiles + "/hammerspoon";

              # Enable XDG for proper config management
              xdg.enable = true;
              programs.home-manager.enable = true;
            };
          }
        ];
      };

      # Add required outputs for nix-darwin compatibility
      packages.aarch64-darwin.default =
        self.darwinConfigurations."MacBook-Pro-Kamil".system;
      packages.x86_64-darwin.default =
        self.darwinConfigurations."MacBook-Pro-Kamil".system;

      apps.aarch64-darwin.default = {
        type = "app";
        program = "${
            self.darwinConfigurations."MacBook-Pro-Kamil".system
          }/sw/bin/darwin-rebuild";
      };

      apps.x86_64-darwin.default = {
        type = "app";
        program = "${
            self.darwinConfigurations."MacBook-Pro-Kamil".system
          }/sw/bin/darwin-rebuild";
      };
    };
}

