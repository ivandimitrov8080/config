toplevel @ { moduleWithSystem, ... }: {
  flake.homeManagerModules = {
    ivand = moduleWithSystem (
      _: { pkgs, ... }: {
        home = {
          username = "ivand";
          homeDirectory = "/home/ivand";
          sessionVariables = { EDITOR = "nvim"; };
          packages = with pkgs; [ nvim ];
        };
        programs = {
          git = with pkgs.lib; {
            userName = mkForce "Ivan Kirilov Dimitrov";
            userEmail = mkForce "ivan@idimitrov.dev";
            signing = mkForce {
              signByDefault = true;
              key = "ivan@idimitrov.dev";
            };
          };
          ssh = {
            matchBlocks = {
              vpsfree-ivand = {
                hostname = "192.168.69.1";
                user = "ivand";
              };
              vpsfree-root = {
                hostname = "192.168.69.1";
                user = "root";
              };
            };
          };
          neomutt = {
            enable = true;
            vimKeys = true;
            binds = [
              { map = [ "index" ]; key = "\\Cf"; action = "imap-fetch-mail"; }
            ];
            sidebar.enable = true;
            extraConfig = ''
              source ${pkgs.mutt-themes}/mutt-colors-solarized-dark-16.muttrc
            '';
          };
          msmtp.enable = true;
          offlineimap.enable = true;
        };
        accounts.email = {
          maildirBasePath = "mail";
          accounts = {
            ivan = rec {
              primary = true;
              realName = "Ivan Kirilov Dimitrov";
              address = "ivan@idimitrov.dev";
              userName = address;
              passwordCommand = "pass vps/mail.idimitrov.dev/ivan@idimitrov.dev";
              msmtp = {
                enable = true;
                extraConfig = {
                  auth = "login";
                };
              };
              signature = {
                text = ''
                  Ivan Dimitrov
                  Software Developer
                  ivan@idimitrov.dev
                '';
              };
              getmail = {
                enable = true;
                mailboxes = [ "ALL" ];
              };
              gpg = {
                encryptByDefault = true;
                signByDefault = true;
              };
              smtp = {
                host = "mail.idimitrov.dev";
              };
              imap = {
                host = "mail.idimitrov.dev";
              };
              neomutt = {
                enable = true;
                mailboxType = "imap";
                extraMailboxes = [ "Sent" "Drafts" "Trash" "Archive" ];
              };
              offlineimap.enable = true;
            };
          };
        };
      }
    );
    util = moduleWithSystem (_: { pkgs, config, ... }: {
      home = {
        packages = with pkgs; [ openssl mlocate uutils-coreutils-noprefix speedtest-cli deadnix statix ];
        sessionVariables = {
          PAGER = "bat";
          BAT_THEME = "catppuccin-mocha";
        };
      };
      programs = {
        password-store = {
          enable = true;
          package = pkgs.pass.withExtensions (e: with e; [ pass-otp pass-file ]);
          settings = { PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store"; };
        };
        git = {
          enable = true;
          delta.enable = true;
          extraConfig = {
            color.ui = "auto";
            pull.rebase = true;
            push.autoSetupRemote = true;
          };
          aliases = {
            a = "add .";
            c = "commit";
            d = "diff --cached";
            p = "push";
            pa = "!git remote | xargs -L1 git push --all";
          };
        };
        tealdeer = {
          enable = true;
          settings = {
            display = { compact = true; };
            updates = { auto_update = true; };
          };
        };
        bottom = {
          enable = true;
          settings = {
            flags = { rate = "250ms"; };
            row = [
              {
                ratio = 40;
                child = [{ type = "cpu"; } { type = "mem"; } { type = "net"; }];
              }
              {
                ratio = 35;
                child = [{ type = "temp"; } { type = "disk"; }];
              }
              {
                ratio = 40;
                child = [
                  {
                    type = "proc";
                    default = true;
                  }
                ];
              }
            ];
          };
        };
        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        nix-index = {
          enable = true;
          enableZshIntegration = false;
          enableBashIntegration = false;
        };
        bat = {
          enable = true;
          themes =
            let
              catppuccin = pkgs.fetchFromGitHub {
                owner = "catppuccin";
                repo = "bat";
                rev = "82e7ca555f805b53d2b377390e4ab38c20282e83";
                sha256 = "sha256-/Ob9iCVyjJDBCXlss9KwFQTuxybmSSzYRBZxOT10PZg=";
              };
            in
            {
              catppuccin-mocha = {
                src = catppuccin;
                file = "themes/Catppuccin Mocha.tmTheme";
              };
              catppuccin-macchiato = {
                src = catppuccin;
                file = "themes/Catppuccin Macchiato.tmTheme";
              };
              catppuccin-frappe = {
                src = catppuccin;
                file = "themes/Catppuccin Frappe.tmTheme";
              };
              catppuccin-latte = {
                src = catppuccin;
                file = "themes/Catppuccin Latte.tmTheme";
              };
            };
        };
        yazi = {
          enable = true;
        };
        fd.enable = true;
        ssh.enable = true;
        gpg.enable = true;
      };
      services = {
        gpg-agent = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          pinentryPackage = pkgs.pinentry-qt;
        };
      };
    }
    );
    shell = moduleWithSystem (
      _: { pkgs, ... }: {
        programs =
          let
            shellAliases = {
              cal = "cal $(date +%Y)";
              GG = "git add . && git commit -m 'GG' && git push --set-upstream origin HEAD";
              gad = "git add . && git diff --cached";
              gac = "ga && gc";
              ga = "git add .";
              gc = "git commit";
              dev = "nix develop --command $SHELL";
              ls = "eza";
              la = "eza --all -a";
              lt = "eza --git-ignore --all --tree --level=10";
              sc = "systemctl";
              neofetch = "${pkgs.fastfetch}/bin/fastfetch -c all.jsonc";
              opacity = "kitten @ set-background-opacity";
            };
            sessionVariables = { };
          in
          {
            bash = {
              inherit shellAliases sessionVariables;
              enable = true;
              enableVteIntegration = true;
              historyControl = [ "erasedups" ];
              historyIgnore = [ "ls" "cd" "exit" ];
            };
            zsh = {
              inherit shellAliases sessionVariables;
              enable = true;
              dotDir = ".config/zsh";
              defaultKeymap = "viins";
              enableVteIntegration = true;
              syntaxHighlighting.enable = true;
              autosuggestion.enable = true;
              history.expireDuplicatesFirst = true;
              historySubstringSearch.enable = true;
            };
            nushell = {
              enable = true;
              environmentVariables = { config = ''{ show_banner: false, completions: { quick: false partial: false algorithm: "prefix" } } ''; };
              shellAliases = {
                gcal = ''bash -c "cal $(date +%Y)" '';
                la = "ls -al";
                dev = "nix develop --command $env.SHELL";
              };
            };
            kitty.shellIntegration = {
              enableBashIntegration = true;
              enableZshIntegration = true;
            };
            yazi = {
              enableBashIntegration = true;
              enableZshIntegration = true;
            };
            tmux = {
              enable = true;
              clock24 = true;
              baseIndex = 1;
              escapeTime = 0;
              keyMode = "vi";
              shell = "\${SHELL}";
              terminal = "screen-256color";
              plugins = with pkgs.tmuxPlugins; [ tilish catppuccin ];
              extraConfig = ''
                set-option -a terminal-features 'screen-256color:RGB'
              '';
            };
            starship = {
              enable = true;
              enableNushellIntegration = true;
              enableZshIntegration = true;
              enableBashIntegration = true;
            };
            eza = {
              enable = true;
              enableZshIntegration = true;
              enableBashIntegration = true;
              extraOptions = [
                "--long"
                "--header"
                "--icons"
                "--smart-group"
                "--mounts"
                "--group-directories-first"
                "--octal-permissions"
                "--git"
              ];
            };
          };
      }
    );
    swayland = moduleWithSystem (_: { pkgs, config, ... }: {
      home = {
        packages = with pkgs; [ audacity gimp grim libnotify libreoffice-qt mupdf slurp transmission_4 wl-clipboard xdg-user-dirs xdg-utils telegram-desktop ];
        pointerCursor = {
          name = "phinger-cursors-light";
          package = pkgs.phinger-cursors;
        };
      };
      wayland.windowManager.sway = {
        enable = true;
        package = pkgs.swayfx;
        checkConfig = false;
        systemd.enable = true;
        wrapperFeatures.gtk = true;
        config = rec {
          menu = "rofi -show drun";
          terminal = "kitty";
          modifier = "Mod4";
          startup = [
            { command = "swaymsg 'workspace 2; exec firefox'"; }
            { command = "swaymsg 'workspace 1; exec kitty'"; }
          ];
          bars = [ ];
          gaps = {
            horizontal = 1;
            vertical = 1;
          };
          window = {
            titlebar = false;
            commands = [
              { command = "floating enable; move position center; resize set 30ppt 50ppt;"; criteria = { title = "^calendar$"; }; }
              { command = "floating enable; move position center; resize set 70ppt 50ppt;"; criteria = { title = "^mutt$"; }; }
            ];
          };
          keybindings = pkgs.lib.mkOptionDefault {
            "F1" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "Shift+F1" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "F2" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "Shift+F2" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-volume @DEFAULT_SOURCE@ -5%";
            "F3" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "Shift+F3" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-volume @DEFAULT_SOURCE@ +5%";
            "F9" = "exec doas ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
            "F8" = "exec doas ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
            "Alt+Shift+l" = "exec ${pkgs.swaylock}/bin/swaylock";
            "${modifier}+p" = "exec ${menu}";
            "${modifier}+Shift+s" = "exec ${pkgs.screenshot}/bin/screenshot screen";
            "${modifier}+Shift+a" = "exec ${pkgs.screenshot}/bin/screenshot area";
            "${modifier}+Shift+w" = "exec ${pkgs.screenshot}/bin/screenshot window";
            "${modifier}+c" = "exec kitty --title calendar -- ${pkgs.calcurse}/bin/calcurse";
            "${modifier}+m" = "exec kitty --title mutt -- neomutt";
            "End" = "exec rofi -show calc";
            "${modifier}+Shift+r" = "reload";
            "${modifier}+Shift+c" = "kill";
            "${modifier}+Shift+q" = "exec ${pkgs.procps}/bin/pkill -9 -u ${config.home.username}";
          };
          input = {
            "*" = {
              xkb_layout = "us,bg";
              xkb_options = "grp:win_space_toggle";
              xkb_variant = ",phonetic";
            };
          };
        };
        extraConfig = ''
          blur enable
          shadows enable
          corner_radius 15
          default_dim_inactive 0.5
        '';
        swaynag = { inherit (config.wayland.windowManager.sway) enable; };
      };
      programs = {
        waybar = {
          enable = true;
          settings = {
            mainBar = {
              layer = "top";
              position = "top";
              height = 30;
              output = [ "eDP-1" "HDMI-A-1" "*" ];
              modules-left = [ "sway/workspaces" "sway/mode" ];
              modules-center = [ "clock#week" "clock#year" "clock#time" ];
              modules-right = [ "network" "pulseaudio" "memory" "cpu" "battery" "keyboard-state" ];
              "clock#time" = { format = "{:%H:%M:%S}"; interval = 1; tooltip = false; };
              "clock#week" = { format = "{:%a}"; tooltip = false; };
              "clock#year" = { format = "{:%Y-%m-%d}"; tooltip = false; };
              keyboard-state = { capslock = true; format = "{icon}"; format-icons = { locked = ""; unlocked = ""; }; };
              battery = { format = "{icon} <span color='#cdd6f4'>{capacity}% {time}</span>"; format-time = " {H} h {M} m"; format-icons = [ "" "" "" "" "" ]; states = { warning = 30; critical = 15; }; tooltip = false; };
              cpu = { format = "<span color='#74c7ec'></span>  {usage}%"; };
              memory = { format = "<span color='#89b4fa'></span>  {percentage}%"; interval = 5; };
              pulseaudio = { format = "<span color='#a6e3a1'>{icon}</span> {volume}% | {format_source}"; format-muted = "<span color='#f38ba8'>󰝟</span> {volume}% | {format_source}"; format-source = "{volume}% <span color='#a6e3a1'></span>"; format-source-muted = "{volume}% <span color='#f38ba8'></span>"; format-icons = { headphone = ""; default = [ "" "" "" ]; }; tooltip = false; };
              network = { format-ethernet = "<span color='#89dceb'>󰈁</span> | <span color='#fab387'></span> {bandwidthUpBytes}  <span color='#fab387'></span> {bandwidthDownBytes}"; format-wifi = "<span color='#06b6d4'>{icon}</span> | <span color='#fab387'></span> {bandwidthUpBytes}  <span color='#fab387'></span> {bandwidthDownBytes}"; format-disconnected = "<span color='#eba0ac'>󰈂 no connection</span>"; format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ]; interval = 5; tooltip = false; };
              "sway/workspaces" = { disable-scroll = true; all-outputs = true; };
            };
          };
          systemd = {
            enable = true;
            target = "sway-session.target";
          };
          style = ''
            @define-color rosewater #f5e0dc;
            @define-color flamingo #f2cdcd;
            @define-color pink #f5c2e7;
            @define-color mauve #cba6f7;
            @define-color red #f38ba8;
            @define-color maroon #eba0ac;
            @define-color peach #fab387;
            @define-color yellow #f9e2af;
            @define-color green #a6e3a1;
            @define-color teal #94e2d5;
            @define-color sky #89dceb;
            @define-color sapphire #74c7ec;
            @define-color blue #89b4fa;
            @define-color lavender #b4befe;
            @define-color text #cdd6f4;
            @define-color subtext1 #bac2de;
            @define-color subtext0 #a6adc8;
            @define-color overlay2 #9399b2;
            @define-color overlay1 #7f849c;
            @define-color overlay0 #6c7086;
            @define-color surface2 #585b70;
            @define-color surface1 #45475a;
            @define-color surface0 #313244;
            @define-color base #1e1e2e;
            @define-color mantle #181825;
            @define-color crust #11111b;
            * {
                font-family: FontAwesome, 'Fira Code';
                font-size: 13px;
            }

            window#waybar {
                background-color: rgba(43, 48, 59, 0.1);
                border-bottom: 2px solid rgba(100, 114, 125, 0.5);
                color: @rosewater;
            }

            #workspaces button {
                padding: 0 5px;
                background-color: @base;
                color: @text;
                border-radius: 6px;
            }

            #workspaces button:hover {
                background: @mantle;
            }

            #workspaces button.focused {
                background-color: @crust;
                box-shadow: inset 0 -2px @sky;
            }

            #workspaces button.urgent {
                background-color: @red;
            }

            #clock,
            #battery,
            #cpu,
            #memory,
            #disk,
            #temperature,
            #backlight,
            #network,
            #pulseaudio,
            #wireplumber,
            #custom-media,
            #tray,
            #mode,
            #idle_inhibitor,
            #scratchpad,
            #power-profiles-daemon,
            #mpd {
                padding: 0 10px;
                color: @text;
                background-color: @base;
                margin: 0 .5em;
                border-radius: 9999px;
            }

            #clock.week {
              margin-right: 0px;
              color: @peach;
              border-radius: 9999px 0px 0px 9999px;
            }

            #clock.year {
              margin: 0px;
              padding: 0px;
              color: @pink;
              border-radius: 0px;
            }

            #clock.time {
              margin-left: 0px;
              color: @sky;
              border-radius: 0px 9999px 9999px 0px;
            }

            #battery.charging, #battery.plugged {
                color: @green;
            }

            #battery.discharging {
                color: @yellow;
            }

            #keyboard-state label {
                color: @green;
            }

            #keyboard-state label.locked {
                color: @red;
            }

            @keyframes blink {
                to {
                    background-color: #ffffff;
                    color: #000000;
                }
            }

            #battery.warning:not(.charging) {
                background-color: @red;
            }

            /* Using steps() instead of linear as a timing function to limit cpu usage */
            #battery.critical:not(.charging) {
                background-color: @red;
                animation-name: blink;
                animation-duration: 0.5s;
                animation-timing-function: steps(12);
                animation-iteration-count: infinite;
                animation-direction: alternate;
            }
          '';
        };
        wpaperd = {
          enable = true;
          settings = {
            default = {
              path = "${config.xdg.userDirs.pictures}/bg";
              duration = "10m";
            };
          };
        };
        swaylock = {
          enable = true;
          settings = {
            show-failed-attempts = true;
            image = config.home.homeDirectory + "/pic/bg.png";
          };
        };
        rofi = {
          enable = true;
          package = pkgs.rofi-wayland.override {
            plugins = with pkgs; [
              (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
            ];
          };
          extraConfig = {
            modi = "window,drun,run,ssh,calc";
            show-icons = true;
          };
          theme = "${pkgs.rofi-themes}/rounded-nord-dark.rasi";
        };
        kitty = {
          enable = true;
          font = {
            package = pkgs.fira-code;
            name = "FiraCodeNFM-Reg";
          };
          settings = {
            background_opacity = "0.80";
            background_blur = "1";
            cursor_shape = "beam";
            allow_remote_control = "yes";
            dynamic_background_opacity = "yes";
          };
          themeFile = "Catppuccin-Mocha";
        };
        imv = {
          enable = true;
          settings = { options.fullscreen = true; };
        };
        mpv = {
          enable = true;
          scripts = with pkgs.mpvScripts; [ uosc thumbfast ];
        };
        bash.profileExtra = ''[ "$(tty)" = "/dev/tty1" ] && exec sway '';
        zsh.loginExtra = ''[ "$(tty)" = "/dev/tty1" ] && exec sway '';
        nushell.loginFile.text = ''if (tty) == "/dev/tty1" { sway } '';
      };
      services = {
        mako = {
          enable = true;
          anchor = "bottom-right";
          backgroundColor = "#1E1E2EDD";
          borderRadius = 20;
        };
        cliphist = {
          enable = true;
          systemdTarget = "sway-session.target";
        };
      };
      systemd.user = {
        services = {
          wpaperd = {
            Install = { WantedBy = [ "graphical-session.target" ]; };
            Unit = {
              Description = "Modern wallpaper daemon for Wayland";
              After = "graphical-session-pre.target";
              PartOf = "graphical-session.target";
            };
            Service = {
              ExecStart = [ "${pkgs.wpaperd}/bin/wpaperd" ];
            };
          };
        };
      };
      xdg.mimeApps.defaultApplications = {
        "image/jpg" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/svg+xml" = "imv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";
        "video/ogg" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
      };
    }
    );
    web = moduleWithSystem (
      _: _: {
        programs = {
          browserpass.enable = true;
          firefox = {
            enable = true;
            profiles.ivand = {
              id = 0;
              search = {
                default = "DuckDuckGo";
                privateDefault = "DuckDuckGo";
                force = true;
              };
              bookmarks = [
                {
                  name = "home-options";
                  url = "https://nix-community.github.io/home-manager/options.xhtml";
                }
                {
                  name = "nixvim-docs";
                  url = "https://nix-community.github.io/nixvim/";
                }
              ];
              settings = {
                "general.smoothScroll" = true;
                "signon.rememberSignons" = false;
                "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
                "layout.frame_rate" = 60;
                "browser.newtabpage.activity-stream.feeds.telemetry" = false;
                "browser.newtabpage.activity-stream.telemetry" = false;
                "browser.ping-centre.telemetry" = false;
                "datareporting.healthreport.service.enabled" = false;
                "datareporting.healthreport.uploadEnabled" = false;
                "datareporting.policy.dataSubmissionEnabled" = false;
                "datareporting.sessions.current.clean" = true;
                "devtools.onboarding.telemetry.logged" = false;
                "toolkit.telemetry.archive.enabled" = false;
                "toolkit.telemetry.bhrPing.enabled" = false;
                "toolkit.telemetry.enabled" = false;
                "toolkit.telemetry.firstShutdownPing.enabled" = false;
                "toolkit.telemetry.hybridContent.enabled" = false;
                "toolkit.telemetry.newProfilePing.enabled" = false;
                "toolkit.telemetry.prompted" = 2;
                "toolkit.telemetry.rejected" = true;
                "toolkit.telemetry.reportingpolicy.firstRun" = false;
                "toolkit.telemetry.server" = "";
                "toolkit.telemetry.shutdownPingSender.enabled" = false;
                "toolkit.telemetry.unified" = false;
                "toolkit.telemetry.unifiedIsOptIn" = false;
                "toolkit.telemetry.updatePing.enabled" = false;
              };
            };
            policies = {
              CaptivePortal = false;
              DisableFirefoxStudies = true;
              DisablePocket = true;
              DisableTelemetry = true;
              DisableFirefoxAccounts = true;
              OfferToSaveLogins = false;
              OfferToSaveLoginsDefault = false;
              PasswordManagerEnabled = false;
              NoDefaultBookmarks = true;
              PopupBlocking.Default = false;
              PromptForDownloadLocation = false;
              TranslateEnabled = false;
              SearchBar = "unified";
              SearchSuggestEnabled = false;
              SanitizeOnShutdown = {
                Cache = true;
                FormData = true;
                Locked = true;
                Cookies = false;
                Downloads = false;
                History = false;
                Sessions = false;
                SiteSettings = false;
                OfflineApps = true;
              };
              FirefoxHome = {
                Search = true;
                Pocket = false;
                Snippets = false;
                TopSites = false;
                Highlights = false;
              };
              UserMessaging = {
                ExtensionRecommendations = false;
                FeatureRecommendations = false;
                UrlbarInterventions = false;
                MoreFromMozilla = false;
                SkipOnboarding = true;
              };
              EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
              };
              ExtensionSettings = {
                "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
                # uBlock Origin:
                "uBlock0@raymondhill.net" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                  installation_mode = "force_installed";
                };
                # Privacy Badger:
                "jid1-MnnxcxisBPnSXQ@jetpack" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
                  installation_mode = "force_installed";
                };
                # Browserpass:
                "browserpass@maximbaz.com" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/browserpass-ce/latest.xpi";
                  installation_mode = "force_installed";
                };
                # Vimium
                "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
                  installation_mode = "force_installed";
                };
              };

              Handlers = {
                schemes = {
                  mailto = {
                    action = "useHelperApp";
                    ask = false;
                    handlers = [
                      {
                        name = "RoundCube";
                        uriTemplate = "https://mail.idimitrov.dev/?_task=mail&_action=compose&_to=%s";
                      }
                    ];
                  };
                };
              };
            };
          };
          chromium = {
            enable = true;
          };
        };
        xdg.mimeApps.defaultApplications = {
          "text/html" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
        };
      }
    );
  };
}
