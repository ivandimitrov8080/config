toplevel: { moduleWithSystem }: moduleWithSystem (
  toplevel@{}: { config, ... }: {
    programs.home-manager.enable = true;
    home.stateVersion = toplevel.config.flake.stateVersion;
    xdg = {
      enable = true;
      userDirs = with config; {
        enable = true;
        createDirectories = true;
        desktop = "${home.homeDirectory}/dt";
        documents = "${home.homeDirectory}/doc";
        download = "${home.homeDirectory}/dl";
        pictures = "${home.homeDirectory}/pic";
        videos = "${home.homeDirectory}/vid";
        templates = "${home.homeDirectory}/tpl";
        publicShare = "${home.homeDirectory}/pub";
        music = "${home.homeDirectory}/mus";
      };
      mimeApps.enable = true;
    };
  }
)
