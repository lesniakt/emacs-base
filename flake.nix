{
  description = "Portable, composable Emacs configuration for Home Manager";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      home = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ self.homeManagerModules.default {
            home.username = "example";
            home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/example" else "/home/example";
            home.stateVersion = "25.05";
            programs.emacs-base = {
              enable = true;
              extraConfig = "(setq emacs-base-extension-loaded t)";
            };
          } ];
        };
    in {
      homeManagerModules.default = import ./nix/home-manager.nix;
      packages = forAllSystems (system: {
        default = (home system).config.programs.emacs.finalPackage;
        test-init = (home system).config.home.file.".emacs.d/init.el".source;
        activation = (home system).activationPackage;
      });
      checks = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          config = (home system).config;
        in {
          base = pkgs.runCommand "emacs-base-tests" {
            nativeBuildInputs = [ config.programs.emacs.finalPackage ];
            INIT = config.home.file.".emacs.d/init.el".source;
          } ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"
            emacs --batch -l ${./tests/no-network.el} -l "$INIT" \
              -l ${./tests/base-tests.el} -f ert-run-tests-batch-and-exit
            touch "$out"
          '';
        });
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
