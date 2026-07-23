{ pkgs, inputs, ... }:
let
  noctalia-unwrapped = inputs.noctalia.packages.${pkgs.system}.default;
in
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    package = (pkgs.symlinkJoin {
      name = "noctalia-wrapped";
      paths = [ noctalia-unwrapped ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/noctalia \
          --prefix LD_LIBRARY_PATH : /usr/lib64
      '';
    }).overrideAttrs {
      meta = noctalia-unwrapped.meta or { };
    };
  };
}
