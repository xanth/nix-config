# Alacritty terminal configuration
{ pkgs, ... }:
{
  # Install alacritty package
  environment.systemPackages = with pkgs; [
    alacritty
  ];

  # Create alacritty configuration directory and files
  environment.etc."alacritty/alacritty.toml".text = ''
    # Alacritty configuration
    [window]
    opacity = 0.95
    dynamic_padding = true
    decorations = "buttonless"
    startup_mode = "Windowed"

    [window.padding]
    x = 10
    y = 10

    [font]
    size = 14.0

    [font.normal]
    family = "SF Mono"
    style = "Regular"

    [font.bold]
    family = "SF Mono"
    style = "Bold"

    [font.italic]
    family = "SF Mono"
    style = "Italic"

    [colors.primary]
    background = "#1e1e2e"
    foreground = "#cdd6f4"

    [colors.cursor]
    text = "#1e1e2e"
    cursor = "#f5e0dc"

    [colors.normal]
    black = "#45475a"
    red = "#f38ba8"
    green = "#a6e3a1"
    yellow = "#f9e2af"
    blue = "#89b4fa"
    magenta = "#f5c2e7"
    cyan = "#94e2d5"
    white = "#bac2de"

    [colors.bright]
    black = "#585b70"
    red = "#f38ba8"
    green = "#a6e3a1"
    yellow = "#f9e2af"
    blue = "#89b4fa"
    magenta = "#f5c2e7"
    cyan = "#94e2d5"
    white = "#a6adc8"

    [shell]
    program = "${pkgs.powershell}/bin/pwsh"
    args = []

    [env]
    TERM = "alacritty"
  '';
}
