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
Plug 'Raimondi/delimitMate'
"Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" syntax check
Plug 'dense-analysis/ale'

" syntax support
"Plug 'tikhomirov/vim-glsl'
"Plug 'hashivim/vim-terraform'
"Plug 'tbastos/vim-lua'
"Plug 'udalov/kotlin-vim'
Plug 'sheerun/vim-polyglot'

" formatting
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
"Plug 'rhysd/vim-clang-format'

" language tooling
"Plug 'rust-lang/rust.vim'
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
"Plug 'OmniSharp/omnisharp-vim'
"Plug 'ziglang/zig.vim'
Plug 'posva/vim-vue' " vue single-file components
"Plug 'davidhalter/jedi-vim'

" color schemes
Plug 'tomasr/molokai'
Plug 'nanotech/jellybeans.vim'
Plug 'morhetz/gruvbox'

" quality of life
Plug 'jwhitley/vim-matchit'
Plug 'tpope/vim-repeat'
Plug 'vimlab/split-term.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-abolish'
Plug 'puremourning/vimspector'

" extra helpers
Plug 'kana/vim-operator-user'
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
Plug 'wannesm/wmgraphviz.vim'
Plug 'tpope/vim-eunuch'

" myndshft config
Plug 'https://bitbucket.org/myndshft/mynd-config-vim.git', { 'do': 'make' }

call plug#end()

" basic sanity
set ttimeoutlen=50
set updatetime=100
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

" enable folding, but disable it by default
set foldmethod=syntax
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
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set textwidth=0
set wrap
set breakindent
"set breakindentopt=sbr,shift:4
"set showbreak=>
set linebreak
let g:vim_indent_cont = &shiftwidth

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

" netrw explorer
let g:netrw_liststyle    = 3
let g:netrw_banner       = 0
let g:netrw_browse_split = 2
let g:netrw_winsize      = 25
let g:netrw_altv         = 1

" If completion menu is visible, and only one item is left, select it.
" Otherwise, move to the next item.
" If completion menu is not visible, check if we should refresh the list.
inoremap <silent><expr> <Tab>
            \ pumvisible() ?
            \ (len(complete_info().items) == 1 ? coc#_select_confirm() : "\<C-n>") :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-p>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>fa <Plug>(coc-codeaction)
nmap <silent> <leader>la <Plug>(coc-codeaction-line)
nmap <silent> <leader>ca <Plug>(coc-codelens-action)

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

" generate a uuid
command! -nargs=0 UUID :exe 'norm i' . substitute(system('uuidgen'), '\n$', '', '')

" auto close scratch/preview window after completion
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" vim-lsp odd behavior workaround: https://github.com/dense-analysis/ale/issues/1212
let g:lsp_diagnostics_echo_cursor = 0

"
" ale
"

" misc
let g:ale_cache_executable_check_failures = 1
let g:ale_completion_enabled              = 0
let g:ale_warn_about_trailing_blank_lines = 0
let g:ale_sign_priority                   = 999
let g:ale_list_vertical                   = 1

" display
let g:ale_sign_column_always     = 1
let g:ale_virtualtext_cursor     = 1
let g:ale_set_balloons           = 1
let g:ale_cursor_detail          = 0
let g:ale_sign_highlight_linenrs = 1
let g:ale_set_highlights         = 1
let g:ale_set_signs              = 1

" lint/fix
let g:ale_fix_on_save              = 1
let g:ale_set_quickfix             = 1
let g:ale_lint_on_text_changed     = 1
let g:ale_lint_on_insert_leave     = 1
let g:ale_lint_on_enter            = 1
let g:ale_lint_on_save             = 1
let g:ale_lint_on_filetype_changed = 1

let g:ale_linters = {
    \  'c': [
    \    'clangd',
    \  ],
    \  'cpp': [
    \     'clangd',
    \  ],
    \  'cs': [
    \    'OmniSharp',
    \  ],
    \  'html': [
    \    'htmlhint',
    \  ],
    \  'go': [
    \    'gofmt',
    \    'golint',
    \    'gopls',
    \    'gotype',
    \  ],
    \  'haskell': [
    \    'hie',
    \    'hlint',
    \  ],
    \  'java': [],
    \  'kotlin': [
    \    'languageserver',
    \  ],
    \  'python': [
    \    'flake8',
    \    'mypy',
    \  ],
    \  'markdown': [
    \    'markdownlint',
    \  ],
    \  'ts': [
    \    'prettier',
    \    'tslint',
    \  ],
    \}

let g:ale_linters_ignore =  {
    \   'html': [
    \     'proselint',
    \   ],
    \ }

let g:ale_fixers = {
    \  'c': [
    \    'clang-format',
    \    'trim_whitespace',
    \  ],
    \  'cpp': [
    \    'clang-format',
    \    'trim_whitespace',
    \  ],
    \  'cs': [
    \    'OmniSharp',
    \    'uncrustify',
    \    'trim_whitespace',
    \  ],
    \  'html': [
    \    'html-beautify',
    \    'trim_whitespace',
    \    'remove_trailing_lines',
    \  ],
    \  'go': [
    \    'goimports',
    \    'trim_whitespace',
    \  ],
    \  'haskell': [
    \    'hlint',
    \    'trim_whitespace',
    \  ],
    \  'lua': [
    \    'trim_whitespace',
    \  ],
    \  'kotlin': [
    \    'ktlint',
    \    'trim_whitespace',
    \  ],
    \  'python': [
    \    'black',
    \    'isort',
    \  ],
    \  'markdown': [
    \    'prettier',
    \    'remove_trailing_lines',
    \    'textlint',
    \    'trim_whitespace',
    \  ],
    \  'sql': [
    \    'trim_whitespace',
    \  ],
    \  'ts': [
    \    'prettier',
    \    'tslint',
    \    'remove_trailing_lines',
    \    'trim_whitespace',
    \  ],
    \  'vim': [
    \    'trim_whitespace',
    \  ],
    \  'vue': [
    \    'prettier',
    \    'trim_whitespace',
    \  ],
    \  'yaml': [
    \    'trim_whitespace',
    \  ]
    \}

let g:ale_java_eclipselsp_executable       = '/Users/aleciverson/.config/coc/extensions/coc-java-data/server/plugins/org.eclipse.equinox.launcher_1.5.500.v20190715-1310.jar'
let g:ale_java_eclipselsp_config_path      = '/Users/aleciverson/.config/coc/extensions/coc-java-data/server/config_mac/'
let g:ale_c_parse_makefile                 = 0
let g:ale_c_parse_compile_commands         = 1
let g:ale_c_clang_executable               = '/usr/local/opt/llvm@10/bin/clang'
let g:ale_c_clangd_executable              = '/usr/local/opt/llvm@10/bin/clangd'
let g:ale_c_clangformat_executable         = '/usr/local/opt/llvm@10/bin/clang-format'
let g:ale_cpp_clang_executable             = '/usr/local/opt/llvm@10/bin/clang'
let g:ale_cpp_clangd_executable            = '/usr/local/opt/llvm@10/bin/clangd'
let g:ale_cpp_clangformat_executable       = '/usr/local/opt/llvm@10/bin/clang-format'
let g:ale_c_clang_options                  = '-std=c11 -Wall -Wextra -I/usr/local/include -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
let g:ale_cpp_clang_options                = '-std=c++2a -Wall -Wextra -I/usr/local/include -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk -I/usr/local/opt/llvm@10/include'
let g:ale_c_clangd_options                 = '--function-arg-placeholders --all-scopes-completion --pch-storage=memory --limit-results=50 --completion-style=detailed --background-index'
let g:ale_cpp_clangd_options               = '--function-arg-placeholders --all-scopes-completion --pch-storage=memory --limit-results=50 --completion-style=detailed --background-index'
let g:ale_kotlin_languageserver_executable = '/Users/aleciverson/Code/kotlin/kotlin-language-server/server/build/install/server/bin/kotlin-language-server'
let g:ale_python_flake8_options            = '--max-line-length=120'
let g:ale_python_black_options             = '--line-length 120'
let g:ale_markdown_redpen_options          = '--configuration ~/.config/redpen/config.xml'

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

let delimitMate_expand_cr = 1

" split-term
let g:disable_key_mappings = 1
set splitbelow

" fzf
let g:fzf_buffers_jump = 1

" terraform
let g:terraform_align         = 1
let g:terraform_fold_sections = 0
let g:terraform_fmt_on_save   = 1

"
" C# / OmniSharp settings
"
let g:OmniSharp_server_stdio  = 1
let g:OmniSharp_selector_ui   = 'fzf'
let g:OmniSharp_highlighting  = 3
let g:OmniSharp_popup_options = {
    \ 'winblend': 30,
    \ 'winhl': 'Normal:Normal'
    \}

"
" zig settings
"
let g:zig_fmt_autosave = 0

"
" go settings
"

let g:go_def_mode                    = 'gopls'
let g:go_info_mode                   = 'gopls'
let g:go_fold_enable                 = ['block', 'import', 'varconst', 'package_comment']
let g:go_highlight_functions         = 1
let g:go_highlight_function_calls    = 1
let g:go_highlight_methods           = 1
let g:go_highlight_types             = 1
let g:go_highlight_fields            = 1
let g:go_highlight_operators         = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags     = 1
let g:go_highlight_debug             = 1

let g:go_fmt_command       = "goimports"
let g:go_fmt_autosave      = 0
let g:go_fmt_fail_silently = 1
let g:go_mod_fmt_autosave  = 0
let g:go_asmfmt_autosave   = 0

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

""" status line, after plugins and such are setup

let g:airline_exclude_preview            = 0
let g:airline#extensions#ale#enabled     = 1
let g:airline#extensions#coc#enabled     = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme                      = 'gruvbox'

""" color scheme

let g:gruvbox_contrast_dark     = 'hard'
let g:gruvbox_invert_signs      = 1
let g:gruvbox_invert_tabline    = 1
let g:gruvbox_improved_warnings = 1

""" vimpsector

let g:vimspector_base_dir = '/Users/aleciverson/.local/share/nvim/plugged/vimspector/gadgets/macos'

" When stopping debugging, reset the view too
function! s:stop_debugging()
    call vimspector#Stop()
    call vimspector#Reset()
endfunction

noremap <F3> :CocCommand java.debug.vimspector.start<CR>
noremap <F4> :call <SID>stop_debugging()<CR>
noremap <F5> <Plug>VimspectorContinue
noremap <S-F5> <Plug>VimspectorRestart
noremap <F6> <Plug>VimspectorPause
noremap <F8> <Plug>VimspectorToggleBreakpoint
noremap <S-F8> <Plug>VimspectorToggleConditionalBreakpoint
noremap <F9> <Plug>VimspectorStepOver
noremap <F10> <Plug>VimspectorStepInto
noremap <F11> <Plug>VimspectorStepOut

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

" search for TODOs with ag
set grepprg=ag
command! Todo silent lgrep -i --ignore-dir=vendor/ '\/\/.*TODO.*' | lwindow
command! TodoN lnext
command! TodoP lprevious
command! TodoE lclose

" list of stuff in the file!
let g:tagbar_zoomwidth = 0
let g:tagbar_case_insensitive = 1
let g:tagbar_show_linenumbers = 1
let g:tagbar_autoshowtag = 0
let g:tagbar_previewwin_pos = "rightbelow"
let g:no_status_line = 1
" auto-open Tagbar when opening a buffer containing a supported file type
"autocmd BufEnter * nested :call tagbar#autoopen(0)
nnoremap <F2> :TagbarToggle<CR>
nnoremap gst :TagbarShowTag<CR>
nnoremap st :TagbarOpen fj<CR>

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

"nnoremap ,f <Plug>(fzf-complete-file)

function! s:trim_whitespace()
    let l:winview = winsaveview()
    silent! %s/\s\+$//e
    call winrestview(l:winview)
endfunction

" trim trailing whitespace on write
autocmd! BufWritePre * call <SID>trim_whitespace()

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
augroup END

augroup cpp_files
    autocmd!
    au BufRead,BufNewFile *.tpp set filetype=cpp
augroup END

"augroup omnisharp_commands
"  autocmd!
"
"  " Show type information automatically when the cursor stops moving.
"  " Note that the type is echoed to the Vim command line, and will overwrite
"  " any other messages in this space including e.g. ALE linting messages.
"  autocmd CursorHold *.cs OmniSharpTypeLookup
"
"  " The following commands are contextual, based on the cursor position.
"  autocmd FileType cs nmap <silent> <buffer> gd <Plug>(omnisharp_go_to_definition)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osfu <Plug>(omnisharp_find_usages)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osfi <Plug>(omnisharp_find_implementations)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>ospd <Plug>(omnisharp_preview_definition)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>ospi <Plug>(omnisharp_preview_implementations)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>ost <Plug>(omnisharp_type_lookup)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osd <Plug>(omnisharp_documentation)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osfs <Plug>(omnisharp_find_symbol)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osfx <Plug>(omnisharp_fix_usings)
"  autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
"  autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
"
"  " Navigate up and down by method/property/field
"  autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
"  autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)
"  " Find all code errors/warnings for the current solution and populate the quickfix window
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osgcc <Plug>(omnisharp_global_code_check)
"  " Contextual code actions (uses fzf, CtrlP or unite.vim when available)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
"  autocmd FileType cs xmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
"
"  autocmd FileType cs nmap <silent> <buffer> <Leader>os= <Plug>(omnisharp_code_format)
"
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osnm <Plug>(omnisharp_rename)
"
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osre <Plug>(omnisharp_restart_server)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>osst <Plug>(omnisharp_start_server)
"  autocmd FileType cs nmap <silent> <buffer> <Leader>ossp <Plug>(omnisharp_stop_server)
"augroup END

augroup docker_files
    autocmd!
    au BufRead,BufNewFile Dockerfile.* set filetype=Dockerfile
augroup END

augroup fsharp_files
    autocmd!
    au BufRead,BufNewFile *.fs set filetype=fsharp
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
