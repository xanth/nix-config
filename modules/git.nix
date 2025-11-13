# Git module - Git installation and configuration
{ pkgs, hostConfig, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];

  home-manager.users.${hostConfig.userName} = {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "Rhys Williams";
          email = "5460583+xanth@users.noreply.github.com";
        };

        # Force SSH instead of HTTPS for common git hosts
        url."git@github.com:".insteadOf = [
          "https://github.com/"
          "git://github.com/"
        ];
        url."git@gitlab.com:".insteadOf = [
          "https://gitlab.com/"
          "git://gitlab.com/"
        ];
        url."git@bitbucket.org:".insteadOf = [
          "https://bitbucket.org/"
          "git://bitbucket.org/"
        ];
      };
    };
  };
}
