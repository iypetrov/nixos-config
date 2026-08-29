{ pkgs, lib, ... }:

let
  # Vim plugins not packaged in nixpkgs, built straight from upstream.
  zazen = pkgs.vimUtils.buildVimPlugin {
    name = "zazen";
    src = pkgs.fetchFromGitHub {
      owner = "zaki";
      repo = "zazen";
      rev = "5cd00e929df650d66abcb910602e5ebfa50c914a";
      hash = "sha256-wFthuVpD0tZdh76xmDs1cNKzQVtOSg69X4nPwp0Xt+U=";
    };
  };
  vim-markdown-preview = pkgs.vimUtils.buildVimPlugin {
    name = "vim-markdown-preview";
    src = pkgs.fetchFromGitHub {
      owner = "tjhop";
      repo = "vim-markdown-preview";
      rev = "192f94c058a55a0bf1d56f351dd859661bef0bc6";
      hash = "sha256-qusR7JrirFRKuDtFo5RXyBS9fw9kbKMB8ZSInkkESCY=";
    };
  };

  # Every file in ./scripts is linked into ~/.local/bin as an executable.
  scriptFiles = builtins.attrNames (builtins.readDir ./scripts);
  binScripts = builtins.listToAttrs (map (name: {
    name = ".local/bin/${name}";
    value = {
      source = ./scripts/${name};
      executable = true;
    };
  }) scriptFiles);
in {
  # Home Manager state version. Leave at your first-install release.
  home.stateVersion = "26.05";
  # Make ~/.local/bin (where ./scripts are linked) available on PATH.
  home.sessionPath = [ "$HOME/.local/bin" ];
  xdg.enable = true;
  home.packages = with pkgs; [
    # Common utils.
    bat
    fzf
    jq
    yq
    tree
    watch
    silver-searcher
    newt

    # Specific for me.
    terraform
    docker-compose
    lazygit
    gh

    # Kubernetes toolchain.
    kubectl
    kubectx          # kubectx / kubens context+namespace switcher
    kustomize
    kubernetes-helm  # `helm`
    fluxcd           # `flux`
    k9s
    kubebuilder
    kind

    # LSP servers
    gopls
    typescript-language-server
    clang-tools
    python3Packages.jedi-language-server
    terraform-ls

    # GUI terminal.
    ghostty
    rofi

    # i3 tools.
    dex                    # XDG autostart (dex --autostart)
    xss-lock               # lock on suspend
    i3lock                 # screen locker
    networkmanagerapplet   # nm-applet tray
  ];

  #-----------------------------------------------------------------------------
  # Programs                                                                   #
  #-----------------------------------------------------------------------------

  # i3 is enabled as a system-level window manager in configuration.nix; its
  # per-user config is a plain dotfile we link into place here.
  xdg.configFile."i3/config".source = ./i3;
  # Ghostty terminal config.
  xdg.configFile."ghostty/config".source = ./ghostty.linux;
  # Powerlevel10k prompt config.
  home.file = {
    ".p10k.zsh".source = ./p10k.zsh;
  } // binScripts;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    # powerlevel10k prompt theme, sourced before our zshrc so instant-prompt works.
    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];
    initContent = builtins.readFile ./zshrc;
  };
  # Shell history search.
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };
  programs.vim = {
    enable = true;
    defaultEditor = true;
    # Vim plugins are managed by Nix, not by Vim plugin manager, like vim-plug.
    plugins = (with pkgs.vimPlugins; [
      lightline-vim
      vim-gitgutter
      ctrlp-vim
      fzf-wrapper      # junegunn/fzf
      fzf-vim          # junegunn/fzf.vim
      undotree
      vim-lsp
      vim-lsp-settings
      asyncomplete-vim
      asyncomplete-lsp-vim
      vim-go
    ]) ++ [
      zazen
      vim-markdown-preview
    ];
    extraConfig = builtins.readFile ./vimrc;
  };
  programs.tmux = {
    enable = true;
    prefix = "C-j";
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;
    terminal = "xterm-256color";
    plugins = [ pkgs.tmuxPlugins.sensible ];
    extraConfig = builtins.readFile ./tmux.conf;
  };
  programs.i3status = {
    enable = true;
    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };
    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fzf.enable = true;
  # Runs an ssh-agent for the user session. Add keys with `ssh-add` (must be
  # copied into ~/.ssh on the VM first).
  services.ssh-agent.enable = true;
}
