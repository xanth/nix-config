# Dock module - macOS dock appearance and behavior settings
{ ... }:
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
  };
}
