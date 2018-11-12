#! /usr/bin/env sh

###############################################################################
# touch sources files from template
###############################################################################

today=$(date +%Y-%m-%d)

prefix='https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/template'

while getopts 'n:h' args
do
	case $args in
		n)  #!< name of source file
			pattern_header='\.h$'
			pattern_source='\.c$'
			pattern_python='\.py$'
			pattern_hheader='\.hh$'  # hh
			pattern_ssource='\.cc$'  # cc
				
			# Makefile
			#if [ $OPTARG == 'Makefile' ] && [ -e $prefix/Makefile ]; then
			if [ $OPTARG == 'Makefile' ]; then
                                curl $prefix/linux.mk -o $PWD/$OPTARG

			# c
			elif [[ $OPTARG =~ $pattern_header ]]; then
				uppername=$( sed -e "s/${pattern_header}//g" -e 's/\([a-z]\+\)/\U\1/g' <<< $OPTARG )
                                if curl $prefix/template.h -o $PWD/$OPTARG; then
                                        sed -i  -e "s/\\date.\+/\\date $today/g" \
                                                -e "s/_.\+_H_/_${uppername}_H_/g" $PWD/$OPTARG
                                fi
			elif [[ $OPTARG =~ $pattern_source ]]; then
                                if curl $prefix/template.c -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi

			# c++
			elif [[ $OPTARG =~ $pattern_hheader ]]; then
				uppername=$( sed -e "s/${pattern_hheader}//g" -e 's/\([a-z]\+\)/\U\1/g' <<< $OPTARG )
                                if curl $prefix/template.hh -o $PWD/$OPTARG; then
                                        sed -i  -e "s/\\date.\+/\\date $today/g" \
                                                -e "s/_.\+_HH_/_${uppername}_HH_/g" $PWD/$OPTARG
                                fi
			elif [[ $OPTARG =~ $pattern_ssource ]]; then
                                if curl $prefix/template.cc -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi
			# python
			elif [[ $OPTARG =~ $pattern_python ]]; then
                                if curl $prefix/template.py -o $PWD/$OPTARG; then
				        sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
                                fi
			else
				echo 'error:Unkown file type!'
			fi

			;;
		h)
			echo -e "usage: $0 -n <name-of-source>\neg.$0 -n example.h"
			;;
		?)
			echo "error:Unknown argument $OPTARG!"
			;;
	esac
done

shift $(($OPTIND - 1))

