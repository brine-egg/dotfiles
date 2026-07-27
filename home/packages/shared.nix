{
  pkgs,
  ...
}:
{
  # CLI tools and system utilities available on both platforms
  home.packages = [
    pkgs.bat
    pkgs.fzf
    pkgs.lua-language-server
    pkgs.lsd
    pkgs.manix
    (pkgs.mdformat.withPlugins (p: [
      p.mdformat-gfm
      p.mdformat-tables
    ]))
    pkgs.nerd-fonts.roboto-mono
    pkgs.nh
    pkgs.nixd
    pkgs.nixfmt
    pkgs.onefetch
    pkgs.ripgrep
    pkgs.ripgrep-all
    pkgs.rtk
    pkgs.rustup
    pkgs.stylua
    pkgs.tmux
    pkgs.tokscale
    pkgs.treefmt
    pkgs.yazi
    pkgs.yt-dlp
    pkgs.zoxide
  ];
}
