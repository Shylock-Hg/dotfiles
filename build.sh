#! /usr/bin/env sh

###############################################################################
# install my custom ultility scripts to `/usr/bin`
# 1. archlinux-python
# 2. mksource
# 3. win2nix
###############################################################################

readonly url_prefix='https://raw.githubusercontent.com/Shylock-Hg/config.linux/master'
readonly prefix='/usr/local/bin'

readonly scripts='archlinux-python mksource win2nix startup'

# build scripts
build() {
        for script in $*
        do
                echo "From $url_prefix/$script.sh to $prefix/$script"
                if ! sudo curl $url_prefix/$script.sh -o $prefix/$script; then
                        exit 1
                fi
        done
}

build $scripts
