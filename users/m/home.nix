{ config, pkgs, osConfig, lib, ... }:
with lib;

{
	home = rec {
		username		= lib.mkDefault "m";
		homeDirectory	= 
				if
					pkgs.stdenv.isDarwin
				then
					lib.mkDefault "/Users/${config.home.username}"
				else
					lib.mkDefault "/home/${config.home.username}";
	};

	# Enable various modules
	dwl.enable = true;

	firefox.enable = true;

	imports = [
		./modules
	];

	home.sessionVariables = {
		KEYTIMEOUT		= "1";
		VISUAL			= "nvim";
		EDITOR			= "nvim";
		LC_CTYPE		= "C";
	};

	# nix-darwin doesn't have support for configuring syncthing, so enable it
	# here for macOS. The shares configured by NixOS for the Linux boxes will
	# still automate most of the needed configs.
	#
	# We don't need to enable here for Linux because that is done in
	# 'modules/linux/syncthing.nix'
	services.syncthing = mkIf pkgs.stdenv.isDarwin {
		enable = true;
	};

	# Use home-manager to create the .stignore file for the syncthing shares
	home.file.stignore = {
		target = "./src/shared/.stignore";
		text = ''
            direnv
            build
            '';
	};

	home.packages = with pkgs; [
		neofetch
		mdcat
		sptlrx
		fd
		unzip
		jq

		# Install my own custom scripts from the scripts dir
		(stdenv.mkDerivation {
			name		= "homedir-scripts";
			buildInputs	= with pkgs; [ bash ];
			src			= ./scripts;
			installPhase = ''
				mkdir -p $out/bin
				cp * $out/bin/
				chmod +x $out/bin/*
			'';
		})
	] ++ lib.optionals (osConfig.gui.enable && (
			(pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64) ||
			(pkgs.stdenv.isDarwin)
	)) [
		# These aren't available on aarch64 linux
		#spotify
		#spotify-tui
		#slack
	] ++ lib.optionals osConfig.gui.enable [
		#freerdp
		#mpv
	] ++ lib.optionals (osConfig.gui.enable && pkgs.stdenv.isLinux) [
		# chromium

		pavucontrol
		pamixer
		linuxConsoleTools # jstest
	];

	# Kitty is configured in a module, but only if enabled
	programs.kitty.enable = true;

	programs.ripgrep = {
		enable			= true;
		arguments		= [ "--smart-case" ];
	};

	programs.git = {
		enable			= true;

		userEmail		= "m@test.net";
		userName		= "Test";

	};

	#home.file.ssh-config = {
	#	source = ./dotfiles/ssh-config;
	#	target = "./.ssh/config";
	#};

	#home.file.ssh-rc = {
	#	source = ./dotfiles/ssh-rc;
	#	target = "./.ssh/rc";
	#};

	programs.readline.enable = true;
	home.file.".inputrc".source = ./dotfiles/inputrc;

	dconf.settings = mkIf pkgs.stdenv.isLinux {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
		};
	};

	gtk = mkIf pkgs.stdenv.isLinux {
		enable = true;

		iconTheme = {
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};

		theme = {
			name = "palenight";
			package = pkgs.palenight-theme;
		};

		cursorTheme = {
			name = "Numix-Cursor";
			package = pkgs.numix-cursor-theme;
		};

		gtk3.extraConfig = {
			"gtk-application-prefer-dark-theme" = "1";
		};

		gtk4.extraConfig = {
			"gtk-application-prefer-dark-theme" = "1";
		};
	};

	# On darwin the terminfo related environment variables don't seem to get
	# set early enough to be used via ssh.
	#
	# Just make the symlink in our home dir to ensure we can ssh from kitty
	home.file.kitty-terminfo1 = {
		source = "${pkgs.kitty.terminfo.outPath}/share/terminfo/78/xterm-kitty";
		target = "./.terminfo/xterm-kitty";
	};

	home.file.kitty-terminfo2 = {
		source = "${pkgs.kitty.terminfo.outPath}/share/terminfo/78/xterm-kitty";
		target = "./.terminfo/78/xterm-kitty";
	};

	# Don't touch
	programs.home-manager.enable = true;
	home.stateVersion = "24.05";
}

