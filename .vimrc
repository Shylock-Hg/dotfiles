""""""""""""""""""""""""""""""native setting""""""""""""""""""""""""""""""""""
set nocompatible " not comptible to vi
syntax on " syntax highlight
set nu " line number
set cc=80

" tab setting
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

set hlsearch " highlight the search match

""""""""""""""""""""""""""""""plugin setting""""""""""""""""""""""""""""""""""
" vim-plug
call plug#begin()
Plug 'w0rp/ale', {do: 'curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/viman/recipe-ale.sh | sh'}
Plug 'scrooloose/nerdtree'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar', {do: 'sudo pacman --noconfirm --needed -Sy ctags'}
Plug 'vim-airline/vim-airline', {do: 'sudo pacman --needed --noconfirm -Sy powerline-fonts'}
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
Plug 'wakatime/vim-wakatime', {do: 'curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/viman/recipe-vim-wakatime.sh | sh'}
call plug#end()

" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
" Enable completion where available.
let g:ale_completion_enabled = 1

"NERDTree
let NERDTreeWinSize=20
let NERDTreeShowHidden=1

"Tarbar
let g:tagbar_width=20

"airline
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1

"solarized
set background=dark
colorscheme solarized

