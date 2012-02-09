"""filetype plugin indent on
set uc=0 """no swapfile
set ic
set history=9000
set nocompatible
set nowrap
syntax on

set number

colorscheme solarized
set background=dark
hi Normal ctermfg=green ctermbg=none
hi LineNr ctermfg=blue ctermbg=darkgray

set mouse=a

set hlsearch
set expandtab
set autoindent
set smarttab
set tabstop=4
set softtabstop=4
set shiftwidth=4

"""keep cursor vertically centered while searching"""
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

"""command repeat"""
nmap , @:
""""""

"""Quit"""
nmap <C-X><C-C> :q!<CR>
imap <C-X><C-C> <Esc>:q!<CR>

nmap <C-C> :q<CR>
imap <C-C> <Esc>:q<CR>
""""""

"""delete/paste"""
imap <C-D> <Esc>ddli
imap <C-P> <Esc>pli
""""""

"""Undo"""
nmap <C-U>      u
imap <C-U> <Esc>uli

nmap <C-R>      <C-R>
imap <C-R> <Esc><C-R>li
""""""

"""word wrap"""
map <C-w><C-w> :s/\v(.{80}[^ ]*)/\1\r/g<CR>
map <C-w><C-h> :s/\v(.{80}[^ ]*)/\1\r--/g<CR>
""""""

"""Write"""
nmap <F3>      :w<CR>
imap <F3> <Esc>:w<CR>li
vmap <F3> :w<Del><CR>lv
""""""

"""RUN"""
nmap <F5>      :w<CR>:RUN<CR>
imap <F5> <Esc>:w<CR>:RUN<CR>li

nmap <F6>      :w<CR>:RUN<Space>
imap <F6> <Esc>:w<CR>:RUN<Space>li
""""""

"""Clipboard"""
nmap <F7>      "+y
imap <F7> <ESC>"+yi
vmap <F7>      "+y

nmap <F8>      "+p
imap <F8> <ESC>"+pi
vmap <F8>      "+p
""""""

"""Register l"""
nmap <F9>      "ly
imap <F9> <ESC>"lyi
vmap <F9>      "ly

nmap <F10>      "lp
imap <F10> <ESC>"lpi
vmap <F10>      "lp
""""""

"""Register r"""
nmap <F11>      "ry
imap <F11> <ESC>"ryi
vmap <F11>      "ry

nmap <F12>      "rp
imap <F12> <ESC>"rpi
vmap <F12>      "rp
""""""


command -nargs=* RUN call RUN(<f-args>)
function RUN(...)
    perldo `rm -rf ~/.CONSOLE.swp`
    1wincmd w
    let interpreter = strpart(getline(1),2)
    let abspath = expand("%:p")
    let arguments = join(a:000, " ")
    let runcmd = interpreter . ' ' . abspath . ' ' . arguments
    
    let sep = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    
    let slurp = "perl -0777 -e 'print qq(" . sep . ") . <>;'"

    let encode = "perldo s/&/&amp;/g; s/;/&semi;/g; s/\n/&nl;/g;"
    let decode = "%s/&nl;/\r/ge | %s/&semi;/;/ge | %s/&amp;/&/ge"

    let format = '%s/' .
               \       '\(\_.*\)' . sep . '\(\_.*\)' .
               \   '/' .
               \       '\2' . sep . '\r' . '\1' .
               \   '/'

    if winnr("$") == 1
        below new ~/.CONSOLE
    endif
    2wincmd w

    %s/\_.*/-temp-/g

    execute 'perldo $_=`(' . runcmd . ' | ' . slurp . ') 2>&1 `;'
    
    execute encode
    execute decode
    execute format

    normal 1G
    1wincmd w
endfunction

