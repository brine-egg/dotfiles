{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.archivemount
    pkgs.bat
    pkgs.dipc
    pkgs.fastfetch
    pkgs.fzf
    pkgs.lsd
    pkgs.nerd-fonts.roboto-mono
    pkgs.nh
    pkgs.onefetch
    pkgs.ripgrep
    pkgs.ripgrep-all
    pkgs.rustup
    pkgs.spicetify-cli
    pkgs.trashy
    pkgs.tmux
    pkgs.w3m
    pkgs.yazi
    pkgs.ytfzf
    pkgs.yt-dlp
    pkgs.zoxide
  ];
}
