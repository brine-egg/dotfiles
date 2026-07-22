{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.roboto-mono ];
}
