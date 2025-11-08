# Git module - Git installation and configuration
{ pkgs, hostConfig, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];

  home-manager.users.${hostConfig.userName} = {
    programs.git = {
      enable = true;
      
      userName = "Rhys Williams";
      userEmail = "5460583+xanth@users.noreply.github.com";
    };
  };
}

