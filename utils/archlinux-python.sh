#! /usr/bin/env sh

################################################################################
# switch python2 or python3 to python
################################################################################

readonly prefix=/usr/sbin
readonly prefix2=/usr/bin

while getopts 'p:h' args
do
	case $args in
		p)  #!< name of source file
			# check the input
			if [ $OPTARG != 'python2' ] && [ $OPTARG != 'python3' ]; then
				echo "Invalid python version $OPTARG!"
				echo 'Please input `python2` or `python3`!'
				exit 1
			fi
			readonly input_python="$(which $OPTARG)"

			# change the default command entry python
			if [ -e $input_python ]; then
				sudo mv $prefix/python $prefix/python.bak
				sudo ln -s $input_python $prefix/python

				sudo mv $prefix2/python $prefix2/python.bak
				sudo ln -s $input_python $prefix2/python
			else
				echo "[err]:$input_python - no such file or directory!"
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

shift $((OPTIND - 1))
