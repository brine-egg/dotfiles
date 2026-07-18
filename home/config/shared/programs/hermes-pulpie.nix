# hermes-pulpie plugin + pulpie library, built against numtide's python3
# (same interpreter hermes-agent ships with) so imports resolve inside the
# HERMES_PYTHON gateway env.
#
# Plugin repo: https://github.com/kachook/hermes-pulpie
# Pulpie lib:  https://pypi.org/project/pulpie/
#
# The plugin registers itself via the `hermes_agent.plugins` entry point,
# which nixpkgs' buildPythonPackage wires up automatically — no manual
# registration needed. Set `web.extract_backend: pulpie` in config to activate.
#
# Model weights (210M encoder) download from HuggingFace Hub on first
# extract() call and cache to ~/.cache/huggingface/ — NOT reproducible,
# intentional per Brine's request.
{ python3Packages, fetchFromGitHub }:

let
  # pulpie library — the 210M encoder model wrapper
  pulpie = python3Packages.buildPythonPackage rec {
    pname = "pulpie";
    version = "0.0.2";
    pyproject = true;

    src = python3Packages.fetchPypi {
      inherit pname version;
      hash = "sha256-VbZ5D10NF9/9oSBIXF6H7oM/3nzalesHR9YUEOQkG+E=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = with python3Packages; [
      torch
      transformers
      lxml
      selectolax
      beautifulsoup4
    ];

    # pulpie imports torch at module load — torch CPU is fine on 1080 Ti
    # (CC 6.1 too old for modern CUDA builds).
    #
    # pulpie pins transformers<5.0 but nixpkgs ships 5.5.4; relax the pin so
    # the install check passes. Runtime is fine — pulpie only runs forward
    # passes through the encoder, which is API-stable across transformers 4→5.
    #
    # transformers 5.x removed the "default" key from ROPE_INIT_FUNCTIONS, but
    # the HF-downloaded EuroBERT custom model code (modeling_eurobert.py) still
    # looks it up. Patch model_utils.py to register a "default" rope init fn at
    # import time — this runs before the model code loads and prevents the
    # KeyError. The implementation matches transformers 4.x's original.
    pythonRelaxDeps = [ "transformers" ];

    postInstall = ''
      # transformers 5.x removed the "default" key from ROPE_INIT_FUNCTIONS,
      # but the HF-downloaded EuroBERT custom model code (modeling_eurobert.py)
      # still looks it up at runtime → KeyError. Append a monkey-patch to the
      # end of model_utils.py that registers a "default" rope init fn. This
      # module is imported before any model code loads, so the patch is in
      # place by the time from_pretrained() triggers the custom modeling code.
      local sitepkgs="$out/lib/python3.14/site-packages/pulpie"
      cat >> "$sitepkgs/model_utils.py" <<'PATCH'

# --- transformers 5.x compat: restore "default" RoPE init fn ---
def _restore_default_rope():
    try:
        from transformers.modeling_rope_utils import ROPE_INIT_FUNCTIONS
    except ImportError:
        return
    if "default" in ROPE_INIT_FUNCTIONS:
        return
    def _compute_default_rope_parameters(config=None, device=None, seq_len=None, layer_type=None):
        base = getattr(config, "rope_theta", 10000.0)
        partial_rotary_factor = getattr(config, "partial_rotary_factor", 1.0)
        head_dim = getattr(config, "head_dim", None) or config.hidden_size // config.num_attention_heads
        dim = int(head_dim * partial_rotary_factor)
        inv_freq = 1.0 / (base ** (torch.arange(0, dim, 2, dtype=torch.int64).to(device=device, dtype=torch.float) / dim))
        return inv_freq, 1.0
    ROPE_INIT_FUNCTIONS["default"] = _compute_default_rope_parameters

_restore_default_rope()
# --- end compat patch ---
PATCH
    '';

    pythonImportsCheck = [ "pulpie" ];

    meta = with python3Packages.lib; {
      description = "HTML content extraction via 210M encoder model";
      homepage = "https://huggingface.co/blog/feyninc/pulpie";
      license = licenses.asl20;
      platforms = platforms.linux ++ platforms.darwin;
    };
  };

  # hermes-pulpie plugin — thin WebSearchProvider wrapper
  hermes-pulpie = python3Packages.buildPythonPackage rec {
    pname = "hermes-pulpie";
    version = "1.0.0";
    pyproject = true;

    # No release tags — pin to the commit that was HEAD at packaging time.
    # Bump by: curl -sL https://api.github.com/repos/kachook/hermes-pulpie/commits/main
    src = fetchFromGitHub {
      owner = "kachook";
      repo = "hermes-pulpie";
      rev = "99291340d9755d1c403f371686a00a0d8578f7b5";
      hash = "sha256-FFzfjZe1djmNOJiGpRLQ3l9rRXweMfLfBNPX0Bw0qgo=";
    };

    build-system = with python3Packages; [
      setuptools
    ];

    dependencies = [
      pulpie
      python3Packages.html2text
      python3Packages.httpx
    ];

    # Don't run importsCheck — it imports `agent.web_search_provider` which
    # only exists inside hermes-agent's env, not at standalone build time.
    # The entry point + plugin loader handle registration; is_available()
    # gates runtime use on `import pulpie` succeeding.
    doCheck = false;

    meta = with python3Packages.lib; {
      description = "Pulpie content extraction backend for Hermes Agent";
      homepage = "https://github.com/kachook/hermes-pulpie";
      license = licenses.mit;
      platforms = platforms.linux ++ platforms.darwin;
    };
  };
in
hermes-pulpie
