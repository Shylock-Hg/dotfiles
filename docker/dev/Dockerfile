FROM base/devel
MAINTAINER 'Shylock Hg'
RUN useradd -m -g users -G wheel -s /usr/bin/bash shylock
RUN echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo -e '\n' | pacman -Syu
RUN echo -e '\n' | pacman -Sy wget git vim python-pip ruby nodejs

USER shylock
WORKDIR /home/shylock
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>/dev/null
RUN sh Miniconda3-latest-Linux-x86_64.sh -b -p ./Miniconda3
ENV PATH="$PATH:/home/shylock/Miniconda3/bin"
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
RUN conda config --set show_channel_urls yes
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
RUN conda create --name=torch && conda install --name=torch pytorch torchvision cuda92
RUN conda create --name=tf && conda install --name=tf tensorflow-gpu

RUN gpg --recv-key 465022E743D71E39 || git clone https://aur.archlinux.org/aurman.git && cd aurman && echo -e '\n' | makepkg -si && cd ..
ENV NATIVE_INSTALL='sudo pacman -Sy'
RUN git clone https://github.com/Shylock-Hg/config.linux.git && cd config.linux && ./build-vim.sh && cd ..

