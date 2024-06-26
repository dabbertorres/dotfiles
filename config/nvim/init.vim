" get plugin manager if we don't already have it
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" interface
Plug 'ellisonleao/gruvbox.nvim'
Plug 'nvim-lualine/lualine.nvim', { 'commit': '1e53bf7386619722b7cfae0d541b45978f0152e4' }
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'kosayoda/nvim-lightbulb'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'rcarriga/nvim-notify'
Plug 'akinsho/toggleterm.nvim'

" dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-neotest/nvim-nio'

" tools
"Plug 'nvim-neorg/neorg'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rest-nvim/rest.nvim', { 'commit': '91badd46c60df6bd9800c809056af2d80d33da4c' }

" git
Plug 'lewis6991/gitsigns.nvim'
Plug 'TimUntersberger/neogit'

" testing tooling
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-go'
Plug 'nvim-neotest/neotest-python'

" debugging tooling
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
Plug 'leoluz/nvim-dap-go'

" language tooling
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-treesitter/playground'
Plug 'mfussenegger/nvim-jdtls'
" Plug 'nanotee/sqls.nvim'
Plug 'kndndrj/nvim-dbee', { 'do': ':lua require(\"dbee\").install()' }
Plug 'mfussenegger/nvim-lint'
Plug 'averms/black-nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ThePrimeagen/refactoring.nvim'

" autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-calc'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'hrsh7th/cmp-path'
Plug 'rcarriga/cmp-dap'
Plug 'f3fora/cmp-spell'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip', { 'do': 'make install_jsregexp' }
Plug 'SmiteshP/nvim-navic'
Plug 'MunifTanjim/nui.nvim'
Plug 'SmiteshP/nvim-navbuddy'

" quality of life
Plug 'andymass/vim-matchup'
Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-repeat'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-abolish'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
Plug 'tpope/vim-eunuch'
Plug 'sindrets/diffview.nvim'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'willothy/flatten.nvim'
Plug 'b0o/schemastore.nvim'

call plug#end()

" disable unused plugins
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0

" used throughout script
let mapleader = "m"

" basic sanity
set timeoutlen=1000
set ttimeoutlen=10
set updatetime=100
set encoding=utf-8
set clipboard+=unnamedplus
set synmaxcol=300
set shortmess=filmnrxoOtTIcF

if has('mac')
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
endif

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
set nrformats=alpha,octal,hex,bin

" unset visualbell terminal code
set visualbell
set t_vb=

set mouse=a
set cmdheight=1
set number
set pastetoggle=<F12>

" searching
set hlsearch

" indentation
set autoindent
set smartindent
" set cindent
" set indentexpr=nvim_treesitter#indent()
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set textwidth=0
set wrap
" set breakindent
" set breakindentopt=sbr,shift:4
" set showbreak=>
set linebreak
let g:vim_indent_cont = &shiftwidth
filetype plugin indent on

" persistent undo
set undofile
set undolevels=1000
set undoreload=1000
" ensure undo directory exists
silent !mkdir -p "$HOME/.config/nvim/undo"

" rather than fix myself, workaround my flaws
command! Qa :qa

set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes:1

" let g:python3_host_prog = $HOME . '/.local/share/nvim/py-venv/bin/python3'

lua <<EOF
require("gruvbox_config")
require("notifications")
require("lsp_config")
require("nvim-autopairs").setup{}
require("cmp_config")
require("treesitter_config")
require("telescope_config")
require("devicons_config")
require("lualine_config")
require("dap_config")
require("diffview_config")
--lua require("neorg_config")
require("neogit_config")
require("gitsigns_config")
require("neotest_config")
require("toggleterm_config")
require("refactoring_config")
require("rest_config")
require("dotenv").setup()
require("dbee_config")
require("flatten_config")
EOF

" enable folding, but disable it by default
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable
set foldlevelstart=99

" generate a uuid
command! -nargs=0 UUID :exe 'norm i' . substitute(system('uuidgen | tr "[A-Z]" "[a-z]"'), '\n$', '', '')

let g:asmsyntax = 'nasm'

"
" vim-matchup
"

let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_offscreen = {
    \ 'method': 'popup',
    \ 'scrolloff': 5,
    \ }

" Using <Cmd> in the matchup mappings instead of :<c-u> (as matchup does out
" of the box) avoids any mode flickering in the status line.
" See https://github.com/andymass/vim-matchup/blob/ff3bea611696f5cfdfe61a939149daadff41f2af/autoload/matchup.vim#L242
let g:matchup_mappings_enabled = 1

"" the basic motions % and g%
"nnoremap <silent> % <Cmd>call matchup#motion#find_matching_pair(0, 1)<CR>
"nnoremap <silent> g% <Cmd>call matchup#motion#find_matching_pair(0, 0)<CR>
"
"" visual and operator-pending
"xnoremap <silent> % <Cmd>call matchup#motion#find_matching_pair(1, 1)<CR>
"xmap     <silent> % <Cmd>call matchup#motion#find_matching_pair(1, 1)<CR>
"
"xnoremap <silent> g% <Cmd>call matchup#motion#find_matching_pair(1, 0)<CR>
"xmap     <silent> g% <Cmd>call matchup#motion#find_matching_pair(1, 0)<CR>
"
"" ]% and [%
"nnoremap <silent> ]% <Cmd>call matchup#motion#find_unmatched(0, 1)<CR>
"nnoremap <silent> [% <Cmd>call matchup#motion#find_unmatched(0, 0)<CR>
"
"xnoremap <silent> ]% <Cmd>call matchup#motion#find_unmatched(1, 1)<CR>
"xnoremap <silent> [% <Cmd>call matchup#motion#find_unmatched(1, 0)<CR>
"xmap     <silent> ]% <Cmd>call matchup#motion#find_unmatched(1, 1)<CR>
"xmap     <silent> [% <Cmd>call matchup#motion#find_unmatched(1, 0)<CR>
"
"" jump inside z%
"nnoremap <silent> z% <Cmd>call matchup#motion#jump_inside(0)<CR>
"xnoremap <silent> z% <Cmd>call matchup#motion#jump_inside(1)<CR>
"xmap     <silent> z% <Cmd>call matchup#motion#jump_inside(1)<CR>
"
"" 'opposite' of z%
"nnoremap <silent> Z% <Cmd>call matchup#motion#jump_inside_prev(0)<CR>
"xnoremap <silent> Z% <Cmd>call matchup#motion#jump_inside_prev(1)<CR>
"xmap     <silent> Z% <Cmd>call matchup#motion#jump_inside_prev(1)<CR>
"inoremap <silent> <C-g>% <C-\><C-o><Cmd>call matchup#motion#insert_mode()<CR>

" split-term
let g:disable_key_mappings = 1
set splitright

" fzf
let g:fzf_buffers_jump = 1

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

let g:zig_fmt_autosave = 0

" prolog specific behaviors
let g:prolog_swipl_timeout = 10

"
" commands
"

command! Todo silent lgrep -i --ignore-dir=vendor/ '\/\/.*TODO.*' | lwindow
command! TodoN lnext
command! TodoP lprevious
command! TodoE lclose

" easy align (visual, interactive)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" end search
nnoremap <silent> <leader>/ <Cmd>let @/ = ""<CR>

" switch buffers
nnoremap <silent> gb <Cmd>bp<CR>
nnoremap <silent> gB <Cmd>bn<CR>

" move tabs around
nnoremap <silent> ght <Cmd>-tabmove<CR>
nnoremap <silent> glt <Cmd>+tabmove<CR>

"nnoremap ,f <Plug>(fzf-complete-file)

function! s:trim_whitespace()
    let l:winview = winsaveview()
    silent! %s/\s\+$//e
    call winrestview(l:winview)
endfunction

" trim trailing whitespace on write
" autocmd! BufWritePre * call <SID>trim_whitespace()

augroup python_black
    autocmd!
    au BufWritePre *.py call Black()
augroup END
let g:black#settings = {
    \ 'fast': 1,
    \ 'line_length': 100,
\}

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
    au BufFilePre,BufNewFile,BufReadPost *.tpp set filetype=cpp " C++ template implementation files
    au BufFilePre,BufNewFile,BufReadPost *.cppm set filetype=cpp " C++ importable module unit
    au BufFilePre,BufNewFile,BufReadPost Dockerfile.* set filetype=dockerfile
    au BufFilePre,BufNewFile,BufReadPost *.fs set filetype=fsharp
    au BufFilePre,BufNewFile,BufReadPost *.frag set filetype=glsl
    au BufFilePre,BufNewFile,BufReadPost go.mod set filetype=gomod
    au BufFilePre,BufNewFile,BufReadPost *.cshtml set filetype=html
    au BufFilePre,BufNewFile,BufReadPost *.gohtml set filetype=html
    au BufFilePre,BufNewFile,BufReadPost *.ftlh set filetype=html
augroup END

augroup different_indent_filetypes
    autocmd!
    au FileType cmake setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType hcl setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType java setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType jsonnet setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType make setlocal noexpandtab
    au FileType markdown setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType sql setlocal tabstop=2 softtabstop=2 shiftwidth=2 commentstring=--%s
    au FileType svelte setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType terraform setlocal tabstop=2 softtabstop=2 shiftwidth=2 commentstring=#%s
    au FileType typescript setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType vue setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType xml setlocal tabstop=2 softtabstop=2 shiftwidth=2
    au FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup csv_files
    autocmd!
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

    if exists(':LspStop')
        exec 'LspStop'
    endif

    setlocal syntax=off
    setlocal foldmethod=manual
    setlocal filetype=off
    setlocal noundofile
    setlocal noswapfile
    setlocal noloadplugins
endfunction

augroup large_files
    au BufReadPre * if getfsize(expand("%")) > 1024 * 1024 | exec s:read_large_file() | endif
augroup END
