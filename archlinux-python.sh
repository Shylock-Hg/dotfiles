#! /usr/bin/env sh

################################################################################
# switch python2 or python3 to python
################################################################################

prefix=/usr/sbin

while getopts 'p:h' args
do
	case $args in
		p)  #!< name of source file

			if [ -e $prefix/$OPTARG ]; then 
				sudo mv $prefix/python $prefix/python.bak
				sudo ln -s $prefix/$OPTARG $prefix/python
			else
				echo "[err]:$prefix/$OPTART:no such file or directory!"
			fi

			;;
		h)
			printf "usage: $0 -n <python>\neg: $0 -p python2"
			;;
		?)
			echo "[err]:Unknown argument $OPTARG!"
			;;
	esac
done

shift $(OPTIND - 1)


