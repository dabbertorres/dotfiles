set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

" set up Vundle plugin management
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" interface
Plugin 'tpope/vim-fugitive'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ctrlpvim/ctrlp.vim'

" text completion
Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'
Plugin 'Raimondi/delimitMate'

" syntax checking
Plugin 'vim-syntastic/syntastic'

" formatting
Plugin 'godlygeek/tabular'

" language specific
Plugin 'rust-lang/rust.vim'
Plugin 'zah/nim.vim'
Plugin 'fatih/vim-go'

" color schemes
Plugin 'tomasr/molokai'
Plugin 'nanotech/jellybeans.vim'

" quality of life
Plugin 'jwhitley/vim-matchit'

" Obey editorconfig settings
Plugin 'editorconfig/editorconfig-vim'

call vundle#end()

" basic sanity
filetype indent plugin on
syntax on

" allow for project-specific vim config settings
set exrc
set secure

" color scheme
set background=dark
let g:molokai_original=1
let g:rehash256=1
colorscheme molokai

" indentation
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" NERD tree
let g:nerdtree_tabs_open_on_console_startup=0

" YouCompleteMe
let g:ycm_key_invoke_completion='<C-Space>'
let g:ycm_auto_trigger=1
let g:ycm_confirm_extra_conf=0
let g:ycm_rust_src_path='~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src'

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0

" airline
let g:airline#extensions#tabline#enabled=1

" ctrlp
let g:ctrlp_user_command=['.git', 'cd %s && git ls-files -co --exclude-standard']

" syntax highlighting
let g:go_highlight_functions=1
let g:go_highlight_methods=1
let g:go_highlight_structs=1
let g:go_highlight_operators=1
let g:go_highlight_build_constraints=1

"
" commands
"

" if forgot to open vim as sudo, save as sudo, and reload the (now changed) file
cnoremap sudow w !sudo tee % > /dev/null <CR> :e!<CR>

"
" keybindings
"

" block folding, if folded, toggles, if not, folds
nmap <silent> <F2> @=(foldlevel('.') ? 'za' : 'zfa}')<CR>

" list of stuff in the file!
nmap <F8> :TagbarToggle<CR> 

" filesystem/project view!
nmap <F7> :NERDTreeToggle<CR>

" format the whole file
nmap <F5> mzgg=G`z

" unhighlight search results
noremap <silent> <F4> :noh<CR>

" add a new line, but stay in normal mode
nnoremap <C-o> o<Esc>

" auto complete
set wildmenu

" switch buffers
nnoremap <silent> <A-S-Left> :bp<CR>
nnoremap <silent> <A-S-Right> :bn<CR>

" switch tabs
nnoremap <silent> <A-Left> :tabprevious<CR>
nnoremap <silent> <A-Right> :tabnext<CR>

" move tabs around
nnoremap <silent> <C-A-Left> :-tabmove<CR>
nnoremap <silent> <C-A-Right> :+tabmove<CR>

" toggle paste mode
map <F11> :set invpaste<CR>

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

" make actually uses tabs, so don't turn tabs to spaces
autocmd FileType make setlocal noexpandtab

" C++ template implementation files syntax highlighting
augroup filetypedetect
        au BufRead,BufNewFile *.tpp setfiletype cpp
        au BufRead,BufNewFile *.tmpl setfiletype cpp
augroup END

