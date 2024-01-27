{ inputs, overlays, linuxOverlays, ... }:

let
	lib = inputs.nixpkgs.lib;
in
inputs.nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [
		"${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

		{
			nixpkgs.overlays = overlays ++ linuxOverlays ++ [
				# Add host specific overlays here
			];

			# Modules
			gui.enable								= true;
			steam.enable							= true;
			"8bitdo".enable							= true;
			amdgpu.enable							= true;
			nvidia.enable							= false;
			samba.enable							= true;

			services.fstrim.enable					= true;
			interception-tools.enable				= true;

			# Remote builders and binary cache
			builders.enable							= true;
			builders.cache							= false;
			builders.dent							= true;
			builders.hotblack						= true;
			builders.zaphod							= false;

			# Enable networking, with DHCP and a bridge device
			networking.hostName						= "wonko";
			networking.useDHCP						= false;

			boot.loader.efi.canTouchEfiVariables	= true;

			imports = [
				../../users/m/linux.nix

				../../modules
				../../modules/linux
				inputs.home-manager.nixosModules.home-manager
			];
		}
	];
}
