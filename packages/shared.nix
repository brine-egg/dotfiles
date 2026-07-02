{
  pkgs,
  ...
}:
{
  # CLI tools and system utilities available on both platforms
  home.packages = [
    pkgs.bat
    pkgs.fastfetch
    pkgs.fzf
    pkgs.lsd
    pkgs.nerd-fonts.roboto-mono
    pkgs.nh
    pkgs.nixd
    pkgs.nixfmt
    pkgs.nixfmt-tree
    pkgs.onefetch
    pkgs.ripgrep
    pkgs.ripgrep-all
    pkgs.rustup
	pkgs.stylua
    pkgs.tmux
    pkgs.yazi
    pkgs.yt-dlp
    pkgs.zoxide
  ];
}
