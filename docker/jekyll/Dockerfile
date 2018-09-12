FROM archlinux/base
MAINTAINER Shylock Hg
EXPOSE 4000
USER shylock:wheel user
WORKDIR /home/shylock
COPY ~/.ssh /home/shylock
RUN sudo pacman -Sy base-devel git ruby
RUN gem install jekyll bundler
