" Make Vim more useful
set nocompatible

filetype plugin indent on

" Enable syntax highliting
syntax on

" Interface
  " Number of colors
  set t_Co=256
  " Character encoding used inside Vim
  " Only available when compiled with the +multi_byte feature
  set encoding=utf-8
  " Character encodings considered when starting to edit an existing file
  " Only available when compiled with the +multi_byte feature
  set fileencodings=utf-8,cp1251
  " Enhance command-line completion
  " Only available when compiled with the +wildmenu feature
  set wildmenu
  " Set completion mode
  " When more than one match, list all matches and complete first match
  " Then complete the next full match
  set wildmode=list:longest,full
  " Ignore following files when completing file/directory names
  " Version control
  set wildignore+=.hg,.git,.svn
  " Python byte code
  set wildignore+=*.pyc,*.pyo
  " Binary images
  set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg
  " Set title of the window to filename [+=-] (path) - VIM
  " Only available when compiled with the +title feature
  set title
  " Show (partial) command in the last line of the screen
  " Comment this line if your terminal is slow
  " Only available when compiled with the +cmdline_info feature
  set showcmd
  " Wrap long lines
  set wrap
  " Don't break words when wrapping
  " Only available when compiled with the +linebreak feature
  set linebreak
  " Show ↪ at the beginning of wrapped lines
  if has("linebreak")
    let &sbr = nr2char(8618).' '
  endif
  " Display invisible characters
  set list
  if version >= 700
    set listchars=tab:▸\ ,trail:·,extends:❯,precedes:❮,nbsp:×
  else
    set listchars=tab:»\ ,trail:·,extends:>,precedes:<,nbsp:_
  endif
  " Copy indent from current line when starting a new line
  set autoindent
  " Do smart indenting when starting a new line
  " Only available when compiled with the +smartindent feature
  set smartindent
  " Use spaces instead of tab
  set expandtab
  " Number of spaces to use for each step of (auto)indent
  set shiftwidth=2
  " Number of spaces that a tab counts for
  set tabstop=2
  " Number of spaces that a tab counts for while performing editing operations
  set softtabstop=2
  " Показывать положение курсора всё время.
  set ruler
  " Показывать номера строк
  set number
  " Умная зависимость от регистра. Детали `:h smartcase`
  set ignorecase
  set smartcase
  " Фолдинг по отсупам
  set foldenable
  set foldlevel=100
  set foldmethod=indent
  " Last window always has a status line
  set laststatus=2
  " Statusline format
  set statusline=%<%f%h%m%r\ %b\ %{&encoding}\ 0x\ \ %l,%c%V\ %P
  " Highlight the screen line of the cursor
  " Only available when compiled with the +syntax feature
  set cursorline
  highlight CursorLine guibg=lightblue ctermbg=lightgray
  highlight CursorLine term=none cterm=none
  " Don't show the intro message starting Vim
  set shortmess+=I
  " Edit several files in the same time without having to save them
  set hidden
  " No beeps, no flashes
  set visualbell
  set t_vb=

" Environment
  " Store lots of history entries: :cmdline and search patterns
  set history=1000
  " Save file with root permissions
  command! W exec 'w !sudo tee % > /dev/null' | e!
  " Backspacing settings:
  " start allow backspacing over the start of insert;
  " CTRL-W and CTRL-U stop once at the start of insert.
  " indent allow backspacing over autoindent
  " eol allow backspacing over line breaks (join lines)
  set backspace=indent,eol,start
  " Backup и swp files
  set nobackup " Don't create backups
  set noswapfile " Don't create swap files
