{
  pkgs,
  ...
}:
{
  # Packages for macOS device
  darwin.packages = [
  	pkgs.kitty
  ];
}
