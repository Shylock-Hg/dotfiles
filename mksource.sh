#! /usr/bin/env sh

# touch header/source file 

today=$(date +%Y-%m-%d)

#prefix="$HOME/Workspace/config.linux/template"
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
				#cp $prefix/linux.mk $PWD/$OPTARG
                                curl $prefix/linux.mk -o $PWD/$OPTARG

			# c
			elif [[ $OPTARG =~ $pattern_header ]]; then
				uppername=$( sed -e "s/${pattern_header}//g" -e 's/\([a-z]\+\)/\U\1/g' <<< $OPTARG )
				#cp $prefix/template.h $PWD/$OPTARG
                                curl $prefix/template.h -o $PWD/$OPTARG
				sed -i  -e "s/\\date.\+/\\date $today/g" \
					-e "s/_.\+_H_/_${uppername}_H_/g" $PWD/$OPTARG
			elif [[ $OPTARG =~ $pattern_source ]]; then
				#cp $prefix/template.c $PWD/$OPTARG
                                curl $prefix/template.c -o $PWD/$OPTARG
				sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG

			# c++
			elif [[ $OPTARG =~ $pattern_hheader ]]; then
				uppername=$( sed -e "s/${pattern_hheader}//g" -e 's/\([a-z]\+\)/\U\1/g' <<< $OPTARG )
				#cp $prefix/template.hh $PWD/$OPTARG
                                curl $prefix/template.hh -o $PWD/$OPTARG
				sed -i  -e "s/\\date.\+/\\date $today/g" \
					-e "s/_.\+_HH_/_${uppername}_HH_/g" $PWD/$OPTARG
			elif [[ $OPTARG =~ $pattern_ssource ]]; then
				#cp $prefix/template.cc $PWD/$OPTARG
                                curl $prefix/template.cc -o $PWD/$OPTARG
				sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
			# python
			elif [[ $OPTARG =~ $pattern_python ]]; then
				#cp $prefix/template.py $PWD/$OPTARG
                                curl $prefix/template.py -o $PWD/$OPTARG
				sed -i "s/\\date.\+/\\date $today/g" $PWD/$OPTARG
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

