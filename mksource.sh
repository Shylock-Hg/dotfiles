#! /usr/bin/env sh

###############################################################################
# touch sources files from template
###############################################################################

readonly today=$(date +%Y-%m-%d)

readonly prefix='https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/template'

while getopts 'n:h' args
do
	case $args in
		n)  #!< name of source file
                        readonly suffix_cheader='h'
                        readonly suffix_csource='c'
                        readonly suffix_python='py'
                        readonly suffix_ccheader='hh'
                        readonly suffix_ccsource='cc'
                        readonly suffix_sh='sh'
				
			# Makefile
			if [ $OPTARG = 'Makefile' ]; then
                                curl $prefix/linux.mk -o $PWD/$OPTARG

			# c
                        elif [ ${OPTARG##*.} = $suffix_cheader ]; then
                                uppername=${OPTARG%.*}
                                uppername=${uppername^^}
                                if curl $prefix/template.h -o $PWD/$OPTARG; then
                                        sed -i  -e "s/\\date.\+/\\date $today/g" \
                                                -e "s/_.\+_H_/_${uppername}_H_/g" $PWD/$OPTARG
                                fi
                        elif [ ${OPTARG##*.} = $suffix_csource ]; then
                                if curl $prefix/template.c -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi

			# c++
                        elif [ ${OPTARG##*.} = $suffix_ccheader ]; then
                                uppername=${OPTARG%.*}
                                uppername=${uppername^^}
                                if curl $prefix/template.hh -o $PWD/$OPTARG; then
                                        sed -i  -e "s/\\date.\+/\\date $today/g" \
                                                -e "s/_.\+_HH_/_${uppername}_HH_/g" $PWD/$OPTARG
                                fi
                        elif [ ${OPTARG##*.} = $suffix_ccsource ]; then
                                if curl $prefix/template.cc -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi
			# python
                        elif [ ${OPTARG##*.} = $suffix_python ]; then
                                if curl $prefix/template.py -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi
                        elif [ ${OPTARG##*.} = $suffix_sh ]; then
                                if curl $prefix/template.sh -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi
                        # shell
			else
				echo 'error:Unkown file type!'
			fi

			;;
		h)
                        printf "usage: $0 -n <name-of-source>\neg.$0 -n example.h"
			;;
		?)
			echo "error:Unknown argument $OPTARG!"
			;;
	esac
done

shift $($OPTIND - 1)
