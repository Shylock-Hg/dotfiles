#!/usr/bin/env bash

set -euo pipefail
umask 022

# These environments are workstation tools, not CI dependencies.
if [[ ${IN_CI:-false} == true ]]; then
    exit 0
fi

readonly TOOLS_DIR="${VIDEO_TOOLS_DIR:-/opt/video-tools}"
readonly BIN_DIR="${VIDEO_TOOLS_BIN_DIR:-/usr/local/bin}"
if (( EUID == 0 )); then
    SUDO=()
else
    SUDO=(sudo)
fi
if command -v python3.13 >/dev/null 2>&1; then
    PYTHON=$(command -v python3.13)
else
    PYTHON=$(command -v python3)
fi
readonly NPM=$(command -v npm)
readonly GIT=$(command -v git)
"${SUDO[@]}" mkdir -p "$TOOLS_DIR"

"${SUDO[@]}" "$PYTHON" -m venv "$TOOLS_DIR/moviepy"
"${SUDO[@]}" "$TOOLS_DIR/moviepy/bin/python" -m pip install 'moviepy>=2,<3'

# Keep Remotion packages on the same version, in a shared npm workspace.
"${SUDO[@]}" mkdir -p "$TOOLS_DIR/remotion"
readonly REMOTION_VERSION="$("$NPM" view remotion version)"
"${SUDO[@]}" "$NPM" install --prefix "$TOOLS_DIR/remotion" --save-exact \
    "remotion@$REMOTION_VERSION" "@remotion/cli@$REMOTION_VERSION" react react-dom

# Leave an existing checkout and its models/custom nodes untouched on reruns.
if [[ ! -e "$TOOLS_DIR/ComfyUI" ]]; then
    "${SUDO[@]}" "$GIT" clone --depth 1 https://github.com/Comfy-Org/ComfyUI.git "$TOOLS_DIR/ComfyUI"
fi
if [[ ! -f "$TOOLS_DIR/ComfyUI/requirements.txt" ]]; then
    echo "Missing ComfyUI requirements in $TOOLS_DIR/ComfyUI" >&2
    exit 1
fi
"${SUDO[@]}" "$PYTHON" -m venv "$TOOLS_DIR/comfyui-venv"
"${SUDO[@]}" "$TOOLS_DIR/comfyui-venv/bin/python" -m pip install \
    torch torchvision torchaudio \
    --index-url "${COMFYUI_TORCH_INDEX_URL:-https://download.pytorch.org/whl/cpu}"
"${SUDO[@]}" "$TOOLS_DIR/comfyui-venv/bin/python" -m pip install \
    -r "$TOOLS_DIR/ComfyUI/requirements.txt"

# Install shared launchers, but run applications as the invoking user.
readonly LAUNCHERS_DIR=$(mktemp -d)
trap 'rm -rf -- "$LAUNCHERS_DIR"' EXIT
for name in moviepy-python remotion comfyui; do
    printf '#!/usr/bin/env bash\nset -euo pipefail\nreadonly TOOLS_DIR=%q\n' \
        "$TOOLS_DIR" > "$LAUNCHERS_DIR/$name"
done
cat >> "$LAUNCHERS_DIR/moviepy-python" <<'EOF'
exec "$TOOLS_DIR/moviepy/bin/python" "$@"
EOF
cat >> "$LAUNCHERS_DIR/remotion" <<'EOF'
exec "$TOOLS_DIR/remotion/node_modules/.bin/remotion" "$@"
EOF
cat >> "$LAUNCHERS_DIR/comfyui" <<'EOF'
readonly USER_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/ComfyUI"
mkdir -p "$USER_DATA"/{user,input,output,temp}
exec "$TOOLS_DIR/comfyui-venv/bin/python" "$TOOLS_DIR/ComfyUI/main.py" \
    --user-directory "$USER_DATA/user" --input-directory "$USER_DATA/input" \
    --output-directory "$USER_DATA/output" --temp-directory "$USER_DATA/temp" "$@"
EOF
"${SUDO[@]}" install -d -m 0755 "$BIN_DIR"
for name in moviepy-python remotion comfyui; do
    "${SUDO[@]}" install -m 0755 "$LAUNCHERS_DIR/$name" "$BIN_DIR/$name"
done
