{ fetchurl
, writeText }:

{
  # Admin mods
  "mods/better-fabric-console.jar" = fetchurl rec {
    hash = "sha256-Fl+bKhUwBk7Q/P3Z43g6vP51b4SyCt9QYRn631J1IOc=";
    pname = "better-fabric-console";
    url = "https://cdn.modrinth.com/data/Y8o1j1Sf/versions/8YUqYot0/${pname}-${version}.jar";
    version = "mc1.20.1-1.1.6";
  };
  "mods/minimotd.jar" = fetchurl rec {
    hash = "sha256-Uup1gNeM4/5OhDqkH0f5JGs7gI65w98zOvfIoqCiKZ8=";
    pname = "minimotd";
    url = "https://cdn.modrinth.com/data/16vhQOQN/versions/SxaMhttu/${pname}-${version}.jar";
    version = "fabric-mc1.20.1-2.0.13";
  };
  "config/MiniMOTD/main.conf" = writeText "to_include.hocon" ''
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
  "config/MiniMOTD/icons/image.png" = fetchurl rec {
    hash = "sha256-9QvXb9oxBpEIJGV0S25ofyriKTK5PUIt6b1z9uEvRW4=";
    url = "https://kursu.dev/minecraft/image.png";
  };
  "mods/TAB.jar" = fetchurl rec {
    hash = "sha256-mBasPD/mFrAMB4OT05waaDReLkU9ufkANJr2AhIZlAs=";
    pname = "TAB";
    url = "https://cdn.modrinth.com/data/gG7VFbG0/versions/Jo9YGxAl/${pname}%20${version}.jar";
    version = "v5.0.7";
  };
  ## We can mostly leave it to our jar to do it for us, as Nix will just overlay it when using yml anyways :)
  "config/tab/config.yml" = builtins.toFile "yml" (builtins.toJSON {

  });
  "mods/styled-chat.jar" = fetchurl rec {
    hash = "sha256-wwHy+JVqDR9tRqcyS1eNde3O3ULdrotDBk33QdAM9Bg=";
    pname = "styled-chat";
    url = "https://cdn.modrinth.com/data/doqSKB0e/versions/pwr7uYCH/${pname}-${version}.jar";
    version = "2.2.4%2B1.20.1";
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
  "mods/player-roles.jar" = fetchurl rec {
    hash = "sha256-6ddXVpg4TQZ6z0gyDi7R0CuIaTxkZsu7ZIj0yIXHVUM=";
    pname = "player-roles";
    url = "https://cdn.modrinth.com/data/Rt1mrUHm/versions/ulkivKzy/${pname}-${version}.jar";
    version = "1.6.6";
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
}