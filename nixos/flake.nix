{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager.url = "github:nix-community/home-manager/release-24.11";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

# bring your dotfiles in as a flake input (read-only, pure)
		dotfiles.url = "path:..";
		dotfiles.flake = false;

		neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay"; 
		rust-overlay.url = "github:oxalica/rust-overlay";

# Add private fonts
		berkeley-font = {
			url = "path:///home/kamil/.local/share/fonts";
			flake = false;
		};

	};

	outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, berkeley-font, neovim-nightly-overlay, dotfiles, rust-overlay, ... }:
		let
		system = "aarch64-linux"; # UTM on M1/M2
		pkgs = import nixpkgs {
			inherit system;
			overlays = [rust-overlay.overlays.default ];
			config.allowUnfree = true;
		};
	pkgsUnstable = import nixpkgs-unstable {
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
								pkgsUnstable.opencode
									neovim-nightly-overlay.packages.${system}.default
								];


# fonts.fontconfig.defaultFonts.monospace = ["Berkeley Mono"];

# programs.*: let HM manage app configs

							programs.zsh = {
								enable = true;
								autosuggestion.enable = true;
								syntaxHighlighting.enable = true;
								initExtra = ''
									export FORCE_COLOR=1
									export NO_COLOR=
									source ~/.zshrc
									'';
							};




programs.starship = {
	enable = true;
	enableZshIntegration = true;
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
xdg.configFile."starship.toml".source = dotfiles + "/starship/starship.toml";
xdg.configFile."hyprland".source     = dotfiles + "/config/hypr";
# (you also have mac-only stuff like yabai/skhd/sketchybar—gate those below)

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
};
}

