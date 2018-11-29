#! /usr/bin/env sh

###############################################################################
#!  \brief  
#   \author Shylock Hg
#   \date 2018-11-27
#   \email tcath2s@gmail.com
###############################################################################

###############################################################################
# prerequisites
# - git
# - curl
# - mksource
###############################################################################
target=''

readonly dest=$PWD  # target repo directory

readonly target_c='c'
readonly url_c_gitignore='https://raw.githubusercontent.com/github/gitignore/master/C.gitignore'

readonly target_cc='cc'
readonly url_cc_gitignore='https://raw.githubusercontent.com/github/gitignore/master/C%2B%2B.gitignore'

readonly source_main='int main(int argc, char * argv[]) {\n        return 0;\n}'

check_prerequisites() {
        # git
        if ! command -v git >/dev/null; then
                echo 'Err: Require git!'
                return 1;
        fi
        # curl
        if ! command -v curl >/dev/null; then
                echo 'Err: Require curl!'
                return 1;
        fi
        # mksource
        if ! command -v mksource >/dev/null; then
                echo 'Err: require mksource!'
                return 1;
        fi
        return 0;
}

common() {  # common dir
        git init $1
}

# check prerequisites
if ! check_prerequisites; then
        exit 1
fi

# handle input parameters
while getopts 't:h' args
do
	case $args in
		t)  #!< target type
                        target=$OPTARG
			;;
		h)
			printf "usage: $0 -t <target> name...\neg: $0 -t cc hello echo"
                        exit 0
			;;
		?)
			echo "Err: Unknown argument $OPTARG!"
			;;
	esac
done

shift $($OPTIND - 1)

# check target input
if [ -z "$target" ]; then
        echo 'Err: Empty target!'
        exit 1
fi

# check names input
if [ -z "$*" ]; then
        echo 'Err: Empty names!'
        exit 1
fi

# handle sub directories input
for dir in $*
do
        if [ $target = $target_c ]; then
                common $dest/$dir
                if ! curl $url_c_gitignore > $dest/$dir/.gitignore; then
                        exit 1
                fi
                pwd=$PWD
                cd $dest/$dir
                if ! mksource -n main.c; then
                        exit 1
                fi
                if ! mksource -n Makefile; then
                        exit 1
                fi
                printf "$source_main" >> main.c
                mkdir -p 'source'
                mkdir -p 'include'
                cd $pwd
        elif [ $target = $target_cc ]; then
                common $dest/$dir
                if ! curl $url_cc_gitignore > $dest/$dir/.gitignore; then
                        exit 1
                fi
                pwd=$PWD
                cd $dest/$dir
                if ! mksource -n main.cc; then
                        exit 1
                fi
                if ! mksource -n Makefile; then  # modify CC manually
                        exit 1
                fi
                printf "$source_main" >> main.cc
                mkdir -p 'source'
                mkdir -p 'include'
                cd $pwd
        else
                echo "Err: Unkonwn target $target!"
        fi
done
