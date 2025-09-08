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

# Add private fonts
		berkeley-font = {
			url = "path:///home/kamil/.local/share/fonts";
			flake = false;
		};

	};

	outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nix-darwin, berkeley-font, neovim-nightly-overlay, dotfiles, rust-overlay, ... }:
		let
		# Define supported systems
		systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
		
		# Auto-detect current system or fall back to aarch64-linux
		system = builtins.currentSystem or "aarch64-linux";
		
		# Helper function to create packages for a given system
		mkPkgs = system: import nixpkgs {
			inherit system;
			overlays = [rust-overlay.overlays.default ];
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

# enable HM as a NixOS module
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.backupFileExtension = "backup";

# --- your user ---
						home-manager.users.kamil = { pkgs, config, ... }: {
							home.username = "kamil";
							home.homeDirectory = lib.mkForce "/home/kamil";
							home.stateVersion = "24.11";


# if mako comes in, disable it since it crashes
# home.disabledModules = ["services.mako.nix"];

# packages you want at user scope
							home.packages = (with pkgs; [
									wezterm firefox
									fzf bat delta lazygit lazydocker docker


# C, Rust, Zig
									gcc 
									(pkgs.rust-bin.nightly.latest.default.override {
									 extensions = [ "rust-src" "cargo" "rustc" ];
									 })
							]) ++
								[
# + the ones from `unstable` branch  
								pkgs.opencode  # Now using unstable nixpkgs as main
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
								
							initContent = ''
									export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH"

									# Disable auto update and title
									DISABLE_AUTO_UPDATE=true
									export DISABLE_AUTO_TITLE=true
									export MANPAGER="nvim -c 'Man!' -"
									
									# Editor configuration
									if [[ -n $SSH_CONNECTION ]]; then
										export EDITOR='vim'
									else
										export EDITOR='nvim'
									fi
									
									# XDG config directory
									export XDG_CONFIG_HOME="$HOME/.config"
									
									# FZF configuration
									export FZF_DEFAULT_OPTS=" \
									--multi \
									--height=50% \
									--margin=5%,2%,2%,5% \
									--layout=reverse-list \
									--border=double \
									--info=inline \
									--prompt='$>' \
									--pointer='→' \
									--marker='♡' \
									--color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#7AA89F \
									--color=fg:-1,bg:-1,header:#DCD7BA,info:#7AA89F,pointer:#f5e0dc \
									--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#7AA89F,hl+:#7AA89F \
									--header='CTRL-c or ESC to quit' \
									--preview 'bat --style=numbers --color=always --line-range :500 {}' \
									--height 70% --layout reverse --border top"
									export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
									
									# Node and package managers
									export NVM_DIR="$HOME/.nvm"
									[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
									[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
									
									export BUN_INSTALL="$HOME/.bun"
									export PATH="$BUN_INSTALL/bin:$PATH"
									
									if [[ "$OSTYPE" == "darwin"* ]]; then
										export PNPM_HOME="/Users/kamil/Library/pnpm"
									else
										export PNPM_HOME="$HOME/.local/share/pnpm"
									fi
									case ":$PATH:" in
										*":$PNPM_HOME:"*) ;;
										*) export PATH="$PNPM_HOME:$PATH" ;;
									esac
									
									# Homebrew
									export HOMEBREW_NO_AUTO_UPDATE=1
									
									# Bat theme
									export BAT_THEME="gruvbox-dark"
									
									# Vi mode and key bindings
									bindkey -v
									export KEYTIMEOUT=1
									export VI_MODE_SET_CURSOR=true
									bindkey '^[[A' history-search-backward
									bindkey '^[[B' history-search-forward
									
									# ZVM configuration
									ZVM_VI_HIGHLIGHT_BACKGROUND=#A33FC4
									ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL
									
									# FZF completion helper
									_fzf_comprun() {
										local command=$1
										shift
										case "$command" in
											cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
											*)            fzf "$@" ;;
										esac
									}
									
									# Powerline settings
									USE_POWERLINE="true"
									HAS_WIDECHARS="false"
									
									# Weather function
									weather() {
										curl "wttr.in/$1?lang=pl"
									}
									
									# Directory search and navigation
									sd() {
										local dirs=()
										if [ -f "$HOME/.zsh_company_dirs" ]; then
											source "$HOME/.zsh_company_dirs"
											dirs+=("''${COMPANY_DIRS[@]}")
										fi
										if [ -f "$HOME/.zsh_personal_dirs" ]; then
											source "$HOME/.zsh_personal_dirs"
											dirs+=("''${PERSONAL_DIRS[@]}")
										fi
										cd "$(printf '%s\n' "''${dirs[@]}" | fzf)"
									}
									
									# SSH fuzzy search
									sshf() {
										local ssh_hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}')
										local selected_host=$(printf '%s\n' "''${ssh_hosts[@]}" | fzf)
										if [[ -n $selected_host ]]; then
											ssh "$selected_host"
										fi
									}
									
									# Remote SSHFS mount
									remote_sshfs() {
										local ssh_alias=$(awk '/^Host / {print $2}' ~/.ssh/config | fzf)
										if [ -z "$ssh_alias" ]; then
											echo "No alias selected!"
											return 1
										fi
										local remote_base_path="/"
										local remote_dir=$(ssh $ssh_alias "find $remote_base_path -maxdepth 1 -type d" | fzf)
										if [ -z "$remote_dir" ]; then
											echo "No directory selected!"
											return 1
										fi
										local mount_point="$HOME/remote-repos/$ssh_alias"
										mkdir -p $mount_point
										echo "Mounting $remote_dir..."
										sshfs -F ~/.ssh/config $ssh_alias:$remote_dir $mount_point
										echo "Attaching to Docker container..."
										ssh $ssh_alias "cd $remote_dir && docker-compose exec app bash"
										nvim $mount_point
										echo "Unmounting $remote_dir..."
										fusermount -u $mount_point
									}
									
									# Search directory and open nvim
									sdn() {
										sd && nvim .
									}
									
									# Config search
									config() {
										source "$HOME/.zsh_config_aliases"
										local config_keys=("''${(k)CONFIG_ALIASES[@]}")
										local selected_key=$(printf '%s\n' "''${config_keys[@]}" | fzf)
										if [[ -n $selected_key ]]; then
											eval "''${CONFIG_ALIASES[$selected_key]}"
										fi
									}
									
									# Database search
									db() {
										source "$HOME/.zsh_db_configs"
										local config_keys=("''${(k)DB_CONFIGS[@]}")
										local selected_key=$(printf '%s\n' "''${config_keys[@]}" | fzf)
										if [[ -n $selected_key ]]; then
											eval "''${DB_CONFIGS[$selected_key]}"
										fi
									}
									
									# Work sites browser
									work_sites() {
										source "$HOME/.zsh_company_websites"
										local company_website_keys=("''${(k)COMPANY_WEBSITES[@]}")
										local selected_key=$(printf '%s\n' "''${company_website_keys[@]}" | fzf)
										if [[ -n $selected_key ]]; then
											open "''${COMPANY_WEBSITES[$selected_key]}"
										fi
									}
									
									# Git branch switcher
									switch_branch() {
										git fetch -a
										local selected_branch=$(git branch --list | fzf)
										if [[ -n $selected_branch ]]; then
											git checkout "$selected_branch"
										fi
									}
									
									# History fuzzy search
									hisf() {
										local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)
										local selected_command_from_history=$(printf '%s\n' "''${commands_history_entries[@]}" | fzf)
										if [[ -n $selected_command_from_history ]]; then
											eval "$selected_command_from_history"
										fi
									}
									
									# Process killer
									killf() {
										ps aux | fzf --preview="" --prompt="Select process to kill: " | awk '{print $2}' | xargs -r kill -9
									}
									
									# Color palette display
									color_palette() {
										for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}''${(l:3::0:)i}%f " ''${''${(M)$((i%6)):#3}:+$'\n'}; done
									}
									
									# Second brain shortcut
									sb() {
										cd ~/second-brain/ && nvim .
									}
									
									# macOS clipboard copy
									macos_copy_to_clipboard() {
										pbcopy < $1
									}
									
									# macOS key repeat settings
									macos_set_proper_key_repeat() {
										defaults write -g KeyRepeat -int 1 && defaults write -g InitialKeyRepeat -int 10
									}
									
									# Source external files if they exist
									[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"
									[ -f "$HOME/.dotfiles/config/scripts/fzf-git.sh" ] && source "$HOME/.dotfiles/config/scripts/fzf-git.sh"
									
									# Enable colors and prompt substitution
									autoload -U colors && colors
									setopt PROMPT_SUBST
									
									# Set up fzf key bindings and fuzzy completion
									eval "$(fzf --zsh)"
								'';
							};




programs.starship = {
	enable = true;
	enableZshIntegration = true;
	settings = {
		format = "$directory$git_branch$character";
		directory = {
			style = "#7B958E";  # muted teal-green
			format = "[$path]($style) ";
		};
		git_branch = {
			style = "#958294";  # muted purple-grey
			format = "on [$symbol$branch]($style) ";
		};
		character = {
			success_symbol = "[➜](#7B9A5B)";  # muted green with similar saturation
			error_symbol = "[➜](#A95B58)";    # muted red-brown
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
							xdg.configFile."nvim".source     = dotfiles + "/nvim";
							xdg.configFile."wezterm".source  = dotfiles + "/wezterm";
							xdg.configFile."lazygit".source  = dotfiles + "/config/lazygit";
							xdg.configFile."lazydocker".source  = dotfiles + "/config/lazydocker";

							# Linux-specific configs
							} // lib.optionalAttrs (builtins.match ".*linux.*" system != null) {
								xdg.configFile."hypr".source     = dotfiles + "/config/hypr";
								xdg.configFile."waybar".source   = dotfiles + "/config/waybar";
								xdg.configFile."wofi".source     = dotfiles + "/config/wofi";
								
							# macOS-specific configs  
							} // lib.optionalAttrs (builtins.match ".*darwin.*" system != null) {
								xdg.configFile."yabai".source      = dotfiles + "/yabai";
								xdg.configFile."skhd".source       = dotfiles + "/skhd";
								xdg.configFile."sketchybar".source = dotfiles + "/sketchybar";
								xdg.configFile."hammerspoon".source = dotfiles + "/hammerspoon";

home.file."second-brain/.keep".text = ""; 

# files in $HOME root (start with a dot)
home.file.".local/share/fonts/BerkeleyMono-Regular.otf".source = berkeley-font + "/BerkeleyMono-Regular.otf";
home.file.".local/share/fonts/BerkeleyMono-Bold.otf".source = berkeley-font + "/BerkeleyMono-Bold.otf";
home.file.".local/share/fonts/BerkeleyMono-Oblique.otf".source = berkeley-font + "/BerkeleyMono-Oblique.otf";
home.file.".local/share/fonts/BerkeleyMono-Bold-Oblique.otf".source = berkeley-font + "/BerkeleyMono-Bold-Oblique.otf";

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
		darwinConfigurations."MacBook-Pro-Kamil" = 
		let
			darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel Macs
			darwinPkgs = import nixpkgs {
				system = darwinSystem;
				overlays = [rust-overlay.overlays.default];
				config.allowUnfree = true;
			};
			darwinPkgsStable = import nixpkgs-stable {
				system = darwinSystem;
				config.allowUnfree = true;
			};
		in
		nix-darwin.lib.darwinSystem {
			system = darwinSystem;
			specialArgs = { 
				inherit lib;
				pkgs = darwinPkgs;
				pkgsStable = darwinPkgsStable;
			};
			modules = [
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
					environment.interactiveShellInit = ''
						# Nix
						if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
							. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
						fi
						# End Nix
					'';

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
						onActivation.cleanup = "zap";
						casks = [
							# Keep these that aren't available in nixpkgs or ARM macOS
							"vivaldi"
							"libreoffice" 
							"love"
							"stats"
							"macs-fan-control"
							"utm" 
							"podman-desktop"
							"qmk-toolbox"
							"ytmdesktop-youtube-music"
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
							wezterm firefox qutebrowser
							
							# Development tools
							vscode
							
							# Terminal tools
							fzf bat delta lazygit lazydocker docker
							ripgrep btop lsd yazi tmux
							
							# Shell and CLI utilities  
							starship zsh gh curl wget tree fd
							eza difftastic just jq yq
							
							# Development tools
							gcc go nodejs yarn pnpm deno
							lua luarocks python3 php
							
							# Text processing and search
							gnugrep gnused coreutils
							
							# System monitoring and management
							htop fastfetch pfetch neofetch
							
							# File and archive tools
							unzip p7zip trash-cli
							
							# Network and system tools
							nmap wireshark-cli socat
							
							# Office/Documents moved to homebrew for ARM macOS
							
							# Development/Programming
							kitty # Terminal emulator
							
							# Container tools (CLI versions, GUI via homebrew)
							podman podman-compose
							
							# Media and graphics
							ffmpeg imagemagick
							
							# Database and data tools
							sqlite postgresql
							
							# Text editors and viewers
							helix
							
							# Version control extras
							git-extras tig
							
							# Virtualization and containers
							qemu lima colima
							
							# System utilities
							stow cowsay figlet fortune lolcat
							
							# Programming language tools
							zig stylua lua-language-server
							
							# Terminal multiplexers and sessions
							zellij
							
							# File synchronization and transfer
							rsync openssh sshfs-fuse
							
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
							
							initContent = ''
								# Source nix-darwin environment first
								if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
									. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
								fi
								
								# macOS-specific paths
								export PATH="/opt/homebrew/bin:$PATH"
								export PNPM_HOME="/Users/kamil/Library/pnpm"
								export PATH="$PNPM_HOME:$PATH"
								
								# Editor configuration
								export EDITOR='nvim'
								export XDG_CONFIG_HOME="$HOME/.config"
								export BAT_THEME="gruvbox-dark"
								
								# Homebrew
								export HOMEBREW_NO_AUTO_UPDATE=1
								
								# FZF configuration
								export FZF_DEFAULT_OPTS=" \
								--multi \
								--height=50% \
								--margin=5%,2%,2%,5% \
								--layout=reverse-list \
								--border=double \
								--info=inline \
								--prompt='$>' \
								--pointer='→' \
								--marker='♡' \
								--color=bg:-1,bg:-1,spinner:#f5e0dc,hl:#7AA89F \
								--color=fg:-1,bg:-1,header:#DCD7BA,info:#7AA89F,pointer:#f5e0dc \
								--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#7AA89F,hl+:#7AA89F \
								--header='CTRL-c or ESC to quit' \
								--preview 'bat --style=numbers --color=always --line-range :500 {}' \
								--height 70% --layout reverse --border top"
								export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
								
								# Vi mode and key bindings
								bindkey -v
								export KEYTIMEOUT=1
								export VI_MODE_SET_CURSOR=true
								bindkey '^[[A' history-search-backward
								bindkey '^[[B' history-search-forward
								
								# FZF completion helper
								_fzf_comprun() {
									local command=$1
									shift
									case "$command" in
										cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
										*)            fzf "$@" ;;
									esac
								}
								
								# Weather function
								weather() {
									curl "wttr.in/$1?lang=pl"
								}
								
								# Directory search and navigation
								sd() {
									local dirs=()
									if [ -f "$HOME/.zsh_company_dirs" ]; then
										source "$HOME/.zsh_company_dirs"
										dirs+=("''${COMPANY_DIRS[@]}")
									fi
									if [ -f "$HOME/.zsh_personal_dirs" ]; then
										source "$HOME/.zsh_personal_dirs"
										dirs+=("''${PERSONAL_DIRS[@]}")
									fi
									cd "$(printf '%s\n' "''${dirs[@]}" | fzf)"
								}
								
								# SSH fuzzy search
								sshf() {
									local ssh_hosts=$(grep "^Host " ~/.ssh/config | awk '{print $2}')
									local selected_host=$(printf '%s\n' "''${ssh_hosts[@]}" | fzf)
									if [[ -n $selected_host ]]; then
										ssh "$selected_host"
									fi
								}
								
								# Search directory and open nvim
								sdn() {
									sd && nvim .
								}
								
								# Config search
								config() {
									source "$HOME/.zsh_config_aliases"
									local config_keys=("''${(k)CONFIG_ALIASES[@]}")
									local selected_key=$(printf '%s\n' "''${config_keys[@]}" | fzf)
									if [[ -n $selected_key ]]; then
										eval "''${CONFIG_ALIASES[$selected_key]}"
									fi
								}
								
								# Database search
								db() {
									source "$HOME/.zsh_db_configs"
									local config_keys=("''${(k)DB_CONFIGS[@]}")
									local selected_key=$(printf '%s\n' "''${config_keys[@]}" | fzf)
									if [[ -n $selected_key ]]; then
										eval "''${DB_CONFIGS[$selected_key]}"
									fi
								}
								
								# Work sites browser
								work_sites() {
									source "$HOME/.zsh_company_websites"
									local company_website_keys=("''${(k)COMPANY_WEBSITES[@]}")
									local selected_key=$(printf '%s\n' "''${company_website_keys[@]}" | fzf)
									if [[ -n $selected_key ]]; then
										open "''${COMPANY_WEBSITES[$selected_key]}"
									fi
								}
								
								# Git branch switcher
								switch_branch() {
									git fetch -a
									local selected_branch=$(git branch --list | fzf)
									if [[ -n $selected_branch ]]; then
										git checkout "$selected_branch"
									fi
								}
								
								# History fuzzy search
								hisf() {
									local commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)
									local selected_command_from_history=$(printf '%s\n' "''${commands_history_entries[@]}" | fzf)
									if [[ -n $selected_command_from_history ]]; then
										eval "$selected_command_from_history"
									fi
								}
								
								# Process killer
								killf() {
									ps aux | fzf --preview="" --prompt="Select process to kill: " | awk '{print $2}' | xargs -r kill -9
								}
								
								# Second brain shortcut
								sb() {
									cd ~/second-brain/ && nvim .
								}
								
								# macOS clipboard copy
								macos_copy_to_clipboard() {
									pbcopy < $1
								}
								
								# macOS key repeat settings
								macos_set_proper_key_repeat() {
									defaults write -g KeyRepeat -int 1 && defaults write -g InitialKeyRepeat -int 10
								}
								
								# Source external files if they exist
								[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"
								[ -f "$HOME/.dotfiles/config/scripts/fzf-git.sh" ] && source "$HOME/.dotfiles/config/scripts/fzf-git.sh"
								
								# Enable colors and prompt substitution
								autoload -U colors && colors
								setopt PROMPT_SUBST
								
								# Set up fzf key bindings and fuzzy completion
								eval "$(fzf --zsh)"
							'';
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
		packages.aarch64-darwin.default = self.darwinConfigurations."MacBook-Pro-Kamil".system;
		packages.x86_64-darwin.default = self.darwinConfigurations."MacBook-Pro-Kamil".system;
		
		apps.aarch64-darwin.default = {
			type = "app";
			program = "${self.darwinConfigurations."MacBook-Pro-Kamil".system}/sw/bin/darwin-rebuild";
		};
		
		apps.x86_64-darwin.default = {
			type = "app";
			program = "${self.darwinConfigurations."MacBook-Pro-Kamil".system}/sw/bin/darwin-rebuild";
		};
};
}

