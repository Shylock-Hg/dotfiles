#! /usr/bin/env bash

VIM_RC=("$HOME/.vimrc" './.vimrc')
VIM_MAN=("$HOME/.viman.yml" './viman/.viman.yml')

SS_PAC=("$HOME/.ss.pac" './.ss.d/.ss.pac')
SS_CONF=('/etc/shadowsocks/.ss.conf.json' './.ss.d/.ss.conf.json')

while getopts 'o:h' args
do
	case $args in
		o)  #orientation
			if [ $OPTARG = "backup" ]
			then
				#vim
				if [ -e ${VIM_RC[0]} ] ; then
					cp ${VIM_RC[0]}  ${VIM_RC[1]}
				else 
					echo "error : ${VIM_RC[0]} do not exist!"
				fi
				if [ -e ${VIM_MAN[0]} ] ; then
					cp ${VIM_MAN[0]} ${VIM_MAN[1]}
				else 
					echo "error : ${VIM_MAN[0]} do not exist!"
				fi

				#shadowsocks
				if [ -e ${SS_PAC[0]} ] ; then
					cp  ${SS_PAC[0]}  ${SS_PAC[1]}
				else
					echo "error : ${SS_PAC[0]} do not exist!"
				fi
				if [ -e ${SS_CONF[0]} ] ; then
					cp ${SS_CONF[0]} ${SS_CONF[1]}
				else
					echo "error : ${SS_CONF[0]} do not exist!"
				fi

			elif [ $OPTARG = "reduct" ]
			then
				#vim
				cp ${VIM_RC[1]}  ${VIM_RC[0]}
				cp ${VIM_MAN[1]} ${VIM_MAN[0]}

				#shadowsocks
				cp ${SS_PAC[1]} ${SS_PAC[0]}
				if [ -e $(dirname ${SS_CONF[0]}) ] 
				then
					sudo cp ${SS_CONF[1]} ${SS_CONF[0]}
				else
					echo "error : $(dirname ${SS_CONF[1]}) do not exist!"
				fi

			else
				echo "error : Unknown argument $OPTARG"
			fi
			;;
		h)
			echo "Usage: ./sync.sh -o <backup or reduct>!"
			;;
		?)
			echo "error : Unknown parameter!"
			;;
	esac
done

shift $(($OPTIND - 1))


