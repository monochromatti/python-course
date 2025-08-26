{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utgard.url = "github:fornybar/utgard";
  };
  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          system,
          lib,
          ...
        }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ inputs.utgard.overlays.jupyterlab-extensions ];
          };
          python = pkgs.python313.withPackages (
            ps: with ps; [
              jupyter
              jupytext
              altair
              polars
              great-tables
              fastexcel
              xlsxwriter
              jupyterlab-extensions.quarto
            ]
          );
        in
        {
          devenv.shells.default = {
            languages.python = {
              enable = true;
              package = python;
            };
            packages = with pkgs; [
              glow
              quarto
              jupyter
            ];
            env.QUARTO_PYTHON = lib.getExe python;
            env.VIRTUAL_ENV = python;
            enterShell = ''
              glow ${./README.md}
            '';
          };
        };
    };
}
