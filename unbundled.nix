{
  lib,
  fetchurl,
  buildNpmPackage,
  makeWrapper,
  nodejs,
  cacert,
}:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
in
buildNpmPackage {
  pname = "venice-mcp-server";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@veniceai/mcp-server/-/mcp-server-${data.version}.tgz";
    hash = data.integrity;
  };

  # Generated from the published tarball's package.json; bumped by CI.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = data.npmDepsHash;
  npmFlags = [ "--legacy-peer-deps" ];

  # The npm tarball already ships a built dist/; only dependencies are installed.
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/venice-mcp $out/bin
    cp -r . $out/lib/venice-mcp
    makeWrapper ${nodejs}/bin/node $out/bin/venice-mcp \
      --add-flags "$out/lib/venice-mcp/dist/cli.js" \
      --set NODE_OPTIONS "--use-env-proxy" \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Venice AI MCP server (official npm release)";
    homepage = "https://github.com/veniceai/venice-mcp-server";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "venice-mcp";
  };
}
