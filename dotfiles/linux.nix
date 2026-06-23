{
  pkgs,
  ...
}: {
  # GTK fonts and cursors (Linux-only)
  gtk = {
    enable = true;
    font = {
      name = "Clear Sans Medium, Medium 12";
      package = pkgs.texlivePackages.clearsans;
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors;
    };
  };
}
