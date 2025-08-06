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
            tasks = {
              "bash:build-kernel" = {
                exec = "${lib.getExe python} -m ipykernel install --user --name course";
                after = [ "devenv:enterShell" ];
              };
            };
            env.QUARTO_PYTHON = lib.getExe python;
            enterShell = ''
              glow ${./README.md}
            '';
          };
        };
    };
}
