{
  pkgs,
  ...
}:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
  };
}
