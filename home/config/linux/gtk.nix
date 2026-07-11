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
	  name = "Catppuccin-GTK-Lavender-Dark-Compact";
      package = pkgs.magnetic-catppuccin-gtk.override {
		  size = "compact";
		  shade = "dark";
		  accent = [ "lavender" ];
	  };
    };
  };
}
