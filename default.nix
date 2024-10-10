toplevel @ { inputs, moduleWithSystem, ... }:
let
  lib = inputs.nixpkgs.lib;
  listNixFiles = dir: builtins.filter (lib.strings.hasSuffix ".nix") (lib.filesystem.listFilesRecursive dir);
  homeModules = listNixFiles ./src/home;
  nixModules = listNixFiles ./src/nixos;
in
{
  imports = homeModules ++ nixModules;
  systems = [ "x86_64-linux" ];
  flake.stateVersion = "24.05";
  perSystem = { system, ... }: {
    config._module.args = {
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          toplevel.config.flake.overlays.default
          inputs.neovim-nightly-overlay.overlays.default
        ];
      };
    };
  };
}
