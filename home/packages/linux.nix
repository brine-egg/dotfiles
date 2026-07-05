{
  pkgs,
  ...
}:
{
  # Packages for Linux device (Linux-exclusive or only useful on my Linux device)
  home.packages = [
    pkgs.archivemount
    pkgs.dipc
    pkgs.trashy
    pkgs.w3m
  ];
}
