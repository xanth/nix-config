# Alacritty terminal configuration
{ pkgs, hostConfig, ... }:
{
  environment.systemPackages = with pkgs; [
    alacritty
  ];

  home-manager.users.${hostConfig.userName} = {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 1;
          dynamic_padding = true;
          startup_mode = "Windowed";
          padding = {
            x = 10;
            y = 10;
          };
        };

        font = {
          size = 14.0;
          normal = {
            family = "FiraCode Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            family = "FiraCode Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "FiraCode Nerd Font Mono";
            style = "Italic";
          };
        };

        terminal = {
          shell = {
            program = "${pkgs.powershell}/bin/pwsh";
            args = [ ];
          };
        };

        env = {
          TERM = "alacritty";
          PATH = "/etc/profiles/per-user/${hostConfig.userName}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:${pkgs.powershell}/bin";
        };
      };
    };
  };
}
