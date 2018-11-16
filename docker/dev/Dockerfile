FROM archlinux/base
LABEL maintainer="tcath2s@gmail.com"

# Add user
RUN useradd -m -g users -G wheel -s /bin/bash shylock \
        && echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set the locale
#RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
#        && echo 'LANG=en_US.UTF-8' > /etc/locale.conf
#ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# environament variable for system package manager
ENV NATIVE_INSTALL='sudo pacman --noconfirm --needed -Sy' \
        AUR_INSTALL='yay --noconfirm --needed -Sy'

# Archlinux installation
RUN pacman --noconfirm --needed -Sy \
        base-devel \
        git vim emacs-nox gdb clang lldb cmake \
        openssh boost boost-libs valgrind man man-pages \
        wget sudo \
        python-pip python2-pip ruby nodejs npm \
        arm-none-eabi-gcc arm-none-eabi-gdb \
        arm-none-eabi-newlib arm-none-eabi-binutils

# Change user and workdir
USER shylock
WORKDIR /home/shylock

# Git configuration
RUN git config --global user.name 'Shylock-Hg' \
        && git config --global user.email 'tcath2s@gmail.com'

# local node, ruby and python path
ENV PATH="$PATH:/home/shylock/node_modules/.bin"
ENV PATH="$PATH:/home/shylock/.gem/ruby/2.5.0/bin"
ENV PATH="$PATH:/home/shylock/.local/bin"

# install aur helper yay
RUN git clone https://aur.archlinux.org/yay.git \
        && cd yay && makepkg --noconfirm -si && cd .. && rm -rf yay

# Conda and torch, tensorflow
ENV PATH="$PATH:/home/shylock/Miniconda3/bin"
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>/dev/null \
        && sh Miniconda3-latest-Linux-x86_64.sh -b -p ./Miniconda3 && rm Miniconda3-latest-Linux-x86_64.sh \
        && conda create --name=torch && conda install --name=torch pytorch torchvision cuda92 -c pytorch \
        && conda create --name=tf && conda install --name=tf tensorflow-gpu \
        && yes y | conda clean --all


# boudica development environment
RUN pip2 install --no-cache-dir --user pyyaml && ${NATIVE_INSTALL} scons

# zsh installation & oh-my-zsh configuration
RUN ${NATIVE_INSTALL} zsh powerline-fonts \
        && sudo chsh -s $(which zsh) shylock \
        && curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
ENV SHELL=/usr/sbin/zsh

# travis-ci cli
RUN gem install travis -v 1.8.9 --no-rdoc --no-ri

# mysql installation and config
# RUN ${NATIVE_INSTALL} mariadb \
#        && sudo usermod -a -G mysql shylock \
#        && sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Vim installation and configuration
RUN curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-vim.sh | sh

# Acceleration agent configuration for `github.com`, `archlinux sources`
RUN curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-speed.sh | sh

# Install my custom ultility to `/usr/local/bin`
RUN curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build.sh | sh

# zsh
CMD ["/usr/sbin/zsh"]
