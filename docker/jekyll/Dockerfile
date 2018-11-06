FROM base/devel
MAINTAINER 'Shylock Hg' <tcath2s@gmail.com>

# Add user
RUN useradd -m -g users -G wheel -s /bin/bash shylock \
        && echo 'shylock ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Set the locale
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen \
        && echo 'LANG=en_US.UTF-8' > /etc/locale.conf
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

EXPOSE 80

RUN sudo pacman --noconfirm --needed -Syu && \
        sudo pacman --noconfirm --needed -Sy git ruby ruby-rdoc nginx

USER shylock
WORKDIR /home/shylock

# local gems environment
ENV PATH="$PATH:/home/shylock/.gem/ruby/2.5.0/bin"
RUN gem install bundler

# build generate static site by jekyll stack
RUN git clone --depth=1 https://github.com/Shylock-Hg/blog.git && \
        cd blog && \
        bundle install && \
        production bundle exec jekyll b && \
        cp -r _site /usr/share/www.shylock-hg.com && \
        cd ~

# configuration nginx
COPY nginx.conf /etc/nginx/

# entrypoint
ENTRYPOINT ['sudo', 'nginx']
