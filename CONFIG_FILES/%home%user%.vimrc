filetype plugin on
let g:omni_sql_no_default_maps = 1

function CSV()
  if &ft ==? "csv"
    %UnArrangeCol
    set filetype=""
  else
    set filetype=csv
    %ArrangeColumn
  endif
endfunction
command CSV call CSV()
command Csv call CSV()

function LoadTemp()
  LoadFileTemplate default
  :normal! Gddgg
endfunction
autocmd! BufNewFile * call LoadTemp()

set hidden
set ofu=syntaxcomplete#Complete
set backspace=2
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

hi TrailingWhitespace ctermbg=red guibg=red
match TrailingWhitespace /\s\+$/

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
""""""

"""word wrap"""
map <C-w><C-w> :s/\v(.{70}[^ ]* *)/\1\r/g<CR>
map <C-w><C-h> :s/\v(.{70}[^ ]* *)/\1\r--/g<CR>
""""""

"""command repeat"""
nmap , @:
""""""

"""Quit"""
nmap <C-X><C-C> :q!<CR>
imap <C-X><C-C> <Esc>:q!<CR>

nmap <C-C> :q<CR>
imap <C-C> <Esc>:q<CR>
""""""

"""Next/Prev File"""
nmap <C-N> :n<CR>
imap <C-N> <Esc>:n<CR>
nmap <C-P> :N<CR>
imap <C-P> <Esc>:N<CR>
""""""

"""delete/paste"""
imap <C-D> <Esc>ddli
imap <C-P> <Esc>pli

xmap p "_dp
xmap P "_dP
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

"""meld"""
nmap <F2>      :Exec cd %:p:h; meld %:p &<CR>
imap <F2> <Esc>:Exec cd %:p:h; meld %:p &<CR>
""""""

"""git"""
nmap <F4>      :Exec cd %:p:h; git gui &<CR>
imap <F4> <Esc>:Exec cd %:p:h; git gui &<CR>
""""""

"""RUN"""
nmap <F5> :1wincmd<space>w<CR>:w<CR>:RUN<CR>
imap <F5> <ESC>:1wincmd<space>w<CR>:w<CR>:RUN<CR>li

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

command! -bar -range=% Reverse <line1>,<line2>g/^/m<line1>-1|nohl

""":Exec cmd arg arg ..
" run external commands quietly
command -nargs=1 Exec
\ execute 'silent ! ' . <q-args>
\ | execute 'redraw! '

""":Wc  msg => save, git ci FILENAME -m msg
""":Wcq msg => save, git ci FILENAME -m msg, quit
command -nargs=1 Wc  call Wc(<f-args>, "noquit")
command -nargs=1 Wcq call Wc(<f-args>, "quit")
cabbrev wc  <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Wc'  : 'wc' )<CR>
cabbrev wcq <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Wcq' : 'wcq')<CR>
function Wc(msg, maybeQuit)
    w
    let msg = "'" . substitute(a:msg, "'", "'\\\\''", "g") . "'"
    let cmd = "! git ci % -m " . msg
    execute cmd
    if a:maybeQuit == "quit"
      q
    endif
endfunction

let g:RUNwin = 1
let g:RUNsize = 5
command -nargs=* RUN call RUN(<f-args>)
function RUN(...)
    1wincmd w
    let interpreter = strpart(getline(1),2)
    let abspath = expand("%:p")
    let arguments = join(a:000, " ")
    let call = interpreter . " " . abspath . " " . arguments
    let perlexp = "print qq(\n) . q(~)x64 . qq(\n) . <>;"
    if winnr("$") == 1
        below new
    endif
    2wincmd w
    execute "resize " . g:RUNsize
    %s/\_.*/-/g
    execute "perldo $_=`(".call." | perl -0777 -e '".perlexp."')2>&1`;"
    perldo s/&/&a!/g; s/!/&e!/g; s/\n/&nl!/g;
    %s/&nl!/\r/ge | %s/&e!/!/ge | %s/&a!/&/ge
    %s/\(\_.*\)\n\(\~\{64}\n\)\(\_.*\)\n/\3\2\1/
    execute g:RUNwin . "wincmd w"
endfunction
command -nargs=* RUNP call RUNP(<f-args>)
function RUNP(win, size, ...)
    let g:RUNwin = a:win
    let g:RUNsize = a:size
    call RUN(a:000)
endfunction

