{
  pkgs,
  hostConfig,
  self,
  sops-nix,
  homeconfig,
  ...
}:
{
  imports = [
    ./nixpkgs.nix
    ./packages.nix
    ({ ... }: import ./system.nix { inherit hostConfig self; })
    ({ ... }: import ./users.nix { inherit pkgs hostConfig; })
    ({ ... }: import ./home-manager.nix { inherit hostConfig sops-nix homeconfig; })
    ({ ... }: import ./system-dock.nix { inherit pkgs hostConfig; })
    ({ ... }: import ./system-homebrew.nix { inherit pkgs hostConfig; })
    ({ ... }: import ./system-preferences.nix { inherit pkgs hostConfig; })
  ];
}
