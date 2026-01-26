FROM cachyos/cachyos-v4:latest
LABEL maintainer="tcath2s@gmail.com"

COPY . /home/shylock/dotfiles

RUN cd /home/shylock/dotfiles && ./setup.sh

# zsh
CMD ["/bin/bash"]
