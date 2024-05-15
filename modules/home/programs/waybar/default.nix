{
  programs.waybar = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "eDP-1"
          "HDMI-A-1"
        ];
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "pulseaudio" "memory" "cpu" "battery" ];

        clock = {
          format = "{:%a %Y-%m-%d %H:%M:%S}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          interval = 1;
        };

        battery = {
          format = "{icon} {capacity}% {time}";
          format-time = " {H} h {M} m";
          format-icons = [ "" "" "" "" "" ];
          states = {
            warning = 30;
            critical = 15;
          };
        };

        cpu = {
          format = "   {usage}%";
        };

        memory = {
          format = "   {percentage}%";
          interval = 5;
        };

        pulseaudio = {
          format = "{icon} {volume}% | {format_source}";
          format-muted = "󰝟 {volume}% | {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "{volume}% ";
          format-icons = {
            headphone = "";
            default = [ "" "" "" ];
          };
        };

        network = {
          format-ethernet = "󰈁 |  {bandwidthUpBytes}   {bandwidthDownBytes}";
          format-wifi = "{icon} |  {bandwidthUpBytes}   {bandwidthDownBytes}";
          format-disconnected = "󰈂";
          format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
          interval = 5;
        };

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
      };
    };
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    style = builtins.readFile ./style.css;
  };
}
