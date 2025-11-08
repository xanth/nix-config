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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, sops-nix }:
  let
    hostConfig = import ./host.nix;
    dockModule = import ./modules/system-dock.nix;
    homebrewModule = import ./modules/system-homebrew.nix;
    systemPreferencesModule = import ./modules/system-preferences.nix;
    
    alacrittyModule = import ./modules/alacritty.nix;
    
    dotnetModule = import ./modules/dotnet.nix;
    zoxideModule = import ./modules/zoxide.nix;
    starshipModule = import ./modules/starship.nix;
    gpgModule = import ./modules/gpg.nix;
    gitModule = import ./modules/git.nix;
    sopsModule = import ./modules/sops.nix;
    nixLanguageServerModule = import ./modules/nix-language-server.nix;
    
    powershellModule = import ./modules/powershell.nix;
    
    homeconfig = {pkgs, ...}: {
      # this is internal compatibility configuration 
      # for home-manager, don't change this!
      home.stateVersion = "25.05";
      # Let home-manager install and manage itself.
      programs.home-manager.enable = true;

      home.packages = with pkgs; [
      ];

      # Enable font management
      fonts.fontconfig.enable = true;

      home.sessionVariables = {
          EDITOR = "vscode";
      };
    };
  in
  {
    darwinConfigurations.${hostConfig.hostName} = nix-darwin.lib.darwinSystem {
      modules = [
        ({ pkgs, ... }: homebrewModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: systemPreferencesModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: dockModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: alacrittyModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: dotnetModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: zoxideModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: starshipModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: gpgModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: gitModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: sopsModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: nixLanguageServerModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: powershellModule { inherit pkgs hostConfig; })
        ({ pkgs, ... }: {
          # Nixpkgs configuration
          nixpkgs = {
            config.allowUnfree = true;
            hostPlatform = "aarch64-darwin";
          };

          users.knownUsers = [
            hostConfig.userName
          ];

          environment.systemPackages = with pkgs; [
            vim

            # cli tools
            fzf
            ripgrep
            bat
            ast-grep
            direnv
            podman
            
            vscode

            fira-code
          ];

          # System configuration
          system = {
            # Set Git commit hash for darwin-version
            configurationRevision = self.rev or self.dirtyRev or null;
            # Used for backwards compatibility, please read the changelog before changing
            # $ darwin-rebuild changelog
            stateVersion = 6;
            primaryUser = hostConfig.userName;
          };

          # Nix configuration
          nix.settings.experimental-features = "nix-command flakes";

          # Declare the user that will be running `nix-darwin`.
          users.users.${hostConfig.userName} = {
             name = hostConfig.userName;
             home = hostConfig.homeDirectory;
             uid = hostConfig.userUid;
             # Workaround for alacritty terminfo issue
             # https://github.com/nix-darwin/nix-darwin/issues/1493
             shell = pkgs.powershell;
          };

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true;
          
          # Enabled TouchID for sudo
          security.pam.services.sudo_local.touchIdAuth = true;
        })
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.sharedModules = [
            sops-nix.homeManagerModules.sops
          ];
          home-manager.users.${hostConfig.userName} = homeconfig;
        }
      ];
    };
  };
}
