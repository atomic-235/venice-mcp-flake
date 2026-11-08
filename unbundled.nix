{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  nodejs,
  cacert,
}:

# The npm tarball ships a fully populated node_modules (bundleDependencies:
# true), so there is nothing to install and no npm dependency hash to keep in
# sync. Pulling the registry dep tree with buildNpmPackage used to fail because
# npm marks bundled deps as `inBundle` without `resolved` URLs, leaving them
# out of the offline cache.
let
  data = builtins.fromJSON (builtins.readFile ./version.json);
in
stdenv.mkDerivation {
  pname = "venice-mcp-server";
  version = data.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@veniceai/mcp-server/-/mcp-server-${data.version}.tgz";
    hash = data.integrity;
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    if [ ! -d node_modules ]; then
      echo "error: upstream tarball no longer bundles node_modules; rework packaging" >&2
      exit 1
    fi
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
