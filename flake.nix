{
  description = "Yahya's Quickshell desktop shell";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
  in
  {
    # Dev shell — nix develop
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        quickshell
        # qt6.full
        cage
        playerctl
        awww          # was swww, renamed
        brightnessctl
        # libsForQt5.qt5.qtwayland
        qt6.qtwayland
      ];

      shellHook = ''
        export QT_QPA_PLATFORM=wayland
        export QML_IMPORT_PATH=${pkgs.quickshell}/lib/qt-6/qml
        echo "Quickshell dev environment ready"
        echo "Run: quickshell -c ./"
      '';
    };

    # Home manager module — consumed by Nix-Config later
    homeManagerModules.default = import ./module.nix;
  };
}
