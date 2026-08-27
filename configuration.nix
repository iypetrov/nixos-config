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

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "nvme" "usbhid" "sr_mod" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

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
  networking.interfaces.enp2s0.useDHCP = true;
  # We're in a NAT'd VM, so the firewall just gets in the way
  networking.firewall.enable = false;

  services.resolved.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

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
        # Make ~/.local/bin (home-manager-linked scripts) available to the X
        # session, so i3 can run them by bare name (e.g. i3_autoresize.sh).
        export PATH="$HOME/.local/bin:$PATH"
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
    shell = pkgs.zsh;
    initialPassword = "123";
  };

  # zsh is our login shell (per-user config lives in home-manager). It must be
  # enabled at the system level for it to be a valid login shell.
  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    # standard
    git
    wget
    curl
    gnumake
    killall
    xclip

    # GUI / i3 (ghostty is installed per-user via home-manager)
    rofi
  ];

  # Fonts (JetBrainsMono Nerd Font is used by ghostty and i3).
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Leave at your first install's release
  system.stateVersion = "26.05";
}
