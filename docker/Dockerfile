FROM opensuse/tumbleweed

LABEL maintainer="tcath2s@gmail.com"

ENV CI=true \
    IN_CI=true \
    PATH="/root/.cargo/bin:/root/.opam/default/bin:${PATH}"

# Select the fast mirror before the first repository refresh. Copy this script
# separately so changes to the package list do not invalidate the bootstrap.
COPY zypper/setup-mirror.tumbleweed.sh ./zypper/setup-mirror.tumbleweed.sh
RUN ./zypper/setup-mirror.tumbleweed.sh

# Bootstrap only what the repository's package installer needs. The next layer
# installs packages used by later build stages and dry-runs the workstation set.
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
