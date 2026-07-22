{
  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = true;
        mouse_follows_focus = false;
      };
      bindings = { };
      swipe.gesture = {
        fingers_count = 3;
      };
    }; # TODO: add paneru config (see https://github.com/karinushka/paneru/blob/main/CONFIGURATION.md)
  };
}
