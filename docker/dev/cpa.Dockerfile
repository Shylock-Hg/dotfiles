FROM ubuntu:24.04

RUN echo "deb http://archive.ubuntu.com/ubuntu/ noble-proposed universe" >> /etc/apt/sources.list \
    && apt update \
    && apt install -y sudo git cmake flex bison clang-format-19 ninja-build mold clang libc++-dev llvm llvm-dev libclang-dev zlib1g-dev \
    && ln -s /usr/bin/clang-format-19 /usr/bin/clang-format

RUN echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN alias cmake_cpa='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCPA_ENABLE_CLANG_FORMAT_GENERATED=ON -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=mold" -DCMAKE_CXX_FLAGS="-stdlib=libc++" -DCMAKE_COLOR_DIAGNOSTICS=ON -G Ninja'

# fix vscode devcontainer permission error
RUN chmod -R 775 /home
RUN useradd -m -s /bin/bash shylock
