#! /usr/bin/env sh

if  [ -z "$NATIVE_INSTALL" ]; then
        NATIVE_INSTALL='sudo pacman --noconfirm --needed -Sy'
        AUR_INSTALL='yay --noconfirm --needed -Sy'
fi

if [ -z "$AUR_INSTALL" ]; then
        AUR_INSTALL='yay --noconfirm --needed -Sy'
fi

# ale plugin setting in $HOME/.vimrc
echo '
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
" Enable completion where available.
let g:ale_completion_enabled = 1'  >> $HOME/.vimrc

# support for python
pip install --no-cache-dir --user autopep8 black flake8 isort mypy prospector pycodestyle 'python-language-server[all]' pyre-check pylint vulture yapf

# support for markdown
#mkdir temp && cd temp && curl -L https://github.com/errata-ai/vale/releases/download/v1.0.1/vale_1.0.1_Linux_64-bit.tar.gz | tar -zxvf - && sudo cp vale /usr/bin/ && cd .. && rm -rf ./temp
yarn add alex prettier remark-lint textlint markdownlint write-good
gem install mdl
pip install --no-cache-dir --user proselint pyredpen

# support for reStructuredText
#$(AUR_INSTALL) vale
#mkdir temp && cd temp && curl -L https://github.com/errata-ai/vale/releases/download/v1.0.1/vale_1.0.1_Linux_64-bit.tar.gz | tar -zxvf - && sudo cp vale /usr/bin/ && cd .. && rm -rf ./temp
yarn add alex write-good
pip install --no-cache-dir --user proselint pyredpen rstcheck

# support for c
eval $NATIVE_INSTALL cppcheck clang gcc uncrustify
eval $AUR_INSTALL cquery ccls && rm -rf $HOME/.cache
pip install --no-cache-dir --user cpplint flawfinder

# support for c++ extra based on c support
eval $NATIVE_INSTALL clazy

