" get plugin manager if we don't already have it
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" interface
Plug 'mhinz/vim-signify'
Plug 'rhysd/git-messenger.vim'
"Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
"Plug 'kosayoda/nvim-lightbulb'
"Plug 'tjdevries/express_line.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" formatting
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
"Plug 'rhysd/vim-clang-format'
"Plug 'EgZvor/vim-black'
Plug 'a-vrma/black-nvim', { 'do': ':UpdateRemotePlugins' }

" debugging tooling
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

" language tooling
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate', 'branch': '0.5-compat' }
Plug 'hrsh7th/nvim-compe'
" successor to nvim-compe?
"Plug 'hrsh7th/nvim-cmp'
"Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'mfussenegger/nvim-jdtls'
Plug 'leoluz/nvim-dap-go'
Plug 'mfussenegger/nvim-dap-python'

" color schemes
Plug 'morhetz/gruvbox'
"Plug 'tomasr/molokai'
"Plug 'nanotech/jellybeans.vim'

" quality of life
Plug 'Raimondi/delimitMate'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-repeat'
Plug 'vimlab/split-term.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
Plug 'tpope/vim-eunuch'
"Plug 'wannesm/wmgraphviz.vim'

call plug#end()

" disable netrw
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

" used throughout script
let mapleader = "m"

" basic sanity
set ttimeoutlen=50
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
set foldmethod=syntax
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99

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
"set spelllang=en
"set spell

lua require("lsp_config")
lua require("compe_config")
lua require("treesitter_config")
lua require("telescope_config")
lua require("devicons_config")
"lua require("statusline_config")
lua require("dap_config")

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

nmap <leader>g <Plug>(git-messenger)

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

""" statusline

let g:airline_exclude_preview            = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme                      = 'gruvbox'

""" color scheme

let g:gruvbox_contrast_dark     = 'hard'
let g:gruvbox_invert_signs      = 1
let g:gruvbox_invert_tabline    = 1
let g:gruvbox_improved_warnings = 1

set termguicolors
set background=dark
colorscheme gruvbox

"
" commands
"

" search for TODOs with ag
"set grepprg=ag --vimgrep $* set grepformat=%f:%l:%c:%m
command! Todo silent lgrep -i --ignore-dir=vendor/ '\/\/.*TODO.*' | lwindow
command! TodoN lnext
command! TodoP lprevious
command! TodoE lclose

" list of stuff in the file!
"let g:tagbar_zoomwidth = 0
"let g:tagbar_case_insensitive = 1
"let g:tagbar_show_linenumbers = 1
"let g:tagbar_autoshowtag = 0
"let g:tagbar_previewwin_pos = "rightbelow"
let g:no_status_line = 1

" auto-open Tagbar when opening a buffer containing a supported file type
"autocmd BufEnter * nested :call tagbar#autoopen(0)
"nnoremap <F2> :TagbarToggle<CR>
"nnoremap gst :TagbarShowTag<CR>
"nnoremap st :TagbarOpen fj<CR>

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

" format on save via LSP
"augroup lsp_formatting
"    autocmd!
"
"    au BufWritePre *.c lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
"    au BufWritePre *.cpp lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
"
"    au BufWritePre Dockerfile lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"dockerls"})
"    au BufWritePre Dockerfile.* lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"dockerls"})
"
"    au BufWritePre *.go lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"gopls"})
"
"    au BufWritePre *.java lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"java_language_server"})
"
"    au BufWritePre *.js lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"tsserver"})
"
"    au BufWritePre *.json lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"jsonls"})
"
"    au BufWritePre *.kt lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"kotlin_language_server"})
"
"    au BufWritePre *.md lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"efm"})
"
"    au BufWritePre *.py lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"pyright"})
"
"    au BufWritePre *.sh lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"bashls"})
"
"    au BufWritePre *.tf lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"terraformls"})
"
"    au BufWritePre *.ts lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"tsserver"})
"
"    au BufWritePre *.yaml lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"yamlls"})
"augroup END

" customize built-in terminal
augroup terminal_buf
    autocmd!
    " let me navigate away from the terminal without needing to 'escape' first
    au TermOpen * tnoremap <buffer> <C-w>h <C-\><C-N><C-w>h
    au TermOpen * tnoremap <buffer> <C-w>j <C-\><C-N><C-w>j
    au TermOpen * tnoremap <buffer> <C-w>k <C-\><C-N><C-w>k
    au TermOpen * tnoremap <buffer> <C-w>l <C-\><C-N><C-w>l
    "
    " let me move the terminal window without needing to 'escape' first
    au TermOpen * tnoremap <buffer> <C-w>H <C-\><C-N><C-w>H
    au TermOpen * tnoremap <buffer> <C-w>J <C-\><C-N><C-w>J
    au TermOpen * tnoremap <buffer> <C-w>K <C-\><C-N><C-w>K
    au TermOpen * tnoremap <buffer> <C-w>L <C-\><C-N><C-w>L

    " I'm not actually modifying a buffer
    au TermClose * call feedkeys('\<CR>')

    au BufEnter,BufWinEnter,WinEnter term://* startinsert

    " https://github.com/neovim/neovim/issues/11072
    au TermEnter * setlocal scrolloff=0
    au TermLeave * setlocal scrolloff=5
augroup END

autocmd FileType json syntax match Comment +\/\/.\+$+

augroup cpp_files
    autocmd!
    au BufRead,BufNewFile *.tpp set filetype=cpp
augroup END

augroup csv_files
    autocmd!
    "au BufEnter *.csv set nowrap
    "au BufLeave *.csv set wrap
    au BufWinEnter *.csv set nowrap
    au BufWinLeave *.csv set wrap
augroup END

augroup docker_files
    autocmd!
    au BufRead,BufNewFile Dockerfile.* set filetype=Dockerfile
augroup END

augroup fsharp_files
    autocmd!
    au BufRead,BufNewFile *.fs set filetype=fsharp
augroup END

augroup glsl_files
    autocmd!
    au BufRead,BufNewFile *.frag set filetype=glsl
augroup END

augroup go_files
    autocmd!
    au BufRead,BufNewFile go.mod set filetype=gomod
augroup END

augroup html_files
    autocmd!
    au FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup java_files
    autocmd!
    au FileType java setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup json_files
    autocmd!
    au FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup make_files
    autocmd!
    au FileType make setlocal noexpandtab
augroup END

augroup markdown_files
    autocmd!
    au FileType markdown setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup svelte_files
    autocmd!
    au FileType svelte setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup typescript_files
    autocmd!
    au FileType typescript setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup vue_files
    autocmd!
    au FileType vue setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup xml_files
    autocmd!
    au FileType xml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup yaml_files
    autocmd!
    au BufRead,BufNewFile *.yml setfiletype yaml
    au FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

" why would it not be highlighted in all files?
augroup HiglightTODO
    autocmd!
    autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO', -1)
augroup END

function! s:read_large_file()
    if exists(':TSBufDisable')
        exec 'TSBufDisable autotag'
        exec 'TSBufDisable highlight'
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
