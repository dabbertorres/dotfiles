" project-specific vim config settings
set exrc
set secure

" runtime paths
set runtimepath=~/.vimrc,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/after

" indentation
filetype indent plugin on
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" syntax
filetype on
syntax on

" auto complete
set wildmenu

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

" latex stuff
set grepprg=grep\ -nH\ $*
let g:tex_flavor = "latex"

" make
autocmd FileType make setlocal noexpandtab

