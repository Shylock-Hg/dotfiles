""""""""""""""""""""""""""""""native setting"""""""""""""""""""""""""""""""
set nocompatible
syntax on
set nu
set cc=80
set guifont=Source\ Code\ Pro\ 12
set tabstop=4
set shiftwidth=4

"complete search path
"augroup setcomplete  "ensure for once
"autocmd FileType python :set complete+=k/home/shylock/App/miniconda3/envs/mltoolchain/lib/python3.6
"autocmd FileType c :set complete+=k/usr/local/include
"autocmd FileType c :set complete+=k/usr/include
"autocmd FileType c :set complete+=k/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
"autocmd FileType c :set complete+=k/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include-fixed
"augroup END

"show visible files only
"let g:netrw_hide=1 

"indent guideline
"augroup setindent  
"autocmd FileType python :set listchars=tab:\|\ 
"autocmd FileType python :set list

"autocmd FileType c :set listchars=tab:\|\ 
"autocmd FileType c :set list
"augroup END



"""""""""""""""""""""""""""""plugin support""""""""""""""""""""""""""""""""""""
" pathogen
execute pathogen#infect()
call pathogen#helptags()

"solarized
set background=dark
colorscheme solarized

"NERDTree
let NERDTreeWinSize=20
let NERDTreeShowHidden=1

"Tarbar
let g:tagbar_width=20

"new-omni-completion
filetype plugin indent on
set completeopt=longest,menu

"airline
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts = 1

"ale
" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL

echo "(>^.^<)"

