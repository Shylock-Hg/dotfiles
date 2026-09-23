#! /usr/bin/env bash

OPAM_PACKAGES=(
    core core_bench utop user-setup tuareg ocamlformat ocaml-lsp-server
)

if [[ ${IN_CI:-false} == true ]]; then
    # The official repository is slow and unreliable from this runner. The
    # container also cannot create bubblewrap namespaces, so disable OPAM's
    # sandbox explicitly instead of waiting for its interactive fallback.
    opam init --yes --disable-sandboxing \
        default https://mirrors.sjtug.sjtu.edu.cn/git/opam-repository.git
    opam install --dry-run --yes "${OPAM_PACKAGES[@]}"
else
    opam init --yes
    opam install --yes "${OPAM_PACKAGES[@]}"
fi
