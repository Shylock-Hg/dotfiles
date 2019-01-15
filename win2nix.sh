#! /usr/bin/env sh

###############################################################################
# convert sources(c/c++) from windows to unix flavor
###############################################################################


dir=$PWD  # default to current dirctory

while getopts 'd:h' args
do
	case $args in
		d)  #!< name of source file
            dir=$OPTARG
            if [ ! -d "$dir" ]; then  # not exists directory
                echo "Invalid directory $dir"
                exit 1
            fi
			;;
		h)
                        printf "usage: $0 -d <directory-to-format>\neg.$0 -d ./project\n"
                        printf "usage: $0 , for current directory!\n"
			;;
		?)
			echo "error:Unknown argument $OPTARG!"
			;;
	esac
done

shift $((OPTIND - 1))

# convert backslash to slash in include path for the c header/source file
find $dir -type f -name '*.h' -name '*.c' -exec sed -i -e '/#include/s/\\/\//' {} \;

# convert line break to unix flavor
# delete trailing spaces
find $dir -type f -exec sed -i -e 's/\r//' -e 's/[[:blank:]]*$//' {} \;
