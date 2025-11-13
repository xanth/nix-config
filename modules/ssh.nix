# SSH module - SSH key and configuration
{ hostConfig, ... }:
{
  home-manager.users.${hostConfig.userName} = {
    # Deploy SSH public key
    home.file.".ssh/id_ed25519.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZnNR5ZTTHSYXjJeXp3ILEgu8Ph84twQJ8rs7hLh5xF rh_ys@outlook.com
    '';

    # SSH client configuration
    home.file.".ssh/config".text = ''
      # GitHub
      Host github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        
      # GitLab
      Host gitlab.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        
      # Bitbucket
      Host bitbucket.org
        User git
        IdentityFile ~/.ssh/id_ed25519
    '';
  };
}
