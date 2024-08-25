{
  pkgs,
  ...
}: {
  
  # Install user level packages with Nix
  home.packages = with pkgs; [
    bat
    dipc
    fastfetch
    fzf
    lsd
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
