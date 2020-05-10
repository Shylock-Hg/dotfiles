FROM archlinux/base:latest
LABEL maintainer="tcath2s@gmail.com"

# environament variable for system package manager
ENV NATIVE_INSTALL='sudo pacman --noconfirm --needed -Sy' \
        AUR_INSTALL='yay --noconfirm --needed -Sy'

# local node, ruby and python path
ENV PATH="$PATH:/home/shylock/node_modules/.bin"
ENV PATH="$PATH:/home/shylock/.gem/ruby/2.5.0/bin"
ENV PATH="$PATH:/home/shylock/.local/bin"

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

# Conda and torch, tensorflow
ENV PATH="$PATH:/home/shylock/Miniconda3/bin"

# zsh
ENV SHELL=/usr/sbin/zsh

# cargo
ENV PATH="$PATH:/home/shylock/.cargo/bin"

RUN useradd -m -g users -G wheel -s /bin/bash shylock && \
echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
pacman --noconfirm -Sy sudo && \
pacman --noconfirm -Syu

# Change user and workdir
USER shylock
WORKDIR /home/shylock

# building dev image
RUN $NATIVE_INSTALL \
        base-devel \
        git vi vim gdb clang lldb cmake \
        openssh boost boost-libs valgrind man man-pages \
        wget sudo \
        python-pip python2-pip ruby nodejs yarn

# yay
RUN git clone https://aur.archlinux.org/yay.git && \
cd yay && makepkg --noconfirm -si && cd .. && rm -rf yay .cache

# Git configuration
RUN git config --global user.name 'Shylock-Hg' && \
git config --global user.email 'tcath2s@gmail.com'

# Conda and torch, tensorflow
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>/dev/null && \
sh Miniconda3-latest-Linux-x86_64.sh -b -p ./Miniconda3 && \
rm Miniconda3-latest-Linux-x86_64.sh && \
conda create --name=ml && \
conda install --name=ml tensorflow-gpu && \
conda install --name=ml -c pytorch pytorch torchvision cudatoolkit=10.0 && \
yes y | conda clean --all

# rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
rustup install nightly

# zsh installation & oh-my-zsh configuration
RUN $AUR_INSTALL zsh powerline-fonts && \
sudo chsh -s $(which zsh) shylock && \
curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# travis-ci cli
RUN gem install travis -v 1.8.9

# Vim installation and configuration
RUN curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-vim.sh | sh && \
\
# Install my custom ultility to `/usr/local/bin`
curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build.sh | sh

# Set the locale
#RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
#        && echo 'LANG=en_US.UTF-8' > /etc/locale.conf
#ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# zsh
CMD ["/usr/sbin/zsh"]
