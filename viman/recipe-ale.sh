#! /usr/bin/env sh

NATIVE_INSTALL='sudo pacman -Sy --noconfirm'
AUR_INSTALL='sudo yay -Sy --noconfirm'

# ale plugin setting in $HOME.vimrc
echo -e '\n" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
" Enable completion where available.
let g:ale_completion_enabled = 1'  >> $HOME/.vimrc

# support for python
pip install --user autopep8 black flake8 isort mypy prospector pycodestyle 'python-language-server[all]' pyre-check pylint vulture yapf

# support for markdown
#mkdir temp && cd temp && curl -L https://github.com/errata-ai/vale/releases/download/v1.0.1/vale_1.0.1_Linux_64-bit.tar.gz | tar -zxvf - && sudo cp vale /usr/bin/ && cd .. && rm -rf ./temp
yes | npm install alex prettier remark-lint textlint markdownlint write-good
gem install mdl
pip install --user proselint pyredpen

# support for reStructuredText
#$(AUR_INSTALL) vale
#mkdir temp && cd temp && curl -L https://github.com/errata-ai/vale/releases/download/v1.0.1/vale_1.0.1_Linux_64-bit.tar.gz | tar -zxvf - && sudo cp vale /usr/bin/ && cd .. && rm -rf ./temp
yes | npm install alex write-good
pip install --user proselint pyredpen rstcheck

# support for c
eval $NATIVE_INSTALL cppcheck clang gcc
eval $AUR_INSTALL cquery
pip install --user cpplint flawfinder

# support for c++

