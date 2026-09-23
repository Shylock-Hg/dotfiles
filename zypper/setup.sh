#! /usr/bin/env bash

set -euo pipefail

pushd "$(dirname "$0")"

./setup-mirror.tumbleweed.sh
./setup-ms-repo.tumbleweed.sh
./install.sh

popd
