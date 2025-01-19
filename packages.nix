{
  pkgs,
  ...
}: {
  
  # Install user level packages with Nix
  home.packages = with pkgs; [
    archivemount
    bat
    dipc
    fastfetch
    fzf
    lsd
    nerd-fonts.roboto-mono
    nh
    onefetch
    ripgrep
    ripgrep-all
    rustup
    spicetify-cli
    trashy
    tmux
    w3m
    yazi
    ytfzf
    yt-dlp
    zoxide
  ];

}
