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
docker run $DOCKER_USERNAME/$REPO mksource -n hello_cc.hh && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_cc.cc && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_python.py && \
docker run $DOCKER_USERNAME/$REPO mksource -n hello_shell.sh

# testing win2nix.sh
#docker run $DOCKER_USERNAME/$REPO win2nix -h

# testing archlinux-python.sh
docker run $DOCKER_USERNAME/$REPO archlinux-python -h && \
docker run $DOCKER_USERNAME/$REPO archlinux-python -p python2 && \
docker run $DOCKER_USERNAME/$REPO archlinux-python -p python3

# testing startup.sh
docker run $DOCKER_USERNAME/$REPO startup -h && \
docker run $DOCKER_USERNAME/$REPO startup -t c test.c hello.c && \
docker run $DOCKER_USERNAME/$REPO startup -t cc test.cc hello.cc
