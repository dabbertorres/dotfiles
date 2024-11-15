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
"Plug 'rest-nvim/rest.nvim', { 'commit': '91badd46c60df6bd9800c809056af2d80d33da4c' }
Plug 'mistweaverco/kulala.nvim'

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
Plug 'MattiasMTS/cmp-dbee'
Plug 'mfussenegger/nvim-lint'
Plug 'averms/black-nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ThePrimeagen/refactoring.nvim'

" autocompletion
"Plug 'hrsh7th/nvim-cmp'
Plug 'yioneko/nvim-cmp', { 'branch': 'perf' }
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
"Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
Plug 'wallpants/github-preview.nvim'
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
set splitright

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

set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes:1

" let g:python3_host_prog = $HOME . '/.local/share/nvim/py-venv/bin/python3'

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
-- require("rest_config")
require("kulala_config")
require("dotenv").setup()
require("dbee_config")
require("flatten_config")
require("github_preview_config")
require("uuid")
require("commands")
require("keymaps")
require("autocmds")
EOF

" enable folding, but disable it by default
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set nofoldenable
set foldlevelstart=99

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
