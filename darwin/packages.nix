{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    (python3.withPackages (
      ps: with ps; [
        pip
      ]
    ))

    # cli tools
    jq
    fzf
    ripgrep
    bat
    ast-grep
    direnv
    podman
    cursor-cli
    nixfmt-rfc-style
    pre-commit

    vscode

    fira-code
  ];
}
