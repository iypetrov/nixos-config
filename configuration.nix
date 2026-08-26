{ config, pkgs, ... }:

{
  #---------------------------------------------------------------------
  # Boot
  #---------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Some VM firmware only supports this being 0, else "error switching
  # console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Run x86_64 binaries via qemu.
  boot.binfmt.emulatedSystems = ["x86_64-linux"];

  #---------------------------------------------------------------------
  # Nix
  #---------------------------------------------------------------------

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  #---------------------------------------------------------------------
  # Networking
  #---------------------------------------------------------------------

  networking.hostName = "vm-aarch64";
  networking.useDHCP = false;
  # TODO: confirm the interface name inside the VM with `ip link`
  networking.interfaces.ens160.useDHCP = true;
  # We're in a NAT'd VM, so the firewall just gets in the way
  networking.firewall.enable = false;

  # Enable the OpenSSH daemon
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";

  #---------------------------------------------------------------------
  # VMware Fusion
  #---------------------------------------------------------------------

  # VMware guest tools (clipboard, resize, etc.)
  virtualisation.vmware.guest.enable = true;
  # Share the host filesystem at /host
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [ "umask=22" "uid=1000" "gid=1000" "allow_other" "auto_unmount" "defaults" ];
  };

  #---------------------------------------------------------------------
  # Desktop
  #---------------------------------------------------------------------

  programs.firefox.enable = true;

  time.timeZone = "Europe/Sofia";
  i18n.defaultLocale = "en_US.UTF-8";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    dpi = 220;
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;

    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xset}/bin/xset r rate 200 40
      '';
    };
  };

  services.displayManager.defaultSession = "none+i3";

  #---------------------------------------------------------------------
  # Users
  #---------------------------------------------------------------------

  users.users.iypetrov = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "123";
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    # dev-setup
    vim
    tmux

    # standard
    git
    wget
    curl
    gnumake
    killall
    xclip
  ];

  # Leave at your first install's release
  system.stateVersion = "26.05";
}
