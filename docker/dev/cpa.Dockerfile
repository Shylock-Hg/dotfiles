FROM ubuntu:24.04

RUN apt update \
    && apt install -y git cmake make flex bison gcc g++ lld clang llvm llvm-dev libclang-dev zlib1g-dev

RUN apt install -y sudo clang-format-19 ninja-build mold clang libc++-dev \
    && ln -s /usr/bin/clang-format-19 /usr/bin/clang-format

RUN alias cmake_cpa='cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCPA_ENABLE_CLANG_FORMAT_GENERATED=ON -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=mold" -DCMAKE_CXX_FLAGS="-stdlib=libc++" -DCMAKE_COLOR_DIAGNOSTICS=ON -G Ninja'


# 获取宿主机 UID（可选，若固定 UID 可直接设置为 1000）
ARG REMOTE_UID=1000
ARG REMOTE_GID=1000

# 创建用户
RUN useradd -u ${REMOTE_UID} -g ${REMOTE_GID} -m -s /bin/bash shylock && \
    echo "shylock ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/shylock && \
    chmod 0440 /etc/sudoers.d/shylock

# 切换为非 root 用户（可选，但推荐）
USER shylock
WORKDIR /home/shylock
