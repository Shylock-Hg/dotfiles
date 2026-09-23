#! /usr/bin/env bash

opam init --yes

OPAM_PACKAGES=(
    core core_bench utop user-setup tuareg ocamlformat ocaml-lsp-server
)

if [[ ${IN_CI:-false} == true ]]; then
    opam install --dry-run --yes "${OPAM_PACKAGES[@]}"
else
    opam install --yes "${OPAM_PACKAGES[@]}"
fi
