{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  inherit (inputs.utils) nu shell tasks;
  l = nixpkgs.lib // builtins;
in {
  # Example Task
  #
  # init = tasks.lib.mkTask rec {
  #   name = "test";
  #   category = "Development";
  #   help = "Run a test";
  #   script = shell.lib.writeShellScript {
  #     inherit name;
  #     script = inputs.self + /nix/automation/tasks/test.sh;
  #     runtimeInputs = [nixpkgs.jq];
  #   };
  # };
}
