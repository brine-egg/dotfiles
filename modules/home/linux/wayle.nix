{
  pkgs,
  lib,
  ...
}:
{
  # Wayle desktop shell for compositors with no desktop GUI
  services.wayle = {
    enable = true;
  };
}
