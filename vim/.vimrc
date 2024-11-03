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
Plug 'dense-analysis/ale'
Plug 'scrooloose/nerdtree'
Plug 'xuyuanp/nerdtree-git-plugin'
" need install ctags
Plug 'majutsushi/tagbar'
" need install powerline-fonts
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'altercation/vim-colors-solarized'
Plug 'wakatime/vim-wakatime'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
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
let g:airline_solarized_bg='light'
let g:airline_powerline_fonts = 1

"solarized
set background=light
colorscheme solarized

