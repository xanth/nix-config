{ pkgs, hostConfig, ... }:
{
  users.knownUsers = [
    hostConfig.userName
  ];

  # Declare the user that will be running `nix-darwin`.
  users.users.${hostConfig.userName} = {
    name = hostConfig.userName;
    home = hostConfig.homeDirectory;
    uid = hostConfig.userUid;
    # Workaround for alacritty terminfo issue
    # https://github.com/nix-darwin/nix-darwin/issues/1493
    shell = pkgs.powershell;
  };
}
