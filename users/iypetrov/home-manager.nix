{ pkgs, lib, ... }:

let
  shellAliases = {
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gdiff = "git diff";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";

    # Two decades of muscle memory: keep pbcopy/pbpaste working on Linux.
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  };

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

  # Every file in ./scripts is linked into ~/.local/bin as an executable, so a
  # new script is picked up just by dropping it in that directory. ~/.local/bin
  # is added to PATH below via home.sessionPath.
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

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # User-facing CLI tools. Project-specific tooling should come from
  # per-project flakes + direnv rather than living here.
  home.packages = with pkgs; [
    # common
    bat
    fzf
    jq
    yq
    tree
    watch
    silver-searcher-ng

    # light tooling ported from the macOS shell
    terraform
    kubectl
    docker-compose
    lazygit                # tmux `prefix g`
    k9s                    # tmux `prefix 9`
    gh                     # used by tmux-sessionizer.sh (gh repo sync)

    # LSP servers used by vim-lsp (see vimrc)
    gopls
    typescript-language-server
    clang-tools                        # provides clangd
    python3Packages.jedi-language-server
    terraform-ls

    # GUI terminal (config lives in ./ghostty.linux, linked below)
    ghostty
    rofi

    # i3 support tools referenced by ./i3
    dex                    # XDG autostart (dex --autostart)
    xss-lock               # lock on suspend
    i3lock                 # screen locker
    networkmanagerapplet   # nm-applet tray
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
    PAGER = "less -FirSwX";
  };

  # Custom scripts (from ./scripts) live in ~/.local/bin; put it on PATH.
  home.sessionPath = [ "$HOME/.local/bin" ];

  # i3 is enabled as a system-level window manager in configuration.nix; its
  # per-user config is a plain dotfile we link into place here.
  xdg.configFile."i3/config".source = ./i3;

  # ghostty terminal config (raw file, mitchellh-style).
  xdg.configFile."ghostty/config".source = ./ghostty.linux;

  # Powerlevel10k prompt config (~/.p10k.zsh) plus every script in ./scripts,
  # linked into ~/.local/bin as executables (see binScripts in the let block).
  home.file = {
    ".p10k.zsh".source = ./p10k.zsh;
  } // binScripts;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = shellAliases;
    # powerlevel10k prompt theme, sourced before our zshrc so instant-prompt works.
    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];
    # initContent (not initExtra) — renamed in home-manager 25.05+.
    initContent = builtins.readFile ./zshrc;
  };

  # Shell history search. --disable-up-arrow keeps the up key as plain history.
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    # Plugins are managed by Nix (not vim-plug); the vim-plug bootstrap has been
    # removed from ./vimrc. zazen and vim-markdown-preview aren't in nixpkgs so
    # they're built from upstream in the `let` block above.
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

  programs.git = {
    enable = true;
    settings = {
      user.name = "Ilia Petrov";
      user.email = "CHANGEME@example.com"; # TODO: set your real email
      init.defaultBranch = "main";
      push.default = "tracking";
      color.ui = true;
      alias = {
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;

  # Runs an ssh-agent for the user session, replacing the manual `eval
  # $(ssh-agent)` block from the macOS zshrc. Add keys with `ssh-add` (your
  # key files must be copied into ~/.ssh on the VM first).
  services.ssh-agent.enable = true;
}
