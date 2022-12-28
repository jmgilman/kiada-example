{
  inputs.nixpkgs.url = "nixpkgs";

  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";

  inputs.utils.url = "github:jmgilman/nix-utils";
  inputs.utils.inputs.nixpkgs.follows = "nixpkgs";
  inputs.utils.inputs.std.follows = "std";

  outputs = {std, ...} @ inputs:
    std.growOn
    {
      inherit inputs;
      cellsFrom = ./nix;

      cellBlocks = [
        (std.blockTypes.devshells "devshells")
        (std.blockTypes.nixago "configs")
        (std.blockTypes.runnables "tasks")
      ];
    }
    {
      devShells = std.harvest inputs.self ["automation" "devshells"];
    };
}
