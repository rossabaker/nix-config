{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  
  home.packages = [
    pkgs.chromium
    pkgs.google-chrome
    pkgs.networkmanagerapplet
    pkgs.slack
    pkgs.spotify
  ];

  home.file = {
    ".xmonad/xmonad.hs".source = ./xmonad/xmonad.hs;
  };

  # Broken, I think due to https://github.com/NixOS/nixos-channel-scripts/issues/9
  programs.command-not-found.enable = true;

  programs.git = {
    enable = true;
    userName = "Ross A. Baker";
    userEmail = "ross@rossabaker.com";
    aliases = {
      "st" = "status --short";
    };
    ignores = [ "*~" "\#*#" "*.elc" ".\#*" ];
  };
}
