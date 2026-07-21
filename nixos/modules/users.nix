{ pkgs, ... }:
{
  users.users.brine = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  programs.zsh.enable = true;
}
