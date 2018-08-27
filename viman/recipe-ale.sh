#! /usr/bin/env sh

# build vim help documents
echo '" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL' >> $HOME/.vimrc

# support for python
pip install --user autopep8 black flake8 isort mypy prospector pycodestyle 'python-language-server[all]' pyre-check pylint vulture yapf

# support for markdown
sudo npm install alex prettier remark-lint textlint markdownlint write-good 
gem install mdl 
pip install --user proselint pyredpen
wget https://github.com/errata-ai/vale/releases/download/v1.0.1/vale_1.0.1_Linux_64-bit.tar.gz | tar -xvf vale_1.0.1_Linux_64-bit.tar.gz && sudo cp vale /usr/bin/

