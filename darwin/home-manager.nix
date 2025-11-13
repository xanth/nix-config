{
  hostConfig,
  sops-nix,
  homeconfig,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.verbose = true;
  home-manager.sharedModules = [
    sops-nix.homeManagerModules.sops
  ];
  home-manager.users.${hostConfig.userName} = homeconfig;
}
