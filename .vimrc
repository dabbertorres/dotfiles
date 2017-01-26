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
syntax on

" auto complete
set wildmenu

" usability
set ignorecase
set smartcase
set backspace=indent,eol,start
set nostartofline
set showcmd
set laststatus=2
set confirm
set ruler
set visualbell
set t_vb= " unset visualbell terminal code
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

