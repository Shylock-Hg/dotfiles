set nocompatible
syntax on
set nu
set cc=80
set guifont=Source\ Code\ Pro\ 12

set background=dark
colorscheme solarized

set tabstop=8
set shiftwidth=8

"complete search path
augroup setcomplete  "ensure for once
autocmd FileType python :set complete+=k/home/shylock/App/miniconda3/envs/mltoolchain/lib/python3.6
"autocmd FileType c :set complete+=k/usr/local/include
"autocmd FileType c :set complete+=k/usr/include
"autocmd FileType c :set complete+=k/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
"autocmd FileType c :set complete+=k/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include-fixed
augroup END

"show visible files only
let g:netrw_hide=1 

"indent guideline
augroup setindent  
autocmd FileType python :set listchars=tab:\|\ 
autocmd FileType python :set list

autocmd FileType c :set listchars=tab:\|\ 
autocmd FileType c :set list
augroup END

"Taglist
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

"WinManager
let g:winManagerWindowLayout='FileExplorer|TagList'

"cscope
set cscopequickfix=s-,c-,d-,i-,e-

"new-omni-completion
filetype plugin indent on
set completeopt=longest,menu

echo "(>^.<^)"

