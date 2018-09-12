#! /usr/bin/env sh

NATIVE_INSTALL='pacman -S'
AUR_INSTALL='aurman -S'

# build vim help documents
echo '" Load all plugins now.
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
sudo npm install alex prettier remark-lint textlint markdownlint write-good
gem install mdl
pip install --user proselint pyredpen

# support for reStructuredText
#$(AUR_INSTALL) vale
#mkdir temp && cd temp && curl -L https://github.com/errata-ai/vale/releases/download/v1.0.1/vale_1.0.1_Linux_64-bit.tar.gz | tar -zxvf - && sudo cp vale /usr/bin/ && cd .. && rm -rf ./temp
sudo npm install alex write-good
pip install --user proselint pyredpen rstcheck

# support for c
$NATIVE_INSTALL cppcheck clang gcc
$AUR_INSTALL cquery
pip install --user cpplint flawfinder


