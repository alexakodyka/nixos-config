{ inputs, overlays, linuxOverlays, ... }:

let
	lib = inputs.nixpkgs.lib;
	pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
in
lib.nixosSystem {
	system = "x86_64-linux";
	modules = [
		{
			nixpkgs.overlays = overlays
			++ linuxOverlays
			++ [
				(import "${inputs.sxmo-nix}/overlay.nix")
			];

			# Modules
			gui.enable							= true;
			laptop.enable						= true;

			networking.hostName					= "lenovo";
			networking.networkmanager.enable	= true;

# In NixOS's option merging priority, values set via mkDefault have
# lower priority compared to those set directly (e.g.,
#  services.fstrim.enable = true;) or via functions like mkOverride.
			services.fstrim.enable				= lib.mkDefault true;

			powerManagement.enable				= true;
			services.upower.enable				= true;
			hardware.opengl.enable				= true;

			imports = [
				#add boot loader
				./hardware-configuration.nix
				./phone.nix
				../../users/m/linux.nix

				../../modules
				../../modules/linux
				inputs.home-manager.nixosModules.home-manager

				(import "${inputs.sxmo-nix}/module.nix")

				#(import "${inputs.mobile-nixos}/lib/configuration.nix" {
				#	device = "uefi-x86_64";
				#})
			];
		}
	];
}
