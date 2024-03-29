autocmd!

" =============== Color scheme ======================
autocmd BufEnter * colorscheme koehler
autocmd BufEnter *.tex colorscheme leafroad

" Line numbering "
set number relativenumber

" Tabwidth "
set tabstop=4 shiftwidth=4

" ================ Autocommands =====================
autocmd Filetype tex set textwidth=80 fo+=t
autocmd FileType tex setlocal spell spelllang=en_us

autocmd FileType cpp packadd deoplete-clang
autocmd FileType python packadd deoplete-jedi


" ================ Spellchecking ====================
nmap <leader>SE :set spell spelllang=en_us<cr>
nmap <leader>SD :set spell spelllang=de_20<cr>
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" ================ Other Commands ===================
nmap <leader>G :Neogit<cr>

" ================ Pugin Configuration ==============
" deoplete
let g:deoplete#enable_at_startup = 1

" vimtex
let g:tex_flavor = 'latex'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_quickfix_enabled=1
let g:vimtex_quickfix_mode=2
let g:vimtex_quickfix_autoclose_after_keystrokes=1

let g:vimtex_log_ignore = [
        \ 'Underfull',
        \ 'Overfull',
        \ 'specifier changed to',
        \ 'Token not allowed in a PDF string',
        \ 'headheight is too small',
        \ 'mdframed Warning',
      \ ]
let g:vimtex_quickfix_ignore_filters = g:vimtex_log_ignore
let g:vimtex_log_verbose = "1"

set conceallevel=2
let g:tex_conceal='abdmgs'


" ultisnips
let g:UltiSnipsExpandTrigger = '<c-e>'
" shortcut to go to next position
let g:UltiSnipsJumpForwardTrigger='<c-j>'
" shortcut to go to previous position
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" Compatibility between deoplete and ultisnips
" au BufEnter * exec "imap <expr><TAB> pumvisible() ? \"\\<C-n>\" : \"\\<TAB>\""

"  ale
let g:ale_fixers = {'cpp' : ['clangtidy', 'trim_whitespace']}

let g:ale_linters = {'c': ['clang'], 'cpp': ['gcc', 'clangd', 'clangtidy']}
let g:ale_cpp_clangd_options = '-std=c++20 -Wall -Wpedantic -Wextra'
let g:ale_cpp_clangtidy_extra_options = '-std=c++20'
let g:ale_cpp_clangtidy_checks = ['clang-analyzer-*', 'bugprone-*', 'cppcoreguidelines-*', 'performance-*']
let g:ale_cpp_cc_options = '-std=c++20 -Wall -Wpedantic -Wextra'

" Exands or completes the selected snippet/item in the popup menu "
imap <expr><silent><CR>
 \ pumvisible() ? deoplete#close_popup() : "\<CR>"

