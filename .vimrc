syntax on
set nu
set cc=80
set guifont=Source\ Code\ Pro\ 14

set background=dark
colorscheme solarized

set tabstop=8
set shiftwidth=8
set expandtab

"show visible files only
let g:netrw_hide=1 

let g:indent_guides_enable_on_vim_startup = 1

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

"super tab autocomplete
let g:SuperTabRetainCompletionType=2
let g:SuperTabDefaultCompletionType="<C-X><C-O>"
