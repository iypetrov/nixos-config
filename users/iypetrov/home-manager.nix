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
    bat
    fzf
    jq
    yq
    tree
    watch
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

  # i3 is enabled as a system-level window manager in configuration.nix; its
  # per-user config is a plain dotfile we link into place here.
  xdg.configFile."i3/config".source = ./i3;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = shellAliases;
    # initContent (not initExtra) — renamed in home-manager 25.05+.
    initContent = builtins.readFile ./zshrc;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./vimrc;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    terminal = "screen-256color";
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
}
