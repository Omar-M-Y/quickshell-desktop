{ config, lib, pkgs, ... }:

{
  options.myDesktop = {
    enable = lib.mkEnableOption "Yahya's Quickshell desktop";
  };

  config = lib.mkIf config.myDesktop.enable {
    # Will fill in as components are built
  };
}
