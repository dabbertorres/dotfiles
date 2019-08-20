" get plugin manager if we don't already have it
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" interface
Plug 'mhinz/vim-signify'
Plug 'majutsushi/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" completion
"Plug 'Raimondi/delimitMate'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" syntax check
Plug 'w0rp/ale'

" syntax support
Plug 'tikhomirov/vim-glsl'

" formatting
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
"Plug 'rhysd/vim-clang-format'

" language tooling
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'OmniSharp/omnisharp-vim'

" color schemes
Plug 'tomasr/molokai'
Plug 'nanotech/jellybeans.vim'
Plug 'morhetz/gruvbox'

" quality of life
Plug 'jwhitley/vim-matchit'
Plug 'tpope/vim-repeat'
Plug 'vimlab/split-term.vim'
Plug 'editorconfig/editorconfig-vim'

" extra helpers
Plug 'kana/vim-operator-user'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'wannesm/wmgraphviz.vim'

" myndshft config
Plug 'https://bitbucket.org/myndshft/mynd-config-vim.git', { 'do': 'make' }

call plug#end()

" basic sanity
set ttimeoutlen=50
set updatetime=300
set encoding=utf-8
set clipboard+=unnamedplus
let mapleader = "m"

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
set textwidth=0
set wrap
set breakindent

" persistent undo
set undofile
set undodir=~/.config/nvim/undo
set undolevels=100
set undoreload=1000
" ensure undo directory exists
silent !mkdir -p "$HOME/.config/nvim/undo"

" python settings
"set pyxversion=3

""" completion config
set hidden
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=yes

inoremap <silent> <expr><Tab>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <silent> <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<C-p>"
inoremap <silent> <expr> <C-Space> coc#refresh()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" use `:OR` for organize import of current buffer
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" auto close scratch/preview window after completion
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" vim-lsp odd behavior workaround: https://github.com/dense-analysis/ale/issues/1212
let g:lsp_diagnostics_echo_cursor = 0

" ale
let g:ale_completion_enabled              = 0
let g:ale_sign_column_always              = 1
let g:ale_fix_on_save                     = 1
let g:ale_set_quickfix                    = 1
let g:ale_virtualtext_cursor              = 1
let g:ale_warn_about_trailing_blank_lines = 0

let g:ale_linters = {
            \ 'python': ['flake8', 'mypy'],
            \ 'c': ['clang', 'clangd'],
            \ 'cpp': ['clang', 'clangd'],
            \ 'cs': ['OmniSharp']
            \ }

let g:ale_fixers = {
            \ '*': ['trim_whitespace'],
            \ 'python': ['black', 'isort'],
            \ 'c': ['trim_whitespace', 'clang-format', 'clangtidy'],
            \ 'cpp': ['trim_whitespace', 'clang-format', 'clangtidy']
            \ }

let g:ale_c_parse_makefile         = 0
let g:ale_c_parse_compile_commands = 1
let g:ale_c_clang_executable       = '/usr/local/opt/llvm/bin/clang'
let g:ale_c_clangd_executable      = '/usr/local/opt/llvm/bin/clangd'
let g:ale_cpp_clang_executable     = '/usr/local/opt/llvm/bin/clang'
let g:ale_cpp_clangd_executable    = '/usr/local/opt/llvm/bin/clangd'
let g:ale_c_clang_options          = '-std=c11 -Wall -Wextra -I/usr/local/include -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
let g:ale_cpp_clang_options        = '-std=c++17 -Wall -Wextra -I/usr/local/include -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
let g:ale_c_clangd_options         = '-function-arg-placeholders -all-scopes-completion -pch-storage=memory -limit-results=50 -completion-style=detailed'
let g:ale_cpp_clangd_options       = '-function-arg-placeholders -all-scopes-completion -pch-storage=memory -limit-results=50 -completion-style=detailed'
let g:ale_python_flake8_options    = '--max-line-length=120'
let g:ale_python_black_options     = '--line-length 120'

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" split-term
let g:disable_key_mappings = 1
set splitbelow

"
" go settings
"

let g:go_fold_enable                 = []
let g:go_highlight_functions         = 1
let g:go_highlight_function_calls    = 1
let g:go_highlight_methods           = 1
let g:go_highlight_types             = 1
let g:go_highlight_fields            = 1
let g:go_highlight_operators         = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags     = 1
let g:go_highlight_debug             = 1

let g:go_fmt_command      = "goimports"
let g:go_mod_fmt_autosave = 1
let g:go_asmfmt_autosave  = 1
let g:go_fmt_autosave     = 1

let g:go_metalinter_autosave        = 0
let g:go_metaliner_enabled          = []
let g:go_metaliner_autosave_enabled = []

let g:go_term_enabled            = 1
let g:go_term_mode               = "VTerm"
let g:go_updatetime              = 100
let g:go_code_completion_enabled = 0
let g:go_jump_to_error           = 0
let g:go_def_mapping_enabled     = 0
let g:go_gorename_prefill        = ''
let g:go_gocode_propose_source   = 0

" markdown preview
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
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

""" status line, after plugins and such are setup

let g:airline#extensions#ale#enabled     = 1
let g:airline#extensions#coc#enabled     = 1
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

" modal cursor: '|' for insert mode, '_' for replace, block for normal.
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

"
" commands
"

" if forgot to open vim as sudo, save as sudo, and reload the (now changed) file
command! Sudow w | !sudo tee % > /dev/null<CR> :e!

" search for TODOs with ag
set grepprg=ag
command! Todo silent lgrep -i --ignore-dir=vendor/ '\/\/.*TODO.*' | lwindow
command! TodoN lnext
command! TodoP lprevious
command! TodoE lclose

command! Reloadrc silent :source ~/.config/nvim/init.vim | :AirlineRefresh

" list of stuff in the file!
nmap <F8> :TagbarToggle<CR>

" easy align (visual, interactive)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" end search
nnoremap <silent> <leader>/ :let @/=""<CR>

" switch buffers
nnoremap <silent> gb :bp<CR>
nnoremap <silent> gB :bn<CR>

" move tabs around
nnoremap <silent> ght :-tabmove<CR>
nnoremap <silent> glt :+tabmove<CR>

" customize built-in terminal
augroup terminal_buf
    autocmd!
    " let me navigate away from the terminal without needing to 'escape' first
    au TermOpen * tnoremap <buffer> <C-w>h <C-\><C-N><C-w>h
    au TermOpen * tnoremap <buffer> <C-w>j <C-\><C-N><C-w>j
    au TermOpen * tnoremap <buffer> <C-w>k <C-\><C-N><C-w>k
    au TermOpen * tnoremap <buffer> <C-w>l <C-\><C-N><C-w>l

    " I'm not actually modifying a buffer
    au TermClose * call feedkeys('\<CR>')

    au BufEnter,BufWinEnter,WinEnter term://* startinsert
augroup END

augroup cpp_files
    autocmd!
    "au FileType c,cpp ClangFormatAutoEnable
    au BufRead,BufNewFile *.tpp setfiletype cpp
    "au FileType c,cpp nnoremap gd :ALEGoToDefinitionInTab<CR>
augroup END

"augroup omnisharp_files
"    autocmd!
"    au CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()
"    au InsertLeave *.cs :OmniSharpCodeFormat
"    au InsertLeave *.cs call OmniSharp#HighlightBuffer()
"    au FileType cs nnoremap <buffer> gd :OmniSharpGotoDefinition<CR>
"augroup END

augroup yaml_files
    autocmd!
    au BufRead,BufNewFile *.yml setfiletype yaml
    au FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup xml_files
    autocmd!
    au FileType xml setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END

augroup make_files
    autocmd!
    au FileType make setlocal noexpandtab
augroup END

augroup docker_files
    autocmd!
    au BufRead,BufNewFile Dockerfile.* set syntax=Dockerfile
augroup END
