# config.linux

|CI|Lint|Project|PR|
|:--|:--|:--|:--|
|[![Build Status](https://travis-ci.org/Shylock-Hg/config.linux.svg?branch=master)](https://travis-ci.org/Shylock-Hg/config.linux)|[![CodeFactor](https://www.codefactor.io/repository/github/shylock-hg/config.linux/badge)](https://www.codefactor.io/repository/github/shylock-hg/config.linux)|[![BCH compliance](https://bettercodehub.com/edge/badge/Shylock-Hg/config.linux?branch=master)](https://bettercodehub.com/)|[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)|
||[![Codacy Badge](https://api.codacy.com/project/badge/Grade/ea9a5df475e2404f9ea1db4d8d42cdb0)](https://www.codacy.com/app/Shylock-Hg/config.linux?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=Shylock-Hg/config.linux&amp;utm_campaign=Badge_Grade)|||

My config file for linux.

## Standard development environment in docker

./docker/dev/Dockerfile

## CI image

`docker/Dockerfile` preinstalls the system packages, Rust toolchain, and opam
switch in separate cacheable layers:

```sh
docker build --file docker/Dockerfile --tag shylockhg/opensuse:latest .
```

## Video creation for AI agents

Normal workstation setup installs these tools on openSUSE Tumbleweed and
Arch/CachyOS. In CI, their packages are resolved without installing them.
MoviePy, Remotion, and ComfyUI are installed separately by `video/setup.sh`
during normal setup; this installer is skipped in CI.

| Tool | Use from an agent |
|:--|:--|
| [FFmpeg](https://ffmpeg.org/) (`ffmpeg`, `ffprobe`) | Assemble frames, mix audio, add subtitles, encode video, and inspect outputs. |
| [ImageMagick](https://imagemagick.org/) (`magick`) | Generate, resize, and composite still images and title cards. |
| [Blender](https://www.blender.org/) (`blender`) | Render scripted scenes and animations with `blender --background --python scene.py`. |
| [eSpeak NG](https://github.com/espeak-ng/espeak-ng) (`espeak-ng`) | Generate offline narration as WAV audio. |
| [Kdenlive](https://kdenlive.org/) (`kdenlive`) | Review and edit video projects interactively. |
| [MoviePy](https://zulko.github.io/moviepy/) | Compose and process video from Python scripts in a dedicated virtual environment. |
| [Remotion](https://www.remotion.dev/docs/cli) | Create React-based videos and render them with the local CLI. |
| [ComfyUI](https://docs.comfy.org/installation/manual_install) | Run local generative image/video workflows through its UI or API. |

To install or refresh the language-based tools separately, run `./video/setup.sh`.
The installer uses `sudo` to put shared environments under `/opt/video-tools`
and launchers in `/usr/local/bin`, so all users can run them without activation
or elevated privileges. Set `VIDEO_TOOLS_DIR` and `VIDEO_TOOLS_BIN_DIR` to
override these system paths. Python dependencies remain isolated from the
distribution's Python packages. For example:

```sh
moviepy-python -c 'from moviepy import VideoFileClip; print("MoviePy ready")'
remotion --help
# Create compositions in your own project with local React/Remotion dependencies.
comfyui --cpu
```

ComfyUI defaults to CPU PyTorch. For GPU support, choose the appropriate wheel
index from the [upstream installation guide](https://docs.comfy.org/installation/manual_install)
and set `COMFYUI_TORCH_INDEX_URL` when running the installer in a fresh tools
directory. An administrator can place shared workflow models in
`/opt/video-tools/ComfyUI/models`. ComfyUI's settings, inputs, outputs and temporary
files are stored per user under `${XDG_DATA_HOME:-$HOME/.local/share}/ComfyUI`.
Setup does not download models or start the server. Existing ComfyUI checkouts,
models, and custom nodes are preserved; update the checkout explicitly with
`sudo git -C /opt/video-tools/ComfyUI pull --ff-only`, then rerun the installer.

For example, create a narrated title card without a display or API keys:

```sh
mkdir -p video-output
magick -size 1280x720 xc:'#182030' -font DejaVu-Sans \
    -fill white -gravity center -pointsize 64 \
    -annotate 0 'Hello from an AI agent' video-output/title.png
espeak-ng -w video-output/narration.wav 'Hello from an AI agent.'
ffmpeg -y -loop 1 -framerate 25 -i video-output/title.png \
    -i video-output/narration.wav -c:v mpeg4 -q:v 4 -pix_fmt yuv420p \
    -c:a aac -shortest video-output/hello.mp4
ffprobe -v error -show_entries stream=codec_type,codec_name \
    -show_entries format=duration -of json video-output/hello.mp4
```

The example uses MPEG-4 Part 2 video; encoder availability varies by distribution.
Check `ffmpeg -encoders` before choosing another codec such as H.264.

## AaaU

Normal workstation setup installs the latest Linux release of
[AaaU](https://github.com/AgentaaU/AaaU) into `/usr/local/bin`. To update it
separately, run `./aaau/setup.sh`. After installation, initialize the agent
user and directories with `sudo aaau-server init`, then start the server as
described in the [upstream instructions](https://github.com/AgentaaU/AaaU#quick-start).
