# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/51345dbe-c749-4043-b347-4231ab92c799";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-3d83c353-b63b-413c-8f84-6a84ace5569a".device = "/dev/disk/by-uuid/3d83c353-b63b-413c-8f84-6a84ace5569a";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8CC6-BDDD";
      fsType = "vfat";
    };

    # My old Arch install
    boot.initrd.luks.devices."luks-d81962c8-e3d0-422b-8ff1-918452b9857f".device = "/dev/disk/by-uuid/d81962c8-e3d0-422b-8ff1-918452b9857f";

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp42s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}