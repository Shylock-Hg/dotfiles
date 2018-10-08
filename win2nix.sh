#! /usr/bin/env sh

###############################################################################
# convert sources(c/c++) from windows to unix flavor
###############################################################################

# convert backslash to slash in include path
# convert line break to unix flavor
find . -type f -name '*.h' -print -o -name '*.c' -print |\
xargs sed -i -e '/#include/s/\\/\//g' -e 's///'

