top@{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules = {
    flakeModule = moduleWithSystem (
      _:
      { pkgs, config, ... }:
      {
        imports = with inputs; [
          hosts.nixosModule
          home-manager.nixosModules.default
          vpsadminos.nixosConfigurations.container
          webshite.nixosModules.default
          simple-nixos-mailserver.nixosModule
        ];
        home-manager = {
          backupFileExtension = "bak";
          useUserPackages = true;
          useGlobalPkgs = true;
          users.ivand =
            { ... }:
            {
              imports = with top.config.flake.homeManagerModules; [
                base
                ivand
                shell
                util
                swayland
                web
                reminders
              ];
            };
        };
        nix.registry = {
          self.flake = inputs.self;
          nixpkgs.flake = inputs.nixpkgs-unstable;
          p.flake = inputs.nixpkgs-unstable;
          stable.flake = inputs.nixpkgs-stable;
        };
        nixpkgs = {
          config = {
            allowUnfree = false;
            packageOverrides = pkgs: {
              stable = import inputs.nixpkgs-stable {
                system = pkgs.system;
                config = config.nixpkgs.config;
              };
            };
          };
          overlays = [
            inputs.self.overlays.default
          ];
        };
        system.stateVersion = top.config.flake.stateVersion;
        i18n.supportedLocales = [ "all" ];
        time.timeZone = "Europe/Prague";
        users.defaultUserShell = pkgs.zsh;
        systemd.network = {
          wait-online.enable = false;
        };
        environment.systemPackages = with pkgs; [ pwvucontrol ];
        users = {
          mutableUsers = false;
          users = {
            ivand = {
              isNormalUser = true;
              createHome = true;
              extraGroups = [
                "adbusers"
                "adm"
                "audio"
                "bluetooth"
                "dialout"
                "flatpak"
                "input"
                "kvm"
                "mlocate"
                "realtime"
                "render"
                "video"
                "wheel"
              ];
              hashedPassword = "$y$j9T$Wf9ljhi4c.LUoX/LJEll//$cTP..D/lBWq1PPCzaHhym8V.cibPTjy2JvRYLTf5SZ7";
            };
          };
          extraGroups = {
            mlocate = { };
            realtime = { };
          };
        };
        programs = {
          dconf.enable = true;
          adb.enable = true;
        };
        fonts.packages = with pkgs; [
          nerd-fonts.fira-code
          noto-fonts
          noto-fonts-emoji
          noto-fonts-lgc-plus
        ];
      }
    );
    default = moduleWithSystem (
      _:
      { lib, ... }:
      let
        files = lib.filesystem.listFilesRecursive ./.;
        endsWith =
          e: x:
          with builtins;
          let
            se = toString e;
            sx = toString x;
          in
          (stringLength sx >= stringLength se)
          && (substring ((stringLength sx) - (stringLength se)) (stringLength sx) sx) == se;
        defaults = with builtins; (filter (x: endsWith "default.nix" x) files);
      in
      {
        imports =
          with builtins;
          filter (x: !((endsWith "nginx/default.nix" x) || (endsWith "nixos/default.nix" x))) defaults;
      }
    );
    music = moduleWithSystem (
      _:
      { pkgs, ... }:
      {
        imports = [ inputs.musnix.nixosModules.musnix ];
        environment.systemPackages = with pkgs; [ guitarix ];
        services.pipewire = {
          jack.enable = true;
          extraConfig = {
            jack."69-low-latency" = {
              "jack.properties" = {
                "node.latency" = "64/48000";
              };
            };
          };
        };
        musnix = {
          enable = true;
          rtcqs.enable = true;
          soundcardPciId = "00:1f.3";
          kernel = {
            realtime = true;
            packages = pkgs.linuxPackages-rt_latest;
          };
        };
        security.pam.loginLimits = [
          {
            domain = "@users";
            item = "memlock";
            type = "-";
            value = "1048576";
          }
        ];
      }
    );
    monero-miner = moduleWithSystem (
      _: _: {
        services = {
          xmrig = {
            enable = true;
            settings = {
              autosave = true;
              cpu = true;
              opencl = false;
              cuda = false;
              pools = [
                {
                  url = "pool.supportxmr.com:443";
                  user = "48e9t9xvq4M4HBWomz6whiY624YRCPwgJ7LPXngcc8pUHk6hCuR3k6ENpLGDAhPEHWaju8Z4btxkbENpcwaqWcBvLxyh5cn";
                  keepalive = true;
                  tls = true;
                }
              ];
            };
          };
        };
      }
    );
  };
}
