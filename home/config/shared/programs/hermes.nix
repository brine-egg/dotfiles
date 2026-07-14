{
  pkgs,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.hermes-agent = {
    enable = true;
    # The hermes-home.nix module only ships the Home-Manager module, not the
    # package. The package lives in the numtide/llm-agents.nix flake, so pull it
    # from there rather than via an overlay that would build it against our own
    # nixpkgs (and likely miss the numtide binary cache).
    package = inputs.llm-agents.packages.${system}.hermes-agent;
    settings = {
      providers = [ "openrouter" ];
      model = "deepseek/deepseek-v4-pro";
      terminal.backend = "local";
    };
  };
}
