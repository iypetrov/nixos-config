{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    fzf
    jq
    yq
    tree
    watch
  ];

  # Required by Home Manager. Keep at your first install's release.
  home.stateVersion = "26.05";
}
