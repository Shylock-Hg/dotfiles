FROM archlinux/base
MAINTAINER 'Shylock Hg'
RUN useradd -m -g users -G wheel -s /usr/bin/bash shylock
RUN echo 'shylock ALL=(ALL) ALL' >> /etc/sudoers
RUN echo -ne '## China\n\
Server = http://mirrors.163.com/archlinux/$repo/os/$arch\n\
## China\n\
Server = http://mirrors.zju.edu.cn/archlinux/$repo/os/$arch\n\
## China\n\
Server = http://mirrors.xjtu.edu.cn/archlinux/$repo/os/$arch\n\
## China\n\
Server = http://mirrors.neusoft.edu.cn/archlinux/$repo/os/$arch\n\
## China\n\
Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch\n' > /etc/pacman.d/mirrorlist
RUN echo -e '\n' | pacman -Syu
RUN echo -e '\n' | pacman -Sy base-devel curl wget sudo git vim python-pip ruby nodejs

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

ENV NATIVE_INSTALL='sudo pacman -Sy'
RUN git clone https://github.com/Shylock-Hg/config.linux.git && cd config.linux && ./build-vim.sh && cd ..

