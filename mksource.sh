#! /usr/bin/env bash

# touch header/source file 

today=$(date +%Y-%m-%d)

prefix="$HOME/Workspace/config.linux/template"

while getopts 'n:h' args
do
	case $args in
		n)  #!< name of source file
			pattern_header='\.h$'
			pattern_source='\.c$'
			pattern_python='\.py$'
				
			# Makefile
			#if [ $OPTARG == 'Makefile' ] && [ -e $prefix/Makefile ]; then
			if [ $OPTARG == 'Makefile' ]; then
				cp $prefix/linux.mk $PWD/$OPTARG

			# header file
			elif [[ $OPTARG =~ $pattern_header ]]; then
				uppername=$( sed -e 's/\.h$//g' -e 's/\([a-z]\+\)/\U\1/g' <<< $OPTARG )
				cp $prefix/template.h $PWD/$OPTARG
				sed -i  -e "s/\\date.\+/\\date $today/g" \
					-e "s/_.\+_H_/_${uppername}_H_/g" $PWD/$OPTARG
		
			# source file
			elif [[ $OPTARG =~ $pattern_source ]]; then
				cp $prefix/template.c $PWD/$OPTARG
				sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
			elif [[ $OPTARG =~ $pattern_python ]]; then
				cp $prefix/template.py $PWD/$OPTARG
				sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
			else
				echo '[err]:Unkown file type!'
			fi

			;;
		h)
			echo "usage: $0 -n <name-of-source>\n\
				eg.$0 -n example.h"
			;;
		?)
			echo "[err]:Unknown argument $OPTARG!"
			;;
	esac
done

shift $(($OPTIND - 1))

