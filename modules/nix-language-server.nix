{ pkgs, hostConfig, ... }:

{
  # Install nil (Nix language server) and nixfmt formatter
  home-manager.users.${hostConfig.userName} = {
    home.packages = with pkgs; [
      nil # Nix language server
      nixfmt-rfc-style # Nix code formatter
    ];
  };
}
