" vim-plug plugin manager
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.
Plug 'vimwiki/vimwiki'
Plug 'ap/vim-css-color'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

let mapleader =" "          " Leader key

set number relativenumber
set background=dark
set history=1000
set scrolloff=10
set guicursor=
set path+=**                " When searching for files with the find command, search through recursively through every subdirectory
set shortmess+=Imrc         " Disable the default Vim startup message
                            " Use [+] instead of [Modified], [RO] instead of [readonly]
                            " Don't give completion match messages
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
set smartcase
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set wildmode=longest,list   " get bash-like tab completions
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set ttyfast                 " Speed up scrolling in Vim
set laststatus=2            " Always show the status line at the bottom
set backspace=indent,eol,start
set confirm                 " Ask for confirmation when handling unsaved or read-only files
nnoremap <expr> oo 'm`' . v:count1 . 'o<Esc>``'
nnoremap <expr> OO 'm`' . v:count1 . 'O<Esc>``'
                            " Insert a blank line below or above current line (do not move the cursor),

" Return to last edit position when opening a file
augroup resume_edit_position
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ | execute "normal! g`\"zvzz"
        \ | endif
augroup END

" New tab shortcut
map <leader>t :tabnew<CR>
" Move to next tab
map <leader>J :tabNext<CR>
" Move to the previous tab
map <leader>K :tabprevious<CR>
" Close current tab

map <leader>d :tabclose<CR>
" Exit vim

map <leader>cl :exit<CR>
" Replace all alias
nnoremap <leader>S :%s//g<Left><Left>
" Open files with fzf
nnoremap <leader>o :F ~<CR>
" Open ~/.dotfiles with fzf
nnoremap <leader>df :F ~/.dotfiles<CR>
" Open ~/.config with fzf
nnoremap <leader>cf :F ~/.config<CR>
" Open vimwiki index
map <leader>w :VimwikiIndex<CR>
" Open vimwiki diary index
map <leader>D :VimwikiDiaryIndex<CR>
" English spell-check set to <leader>en:
map <leader>en :setlocal spell! spelllang=en_us<CR>
" Portuguese spell-check set to <leader>pt:
map <leader>pt :setlocal spell! spelllang=pt_br<CR>
" Resize splits when the window is resized
augroup on_vim_resized
	autocmd!
	autocmd VimResized * wincmd =
augroup END

" Splitting
set splitright
set splitbelow
map <leader>n :new<CR>
map <leader>vn :vnew<CR>

" Shortcuts for split navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Shortcuts for resizing windows
nnoremap <silent> <C-<> <C-w><
nnoremap <silent> <C->> <C-w>>
nnoremap <silent> <C--> <C-w>-
nnoremap <silent> <C-+> <C-w>+

" Vimwiki and Calcurse configuration
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_list = [{'path': '/home/mrcl/Documents/Sincronizados/Obsidian-Vault', 'syntax': 'markdown', 'ext': '.md'}]
autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Perform dot commands over visual blocks:
vnoremap . :normal .<CR>

" Automatically deletes all trailing whitespace and newlines at end of file on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e
autocmd BufWritePre *.[ch] %s/\%$/\r/e

" NERDTree plugin configuration and shortcuts
let NERDTreeShowHidden=1
nnoremap <leader>N :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>

" limelight plugin configuration
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Toggle limelight plugin
nnoremap <leader>l :Limelight!!<CR>

" Toggle Goyo plugin
nnoremap <leader>g :Goyo<CR>

" F5 to insert current date and time
:nnoremap <F5> "=strftime("%c")<CR>P
:inoremap <F5> <C-R>=strftime("%c")<CR>

" set cursorline            " highlight current cursorline
" set spell                 " enable spell check (may need to download language package)
" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.
" set cc=80                   " set an 80 column border for good coding style
