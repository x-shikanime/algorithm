{
  inputs = {
    automata.url = "github:shikanime-studio/automata";
    devenv.url = "github:cachix/devenv";
    devlib.url = "github:shikanime-studio/devlib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
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
          config,
          lib,
          pkgs,
          ...
        }:
        {
          devenv = {
            modules = [
              devlib.devenvModules.docs
              devlib.devenvModules.formats
              devlib.devenvModules.nix
              devlib.devenvModules.shell
              devlib.devenvModules.shikanime
            ];
            shells = {
              default = {
                imports = [
                  devlib.devenvModules.github
                ];
                github.workflows.test = with config.devenv.shells.default.github.actions; {
                  enable = true;
                  settings = {
                    name = "Test";
                    on = {
                      push.branches = [ "main" ];
                      pull_request.branches = [
                        "main"
                        "gh/*/*/base"
                      ];
                    };
                    jobs.test = {
                      "runs-on" = "ubuntu-latest";
                      steps = with config.devenv.shells.default.github.lib; [
                        create-github-app-token
                        checkout
                        setup-nix
                        {
                          run = mkWorkflowRun [
                            "nix"
                            "develop"
                            "--accept-flake-config"
                            "--no-pure-eval"
                            ".#${mkWorkflowRef "matrix.package"}"
                            "--command"
                            "devenv"
                            "test"
                          ];
                          "working-directory" = mkWorkflowRef "matrix.package";
                        }
                      ];
                      strategy.matrix.package = [
                        "algorithm-cc"
                        "algorithm-elixir"
                        "algorithm-javascript"
                        "algorithm-ocaml"
                        "algorithm-python"
                      ];
                    };
                  };
                };
              };
              algorithm-cc = {
                enterTest = ''
                  ${lib.getExe pkgs.cmake} \
                    --preset unknown-unknown-gnu \
                    -B out/build/unknown-unknown-gnu
                  ${lib.getExe pkgs.cmake} \
                    --build out/build/unknown-unknown-gnu
                  ${pkgs.cmake}/bin/ctest \
                    --preset unknown-unknown-gnu \
                    --test-dir out/build/unknown-unknown-gnu
                '';
                gitignore.templates = [
                  "tt:c"
                  "tt:c++"
                ];
                packages = [
                  pkgs.ninja
                  pkgs.gcc
                  pkgs.openssl
                  pkgs.binutils
                  pkgs.cmake
                  pkgs.gtest
                ];
                treefmt.config.programs = {
                  clang-format.enable = true;
                  cmake-format.enable = true;
                };
              };

              algorithm-elixir = {
                imports = [
                  devlib.devenvModules.elixir
                ];
                enterTest = ''
                  ${pkgs.elixir}/bin/mix deps.get
                  ${pkgs.elixir}/bin/mix test
                '';
              };
              algorithm-javascript = {
                imports = [
                  devlib.devenvModules.javascript
                ];
                enterTest = ''
                  ${pkgs.nodejs}/bin/npm ci
                  ${pkgs.nodejs}/bin/npm run test
                '';
              };
              algorithm-ocaml = {
                imports = [
                  devlib.devenvModules.ocaml
                ];
                enterTest = ''
                  ${lib.getExe pkgs.dune_3} runtest
                '';
              };
              algorithm-python = {
                imports = [
                  devlib.devenvModules.python
                ];
                enterTest = ''
                  ${lib.getExe pkgs.uv} run pytest
                '';
              };
            };
          };
        };
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
