{
  pkgs,
  ...
}:
{
  # Yazi file manager
  programs.yazi = {
    enable = true;
    plugins = {
      archivemount = pkgs.fetchFromGitHub {
        owner = "brine-egg";
        repo = "archivemount.yazi";
        rev = "8e09c26552e4dec4ddab274cc603d79982ec722b";
        sha256 = "sha256-uHZLITKmmGsCsCgIKRLiuI/bRMTtcVU5v3f38HPhqTs=";
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "M" ];
          run = "plugin archivemount --args=mount";
          desc = "Mount selected archive";
        }
        {
          on = [ "U" ];
          run = "plugin archivemount --args=unmount";
          desc = "Unmount and save changes to original archive";
        }
      ];
    };
  };
}
