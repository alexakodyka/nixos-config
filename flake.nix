{
	description = "Micah N Gorrell's NixOS Configuration";

	inputs = {
		nixpkgs.url	= "github:NixOS/nixpkgs/nixos-unstable";
		nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

		apple-silicon = {
			url = "github:tpwrules/nixos-apple-silicon";
			# inputs.nixpkgs.follows = "nixpkgs";
		};

		darwin = {
			url = "github:LnL7/nix-darwin";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = github:nix-community/home-manager;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nur = {
			url = github:nix-community/NUR;
			# inputs.nixpkgs.follows = "nixpkgs";
		};

		# Plugin for Interception Tools
		mackeys = {
			url = github:minego/mackeys;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Plugin for Interception Tools
		swapmods = {
			url = github:minego/swapmods;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# My branch of DWL
		dwl-minego-customized = {
			url = github:minego/dwl/main;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Official Firefox builds for Darwin
        nixpkgs-firefox-darwin = {
			url = github:bandithedoge/nixpkgs-firefox-darwin;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# My customized neovim package, with configuration
		neovim-minego = {
			url = github:minego/nixvim;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		zsh-vi-mode = {
			url = github:jeffreytse/zsh-vi-mode;
			flake = false;
		};

		# NixThePlanet - macOS VM builder
		nixtheplanet = {
			url = github:matthewcroughan/nixtheplanet;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		p81 = {
			url = github:devusb/p81.nix;
			inputs.nixpkgs.follows = "nixpkgs";
		};

		mobile-nixos = {
			url = github:NixOS/mobile-nixos;
			flake = false;
		};

		sxmo-nix = {
			url = github:chuangzhu/nixpkgs-sxmo;
			flake = false;
		};

		jovian-nixos = {
			url = github:Jovian-Experiments/Jovian-NixOS;
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, ... }@inputs:
	let
		inherit (nixpkgs) lib;

		overlays = [
			inputs.dwl-minego-customized.overlays.default
			inputs.neovim-minego.overlays.default
			inputs.swapmods.overlay
			inputs.mackeys.overlay
			inputs.p81.overlays.default

			inputs.nur.overlay
			(import ./overlays/fonts.nix)

			# Allow grabbing specific packages from the previous release to
			# deal with things that are broken by unstable.
			(final: _prev: {
				stable = import inputs.nixpkgs-stable {
					system					= final.system;
					config.allowUnfree		= true;
				};
			})

			# Get the latest zsh-vi-mode
			(self: super: {
				zsh-vi-mode = super.zsh-vi-mode.overrideDerivation (oldAttrs: {
					src = inputs.zsh-vi-mode;
				});
			})
		];

		linuxOverlays = [
		];

		darwinOverlays = [
			inputs.nixpkgs-firefox-darwin.overlay
		];
	in rec {
		# Set the version of 'nixpkgs' used on the command line to be locked to
		# the version at the time this configuration was applied. This will
		# prevent downloading a bunch of stuff every time we run a command like
		# 'nix shell nixpkgs#neovim'
		nix.registry.nixpkgs.flake = inputs.nixpkgs;

		nixosConfigurations = {
			# My main desktop computer
			dent		= import ./hosts/dent		{ inherit inputs overlays linuxOverlays; };

			# Thinkpad
			lord		= import ./hosts/lord		{ inherit inputs overlays linuxOverlays; };

			# Home server
			hotblack	= import ./hosts/hotblack	{ inherit inputs overlays linuxOverlays; };

			# Macbook pro (m2 max) running NixOS with Asahi
			zaphod2		= import ./hosts/zaphod2	{ inherit inputs overlays linuxOverlays; };

			# Gateway VM
			gateway-vm	= import ./hosts/gateway-vm { inherit inputs overlays linuxOverlays; };

			# PinePhone Pro
			marvin		= import ./hosts/marvin		{ inherit inputs overlays linuxOverlays; };

			# Lenovo pad
			lenovo		= import ./hosts/lenovo		{ inherit inputs overlays linuxOverlays; };

			# Steam Deck
			wonko		= import ./hosts/wonko		{ inherit inputs overlays linuxOverlays; };
		};

		# Images can be built with `nix build ./#images.foobar`
		images = {
			wonko		= nixosConfigurations.wonko.config.system.build.isoImage;
		};

		darwinConfigurations = {
			# Macbook pro (m2 max)
			zaphod		= import ./hosts/zaphod		{ inherit inputs overlays darwinOverlays; };

			# Mac mini (m1)
			random		= import ./hosts/random		{ inherit inputs overlays darwinOverlays; };
		};

		homeConfigurations = {
			# NixOS
			dent		= nixosConfigurations.dent.config.home-manager.users.m.home;
			hotblack	= nixosConfigurations.hotblack.config.home-manager.users.m.home;
			zaphod2		= nixosConfigurations.zaphod2.config.home-manager.users.m.home;

			# Gavin's NixOS Laptop
			lord-m		= nixosConfigurations.lord.config.home-manager.users.m.home;
			lord-gavin	= nixosConfigurations.lord.config.home-manager.users.gavin.home;

			# Darwin
			zaphod		= nixosConfigurations.zaphod.config.home-manager.users.m.home;
			random		= nixosConfigurations.random.config.home-manager.users.m.home;
		};

		marvin-image	= nixosConfigurations.marvin.config.mobile.outputs.u-boot.disk-image;
	};
}
