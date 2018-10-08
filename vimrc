" plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

" interface
Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'

" completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make' }
Plug 'zchee/deoplete-clang', { 'do': 'make' }
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'Raimondi/delimitMate'

" syntax checking
Plug 'vim-syntastic/syntastic'

" formatting
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'

" language specific
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }

" color schemes
Plug 'tomasr/molokai'
Plug 'nanotech/jellybeans.vim'

" quality of life
Plug 'jwhitley/vim-matchit'

" Obey editorconfig settings
Plug 'editorconfig/editorconfig-vim'

call plug#end()

" basic sanity
filetype indent plugin on
syntax on
set ttimeoutlen=50
set encoding=utf-8

" allow for project-specific vim config settings
set exrc
set secure

" color scheme
if $TERM =~ "kitty"
    let &t_ut=''
endif

set background=dark
colorscheme molokai

" usability
set ignorecase
set smartcase
set backspace=indent,eol,start
set nostartofline
set showcmd
set laststatus=2
set confirm
set ruler
set wildmenu
set scrolloff=5

" unset visualbell terminal code
set visualbell
set t_vb=

set mouse=a
set cmdheight=2
set number
set pastetoggle=<F11>

" searching
set hlsearch

" indentation
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" python settings
set pyxversion=3

" deoplete.nvim
set completeopt+=noselect

let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 0
let g:deoplete#complete_method = "omnifunc"
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_refresh_always = 1

let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
let g:deoplete#sources#clang#clang_header = '/usr/include/clang'
let g:deoplete#sources#clang#std = { 'c': 'c99', 'cpp': 'c++1z' }

let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#pointer = 1
let g:deoplete#sources#go#cgo = 1
let g:deoplete#sources#go#cgo#libclang_path = '/usr/lib/libclang.so'

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
let g:syntastic_go_checkers = ['golint', 'govet']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

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

" make actually uses tabs, so don't turn tabs to spaces
autocmd FileType make setlocal noexpandtab

" C++ template implementation files syntax highlighting
augroup filetypedetect
    au BufRead,BufNewFile *.tpp setfiletype cpp
    au BufRead,BufNewFile *.tmpl setfiletype cpp
augroup END

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

" format the whole file
nmap <F5> mzgg=G`z

" easy align (visual, interactive)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" clear last search
noremap <silent> <C-_> :let @/ = ""<CR>

" add a new line, but stay in normal mode
nnoremap <silent> <C-o> o<Esc>

" switch buffers
nnoremap <silent> <A-S-Left> :bp<CR>
nnoremap <silent> <A-S-Right> :bn<CR>

" switch tabs
nnoremap <silent> <A-Left> :tabprevious<CR>
nnoremap <silent> <M-h> :tabprevious<CR>
nnoremap <silent> <A-Right> :tabnext<CR>
nnoremap <silent> <M-l> :tabnext<CR>

" move tabs around
nnoremap <silent> <C-A-Left> :-tabmove<CR>
nnoremap <silent> <C-M-h> :-tabmove<CR>
nnoremap <silent> <C-A-Right> :+tabmove<CR>
nnoremap <silent> <C-M-l> :+tabmove<CR>

" text completion
inoremap <C-Space> <C-n>
imap <C-@> <C-Space>
inoremap <silent> <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent> <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<C-p>"

