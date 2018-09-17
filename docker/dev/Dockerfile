FROM base/devel
MAINTAINER 'Shylock Hg'
RUN useradd -m -g users -G wheel -s /bin/bash shylock
RUN echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# Set the locale
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf
#RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN yes | pacman -Syu
RUN yes | pacman -Sy wget git vim gdb clang lldb cmake python-pip ruby nodejs npm

USER shylock
WORKDIR /home/shylock

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>/dev/null
RUN sh Miniconda3-latest-Linux-x86_64.sh -b -p ./Miniconda3 && rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH="$PATH:/home/shylock/Miniconda3/bin"
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
RUN conda config --set show_channel_urls yes
RUN conda create --name=torch && conda install --name=torch pytorch torchvision cuda92
RUN conda create --name=tf && conda install --name=tf tensorflow-gpu

RUN git clone https://aur.archlinux.org/yay.git && cd yay && yes | makepkg -si && cd .. && rm -rf yay
ENV NATIVE_INSTALL='yes | sudo pacman -Sy'
RUN curl -sL https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-vim.sh | sh

