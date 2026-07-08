{
  pkgs,
  ...
}:
{
  # Packages for macOS device
  environment.systemPackages = [
  	pkgs.kitty
  ];
}
