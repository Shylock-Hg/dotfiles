#! /usr/bin/env sh

################################################################################
# switch python2 or python3 to python
################################################################################


while getopts 'p:h' args
do
	case $args in
		p)  #!< name of source file

			if [ -e /usr/sbin/$OPTARG ]; then 
				sudo mv /usr/sbin/python /usr/sbin/python.bak
				sudo ln -s /usr/sbin/$OPTARG /usr/sbin/python
				#echo "Change python to /usr/sbin/$OPTARG!"
			else
				ehco "[err]:/usr/sbin/$OPTART:no such file or directory!"
			fi

			;;
		h)
			echo -e "usage: $0 -n <python>\n\
				eg.$0 -p python2"
			;;
		?)
			echo "[err]:Unknown argument $OPTARG!"
			;;
	esac
done

shift $(($OPTIND - 1))


