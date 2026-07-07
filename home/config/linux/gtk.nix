{
  pkgs,
  ...
}:
{
  # GTK theme, icons, fonts, and cursors (Linux-only)
  gtk = {
    enable = true;
    font = {
      name = "Clear Sans Medium, Medium 12";
      package = pkgs.texlivePackages.clearsans;
    };
    theme = {
      name = "catppuccin-mocha-lavender-standard+default";
      package = pkgs.catppuccin-gtk;
    };
  };
}
