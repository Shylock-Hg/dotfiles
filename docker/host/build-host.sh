#! /usr/bin/env sh

###############################################################################
#!  \brief auto build the host environment after new os installation
#   \author Shylock Hg
#   \date 2018-12-22
#   \email tcath2s@gmail.com
###############################################################################

set -e;

# environament variable for system package manager
export readonly NATIVE_INSTALL='sudo pacman --noconfirm --needed -Sy'
export readonly AUR_INSTALL='yay --noconfirm --needed -Sy'

# root
eval \
echo 'root:hsh5757124xyz' | chpasswd && \
\
# upgrade system
pacman --noconfirm -Syu && \
\
# install the softwares
pacman --noconfirm --needed -Sy base-devel \
        git vi vim emacs-nox wget gdb clang lldb cmake \
        openssh boost boost-libs valgrind man man-pages \
        python-pip python2-pip ruby nodejs npm \
        arm-none-eabi-gcc arm-none-eabi-gdb \
        arm-none-eabi-newlib arm-none-eabi-binutils \
        cronie \
        xorg-xinit gnome firefox docker docker-compose && \
\
# add the user
useradd -m -g users -G wheel -s /bin/bash shylock && \
echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
echo 'shylock:huangshihai' | chpasswd && \
\
# shylock
su shylock && cd $HOME
