FROM archlinux/base
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

RUN useradd -m -g users -G wheel -s /bin/bash shylock && \
echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
pacman --noconfirm -Sy sudo

# Change user and workdir
USER shylock
WORKDIR /home/shylock

# building dev image
COPY build-dev.sh .
RUN ./build-dev.sh && \
rm build-dev.sh

# Set the locale
#RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
#        && echo 'LANG=en_US.UTF-8' > /etc/locale.conf
#ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# zsh
CMD ["/usr/sbin/zsh"]
