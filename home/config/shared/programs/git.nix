{
  # Enable Git version control
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        Name = "brine-egg";
        Email = "89018140+brine-egg@users.noreply.github.com";
      };
      init.DefaultBranch = "main";
    };
  };
}
