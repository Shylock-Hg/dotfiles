#! /usr/bin/env sh

###############################################################################
# testing docker and scripts in docker
###############################################################################

# testing docker
docker run $DOCKER_USERNAME/$REPO

# testing mksource.sh
docker run $DOCKER_USERNAME/$REPO mksource -h && \
docker run $DOCKER_USERNAME/$REPO mksource -n Makefile && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_c.h && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_c.c && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_cc.h && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_cc.c && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_python.py && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_shell.py

# testing win2nix.sh
docker run $DOCKER_USERNAME/$REPO win2nix

# testing archlinux-python.sh
docker run $DOCKER_USERNAME/$REPO archlinux-python -h && \
docker run $DOCKER_USERNAME/$REPO archlinux-python -p python2 && \
docker run $DOCKER_USERNAME/$REPO archlinux-python -p python3
