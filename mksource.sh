#! /bin/bash

# touch header/source file 

today=$(date +%Y-%m-%d)

dir=''

while getopts 'o:n:h' args
do
	case $args in
		o)  #!< directory to create source file
			dir=$OPTARG
			;;
		n)  #!< name of source file
			pattern_header='\.h$'
			pattern_source='\.c$'

			if [[ $OPTARG =~ $pattern_header ]]; then
				#uppername=$( sed -e 's/[^_a-zA-Z][^_a-zA-Z0-9]{0,30}/_/g' <<< $OPTARG )
				uppername=$( sed -e 's/\.h$//g' -e 's/\([a-z]\+\)/\U\1/g' <<< $OPTARG )
				cp ./template/template.h $dir/$OPTARG
				sed -i  -e "s/\\date.\+/\\date $today/g" \
					-e "s/_.\+_H_/_${uppername}_H_/g" $dir/$OPTARG
		
			elif [[ $OPTARG =~ $pattern_source ]]; then
				cp ./template/template.c $dir/$OPTARG
				sed -i "s/\\date.\+/\\date $today/g" $dir/$OPTARG
			else
				echo '[err]:Unkown file type!'
			fi
			;;
		h)
			echo "usage: $0 -n <name-of-source> -o <output directory>\n\
				eg.$0 -n example.h -o ~/Workspace/example/"
			;;
		?)
			echo "[err]:Unknown argument $OPTARG!"
			;;
	esac
done

shift $(($OPTIND - 1))

