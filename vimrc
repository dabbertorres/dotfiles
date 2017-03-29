" runtime paths
set runtimepath=~/.vimrc,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim

" plugin management
execute pathogen#infect()

" allow for project-specific vim config settings
set exrc
set secure

" indentation
filetype indent plugin on
syntax on
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" syntax highlighting etc
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" auto complete
set wildmenu
let g:neocomplete#enable_at_startup = 1

" tabs!
command! -complete=file -nargs=1 Te tabedit <args>
nnoremap <silent> <A-Left> :tabprevious<CR>
nnoremap <silent> <A-Right> :tabnext<CR>

nnoremap <silent> <C-A-Left> :execute 'silent! tabmove ' . (tabpagenr() - 2)<CR>
nnoremap <silent> <C-A-Right> :execute 'silent! tabmove ' . (tabpagenr() + 1)<CR>

" usability
set ignorecase
set smartcase
set backspace=indent,eol,start
set nostartofline
set showcmd
set laststatus=2
set confirm
set ruler

" unset visualbell terminal code
set visualbell
set t_vb= 

set mouse=a
set cmdheight=2
set number
set pastetoggle=<F11>

" searching
set hlsearch

" keybindings
map Y y$
nnoremap <C-L> :nohl<CR><C-L>
nmap <F8> :TagbarToggle<CR>
map <C-n> :NERDTreeToggle<CR>
nn <C-g> :call JumpToDef()<CR>

" latex stuff
set grepprg=grep\ -nH\ $*
let g:tex_flavor = "latex"

" make
autocmd FileType make setlocal noexpandtab

" C++ template implementation files
augroup filetypedetect
    au BufRead,BufNewFile *.tpp setfiletype cpp
augroup END

" Nim goto definition support
fun! JumpToDef()
    if exists("*GotoDefinition_" . &filetype)
        call GotoDefinition_{&filetype}()
    else
        exe "norm! \<C-]>"
    endif
endf

