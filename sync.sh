#! /bin/sh

while getopts 'o:h' args
do
	case $args in
		o)  #orientation
                        if [ $OPTARG = "backup" ]
                        then
                                cp ~/.vimrc                       ./
                                cp -r ~/.vim/                     ./
                                cp ~/.ss.pac                      ./.ss.d/
                                cp /etc/shadowsocks/.ss.conf.json ./.ss.d/
                                source activate mltoolchain
                                conda env export -f               ./.conda/mltoolchain.yml
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
                h)
                        echo "Usage: ./sync.sh -o <backup or reduct>!"
                        ;;
		?)
			echo "Unknown parameter!"
			;;
	esac
done

shift $(($OPTIND - 1))

