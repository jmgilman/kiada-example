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
in
  l.mapAttrs (_: std.lib.dev.mkShell) {
    default = {...}: {
      name = "project devshell";
      imports = [
        (utils.devshell.profiles.core {})
        (utils.devshell.profiles.format {})
      ];
      packages = with nixpkgs; [
        # Add packages
      ];
      commands = [] ++ taskCommands;
    };
  }
