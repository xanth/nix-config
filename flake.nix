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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      sops-nix,
      git-hooks,
      ...
    }:
    let
      hostConfig = import ./host.nix;

      alacrittyModule = import ./modules/alacritty.nix;

      dotnetModule = import ./modules/dotnet.nix;
      zoxideModule = import ./modules/zoxide.nix;
      starshipModule = import ./modules/starship.nix;
      gpgModule = import ./modules/gpg.nix;
      gitModule = import ./modules/git.nix;
      sopsModule = import ./modules/sops.nix;
      sshModule = import ./modules/ssh.nix;
      nixLanguageServerModule = import ./modules/nix-language-server.nix;

      powershellModule = import ./modules/powershell;

      homeconfig = import ./home.nix;
      darwinModule = import ./darwin;

      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style.enable = true;
        };
      };
    in
    {
      # Pre-commit checks
      checks.${system} = {
        # Formatting check
        pre-commit = pre-commit-check;

        # Build the full darwin system configuration
        # This verifies: system builds, packages exist, configuration is valid
        darwin-system = self.darwinConfigurations.${hostConfig.hostName}.system;
      };

      # Development shell with pre-commit hooks
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages =
          with pkgs;
          [
            nixfmt-rfc-style
          ]
          ++ pre-commit-check.enabledPackages;
        shellHook = ''
          ${pre-commit-check.shellHook}
        '';
      };

      darwinConfigurations.${hostConfig.hostName} = nix-darwin.lib.darwinSystem {
        modules = [
          ({ pkgs, ... }: alacrittyModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: dotnetModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: zoxideModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: starshipModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: gpgModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: gitModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: sopsModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: sshModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: nixLanguageServerModule { inherit pkgs hostConfig; })
          ({ pkgs, ... }: powershellModule { inherit pkgs hostConfig; })
          home-manager.darwinModules.home-manager
          (
            { pkgs, ... }:
            darwinModule {
              inherit
                pkgs
                hostConfig
                self
                sops-nix
                homeconfig
                ;
            }
          )
        ];
      };
    };
}
