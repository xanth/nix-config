{
  description = "Rhys nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    hostConfig = import ./host.nix;
    configuration = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      system.primaryUser = hostConfig.userName;
      users.knownUsers = [
        hostConfig.userName
      ];
      users.users.${hostConfig.userName}.uid = hostConfig.userUid;

      environment.systemPackages =
        [ pkgs.vim 
          
          pkgs.alacritty
          pkgs.powershell
          pkgs.zoxide
          pkgs.fzf
          pkgs.ripgrep
          pkgs.bat
          pkgs.ast-grep
          pkgs.starship
          pkgs.direnv

          pkgs.vscode
          pkgs.jetbrains.rider
        ];

      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
        global.autoUpdate = true;

        brews = [
        ];
        taps = [
        ];
        casks = [
          "github"
          "AlDente"
        ];
        masApps = {
          "Bitwarden" = 1352778147;
          "Yubico Authenticator" = 1497506650;
          "Kagi for Safari" = 1622835804;
        };
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Declare the user that will be running `nix-darwin`.
      users.users.${hostConfig.userName} = {
         name = hostConfig.userName;
         home = hostConfig.homeDirectory;
      };

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;
      
      # Enabled TouchID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;
    };
    homeconfig = {pkgs, ...}: {
      # this is internal compatibility configuration 
      # for home-manager, don't change this!
      home.stateVersion = "25.05";
      # Let home-manager install and manage itself.
      programs.home-manager.enable = true;

      home.packages = with pkgs; [
      ];

      home.sessionVariables = {
          EDITOR = "vscode";
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations.${hostConfig.hostName} = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager  {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.${hostConfig.userName} = homeconfig;
        }
      ];
    };
  };
}
