{
  description = "Various AI and ML experiments involving OpenAI and LangChain";
  # Default substituters provided by tweag-jupyter are disabled for now

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    # See: https://github.com/tweag/jupyenv/issues/571
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    jupyenv.url = "github:tweag/jupyenv";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    jupyenv,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem
    [
      flake-utils.lib.system.x86_64-linux
    ]
    (
      system: let
        pkgs = import nixpkgs {
          allowUnfree = true;
          inherit system;
        };
        jupyterlab = jupyenv.lib.${system}.mkJupyterlabNew ({...}: {
          inherit nixpkgs;
          imports = [(import ./kernels.nix)];
        });
      in {
        packages = {inherit jupyterlab;};
        packages.default = jupyterlab;
        apps.default.program = "${jupyterlab}/bin/jupyter-lab";
        apps.default.type = "app";

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            poetry
            jupyterlab
          ];
        };
      }
    );
}
