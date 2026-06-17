{
  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };

    devlib = {
      url = "github:shikanime-studio/devlib";
      inputs = {
        devenv.follows = "devenv";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://devenv.cachix.org"
      "https://shikanime.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "shikanime.cachix.org-1:OrpjVTH6RzYf2R97IqcTWdLRejF6+XbpFNNZJxKG8Ts="
    ];
  };

  outputs =
    inputs@{
      devenv,
      devlib,
      flake-parts,
      git-hooks,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
        devlib.flakeModule
        git-hooks.flakeModule
        treefmt-nix.flakeModule
      ];
      perSystem =
        {
          lib,
          pkgs,
          ...
        }:
        with lib;
        {
          devenv = {
            modules = [
              devlib.devenvModules.nix
              devlib.devenvModules.shell
              devlib.devenvModules.shikanime
            ];
            shells.default = {
              imports = [
                devlib.devenvModules.elixir
                devlib.devenvModules.javascript
                devlib.devenvModules.ocaml
                devlib.devenvModules.python
              ];

              github.workflows.nix.enable = true;

              gitignore.templates = [
                "tt:c"
                "tt:c++"
              ];

              languages = {
                javascript.directory = "algorithm-javascript";
                python.directory = "algorithm-python";
              };

              packages = [
                pkgs.ninja
                pkgs.gcc
                pkgs.openssl
                pkgs.binutils
                pkgs.cmake
                pkgs.gtest
              ];

              tasks = {
                "algorithm:cc" = {
                  before = [ "devenv:enterTest" ];
                  exec = ''
                    ${getExe pkgs.cmake} \
                      --preset unknown-unknown-gnu \
                      -B out/build/unknown-unknown-gnu
                    ${getExe pkgs.cmake} \
                      --build out/build/unknown-unknown-gnu
                    ${pkgs.cmake}/bin/ctest \
                      --preset unknown-unknown-gnu \
                      --test-dir out/build/unknown-unknown-gnu
                  '';

                };
                "algorithm:elixir" = {
                  before = [ "devenv:enterTest" ];
                  exec = ''
                    ${pkgs.elixir}/bin/mix deps.get
                    ${pkgs.elixir}/bin/mix test
                  '';
                };

                "algorithm:javascript" = {
                  before = [ "devenv:enterTest" ];
                  exec = ''
                    ${pkgs.nodejs}/bin/npm ci
                    ${pkgs.nodejs}/bin/npm run test
                  '';
                };

                "algorithm:ocaml" = {
                  before = [ "devenv:enterTest" ];
                  exec = ''
                    ${getExe pkgs.dune_3} runtest
                  '';
                };

                "algorithm:python" = {
                  before = [ "devenv:enterTest" ];
                  exec = ''
                    ${getExe pkgs.uv} run pytest
                  '';
                };
              };

              treefmt.config.programs = {
                clang-format.enable = true;
                cmake-format.enable = true;
              };
            };
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
