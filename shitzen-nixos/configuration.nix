{ config, inputs, lib, pkgs, ... }:

{ 
  imports = [
    ./hardware-configuration.nix
  ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "minecraft-server"
  ];
  
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      memtest86.enable = true;
      copyKernels = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 80 443 4300 4301 ];
      allowedUDPPorts = [ 4301 4302 ];
    };
    hostName = "shitzen-nixos";
  };

  environment.systemPackages = with pkgs; [
    ffmpeg_6-headless
    git
    htop
    ncurses
    ncurses5
    neofetch
    openssl
    screen
    tmux
    tshark
    unzip
    wget
    zip
  ];

  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "fuckk.lol" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/private/" = {
              alias = "/data/private/";
              index = "index.htm";
              extraConfig = ''
                autoindex on;
                autoindex_exact_size off;
              '';
            };
            "/" = {
              alias = "/data/web/";
              index = "index.html";
            };
          };
        };
      };
    };
    minecraft-servers = {
      # As much as I want to have this go on the HDD, it's simply too slow.
      dataDir = "/var/lib/minecraft";
      enable = true;
      eula = true;
      servers = {
        test = {
          autoStart = false;
          enable = false;
          files = {
            "mods/fabric-api.jar" = pkgs.fetchurl rec {
              hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
              pname = "fabric-api";
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/${pname}-${version}.jar";
              version = "0.114.0%2B1.21.4";
            };
            "mods/ferritecore.jar" = pkgs.fetchurl rec {
              hash = "sha256-DdXpIDVSAk445zoPW0aoLrZvAxiyMonGhCsmhmMnSnk=";
              pname = "ferritecore";
              url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/${pname}-${version}.jar";
              version = "7.1.1-fabric";
            };
            "mods/lithium.jar" = pkgs.fetchurl rec {
              hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
              pname = "lithium";
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/${pname}-${version}.jar";
              version = "fabric-0.14.3%2Bmc1.21.4";
            };
            "mods/modernfix.jar" = pkgs.fetchurl rec {
              hash = "sha256-yDjUaCH3wW/e5ccG4tpeO4JkMJScj8EbDSvQTlLVu+s=";
              pname = "modernfix";
              url = "https://cdn.modrinth.com/data/nmDcB62a/versions/gx7PIV8n/${pname}-${version}.jar";
              version = "fabric-5.20.1%2Bmc1.21.4";
            };
            "mods/memoryleakfix.jar" = pkgs.fetchurl rec {
              hash = "sha256-uKwz1yYuAZcQ3SXkVBFmFrye0fcU7ZEFlLKKTB2lrd4=";
              pname = "memoryleakfix";
              url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/${pname}-${version}.jar";
              version = "fabric-1.17%2B-1.1.5";
            };
            "mods/Debugify.jar" = pkgs.fetchurl rec {
              hash = "sha256-9f1/iLjcor5vkWoHjiRggP8zhTc3fY80d6hJZeb9OeU=";
              pname = "Debugify";
              url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/TxwUizo2/${pname}-${version}.jar";
              version = "1.21.4%2B1.0";
            };
          };
          whitelist = {
            FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
            SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
            kashikoi22 = "ab33a905-7f5f-4bfa-b0b3-852b8b0ac2e3";
          };
          jvmOpts = "-Xms4G -Xmx4G";
          package = pkgs.fabricServers.fabric-1_21_4;
          serverProperties = {
            admin-slot = true;
            allow-cheats = true;
            compression-algorithm = "zlib";
            compression-threshold = 2;
            difficulty = "hard";
            enable-command-block = true;
            enable-rcon = false;
            enforce-whitelist = true;
            entity-broadcast-range-percentage = 50;
            force-gamemode = false;
            gamemode = "survival";
            hardcore = false;
            max-players = 3;
            max-threads = 8;
            max-tick-time = 60000;
            motd = "Vali's Test Minecraft Server";
            query-port = 4300;
            server-name = "InertiaCraftTest";
            server-port = 4300;
            simulation-distance = 24;
            texturepack-required = true;
            tick-distance = 12;
            view-distance = 24;
            white-list = true;
          };
        };
        prod = {
          autoStart = true;
          enable = true;
          files = {
            "mods/fabric-api.jar" = pkgs.fetchurl rec {
              hash = "sha256-TATNEpMOzG19eCI5NDhdYonSpkRLzH3q9T49o3kgHC0=";
              pname = "fabric-api";
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5tj7y3PJ/${pname}-${version}.jar";
              version = "0.114.0%2B1.21.4";
            };
            "mods/cloth-config.jar" = pkgs.fetchurl rec {
              hash = "sha256-H9oMSonU8HXlGz61VwpJEocGVtJS2AbqMJHSu8Bngeo=";
              pname = "cloth-config";
              url = "https://cdn.modrinth.com/data/9s6osm5g/versions/TJ6o2sr4/${pname}-${version}.jar";
              version = "17.0.144-fabric";
            };
            "mods/ferritecore.jar" = pkgs.fetchurl rec {
              hash = "sha256-DdXpIDVSAk445zoPW0aoLrZvAxiyMonGhCsmhmMnSnk=";
              pname = "ferritecore";
              url = "https://cdn.modrinth.com/data/uXXizFIs/versions/IPM0JlHd/${pname}-${version}.jar";
              version = "7.1.1-fabric";
            };
            "mods/lithium.jar" = pkgs.fetchurl rec {
              hash = "sha256-LJFVhw/3MnsPnYTHVZbM3xJtne1lV5twuYeqZSMZEn4=";
              pname = "lithium";
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/${pname}-${version}.jar";
              version = "fabric-0.14.3%2Bmc1.21.4";
            };
            "mods/modernfix.jar" = pkgs.fetchurl rec {
              hash = "sha256-yDjUaCH3wW/e5ccG4tpeO4JkMJScj8EbDSvQTlLVu+s=";
              pname = "modernfix";
              url = "https://cdn.modrinth.com/data/nmDcB62a/versions/gx7PIV8n/${pname}-${version}.jar";
              version = "fabric-5.20.1%2Bmc1.21.4";
            };
            "mods/memoryleakfix.jar" = pkgs.fetchurl rec {
              hash = "sha256-uKwz1yYuAZcQ3SXkVBFmFrye0fcU7ZEFlLKKTB2lrd4=";
              pname = "memoryleakfix";
              url = "https://cdn.modrinth.com/data/NRjRiSSD/versions/5xvCCRjJ/${pname}-${version}.jar";
              version = "fabric-1.17%2B-1.1.5";
            };
            "mods/Debugify.jar" = pkgs.fetchurl rec {
              hash = "sha256-9f1/iLjcor5vkWoHjiRggP8zhTc3fY80d6hJZeb9OeU=";
              pname = "Debugify";
              url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/TxwUizo2/${pname}-${version}.jar";
              version = "1.21.4%2B1.0";
            };
            "mods/NoChatReports.jar" = pkgs.fetchurl rec {
              hash = "sha256-1jMJbw5wL/PwsNSEHs4MHJpjyvPVhbhiP59dnXRQJwI=";
              pname = "NoChatReports";
              url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/${pname}-${version}.jar";
              version = "FABRIC-1.21.4-v2.11.0";
            };
            "mods/noisium.jar" = pkgs.fetchurl rec {
              hash = "sha256-JmSbfF3IDaC1BifR8WaKFCpam6nHlBWQzVryDR6Wvto=";
              pname = "noisium";
              url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/9NHdQfkN/${pname}-${version}.jar";
              version = "fabric-2.5.0%2Bmc1.21.4";
            };
            "mods/c2me.jar" = pkgs.fetchurl rec {
              hash = "sha256-7gnbVMLOvbWQS+FNrHBSYn4wsI/mwjhkB8nn2qmKeJQ=";
              pname = "c2me";
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/fBvLHC54/${pname}-${version}.jar";
              version = "fabric-mc1.21.4-0.3.1.0";
            };
            "mods/vmp.jar" = pkgs.fetchurl rec {
              hash = "sha256-cYYe7qBhX3gPdcFzyt4m1WB5v0eT20f24SuhmWOnZbI=";
              pname = "vmp";
              url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/k1tcjmTr/${pname}-${version}.jar";
              version = "fabric-mc1.21.4-0.2.0%2Bbeta.7.187-all";
            };
            "mods/Chunky.jar" = pkgs.fetchurl rec {
              hash = "sha256-A8kKcLIzQWvZZziUm+kJ0eytrHQ/fBVZQ18uQXN9Qf0=";
              pname = "Chunky";
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/VkAgASL1/${pname}-${version}.jar";
              version = "Fabric-1.4.27";
            };
            "mods/balm.jar" = pkgs.fetchurl rec {
              hash = "sha256-dj/zhNd1WIMs5pj3LL6myKx9TlhHkOS7W5IDvk02KXg=";
              pname = "balm";
              url = "https://cdn.modrinth.com/data/MBAkmtvl/versions/9pTQ0wCu/${pname}-${version}.jar";
              version = "fabric-1.21.4-21.4.5";
            };
            "mods/netherportalfix.jar" = pkgs.fetchurl rec {
              hash = "sha256-Mzs9yz38b3+wrOFzQYUm8ufGF26Pm3VFULPrnKU/Nk8=";
              pname = "netherportalfix";
              url = "https://cdn.modrinth.com/data/nPZr02ET/versions/QFwLWcVf/${pname}-${version}.jar";
              version = "fabric-1.21.4-21.4.1";
            };
            "mods/Almanac.jar" = pkgs.fetchurl rec {
              hash = "sha256-uUzohqWvbxvlb9Y0vUMY03BQg/W0k0gi/BxYa7zkw48=";
              pname = "Almanac";
              url = "https://cdn.modrinth.com/data/Gi02250Z/versions/inGMPti6/${pname}-${version}.jar";
              version = "1.21.3-fabric-1.4.4";
            };
            "mods/letmedespawn.jar" = pkgs.fetchurl rec {
              hash = "sha256-TTXnoq5R6EX7zBUscbMtonOBYO3zSvDtDg/XqWGkZMg=";
              pname = "letmedespawn";
              url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/e0AXgTFp/${pname}-${version}.jar";
              version = "1.21.x-fabric-1.4.4";
            };
            # Audio
            "mods/voicechat.jar" = pkgs.fetchurl rec {
              hash = "sha256-2ni2tQjMCO3jaEA1OHXoonZpGqHGVlY/9rzVsijrxVA=";
              pname = "voicechat";
              url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pl9FpaYJ/${pname}-${version}.jar";
              version = "fabric-1.21.4-2.5.26";
            };
            "mods/audioplayer.jar" = pkgs.fetchurl rec {
              hash = "sha256-Eu6zoQZa9aeBID7EXk/6QkQHzuhKIN8WYVxaTYynhqw=";
              pname = "audioplayer";
              url = "https://cdn.modrinth.com/data/SRlzjEBS/versions/377C94c4/${pname}-${version}.jar";
              version = "fabric-1.21.4-1.13.2";
            };
            "mods/vcinteraction.jar" = pkgs.fetchurl rec {
              hash = "sha256-lFXEJIyN4aaSE/6LlBuzWGdzqDe3h2wKgL6BqsbdtrU=";
              pname = "vcinteraction";
              url = "https://cdn.modrinth.com/data/qsSP2ZZ0/versions/MCSYkp3r/${pname}-${version}.jar";
              version = "fabric-1.21.4-1.0.8";
            };
            "mods/sound-physics-remastered.jar" = pkgs.fetchurl rec {
              hash = "sha256-l1FcQjYIkKk3lGubdZtUkSeIBS7sMu3woY452k3G+cc=";
              pname = "sound-physics-remastered";
              url = "https://cdn.modrinth.com/data/qyVF9oeo/versions/jtRGevsD/${pname}-${version}.jar";
              version = "fabric-1.21.4-1.4.8";
            };
            # Multi-version interop
            "mods/geyser-fabric.jar" = pkgs.fetchurl rec {
              hash = "sha256-jfkgzNCMVnm26JTBPeO9mEqCXraqBSv7I82CY5p/XHQ=";
              pname = "geyser-fabric";
              url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/wzwTpHlw/${pname}-${version}.jar";
              version = "Geyser-Fabric-2.6.0-b742";
            };
            "config/Geyser-Fabric/config.yml" = builtins.toFile "yml" (builtins.toJSON {
              bedrock = {
                address = "0.0.0.0";
                clone-remote-port = false;
                enable-proxy-protocol = false;
                port = 4302;
                server-name = "InertiaCraft Bedrock";
                motd1 = ".gg/d9ccwK2TNk";
              };
              remote = {
                auth-type = "floodgate";
              };
              allow-third-party-capes = true;
              allow-third-party-ears = true;
              force-resource-packs = true;
              forward-player-ping = true;
              passthrough-player-count = true;
            });
            "mods/Floodgate.jar" = pkgs.fetchurl rec {
              hash = "sha256-xdkGvr8DVF8jx6VEV1ckHU8P2FW2KODqFygS9vc/2Lw=";
              pname = "Floodgate";
              url = "https://cdn.modrinth.com/data/bWrNNfkb/versions/jb3lzved/${pname}-${version}.jar";
              version = "Fabric-2.2.4-b42";
            };
            "mods/ViaFabric.jar" = pkgs.fetchurl rec {
              hash = "sha256-gJQYHj9O2IZ7iKkZcLbuDiEmGIogHipFmJR/8b9lpPM=";
              pname = "ViaFabric";
              url = "https://cdn.modrinth.com/data/YlKdE5VK/versions/Niu0KrUK/${pname}-${version}.jar";
              version = "0.4.17%2B91-main";
            };
            "mods/ViaBackwards.jar" = pkgs.fetchurl rec {
              hash = "sha256-RMDwGh1aZzOM+O9Zz3+7zkyCdv/yLx/bNM7tb0ZjMN8=";
              pname = "ViaBackwards";
              url = "https://cdn.modrinth.com/data/NpvuJQoq/versions/bprnc7WS/${pname}-${version}.jar";
              version = "5.2.1";
            };
            "mods/ViaRewind.jar" = pkgs.fetchurl rec {
              hash = "sha256-ZMdA0yEqZm/9Vs3nq4fCai7GbLgKahBGsY3kP+M9s3U=";
              pname = "ViaRewind";
              url = "https://cdn.modrinth.com/data/TbHIxhx5/versions/qf3oSwsb/${pname}-${version}.jar";
              version = "4.0.5";
            };
            "mods/ViaVersion.jar" = pkgs.fetchurl rec {
              hash = "sha256-yaWqtqxikpaiwdeyfANzu6fp3suSF8ePmJXs9dN4H8g=";
              pname = "ViaVersion";
              url = "https://cdn.modrinth.com/data/P1OZGk5p/versions/p5sXOzZW/${pname}-${version}.jar";
              version = "5.2.1";
            };
            # Admin mods
            "mods/better-fabric-console.jar" = pkgs.fetchurl rec {
              hash = "sha256-nZsga6kXBpb9ci2pfEh1rOzajs1E6w6BrX04FaiM2BA=";
              pname = "better-fabric-console";
              url = "https://cdn.modrinth.com/data/Y8o1j1Sf/versions/3d1g5aTY/${pname}-${version}.jar";
              version = "mc1.21.4-1.2.2";
            };
            "mods/minimotd.jar" = pkgs.fetchurl rec {
              hash = "sha256-0ooWUoHUriao6RF18iCn23lrCxxP9X0VnzW4yjCAdDQ=";
              pname = "minimotd";
              url = "https://cdn.modrinth.com/data/16vhQOQN/versions/FheuITlu/${pname}-${version}.jar";
              version = "fabric-mc1.21.4-2.1.5";
            };
            "config/MiniMOTD/main.conf" = pkgs.writeText "to_include.hocon" ''
              icon-enabled=true
              motd-enabled=true
              motds=[
                  {
                      icon="image"
                      line1="<dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray> <i><b><gradient:#6600CB:#67A7FC>Iner</gradient><gradient:#67A7FC:#AB31BA>tiaC</gradient><gradient:#AB31BA:#9143D9>raft</gradient></b></i> <dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray><gray>*</gray><dark_gray>-</dark_gray>"
                      line2="<gray>fuckk</gray><dark_gray>.</dark_gray><gray>lol</gray>               Welcome!          <dark_gray>.gg/</dark_gray><gray>d9ccwK2TNk</gray>"
                  }
              ]
              player-count-settings {
                  disable-player-list-hover=false
                  hide-player-count=false
                  max-players-enabled=true
                  max-players=20
              }
            '';
            "config/MiniMOTD/icons/image.png" = pkgs.fetchurl rec {
              hash = "sha256-9QvXb9oxBpEIJGV0S25ofyriKTK5PUIt6b1z9uEvRW4=";
              url = "https://fuckk.lol/minecraft/image.png";
            };
            "mods/TAB.jar" = pkgs.fetchurl rec {
              hash = "sha256-ajHlun8YUilqH/Zj2Na+YP8ibLRPhR0/RmWVw+b7B5g=";
              pname = "TAB";
              url = "https://cdn.modrinth.com/data/gG7VFbG0/versions/1T0QxY8p/${pname}%20${version}.jar";
              version = "v5.0.3";
            };
            # We can mostly leave it to our jar to do it for us, as Nix will just overlay it when using yml anyways :)
            "config/tab/config.yml" = builtins.toFile "yml" (builtins.toJSON {

            });
            "mods/styled-chat.jar" = pkgs.fetchurl rec {
              hash = "sha256-XgYWDovpVLGu7Exj60jF3O0JrEVSGLFCGmh/yu1XFPg=";
              pname = "styled-chat";
              url = "https://cdn.modrinth.com/data/doqSKB0e/versions/b7ivf9W5/${pname}-${version}.jar";
              version = "2.7.1%2B1.21.3";
            };
            "config/styled-chat.json" = builtins.toFile "json" (builtins.toJSON {
                CONFIG_VERSION_DONT_TOUCH_THIS = 3;
                text_formatting = {
                  legacy_formatting = true;
                  markdown = true;
                  parse_links = true;
                  parse_mentions = false;
                  respect_colors_client_setting = true;
                };
                custom_message_types = {};
                chat_preview = {
                  require_for_formatting = false;
                  send_full_message = false;
                };
                auto_completion = {
                  emoticons = true;
                  tag_aliases = false;
                  tags = false;
                };
                default = {
                  display_name = "\${default}";
                  message_formats = {
                    chat =  "\${player} <dark_gray>»</dark_gray> \${message}";
                    joined_the_game =  "<gray>✚</gray> <color:#85ff8f><lang:multiplayer.player.joined:'\${player}'>";
                    joined_after_name_change =  "<gray>✚</gray> <color:#85ff8f><lang:multiplayer.player.joined.renamed:'\${player}':'\${old_name}'>";
                    joined_for_first_time =  "<yellow><lang:multiplayer.player.joined:'\${player}'></yellow>";
                    left_game =  "<gray>☁</gray> <color:#ff8585><lang:multiplayer.player.left:'\${player}'>";
                    base_death =  "<gray>☠</gray> <color:#d1d1d1>\${default_message}";
                    advancement_task =  "<lang:chat.type.advancement.task:'\${player}':'\${advancement}'>";
                    advancement_challenge =  "<lang:chat.type.advancement.challenge:'\${player}':'\${advancement}'>";
                    advancement_goal =  "<lang:chat.type.advancement.goal:'\${player}':'\${advancement}'>";
                    sent_team_chat =  "<lang:'chat.type.team.sent':'<hover\\:\\'<lang\\:chat.type.team.hover>\\'><suggest_command\\:\\'/teammsg \\'>\${team}':'\${displayName}':'\${message}'>";
                    received_team_chat =  "<lang:'chat.type.team.text':'<hover\\:\\'<lang\\:chat.type.team.hover>\\'><suggest_command\\:\\'/teammsg \\'>\${team}':'\${displayName}':'\${message}'>";
                    sent_private_message =  "<gray>[<green>PM</green> → \${receiver}] <dark_gray>»<reset> \${message}";
                    received_private_message =  "<gray>[<green>PM</green> ← \${sender}] <dark_gray>»<reset> \${message}";
                    say_command =  "<red>[\${player}] \${message}";
                    me_command =  "<green>* \${player} \${message}";
                    pet_death =  "Oh no! \${default_message}";
                  };
                  emoticons = {
                    "$emojibase:builtin:joypixels" = "\${emoji}";
                    bell =  "<yellow>🔔";
                    bow = "🏹";
                    bucket = "🪣";
                    fire =  "🔥";
                    heart =  "<red>❤";
                    item = "[%player:equipment_slot mainhand%]";
                    pos = "%player:pos_x% %player:pos_y% %player:pos_z%";
                    potion = "🧪";
                    rod = "🎣";
                    shears = "✂";
                    shrug = "¯\\_(ツ)_/¯";
                    sword = "🗡";
                    table = "(╯°□°）╯︵ ┻━┻";
                    trident = "🔱";
                  };
                  formatting = {
                    dark_red = true;
                    green = true;
                    underline = true;
                    dark_green = true;
                    black = true;
                    yellow = true;
                    bold = true;
                    italic = true;
                    dark_blue = true;
                    dark_purple = true;
                    gold = true;
                    red = true;
                    aqua = true;
                    gray = true;
                    light_purple = true;
                    blue = true;
                    white = true;
                    dark_aqua = true;
                    dark_gray = true;
                    spoiler = true;
                    strikethrough = true;
                  };
                  link_style = "<underline><c:#7878ff>\${link}";
                  mention_style = "<c:#7878ff>%player:displayname%";
                  spoiler_style = "<gray>\${spoiler}";
                  spoiler_symbol = "▌";
                };
                styles = [
                  {
                    display_name = "<dark_gray>[<red>Admin</red>]</dark_gray> <c:#ffe8a3>\${vanillaDisplayName}</c>";
                    message_formats = {
                      base_death = "";
                      chat = "\${player} <dark_gray>»</dark_gray> <orange>\${message}";
                    };
                    emoticons = {};
                    formatting = {};
                    require = {
                      operator = 4;
                      permission = "group.admin";
                      type = "permission";
                    };
                  }
                  {
                    display_name = "<dark_gray>[<aqua>Player</aqua>]</dark_gray> <dark_aqua>\${vanillaDisplayName}</dark_aqua>";
                    emoticons = {};
                    formatting = {};
                    message_formats = {};
                    require = {
                      permission = "group.default";
                      type = "permission";
                    };
                  }
                  {
                    require = {
                      operator = 3;
                      permission = "group.vip";
                      type = "permission";
                    };
                    emoticons = {
                      potato = "<rb>Potato";
                    };
                    formatting = {};
                    message_formats = {};
                  }
                ];
            });
            "mods/player-roles.jar" = pkgs.fetchurl rec {
              hash = "sha256-rqFqiCgfRn2LOKqVpo9KQVnn/VnD//sBbXoa7sctiZw=";
              pname = "player-roles";
              url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/Y5EAJzwR/${pname}-${version}.jar";
              version = "1.6.13";
            };
            "config/roles.json" = builtins.toFile "json" (builtins.toJSON {
              admin = {
                level = 100;
                overrides = {
                  command_feedback = true;
                  commands = {
                    ".*" = "allow";
                  };
                  name_decoration = {
                    style = ["red" "bold"];
                    suffix = {
                      text = "*";
                    };
                  };
                  permission_level = 4;
                };
              };
              spectator = {
                level = 10;
                overrides = {
                  commands = {
                    "gamemode (spectator|adventure)" = "allow";
                  };
                };
              };
              mute = {
                level = 1;
                overrides = {
                  mute = true;
                };
              };
              everyone = {
                overrides = {
                  commands = {
                    ".*" = "deny";
                    help = "allow";
                  };
                };
              };
            });
            # Quality-of-life
            #https://cdn.modrinth.com/data/fCpuZIcM/versions/LGVGR1On/resourcepackchecker-fabric-1.21.4-1.2.2.jar
            "mods/resourcepackchecker.jar" = pkgs.fetchurl rec {
              hash = "sha256-Kv7HG1RSPnwcTsasRQeQWUhs0/gHs1iha99Xxo5dkoc=";
              pname = "resourcepackchecker";
              url = "https://cdn.modrinth.com/data/fCpuZIcM/versions/LGVGR1On/${pname}-${version}.jar";
              version = "fabric-1.21.4-1.2.2";
            };
            "mods/spark.jar" = pkgs.fetchurl rec {
              hash = "sha256-E1BDAk8b1YBuhdqLK98Vh4xVmL99qs5dEwI2/wCbt28=";
              pname = "spark";
              url = "https://cdn.modrinth.com/data/l6YH9Als/versions/X2sypdTL/${pname}-${version}.jar";
              version = "1.10.121-fabric";
            };
            "mods/MRU.jar" = pkgs.fetchurl rec {
              hash = "sha256-sXe42FK7g5AKzBVYarDy/0T9zC0czVzFRoF2Ww7t+DU=";
              pname = "MRU";
              url = "https://cdn.modrinth.com/data/SNVQ2c0g/versions/YMG8XHkz/${pname}-${version}.jar";
              version = "1.0.7%2B1.21.4%2Bfabric";
            };
            "mods/SnowUnderTrees.jar" = pkgs.fetchurl rec {
              hash = "sha256-FbBpPHrewYDzkc6SY0pJt57PWy8INgc/9YmjVnNv94Q=";
              pname = "SnowUnderTrees";
              url = "https://cdn.modrinth.com/data/XVnUIUAQ/versions/cuMgw6kW/${pname}-${version}.jar";
              version = "2.6.0%2B1.21.4";
            };
            # Fun
            "mods/polymer-bundled.jar" = pkgs.fetchurl rec {
              hash = "sha256-L9E+oWY2wOJ9MixhywdJB+wdlBxbo0/c8nrJLMA8r7o=";
              pname = "polymer-bundled";
              url = "https://cdn.modrinth.com/data/xGdtZczs/versions/aek1vsQ6/${pname}-${version}.jar";
              version = "0.11.3%2B1.21.4";
            };
            "mods/gamingbarns-guns.jar" = pkgs.fetchurl rec {
              hash = "sha256-S3qGTofspseGaNPHHGetS0Ncli0spcOFMQCsOEXs45g=";
              pname = "gamingbarns-guns";
              url = "https://cdn.modrinth.com/data/gLko9Axn/versions/UyISZqKM/${pname}-${version}.jar";
              version = "V1.24.2-data";
            };
            "mods/modern-guns.jar" = pkgs.fetchurl rec {
              hash = "sha256-fBNwifikKkpPvmzIHajPUTlkw6yY9trllQVNHgi3CVs=";
              pname = "modern-guns";
              url = "https://cdn.modrinth.com/data/ufgOyMFr/versions/4VvTGEWq/${pname}-${version}.jar";
              version = "V1.3-data";
            };
            "mods/katters-structures.jar" = pkgs.fetchurl rec {
              hash = "sha256-YU7DEnP2s/Zko3fmAKAdJJW3CAtp7G6Ng+P+5+3ZnZQ=";
              pname = "katters-structures";
              url = "https://cdn.modrinth.com/data/V6LLU8Gf/versions/EdSR8mgY/${pname}-${version}.jar";
              version = "2.1c";
            };
            "mods/qraftys-end-villages.jar" = pkgs.fetchurl rec {
              hash = "sha256-lONrYdMBeMR3BITgCqr4cEl6Hy1Sei2w9hCAnH79rtE=";
              pname = "qraftys-end-villages";
              url = "https://cdn.modrinth.com/data/NFlNaUBA/versions/mF2RnE4V/${pname}-${version}.jar";
              version = "3.1";
            };
          };
          whitelist = {
            FaintLove = "992e0e99-b817-4f58-96d9-96d4ec8c7d54";
            Killer4563782 = "f159afef-984e-4343-bd7b-d94cfff96c63";
            SOLOZ01 = "a02466ff-a71b-4540-8838-1b850cd4f659";
            hophophop123 = "00000000-0000-0000-0009-01f4f5b93df8";
            kashikoi22 = "ab33a905-7f5f-4bfa-b0b3-852b8b0ac2e3";
          };
          jvmOpts = "-Xms13G -Xmx13G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
          package = pkgs.fabricServers.fabric-1_21_4;
          serverProperties = {
            admin-slot = true;
            allow-cheats = true;
            compression-algorithm = "snappy";
            compression-threshold = 0;
            difficulty = "hard";
            enable-command-block = true;
            enable-rcon = false;
            enforce-whitelist = true;
            entity-broadcast-range-percentage = 40;
            force-gamemode = false;
            gamemode = "survival";
            hardcore = false;
            max-threads = 0;
            max-tick-time = 60000;
            network-compression-threshold = 512;
            query-port = 4301;
            server-ip = "0.0.0.0";
            server-name = "InertiaCraft";
            server-port = 4301;
            simulation-distance = 4;
            sync-chunk-writes = false; 
            texturepack-required = true;
            require-resource-pack = true;
            resource-pack = "https://fuckk.lol/minecraft/resource-pack.zip";
            tick-distance = 12;
            use-alternate-keepalive = true;
            view-distance = 32;
            white-list = true;
          };
        };
      };
    };
    toxvpn = {
      auto_add_peers = [ "ae395131cb50234bed128ff0ff5ffd495517565b1de6522f41f18a925e575c23978546982368" ];
      localip = "10.0.127.3";
    };
  };
  #systemd.services.minecraft-server-prod.serviceConfig.TimeoutStopSec = lib.mkForce "10s";

  security = {
    acme = {
      acceptTerms = true;
      email = "diorcheats.vali@gmail.com";
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

