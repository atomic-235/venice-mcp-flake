{
  description = "Venice AI MCP server, packaged as a self-contained release bundle";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          # What consumers get: the published bundle, no compilation.
          default = pkgs.callPackage ./package.nix { };

          # What CI builds (npm tarball + deps) before bundling it.
          unbundled = pkgs.callPackage ./unbundled.nix { };

          venice-mcp-server = default;
        }
      );

      overlays.default = final: _prev: {
        venice-mcp-server = final.callPackage ./package.nix { };
      };
    };
}
