{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-flake.url = "github:juspay/rust-flake";
  };

  outputs =
    inputs@{ flake-parts, rust-flake, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        rust-flake.flakeModules.default
        rust-flake.flakeModules.nixpkgs
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          lib,
          ...
        }:
        {
          packages.bins = self'.packages.thumbs;
          packages.default = pkgs.tmuxPlugins.mkTmuxPlugin rec {
            src = ./.;
            name = "tmux-thumbs";
            pluginName = "tmux-thumbs";
            rtpFilePath = "tmux-thumbs.tmux";
            runtimeInputs = [ self'.packages.bins ];
            postInstall = ''
              substituteInPlace $out/share/tmux-plugins/tmux-thumbs/tmux-thumbs.sh \
                --replace @tmuxThumbsDir@ ${lib.getBin self'.packages.bins}/bin
            '';
          };
          devShells.default = self'.devShells.rust;
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
          # packages.default = pkgs.tmux.mkTmuxPlugin {
          #
          # };
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
