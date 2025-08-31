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
    dockConfig = import ./dock.nix { inherit hostConfig; };
    homebrew-config = import ./homebrew.nix;
    user-preferences = import ./user-preferences.nix;
    configuration = { pkgs, ... }: homebrew-config // user-preferences // {
      # Nixpkgs configuration
      nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = "aarch64-darwin";
      };

      users.knownUsers = [
        hostConfig.userName
      ];

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

      # System configuration
      system = {
        # Set Git commit hash for darwin-version
        configurationRevision = self.rev or self.dirtyRev or null;
        # Used for backwards compatibility, please read the changelog before changing
        # $ darwin-rebuild changelog
        stateVersion = 6;
        primaryUser = hostConfig.userName;
      } // dockConfig;

      # Nix configuration
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Declare the user that will be running `nix-darwin`.
      users.users.${hostConfig.userName} = {
         name = hostConfig.userName;
         home = hostConfig.homeDirectory;
         uid = hostConfig.userUid;
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
