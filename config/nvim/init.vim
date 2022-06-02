" get plugin manager if we don't already have it
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" interface
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
"Plug 'kosayoda/nvim-lightbulb'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'rcarriga/nvim-notify'
Plug 'vimlab/split-term.vim'

" dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

" tools
Plug 'nvim-neorg/neorg'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" git
" Plug 'mhinz/vim-signify'
Plug 'lewis6991/gitsigns.nvim'
" Plug 'rhysd/git-messenger.vim'
Plug 'TimUntersberger/neogit'

" formatting
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
"Plug 'EgZvor/vim-black'
Plug 'a-vrma/black-nvim', { 'do': ':UpdateRemotePlugins' }

" debugging tooling
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

" language tooling
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdateSync' }
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'mfussenegger/nvim-jdtls'
Plug 'mfussenegger/nvim-dap-python'
Plug 'leoluz/nvim-dap-go'
Plug 'nanotee/sqls.nvim'
Plug 'mfussenegger/nvim-lint'

" autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-calc'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-path'
" Plug 'f3fora/cmp-spell'

" color schemes
"Plug 'morhetz/gruvbox'
Plug 'ellisonleao/gruvbox.nvim'

" quality of life
Plug 'Raimondi/delimitMate'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-repeat'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
Plug 'tpope/vim-eunuch'
Plug 'lewis6991/spellsitter.nvim'
"Plug 'wannesm/wmgraphviz.vim'
Plug 'sindrets/diffview.nvim'

call plug#end()

" disable netrw
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

" used throughout script
let mapleader = "m"

" basic sanity
set timeoutlen=1000
set ttimeoutlen=10
set updatetime=100
set encoding=utf-8
set clipboard+=unnamedplus
set synmaxcol=500

let g:clipboard = {
    \ 'name': 'pbcopy',
    \ 'copy': {
    \     '+': 'pbcopy',
    \     '*': 'pbcopy',
    \ },
    \ 'paste': {
    \     '+': 'pbpaste',
    \     '*': 'pbpaste',
    \ },
    \ 'cache_enabled': 0,
\ }

" usability
set autowrite
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
set inccommand=nosplit

" enable folding, but disable it by default
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99

" unset visualbell terminal code
set visualbell
set t_vb=

set mouse=a
set cmdheight=2
set number
set pastetoggle=<F12>

" searching
set hlsearch

" indentation
"set autoindent
"set smartindent
"set cindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set textwidth=0
set wrap
"set breakindent
"set breakindentopt=sbr,shift:4
"set showbreak=>
set linebreak
let g:vim_indent_cont = &shiftwidth
filetype plugin indent on

" persistent undo
set undofile
set undodir=~/.config/nvim/undo
set undolevels=100
set undoreload=1000
" ensure undo directory exists
silent !mkdir -p "$HOME/.config/nvim/undo"

" python settings
"set pyxversion=3

" rather than fix myself, workaround my flaws
command! Qa :qa

set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes

""" spelling
" set spelllang=en_us
" set spell

""" color scheme

let g:gruvbox_contrast_dark     = 'hard'
let g:gruvbox_invert_signs      = 1
let g:gruvbox_invert_tabline    = 1
let g:gruvbox_improved_warnings = 1

set termguicolors
set background=dark
colorscheme gruvbox

" my lua configs
lua require("notifications")
lua require("lsp_config")
lua require("cmp_config")
lua require("treesitter_config")
lua require("telescope_config")
lua require("devicons_config")
lua require("lualine_config")
lua require("dap_config")
lua require("diffview_config")
lua require("neorg_config")
lua require("neogit_config")
lua require("gitsigns_config")

lua require("spellsitter").setup{ enable = true }

" netrw explorer
"let g:netrw_liststyle    = 3
"let g:netrw_banner       = 0
"let g:netrw_browse_split = 2
"let g:netrw_winsize      = 25
"let g:netrw_altv         = 1

" generate a uuid
command! -nargs=0 UUID :exe 'norm i' . substitute(system('uuidgen'), '\n$', '', '')

let g:asmsyntax = 'nasm'

let delimitMate_expand_cr = 1

" split-term
let g:disable_key_mappings = 1
set splitbelow

" fzf
let g:fzf_buffers_jump = 1

" terraform
"let g:terraform_align         = 1
"let g:terraform_fold_sections = 0
"let g:terraform_fmt_on_save   = 1

" git messenger
let g:git_messenger_always_into_popup = v:true

"
" zig settings
"
let g:zig_fmt_autosave = 0

" markdown preview
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0
let g:mkdp_open_to_the_world = 1
let g:mkdp_browser = ''
let g:mkdp_echo_preview_url = 1
let g:mkdp_browserfunc = ''
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {}
    \ }
let g:mkdp_markdown_css = ''
let g:mkdp_highlight_css = ''
let g:mkdp_port = ''

" prolog specific behaviors
let g:prolog_swipl_timeout = 10

"
" commands
"

" search for TODOs with ag
"set grepprg=ag --vimgrep $* set grepformat=%f:%l:%c:%m
command! Todo silent lgrep -i --ignore-dir=vendor/ '\/\/.*TODO.*' | lwindow
command! TodoN lnext
command! TodoP lprevious
command! TodoE lclose

" easy align (visual, interactive)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" end search
nnoremap <silent> <leader>/ :let @/ = ""<CR>

" switch buffers
nnoremap <silent> gb :bp<CR>
nnoremap <silent> gB :bn<CR>

" move tabs around
nnoremap <silent> ght :-tabmove<CR>
nnoremap <silent> glt :+tabmove<CR>

"nnoremap ,f <Plug>(fzf-complete-file)

function! s:trim_whitespace()
    let l:winview = winsaveview()
    silent! %s/\s\+$//e
    call winrestview(l:winview)
endfunction

" trim trailing whitespace on write
autocmd! BufWritePre * call <SID>trim_whitespace()

augroup python_black
    autocmd!
    au BufWritePre *.py call Black()
augroup END
let g:black#settings = {
    \ 'fast': 1,
    \ 'line_length': 100,
\}
let g:python3_host_prog = $HOME . '/.local/share/nvim/py-venv/bin/python'

" customize built-in terminal
augroup terminal_buf
    autocmd!
    " let me navigate away from the terminal without needing to 'escape' first
    au TermOpen * tnoremap <buffer> <C-w>h <C-\><C-N><C-w>h
    au TermOpen * tnoremap <buffer> <C-w>j <C-\><C-N><C-w>j
    au TermOpen * tnoremap <buffer> <C-w>k <C-\><C-N><C-w>k
    au TermOpen * tnoremap <buffer> <C-w>l <C-\><C-N><C-w>l

    " let me move the terminal window without needing to 'escape' first
    au TermOpen * tnoremap <buffer> <C-w>H <C-\><C-N><C-w>H
    au TermOpen * tnoremap <buffer> <C-w>J <C-\><C-N><C-w>J
    au TermOpen * tnoremap <buffer> <C-w>K <C-\><C-N><C-w>K
    au TermOpen * tnoremap <buffer> <C-w>L <C-\><C-N><C-w>L

    " I'm not actually modifying a buffer
    au TermClose * call feedkeys('\<CR>')

    au BufEnter,BufWinEnter,WinEnter term://* startinsert
augroup END

augroup extra_file_types
    autocmd!
    au BufFilePre,BufNewFile,BufReadPost *.tpp set filetype=cpp
    au BufFilePre,BufNewFile,BufReadPost Dockerfile.* set filetype=Dockerfile
    au BufFilePre,BufNewFile,BufReadPost *.fs set filetype=fsharp
    au BufFilePre,BufNewFile,BufReadPost *.frag set filetype=glsl
    au BufFilePre,BufNewFile,BufReadPost go.mod set filetype=gomod
    au BufFilePre,BufNewFile,BufReadPost *.cshtml set filetype=html
augroup END

augroup different_indent_filetypes
    autocmd!
    au FileType hcl setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType java setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType make setlocal noexpandtab
    au FileType markdown setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType svelte setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType terraform setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType typescript setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType vue setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType xml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup csv_files
    autocmd!
    "au BufEnter *.csv set nowrap
    "au BufLeave *.csv set wrap
    au BufWinEnter *.csv set nowrap
    au BufWinLeave *.csv set wrap
augroup END

" why would it not be highlighted in all files?
augroup HiglightTODO
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO', -1)
augroup END

function! s:read_large_file()
    if exists(':TSBufDisable')
        exec 'TSBufDisable incremental_selection highlight indent matchup'
    endif
    setlocal syntax=off
    setlocal foldmethod=manual
    setlocal filetype=off
    setlocal noundofile
    setlocal noswapfile
    setlocal noloadplugins
endfunction

augroup large_files
    au BufReadPre * if getfsize(expand("%")) > 512 * 1024 | exec s:read_large_file() | endif
augroup END
