{
  description = "cl-nix-lite wrapper with patched iterate source (workaround for expired gitlab.common-lisp.net SSL cert)";

  inputs = {
    cl-nix-lite.url = "github:hraban/cl-nix-lite/eb584721e5e799bafe0c6210a8a1a398f90e8ac0";
  };

  outputs =
    { cl-nix-lite, ... }:
    {
      overlays.default =
        final: prev:
        let
          orig = cl-nix-lite.overlays.default final prev;
        in
        orig
        // {
          lispPackagesLite = orig.lispPackagesLite.overrideScope (
            lispFinal: lispPrev:
            {
              iterate = lispPrev.iterate.overrideAttrs (_: {
                src = prev.fetchgit {
                  url = "https://github.com/lisp-mirror/iterate";
                  rev = "26cf129a03b45d6dd7d2a659622244d20a9ab6f5";
                  hash = "sha256-1qkaZbghNAHj7/FsuJXNqREjJdsGXEDu4WHMclz7oWU=";
                  fetchSubmodules = false;
                };
              });
            }
          );
        };
    };
}