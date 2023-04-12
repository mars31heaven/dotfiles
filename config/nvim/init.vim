" vim-plug plugin manager
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/plugged')

" Declare the list of plugins.
Plug 'vimwiki/vimwiki'
Plug 'ap/vim-css-color'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'preservim/nerdtree'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" General theme
colorscheme default

" vim-airline theme
let g:airline_theme='base16_gruvbox_dark_hard'

" Leader key
let mapleader =","

" Disable compability with vi
set nocompatible

set number relativenumber
set clipboard+=unnamed
set clipboard+=unnamedplus
set background=dark
set history=1000
set scrolloff=10
set guicursor=

" Enable plugins
filetype plugin on

" Enable syntax highlighting and indentation
syntax on
filetype indent on

" When searching for files with the find command, search through recursively through every subdirectory
set path+=**

" Disable the default Vim startup message
" Use [+] instead of [Modified], [RO] instead of [readonly]
" Don't give completion match messages
set shortmess+=Imrc
" Disable Ex mode
nmap Q <Nop>
" Always show the status line at the bottom
set laststatus=2
" Backspace over anything
set backspace=indent,eol,start
" Enable hidden buffers
set hidden
" Case-insensitive search when all characters in the string being search are
" lowercase. Case-sensitive if it contains any capital letters.
set ignorecase
set smartcase
" Enable searching while typing
set incsearch
" Disable search highlighting
set nohlsearch
" Enable tab completion:
set wildmode=longest,list,full
set wildmenu
" Don't show the current mode
set noshowmode

" Soft warp
set wrap linebreak nolist

" Ask for confirmation when handling unsaved or
" read-only files
set confirm

" Insert a blank line below or above current line (do not move the cursor),
" see https://stackoverflow.com/a/16136133/6064933
nnoremap <expr> oo 'm`' . v:count1 . 'o<Esc>``'
nnoremap <expr> OO 'm`' . v:count1 . 'O<Esc>``'

" Yank from current cursor position to the end of the line (make it
" consistent with the behavior of D, C)
nnoremap Y y$

" Do not include white space characters when using $ in visual mode,
" see https://vi.stackexchange.com/a/18571/15292
xnoremap $ g_

" Return to last edit position when opening a file
augroup resume_edit_position
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ | execute "normal! g`\"zvzz"
        \ | endif
augroup END

" Resize splits when the window is resized
augroup on_vim_resized
	autocmd!
	autocmd VimResized * wincmd =
augroup END

" New tab shortcut
map <leader>t :tabnew<CR>
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
let g:vimwiki_list = [{'path': '~/home/mrcl/docs_awl_sync/markor', 'syntax': 'markdown', 'ext': '.md'}]
autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Perform dot commands over visual blocks:
vnoremap . :normal .<CR>

" Automatically deletes all trailing whitespace and newlines at end of file on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e
autocmd BufWritePre *.[ch] %s/\%$/\r/e

" Run xrdb whenever Xdefaults or Xresources are updated.
autocmd BufRead,BufNewFile Xresources,Xdefaults,xresources,xdefaults set filetype=xdefaults
autocmd BufWritePost Xresources,Xdefaults,xresources,xdefaults !xrdb %

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
