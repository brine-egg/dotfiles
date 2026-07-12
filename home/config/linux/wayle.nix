{
  pkgs,
  lib,
  ...
}:
{
  # Wayle desktop shell for compositors with no desktop GUI
  services.wayle = {
    enable = true;
    settings = {
      styling = {
        palette = {
          bg = "#11111b";
          blue = "#74c7ec";
          elevated = "#1e1e2e";
          fg = "#cdd6f4";
          fg-muted = "#bac2de";
          green = "#a6e3a1";
          primary = "#b4befe";
          red = "#f38ba8";
          surface = "#181825";
          yellow = "#f9e2af";
        };
      };
      bar = {
        inset-edge = 0.3;
        inset-ends = 0.3;
        border-location = "all";
        border-color = "border-strong";
        rounding = "sm";
      };
      modules = {
        clock = {
          format = "%a %d %b %H:%M";
          right-click = "";
        };
        hyprland-workspaces = {
          numbering = "relative";
        };
        keyboard-input = {
          border-color = "green";
          icon-bg-color = "green";
          label-color = "green";
        };
        microphone = {
          border-color = "yellow";
          icon-bg-color = "yellow";
          label-color = "yellow";
        };
        power = {
          left-click = "wleave";
        };
        volume = {
          border-color = "yellow";
          icon-bg-color = "yellow";
          label-color = "yellow";
        };
      };
    };
  };
}
