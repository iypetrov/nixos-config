{ config, pkgs, ... }:

{
  #-----------------------------------------------------------------------------
  # Boot                                                                       #
  #-----------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  # Some VM firmware only supports this being 0.
  # If not set, it displayes "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  # Be careful updating this.
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

  #-----------------------------------------------------------------------------
  # Nix                                                                        #
  #-----------------------------------------------------------------------------

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

  #-----------------------------------------------------------------------------
  # Networking                                                                 #
  #-----------------------------------------------------------------------------

  networking.hostName = "vm-aarch64";
  networking.useDHCP = false;
  # TODO: Confirm the interface name inside the VM with `ip link`.
  networking.interfaces.enp2s0.useDHCP = true;
  # For the development VM, a firewall is not needed.
  networking.firewall.enable = false;
  services.resolved.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.hosts = {
    "127.0.0.1" = [
      # Begin of Gardener local setup section
      "registry.local.gardener.cloud"
      # oidc-apps-controller provider local setup
      "dexidp"
      "plutono-garden.ingress.local.seed.local.gardener.cloud"
      "prometheus-seed-garden-0.ingress.local.seed.local.gardener.cloud"
      "prometheus-aggregate-garden-0.ingress.local.seed.local.gardener.cloud"
      "prometheus-cache-garden-0.ingress.local.seed.local.gardener.cloud"
      "vlsingle-victoria-logs-garden.ingress.local.seed.local.gardener.cloud"
      "prometheus-shoot-shoot--local--local-0.ingress.local.seed.local.gardener.cloud"
      "plutono-shoot--local--local.ingress.local.seed.local.gardener.cloud"
      "vlsingle-victoria-logs-shoot--local--local.ingress.local.seed.local.gardener.cloud"
    ];
    "::1" = [
      # Begin of Gardener local setup section
      "registry.local.gardener.cloud"
    ];
  };
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";

  virtualisation.docker.enable = true;

  #-----------------------------------------------------------------------------
  # VMware Fusion                                                              #
  #-----------------------------------------------------------------------------

  # VMware guest tools (clipboard, resize, etc.).
  virtualisation.vmware.guest.enable = true;
  # Share the host filesystem at `/host`.
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };

  #-----------------------------------------------------------------------------
  # Desktop                                                                    #
  #-----------------------------------------------------------------------------

  programs.firefox.enable = true;
  time.timeZone = "Europe/Sofia";
  i18n.defaultLocale = "en_US.UTF-8";
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
  services.displayManager.defaultSession = "none+i3";
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
        export PATH="$HOME/.local/bin:$PATH"
      '';
    };
  };

  #-----------------------------------------------------------------------------
  # Users                                                                      #
  #-----------------------------------------------------------------------------

  users.users.iypetrov = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    initialPassword = "123";
  };
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    gnumake
    killall
    xclip
    iproute2
    openssl
  ];
  # Leave at your first install's release.
  system.stateVersion = "26.05";
}
