{
  lib,
  stdenv,
  curl,
  cacert,
}:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
  system = stdenv.hostPlatform.system;

  asset =
    {
      x86_64-linux = "venice-mcp-linux-x86_64";
    }
    .${system} or (throw "venice-mcp-server: no release bundle for ${system}");

  url = "https://github.com/atomic-235/venice-mcp-flake/releases/download/v${data.version}/${asset}";

  # Self-extracting bundle (arx) with node, node_modules and dist, so it runs
  # without /nix/store. Nix refuses fixed-output paths whose contents mention
  # store paths, hence the waiver.
  bundle = stdenv.mkDerivation {
    name = "venice-mcp-${data.version}-${asset}";

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = data.assets.${system};
    unsafeDiscardReferences = true;

    nativeBuildInputs = [ curl ];

    buildCommand = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      curl -fsSL --cacert "$SSL_CERT_FILE" -o "$out" ${lib.escapeShellArg url}
    '';
  };
in
stdenv.mkDerivation {
  pname = "venice-mcp-server";
  version = data.version;

  src = bundle;
  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/venice-mcp"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Venice AI MCP server, self-contained release bundle";
    homepage = "https://github.com/veniceai/venice-mcp-server";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "venice-mcp";
  };
}
