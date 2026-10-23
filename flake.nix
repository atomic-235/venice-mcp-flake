{
  description = "Venice AI MCP server packaged from the official npm release";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          default = pkgs.callPackage ./package.nix { };
          venice-mcp-server = default;
        }
      );

      overlays.default = final: _prev: {
        venice-mcp-server = final.callPackage ./package.nix { };
      };
    };
}
