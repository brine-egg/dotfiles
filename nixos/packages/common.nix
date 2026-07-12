{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.git
    pkgs.nh
    pkgs.zsh
  ];
}
