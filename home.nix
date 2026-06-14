{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [ ];

  # Allow unfree packages
  nixpkgs = {
    overlays = [ ];

    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # User identity
  home = {
    username = "brine";
    homeDirectory = "/home/brine";
  };

  # Enable font rendering
  fonts.fontconfig.enable = true;

  # Essential programs
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Auto-start systemd user services on switch
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}
