
test -s ~/.alias && . ~/.alias || true

set -o vi

# rustup mirror
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static

