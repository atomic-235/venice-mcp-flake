# venice-mcp-flake

[Venice AI](https://venice.ai) MCP server (`venice-mcp-server`), installed from
the published npm tarball with the dependencies pinned by the committed
`package-lock.json`, then published as a **self-contained arx bundle**.

The package is not in nixpkgs; the bundle means consumers get a single
executable with Node and every dependency inside, no build and no binary cache.

## Packages

| Attribute | Contents |
|---|---|
| `packages.<system>.default` | the published bundle |
| `packages.<system>.venice-mcp-server` | alias of `default` |
| `packages.<system>.unbundled` | npm tarball + `npm ci` output, before bundling |

`overlays.default` provides `pkgs.venice-mcp-server`.

## Usage

```nix
{
  inputs.venice-mcp-flake.url = "github:atomic-235/venice-mcp-flake";
  inputs.venice-mcp-flake.inputs.nixpkgs.follows = "nixpkgs";
}
```

```nix
nixpkgs.overlays = [ inputs.venice-mcp-flake.overlays.default ];
# pkgs.venice-mcp-server
```

The server needs a Venice API key at runtime (`VENICE_API_KEY`); the flake only
packages the binary.

## Updates

CI runs daily at 06:00 UTC: resolve the latest npm version, refresh
`package-lock.json` and `npmDepsHash`, build, bundle, upload
`venice-mcp-linux-x86_64`, verify the flake can fetch the asset, then commit and
tag `v<version>` (force-moving `latest`).
