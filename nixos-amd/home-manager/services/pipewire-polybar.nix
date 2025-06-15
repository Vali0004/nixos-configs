{ i3Config, lib, coreutils, gnused, gawk, pamixer, pulseaudio, pipewire, writeShellScript }:

writeShellScript "pipewire.sh" ''
PATH=${lib.makeBinPath [ coreutils gnused gawk pamixer pulseaudio pipewire ]}

getDefaultSink() {
  pactl info | awk -F': ' '/Default Sink:/{print $2}'
}

getDefaultSource() {
  pactl info | awk -F': ' '/Default Source:/{print $2}'
}

getSinkDescription() {
  local sinkName="$1"
  pactl list sinks | sed -n "/Name: ''${sinkName}/,/Description:/s/^\s*Description: \(.*\)/\1/p"
}

getSourceDescription() {
  local sourceName="$1"
  pactl list sources | sed -n "/Name: ''${sourceName}/,/Description:/s/^\s*Description: \(.*\)/\1/p"
}

SINK_NAME=$(getDefaultSink)
SOURCE_NAME=$(getDefaultSource)

SINK_DESCRIPTION=$(getSinkDescription "$SINK_NAME")
SOURCE_DESCRIPTION=$(getSourceDescription "$SOURCE_NAME")

# Trim descriptions with ellipsis if needed
if [ ''${#SINK_DESCRIPTION} -gt 14 ]; then
  SINK_DESCRIPTION_SHORT="''${SINK_DESCRIPTION:0:11}..."
else
  SINK_DESCRIPTION_SHORT="$SINK_DESCRIPTION"
fi

if [ ''${#SOURCE_DESCRIPTION} -gt 14 ]; then
  SOURCE_DESCRIPTION_SHORT="''${SOURCE_DESCRIPTION:0:11}..."
else
  SOURCE_DESCRIPTION_SHORT="$SOURCE_DESCRIPTION"
fi

VOLUME=$(pactl list sinks | awk -v sink="$SINK_NAME" '
  $0 ~ "Name: "sink {found=1}
  found && /Volume:/ {
    match($0, /([0-9]+)%/, m);
    if (m[1] != "") { print m[1]; exit }
  }
')

IS_MUTED=$(pactl list sinks | awk -v sink="$SINK_NAME" '
  $0 ~ "Name: "sink {found=1}
  found && /Mute:/ {print $2; exit}
')

case $1 in
  "input")
    echo " ''${SOURCE_DESCRIPTION}"
    ;;
  "output")
    if [ "$IS_MUTED" = "yes" ]; then
      echo "%{F${i3Config.barPrimary}}󰝟%{F-} %{F${i3Config.barSecondary}}''${VOLUME}%%{F-}"
    else
      echo "%{F${i3Config.barPrimary}}%{F-} %{F${i3Config.barSecondary}}''${VOLUME}%%{F-}"
    fi
    ;;
  *)
    ;;
esac

case $2 in
  "up")
    pamixer --sink "$SINK_NAME" --increase 5
    ;;
  "down")
    pamixer --sink "$SINK_NAME" --decrease 5
    ;;
  "mute")
    pamixer --sink "$SINK_NAME" --toggle-mute
    ;;
  *)
    ;;
esac
''
