autocmd!

colorscheme leafroad

" Line numbering "
set number relativenumber

" Tabwidth "
set tabstop=4 shiftwidth=4

" always show diagnostic column
" set signcolumn=yes
" ================ Spellchecking ====================
autocmd FileType tex setlocal spell spelllang=en_us
nmap <leader>SE :set spell spelllang=en_us<cr>
nmap <leader>SD :set spell spelllang=de_20<cr>
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" call plug#begin('~/.vim/plugged')
" Plug 'dense-analysis/ale'
" Plug 'tpope/vim-fugitive'
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'Shougo/deoplete-clangx', { 'do': ':UpdateRemotePlugins' }
" let g:deoplete#enable_at_startup = 1
" Plug 'lervag/vimtex'
" Plug 'PietroPate/vim-tex-conceal'
" 
" Plug 'Raimondi/delimitMate'
" Plug 'christoomey/vim-tmux-navigator'
" Plug 'sirver/ultisnips'
" call plug#end()

" au Filetype tex imap ae ä
" au Filetype tex imap Ae Ä
" au Filetype tex imap oe ö
" au Filetype tex imap Oe Ö
" au Filetype tex imap ue ü
" au Filetype tex imap Ue Ü
" au Filetype tex imap ssss ß
" au Filetype tex imap Ssss ẞ
" line width
au Filetype tex set textwidth=80 fo+=t


" ================ Pugin Configuration ==============
"  vimtex
let g:tex_flavor = 'latex'
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:vimtex_view_general_options_latexmk = '--unique'
let g:vimtex_quickfix_enabled = 0

set conceallevel=2
let g:tex_conceal='abdmgs'


" ultisnips
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<s-tab>'

function! g:UltiSnips_Complete()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
		call UltiSnips#JumpForwards()
		if g:ulti_jump_forwards_res == 0
			if pumvisible()
				return "\<C-n>"
			else
               return "\<TAB>"
            endif
        endif
    endif
    return ""
endfunction

au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"

"  ale
" Map expression when a tab is hit:
"           checks if the completion popup is visible
"           if yes
"               then it cycles to next item
"           else
"               if expandable_or_jumpable
"                   then expands_or_jumps
"                   else returns a normal TAB
let g:ale_fixers = {'cpp' : ['clangtidy', 'trim_whitespace']}

let g:ale_linters = {'c': ['clang'], 'cpp': ['gcc', 'clangd', 'clangtidy']}
let g:ale_cpp_clangd_options = '-std=c++17 -Wall -Wpedantic -Wextra'
let g:ale_cpp_clangtidy_extra_options = '-std=c++17'
let g:ale_cpp_clangtidy_checks = ['clang-analyzer-*', 'bugprone-*', 'cppcoreguidelines-*', 'performance-*']
let g:ale_cpp_cc_options = '-std=c++17 -Wall -Wpedantic -Wextra'

" Exands or completes the selected snippet/item in the popup menu "
imap <expr><silent><CR>
 \ pumvisible() ? deoplete#close_popup() : "\<CR>"

