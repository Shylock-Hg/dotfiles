#! /usr/bin/env bash

pushd $(dirname $0)

./setup-mirror.tumbleweed.sh
./setup-ms-repo.tumbleweed.sh
./install.sh

popd
