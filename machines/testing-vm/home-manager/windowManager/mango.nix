{ pkgs
, ... }:

{
  wayland.windowManager.mango = {
    enable = true;
    settings = ''
      # For more options, see: https://github.com/DreamMaoMao/mango/wiki
      # Window effect
      blur=0
      blur_layer=0
      blur_optimized=1
      blur_params_num_passes = 2
      blur_params_radius = 5
      blur_params_noise = 0.02
      blur_params_brightness = 0.9
      blur_params_contrast = 0.9
      blur_params_saturation = 1.2

      shadows = 0
      layer_shadows = 0
      shadow_only_floating = 1
      shadows_size = 10
      shadows_blur = 15
      shadows_position_x = 0
      shadows_position_y = 0
      shadowscolor= 0x000000ff

      border_radius=6
      no_radius_when_single=0
      focused_opacity=1.0
      unfocused_opacity=1.0

      # Animation Configuration(support type:zoom,slide)
      # tag_animation_direction: 0-horizontal,1-vertical
      animations=0
      layer_animations=1
      animation_type_open=slide
      animation_type_close=slide
      animation_fade_in=1
      animation_fade_out=1
      tag_animation_direction=1
      zoom_initial_ratio=0.3
      zoom_end_ratio=0.8
      fadein_begin_opacity=0.5
      fadeout_begin_opacity=0.8
      animation_duration_move=500
      animation_duration_open=400
      animation_duration_tag=350
      animation_duration_close=800
      animation_duration_focus=0
      animation_curve_open=0.46,1.0,0.29,1
      animation_curve_move=0.46,1.0,0.29,1
      animation_curve_tag=0.46,1.0,0.29,1
      animation_curve_close=0.08,0.92,0,1
      animation_curve_focus=0.46,1.0,0.29,1

      # Scroller Layout Setting
      scroller_structs=20
      scroller_default_proportion=0.8
      scroller_focus_center=0
      scroller_prefer_center=0
      edge_scroller_pointer_focus=1
      scroller_default_proportion_single=1.0
      scroller_proportion_preset=0.5,0.8,1.0

      # Master-Stack Layout Setting
      new_is_master=1
      default_mfact=0.55
      default_nmaster=1
      smartgaps=0

      # Overview Setting
      hotarea_size=10
      enable_hotarea=1
      ov_tab_mode=0
      overviewgappi=5
      overviewgappo=30

      # Misc
      no_border_when_single=0
      axis_bind_apply_timeout=100
      focus_on_activate=1
      inhibit_regardless_of_visibility=0
      sloppyfocus=1
      warpcursor=1
      focus_cross_monitor=0
      focus_cross_tag=0
      enable_floating_snap=0
      snap_distance=30
      cursor_size=24
      drag_tile_to_tile=1

      # Keyboard
      repeat_rate=25
      repeat_delay=600
      numlockon=0
      xkb_rules_layout=us

      # Mouse
      # Need to relogin in order to make it apply
      mouse_natural_scrolling=0

      # Appearance
      gappih=5
      gappiv=5
      gappoh=10
      gappov=10
      scratchpad_width_ratio=0.8
      scratchpad_height_ratio=0.9
      borderpx=1
      rootcolor=0x201b14ff
      bordercolor=0x642cffff
      focuscolor=0xc9b890ff
      maximizescreencolor=0x89aa61ff
      urgentcolor=0xad401fff
      scratchpadcolor=0x516c93ff
      globalcolor=0x642cffff
      overlaycolor=0x14a57cff

      # Layout support:
      # tile,scroller,grid,deck,monocle,center_tile,vertical_tile,vertical_scroller
      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:tile
      tagrule=id:3,layout_name:tile
      tagrule=id:4,layout_name:tile
      tagrule=id:5,layout_name:tile
      tagrule=id:6,layout_name:tile
      tagrule=id:7,layout_name:tile
      tagrule=id:8,layout_name:tile
      tagrule=id:9,layout_name:tile

      # Key Bindings
      # key name refer to `xev` or `wev` command output,
      # mod keys name: super,Ctrl,ALT,Shift,none

      # Reload config
      bind=SUPER,r,reload_config

      # App launchers
      bind=SUPER,d,spawn,rofi -show drun
      bind=SUPER,Return,spawn,alacritty
      bind=SUPER+Shift,Return,spawn,google-chrome-stable

      # eEit
      bind=SUPER+Shift,e,quit
      bind=SUPER,q,killclient,

      # Switch window focus
      bind=SUPER,Tab,focusstack,next
      bind=ALT,Left,focusdir,left
      bind=ALT,Right,focusdir,right
      bind=ALT,Up,focusdir,up
      bind=ALT,Down,focusdir,down

      # Swap window
      bind=SUPER+Shift,Up,exchange_client,up
      bind=SUPER+Shift,Down,exchange_client,down
      bind=SUPER+Shift,Left,exchange_client,left
      bind=SUPER+Shift,Right,exchange_client,right

      # Switch window status
      bind=SUPER,g,toggleglobal,
      bind=ALT,Tab,toggleoverview,
      bind=ALT,backslash,togglefloating,
      bind=ALT,a,togglemaximizescreen,
      bind=ALT,f,togglefullscreen,
      bind=ALT+Shift,f,togglefakefullscreen,
      bind=SUPER,i,minimized,
      bind=SUPER,o,toggleoverlay,
      bind=SUPER+Shift,I,restore_minimized
      bind=ALT,z,toggle_scratchpad

      # Scroller layout
      bind=ALT,e,set_proportion,1.0
      bind=ALT,x,switch_proportion_preset,

      # Switch layout
      bind=SUPER,n,switch_layout

      # Tag switch
      bind=SUPER,Left,viewtoleft,0
      bind=Ctrl,Left,viewtoleft_have_client,0
      bind=SUPER,Right,viewtoright,0
      bind=Ctrl,Right,viewtoright_have_client,0
      bind=Ctrl+SUPER,Left,tagtoleft,0
      bind=Ctrl+SUPER,Right,tagtoright,0

      bind=SUPER,1,view,1,0
      bind=SUPER,2,view,2,0
      bind=SUPER,3,view,3,0
      bind=SUPER,4,view,4,0
      bind=SUPER,5,view,5,0
      bind=SUPER,6,view,6,0
      bind=SUPER,7,view,7,0
      bind=SUPER,8,view,8,0
      bind=SUPER,9,view,9,0

      # Tag: move client to the tag and focus it
      # Tagsilent: move client to the tag and not focus it
      # bind=ALT,1,tagsilent,1
      bind=SUPER+Shift,1,tag,1,0
      bind=SUPER+Shift,2,tag,2,0
      bind=SUPER+Shift,3,tag,3,0
      bind=SUPER+Shift,4,tag,4,0
      bind=SUPER+Shift,5,tag,5,0
      bind=SUPER+Shift,6,tag,6,0
      bind=SUPER+Shift,7,tag,7,0
      bind=SUPER+Shift,8,tag,8,0
      bind=SUPER+Shift,9,tag,9,0

      # Monitor switch
      bind=ALT+Shift,Left,focusmon,left
      bind=ALT+Shift,Right,focusmon,right
      bind=SUPER+ALT,Left,tagmon,left
      bind=SUPER+ALT,Right,tagmon,right

      # Gaps
      bind=ALT+Shift,X,incgaps,1
      bind=ALT+Shift,Z,incgaps,-1
      bind=ALT+Shift,R,togglegaps

      # movewin
      bind=Ctrl+Shift,Up,movewin,+0,-50
      bind=Ctrl+Shift,Down,movewin,+0,+50
      bind=Ctrl+Shift,Left,movewin,-50,+0
      bind=Ctrl+Shift,Right,movewin,+50,+0

      # Resize window
      bind=Ctrl+ALT,Up,resizewin,+0,-50
      bind=Ctrl+ALT,Down,resizewin,+0,+50
      bind=Ctrl+ALT,Left,resizewin,-50,+0
      bind=Ctrl+ALT,Right,resizewin,+50,+0

      # Mouse Button Bindings
      # NONE mode key only work in ov mode
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=NONE,btn_middle,togglemaximizescreen,0
      mousebind=SUPER,btn_right,moveresize,curresize
      mousebind=NONE,btn_left,toggleoverview,-1
      mousebind=NONE,btn_right,killclient,0

      # Axis Bindings
      axisbind=SUPER,UP,viewtoleft_have_client
      axisbind=SUPER,DOWN,viewtoright_have_client

      # Layer rules
      layerrule=animation_type_open:zoom,layer_name:rofi
      layerrule=animation_type_close:zoom,layer_name:rofi
    '';
    autostart_sh = ''
      ${pkgs.pipewire}/bin/pw-metadata -n settings 0 default.audio.sink alsa_output.usb-Sony_INZONE_H9_II-00.analog-stereo
      ${pkgs.mpvpaper}/bin/mpvpaper -o "--fullscreen --no-stop-screensaver --loop-file --no-audio --no-osc --no-osd-bar --no-input-default-bindings --vo=libmpv" ALL /home/vali/.config/xwinwrap/wallpaper.gif &
    '';
  };
}