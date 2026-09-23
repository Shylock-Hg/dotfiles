FROM opensuse/tumbleweed

LABEL maintainer="tcath2s@gmail.com"

ENV CI=true \
    PATH="/root/.cargo/bin:/root/.opam/default/bin:${PATH}"

# Bootstrap only what the repository's package installer needs. The complete
# system package set is installed in the next layer.
RUN zypper --non-interactive install --no-recommends \
        ca-certificates curl git sudo \
    && zypper clean --all

WORKDIR /root/dotfiles

# Keep the expensive dependency groups in separate layers so each one is only
# rebuilt when its own installer changes.
COPY zypper/ ./zypper/
RUN ./zypper/setup.sh \
    && zypper clean --all

COPY rust/ ./rust/
RUN cd rust && ./setup-rust.sh

COPY ocaml/ ./ocaml/
RUN ./ocaml/setup.sh

CMD ["/bin/bash"]
