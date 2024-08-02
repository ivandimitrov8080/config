toplevel@{ inputs, withSystem, ... }:
let
  system = "x86_64-linux";
  mods = toplevel.config.flake.nixosModules;
  hardwareConfigurations = {
    nova = { lib, modulesPath, ... }: {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
      boot = {
        initrd = {
          availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
          kernelModules = [ ];
          luks.devices."nixos".device = "/dev/disk/by-uuid/712dd8ba-d5b4-438a-9a77-663b8c935cfe";
        };
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
      };
      fileSystems = {
        "/" = { device = "/dev/disk/by-uuid/47536cbe-7265-493b-a2e3-bbd376a6f9af"; fsType = "btrfs"; };
        "/boot" = { device = "/dev/disk/by-uuid/4C3C-993A"; fsType = "vfat"; };
      };
      swapDevices = [ ];
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkForce false;
    };
  };
  essential = [ hardwareConfigurations.nova inputs.hosts.nixosModule inputs.home-manager.nixosModules.default ] ++ (with mods; [ grub base sound wayland security ivand wireless wireguard ]);
  systemWithModules = modules: withSystem system (ctx@{ config, inputs', pkgs, ... }: inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs inputs' pkgs;
      packages = config.packages;
    };
    modules = modules;
  });
in
{
  flake.nixosConfigurations = {
    nixos = systemWithModules essential;
    music = systemWithModules (essential ++ [ inputs.musnix.nixosModules.musnix mods.music ]);
    nonya = systemWithModules (essential ++ (with mods; [ anon cryptocurrency ]));
    ai = systemWithModules (essential ++ (with mods; [ ai ]));
  };
}
