syntax on
set nu
set cc=80
set guifont=Source\ Code\ Pro\ 16

let g:indent_guides_enable_on_vim_startup = 1

let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

let g:winManagerWindowLayout='FileExplorer|TagList'
nmap wm :WMToggle<cr>

:set cscopequickfix=s-,c-,d-,i-,e-

filetype plugin indent on
set completeopt=longest,menu

let g:SuperTabRetainCompletionType=2
let g:SuperTabDefaultCompletionType="<C-X><C-O>"
