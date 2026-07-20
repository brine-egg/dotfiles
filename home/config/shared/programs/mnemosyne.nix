# Mnemosyne memory layer for Hermes Agent.
#
# Mnemosyne ships as two PyPI packages, neither in nixpkgs:
#   - mnemosyne-memory (core library, pure Python, dep: PyYAML)
#   - mnemosyne-hermes (plugin wrapper with Hermes entry points)
#
# We build both against numtidePythonPackages — the same Python 3.14
# interpreter hermes-agent is built against — so the packages land in
# the same site-packages and are importable by both the `hermes` CLI
# env and the HERMES_PYTHON gateway env (see hermes-agent-package.nix
# for why interpreter match is critical).
#
# The [embeddings] extra (fastembed + sqlite-vec) is folded into
# mnemosyne-memory's dependencies so local embedding generation works
# offline. To switch to a remote embedding API instead, remove
# fastembed/sqlite-vec from mnemosyne-memory's dependencies and set
# MNEMOSYNE_EMBEDDING_API_URL in the Hermes env.
{
  lib,
  python3Packages,
  fetchPypi,
  runCommandLocal,
}:

let
  mnemosyne-memory = python3Packages.buildPythonPackage rec {
    pname = "mnemosyne-memory";
    version = "3.11.1";
    pyproject = true;

    src = fetchPypi {
      pname = "mnemosyne_memory";
      inherit version;
      hash = "sha256-ixiUqszry4o2/UCf7737WjccuBFSh6IpWeeIGFHHLnA=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    # Core runtime dep + [embeddings] extra folded in for local vector
    # generation (fastembed pulls onnxruntime transitively).
    dependencies = with python3Packages; [
      pyyaml
      fastembed
      sqlite-vec
    ];

    pythonImportsCheck = [ "mnemosyne" ];

    meta = with lib; {
      description = "Universal memory layer for AI agents — SQLite-backed, zero-dependency";
      homepage = "https://github.com/mnemosyne-oss/mnemosyne";
      license = licenses.mit;
      sourceProvenance = with sourceTypes; [ fromSource ];
      platforms = platforms.all;
    };
  };

  mnemosyne-hermes = python3Packages.buildPythonPackage rec {
    pname = "mnemosyne-hermes";
    version = "0.5.0";
    pyproject = true;

    src = fetchPypi {
      pname = "mnemosyne_hermes";
      inherit version;
      hash = "sha256-CzEvnUw5oPFtT5bHQQ/GBdy2C/E7qShQn32irIRYKqw=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      mnemosyne-memory
      pyyaml
    ];

    pythonImportsCheck = [ "mnemosyne_hermes" ];

    meta = with lib; {
      description = "Mnemosyne memory provider for Hermes Agent — local-first, zero-cloud";
      homepage = "https://github.com/mnemosyne-oss/mnemosyne";
      license = licenses.mit;
      sourceProvenance = with sourceTypes; [ fromSource ];
      platforms = platforms.all;
    };
  };

  # Plugin directory wrapper for extraPlugins. buildPythonPackage nests
  # plugin.yaml at lib/python3.14/site-packages/mnemosyne_hermes/plugin.yaml;
  # the hermes-home HM module's extraPlugins activation checks for plugin.yaml
  # at the derivation root and symlinks the whole dir into ~/.hermes/plugins/.
  # This runCommand flattens the package dir so plugin.yaml lands at $out/.
  # The Python code is still imported from the pythonEnv (via extraPythonPackages),
  # not from this directory — the plugin dir only needs to satisfy the
  # directory-based plugin loader's _load_directory_module(), which reads
  # __init__.py and plugin.yaml from the root.
  mnemosyne-hermes-plugin-dir = runCommandLocal "mnemosyne-hermes-plugin"
    { }
    ''
      mkdir -p $out
      cp -r \
        "${mnemosyne-hermes}/${python3Packages.python.sitePackages}/mnemosyne_hermes"/* \
        $out/
    '';
in
{
  inherit
    mnemosyne-memory
    mnemosyne-hermes
    mnemosyne-hermes-plugin-dir
    ;
}
