call plug#begin('~/.config/nvim/plugins')
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'phanviet/vim-monokai-pro'
Plug 'itchyny/lightline.vim'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'ruanyl/vim-gh-line'
Plug 'tyru/open-browser.vim'
Plug 'aklt/plantuml-syntax'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'RishabhRD/popfix'
Plug 'RishabhRD/nvim-lsputils'
Plug 'nvim-lua/completion-nvim'
Plug 'aca/completion-tabnine', { 'do': './install.sh' }
call plug#end()

set termguicolors
colorscheme monokai_pro

set hidden
set number
set modeline
set linebreak
set showmatch
set visualbell
set hlsearch
set smartcase
set ignorecase
set incsearch
set autoindent
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4
set tabstop=4
set expandtab
set ruler
set backspace=indent,eol,start
set wildmenu
set laststatus=2
set showtabline=2
set lazyredraw
set nobackup
set nowb
set noswapfile
set encoding=utf-8
set ffs=unix,dos,mac
set autowrite
let mapleader = ","
set updatetime=100
set shortmess+=c
set foldmethod=indent
set nofoldenable
set completeopt=menuone,noinsert,noselect
set clipboard+=unnamedplus
set spell

lua require('lsp')

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap ra <cmd>Telescope lsp_code_actions<cr>

" Lightline
let g:lightline = {
  \     'colorscheme': 'powerline',
  \     'component': {'lineinfo': ' %3l:%-2v'},
  \     'component_function': {'filename': 'LightlineFilename'},
  \     'separator': { 'left': '', 'right': '' },
  \     'subseparator': { 'left': '', 'right': '' },
  \     'active': {
  \         'left': [['mode', 'paste' ], ['readonly', 'filename', 'modified']],
  \         'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding']]
  \     }
  \ }
function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

function! s:gitModified()
    let files = systemlist('git ls-files -m 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction

function! s:gitUntracked()
    let files = systemlist('git ls-files -o --exclude-standard 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction

let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 0
let g:startify_lists = [
    \ { 'type': function('s:gitModified'),  'header': ['   git modified']},
    \ { 'type': function('s:gitUntracked'), 'header': ['   git untracked']},
    \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
    \ { 'type': 'files',     'header': ['   MRU']            },
\ ]

function! RunGoTest()
    :VtrAttachToPane
    let l:path = expand('%:p:h')
    let l:test = go#util#TestName()
    if l:test is ''
        return
    endif
    call VtrSendCommand('go test -v -race -mod=vendor -failfast '. l:path . ' -run ' . l:test)
endfunction

function! RunGoDebug()
    :VtrAttachToPane
    let l:path = expand('%:p:h')
    let l:test = go#util#TestName()
    if l:test is ''
        return
    endif
    call VtrSendCommand('dlv test '. l:path . ' -- -test.v -test.run ' . l:test)
endfunction

nmap <leader>gt :call RunGoTest()<CR>
nmap <leader>gd :call RunGoDebug()<CR>

let g:go_term_enabled = 1
let g:go_term_reuse = 1
let g:go_term_close_on_exit = 0
let g:go_def_mapping_enabled = 0
let g:go_jump_to_error = 0
let g:go_list_height = 5
let g:go_list_type = "quickfix"
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_fmt_fail_silently = 0
let g:go_metalinter_autosave = 1
let g:go_metalinter_autosave_enabled=['revive', 'govet', 'typecheck']
let g:go_metalinter_command='golangci-lint'
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_arguments = 1
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_highlight_format_strings = 1
let g:go_diagnostics_level = 1
let g:go_auto_sameids = 1
let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'
let g:go_referrers_mode = 'gopls'
let g:go_fillstruct_mode = 'gopls'

let g:go_debug_preserve_layout = 1
let g:go_debug_windows = {
        \ 'vars':       'leftabove 50vnew',
        \ 'stack':      'leftabove 30new',
        \ 'goroutines': 'botright 20new',
        \ 'out':        'botright 10new',
\ }

let g:completion_chain_complete_list = {
    \'default': [
        \{'complete_items': ['lsp', 'tabnine']},
        \{'mode': '<c-p>'},
        \{'mode': '<c-n>'}
    \]
\}
