FROM cachyos/cachyos:latest

LABEL maintainer="tcath2s@gmail.com"

ENV CI=true \
    IN_CI=true \
    PATH="/root/.cargo/bin:/root/.opam/default/bin:${PATH}"

# Select Aliyun before the first package database synchronization. Keep this
# copy separate so package-list changes do not invalidate the bootstrap layer.
COPY pacman/setup-mirror.sh /tmp/setup-pacman-mirror.sh
RUN /tmp/setup-pacman-mirror.sh

RUN pacman -Syu --noconfirm --needed \
        ca-certificates curl git sudo \
    && pacman -Scc --noconfirm

WORKDIR /root/dotfiles

COPY pacman/ ./pacman/
RUN ./pacman/setup.sh \
    && pacman -Scc --noconfirm

COPY rust/ ./rust/
RUN cd rust && ./setup-rust.sh

COPY ocaml/ ./ocaml/
RUN ./ocaml/setup.sh

CMD ["/bin/bash"]
