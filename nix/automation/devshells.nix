{
  inputs,
  cell,
}: let
  inherit (inputs) nickel nixpkgs std utils;
  inherit (inputs.cells.packer.packages) packerWithPlugins packerPluginLXD;
  inherit (inputs.utils) nu tasks;
  l = nixpkgs.lib // builtins;

  # Convert tasks into devshell commands
  taskCommands = l.mapAttrsToList (_: task: tasks.lib.mkTaskCommand {inherit task;}) cell.tasks;

  # Match the version of the cluster
  kubectl = nixpkgs.kubectl.overrideAttrs (oldAttrs: rec {
    pname = "kubectl";
    version = "1.24.0";
    src = nixpkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v1.24.0";
      sha256 = "sha256-B5xA5StldfjK3R5PBWM/WI7j8p5RDmgJYuOwPf1J0Ro=";
    };
  });
in
  l.mapAttrs (_: std.lib.dev.mkShell) {
    default = {...}: {
      name = "kiada devshell";
      imports = [
        (utils.devshell.profiles.core {})
        (utils.devshell.profiles.format {})
      ];
      packages = with nixpkgs; [
        jsonnet
        jsonnet-bundler
        kubernetes-helm-wrapped
        k2tf
        kind
        kubectl
        openssl
        postgresql
        tanka
      ];
      commands = [] ++ taskCommands;
    };
  }
