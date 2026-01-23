{
  config,
  pkgs,
  ...
}:
let
  c = config.theme.colors;
  f = config.theme.font;
in
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "none";
        origin = "bottom-right";
        width = 400;
        notification_limit = 5;
        offset = "10x30";
        indicate_hidden = true;
        shrink = false;
        transparency = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 4;
        frame_width = 1;
        frame_color = c.blue;
        separator_color = "frame";
        sort = true;
        idle_threshold = 120;
        font = "${f.family} ${toString (builtins.floor f.size)}";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b> <i>(%a)</i>\\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = false;
        ellipsize = "end";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = false;
        icon_position = "off";
        max_icon_size = 32;
        sticky_history = true;
        history_length = 20;
        dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst: -i -fn '${f.family}-${toString (builtins.floor f.size)}' -nb '${c.base02}' -nf '${c.base1}' -sb '${c.blue}' -sf '${c.base3}'";
        browser = "${pkgs.firefox}/bin/firefox --new-window";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
      };

      urgency_low = {
        background = c.base03;
        foreground = c.base01;
        frame_color = c.base02;
        timeout = 10;
      };

      urgency_normal = {
        background = c.base03;
        foreground = c.base00;
        frame_color = c.blue;
        timeout = 10;
      };

      urgency_critical = {
        background = c.base02;
        foreground = c.base1;
        frame_color = c.red;
        timeout = 0;
      };
    };
  };
}
