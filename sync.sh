#! /bin/sh

#sync vim config
#cp ~/.vimrc $1
#cp -r ~/.vim $1

#sync shadowsocks config
#cp -r ~/.ss.d $1

while getopts 'o:' args
do
	case $args in
		o)  #orientation
                        if [ $OPTARG = "backup" ]
                        then
                                cp ~/.vimrc                       ./
                                cp -r ~/.vim/                     ./
                                cp ~/.ss.pac                      ./.ss.d/
                                cp /etc/shadowsocks/.ss.conf.json ./.ss.d/
                        elif [ $OPTARG = "reduct" ]
                        then
                                cp .vimrc              ~/
                                cp -r .vim/            ~/
                                cp .ss.d/.ss.pac       ~/
                                cp .ss.d/.ss.conf.json /etc/shadowsocks/
                        else
                                echo "Unknown argument $OPTARG"
                        fi
			;;
		?)
			echo "Unknown parameter!"
			;;
	esac
done

shift $(($OPTIND - 1))

