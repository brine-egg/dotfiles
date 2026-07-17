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

  # Install rtk integration plugin for Hermes on first activation only
  home.activation.rtkInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.local/state/home-manager/rtk-init-hermes" ]; then
      ${pkgs.rtk}/bin/rtk init --agent hermes
      mkdir -p "$HOME/.local/state/home-manager"
      touch "$HOME/.local/state/home-manager/rtk-init-hermes"
    fi
  '';

  home.stateVersion = "24.05";
}
