test -s ~/.alias && . ~/.alias || true

set -o vi

# rustup mirror
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static

# prompt git branch
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
  source /usr/share/git/completion/git-prompt.sh
fi

export PS1='\u@\h \[\e[32m\]\w\[\e[91m\]$(__git_ps1)\[\e[00m\]$ '

# script
PATH="$PATH:$HOME/sh"

# for wine app
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# NL CPA
alias cmake_llvm='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug  -DCMAKE_CXX_FLAGS="-stdlib=libc++" -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_INSTALL_PREFIX=~/local -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_LLD=ON -G "Unix Makefiles"'

alias cmake_3rd='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-w" -DCMAKE_CXX_FLAGS="-stdlib=libc++ -w" -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_INSTALL_PREFIX=~/local -DNL_JOBS=16'

readonly CPA_CLANG_TOOL_INCLUDES='/home/shylock/local/include/c++/v1:/home/shylock/local/lib/clang/18/include:/home/shylock/local/include/x86_64-unknown-linux-gnu/c++/v1:/usr/include'
readonly CPA_CLANG_TOOL_OPTIONS='-nostdinc'

#alias cmake_cpa="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCPA_ENABLE_CLANG_FORMAT_GENERATED=ON -DCMAKE_EXE_LINKER_FLAGS='-fuse-ld=mold' -DCMAKE_CXX_FLAGS='-stdlib=libc++' -DCMAKE_COLOR_DIAGNOSTICS=ON -DCPA_CLANG_TOOL_INCLUDES=${CPA_CLANG_TOOL_INCLUDES} -DCPA_CLANG_TOOL_OPTIONS=${CPA_CLANG_TOOL_OPTIONS} -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCPA_USE_LOCAL_LIB=ON -DCPA_LOCAL_PATH=/home/shylock/local"

alias cmake_cpa="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCPA_ENABLE_CLANG_FORMAT_GENERATED=ON -DCMAKE_EXE_LINKER_FLAGS='-fuse-ld=mold' -DCMAKE_CXX_FLAGS='-stdlib=libc++' -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCPA_USE_LOCAL_LIB=ON -DCPA_LOCAL_PATH=/home/shylock/local"

alias cmake_nl="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCPA_ENABLE_CLANG_FORMAT_GENERATED=ON -DCMAKE_EXE_LINKER_FLAGS='-fuse-ld=mold' -DCMAKE_CXX_FLAGS='-stdlib=libc++' -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCPA_USE_LOCAL_LIB=ON -DCPA_LOCAL_PATH=/home/shylock/local -DNL_USE_LOCAL_LIB=ON -DNL_LOCAL_PATH=/home/shylock/local -DBUILD_LOCAL_UI=ON"

# alias cmake for nl simulator
alias cmake_sim="cmake .. -D3RD_PATH='~/local' -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"

alias restartplasma='systemctl --user restart plasma-plasmashell.service'

# enable starship
eval "$(starship init bash)"


