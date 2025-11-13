let
  cpuArchitecture = "aarch64";
  systemOperatingSystem = "darwin";
  systemUser = "rhys";
in
{
  # Host-specific configuration
  hostName = "${systemUser}-lap-osx";
  userName = systemUser;
  userUid = 501;
  homeDirectory = "/Users/${systemUser}";
  systemArchitecture = "${cpuArchitecture}-${systemOperatingSystem}";
}
