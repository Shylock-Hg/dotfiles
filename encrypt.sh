#! /usr/bin/env bash

# decrypt keys
./shylock/sh/gpg-b64.sh ./shylock/.authinfo
./shylock/sh/gpg-b64.sh ./shylock/.ssh/id_ed25519
./shylock/sh/gpg-b64.sh ./shylock/.wakatime.cfg
