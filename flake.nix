{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          pkgs,
          lib,
          ...
        }:
        let
          python = pkgs.python313.withPackages (
            ps: with ps; [
              jupyter
              polars
              matplotlib
              altair
              numpy
              pandas
              great-tables
              xlsxwriter
              fastexcel
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
              quarto
              glow
            ];
            env.QUARTO_PYTHON = lib.getExe python;
            enterShell = ''
              glow ${./README.md}
            '';
          };
        };
    };
}
