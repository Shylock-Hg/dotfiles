test -s ~/.alias && . ~/.alias || true

set -o vi

# rustup mirror
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static

# prompt git branch
export PS1='\u@\h \[\e[32m\]\w\[\e[91m\]$(__git_ps1)\[\e[00m\]$ '

# script
PATH="$PATH:$HOME/sh"


# NL CPA
alias cmake_llvm='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug  -DCMAKE_CXX_FLAGS="-stdlib=libc++" -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_INSTALL_PREFIX=~/local -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" -DLLVM_ENABLE_RTTI=ON -DLLVM_ENABLE_LLD=ON  -G Ninja'

readonly CPA_CLANG_TOOL_INCLUDES='/home/shylock/local/include/c++/v1:/home/shylock/local/lib/clang/18/include:/home/shylock/local/include/x86_64-unknown-linux-gnu/c++/v1:/usr/include'
readonly CPA_CLANG_TOOL_OPTIONS='-nostdinc'

alias cmake_cpa="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCPA_ENABLE_CLANG_FORMAT_GENERATED=ON -DCMAKE_EXE_LINKER_FLAGS='-fuse-ld=mold' -DCMAKE_CXX_FLAGS='-stdlib=libc++'  -DCMAKE_COLOR_DIAGNOSTICS=ON -DLLVM_DIR='~/local/lib/cmake/llvm' -DClang_DIR='~/local/lib/cmake/clang' -DCPA_CLANG_TOOL_INCLUDES=${CPA_CLANG_TOOL_INCLUDES} -DCPA_CLANG_TOOL_OPTIONS=${CPA_CLANG_TOOL_OPTIONS} -G Ninja"

