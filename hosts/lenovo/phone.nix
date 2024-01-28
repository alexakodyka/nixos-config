{ pkgs, config, lib, ... }:
with lib;

{
	config = {
		mobile.beautification = {
			silentBoot						= mkForce false;
			splash							= mkForce false;
		};

		# sxmo

		services.xserver.desktopManager.sxmo = {
			enable							= true;
			user							= "m";
			group							= "users";
		};

		# It is a phone...
		environment.systemPackages			= with pkgs; [
			#chatty
			megapixels
		];
		programs.calls.enable				= false;

		# GPS
		services.geoclue2.enable			= false;
		#users.users.geoclue.extraGroups		= [ "networkmanager" ];

		# Sensors
		hardware.sensor.iio.enable			= false;
		#hardware.firmware					= [
		#	config.mobile.device.firmware
		#];

		# Enable power management options
		powerManagement.enable				= true;

		# Marvin only has 4GB of memory
		zramSwap.enable						= true;

		services.fwupd.enable				= false;


		users.users."m" = {
			extraGroups = [
				"dialout"
				"feedbackd"
				"networkmanager"
				"video"
				"wheel"
			];
		};
	};
}

