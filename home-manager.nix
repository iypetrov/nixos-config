{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    fzf
    jq
    tree
    watch
  ];
}
