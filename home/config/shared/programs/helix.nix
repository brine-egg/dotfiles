{
  # Enable Helix text editor
  programs.helix = {
    enable = true;
    settings = {
      editor = {
        color-modes = true;
        bufferline = "multiple";
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "block";
        };
      };
      keys = {
        insert = {
          "C-[" = "normal_mode";
        };
        select = {
          "C-[" = "normal_mode";
        };
      };
    };
  };
}
