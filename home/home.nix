{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
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
    homeDirectory = if pkgs.stdenv.isLinux then "/home/brine" else "/Users/brine";
  };

  # Enable font rendering (Linux only; macOS handles this natively)
  fonts.fontconfig.enable = pkgs.stdenv.isLinux;

  # Disable Home Manager news
  news.display = "silent";

  # Essential programs
  programs.home-manager.enable = true;

  # Auto-start systemd user services on switch (Linux only)
  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux "sd-switch";

  home.stateVersion = "24.05";
}
