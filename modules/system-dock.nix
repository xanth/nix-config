# Dock module - macOS dock appearance and behavior settings
{ pkgs, hostConfig, ... }:
{
  system.defaults.dock = {
    autohide = true; # auto show and hide dock
    autohide-delay = 0.0; # remove delay for showing dock
    autohide-time-modifier = 0.2; # how fast is the dock showing animation
    expose-animation-duration = 0.2; # duration of expose animation
    tilesize = 30; # size of dock icons in pixels
    launchanim = true; # animate icons when launching an app
    showhidden = true; # show hidden applications in dock
    show-recents = true; # show recently used applications
    show-process-indicators = true; # show dots under running applications
    orientation = "bottom"; # dock position on screen
    mru-spaces = false; # disable most recently used spaces reordering
    
    # Dock app ordering and layout
    persistent-apps = [
      "/Applications/Safari.app"
      "/Applications/Yubico Authenticator.app"
      "/Applications/Nix Apps/Rider.app"
      "/Applications/Nix Apps/Visual Studio Code.app"
      "/Applications/Nix Apps/Alacritty.app"
      "/Applications/Podman Desktop.app"
      "/System/Applications/Messages.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/FaceTime.app"
      "/System/Applications/Contacts.app"
      "/Users/${hostConfig.userName}/Applications/YouTube Music.app"
      "/Users/${hostConfig.userName}/Applications/NetBank.app"
      "/System/Applications/Launchpad.app"
    ];
  };
}
