[ -f /etc/bashrc ] && . /etc/bashrc
[ -f /etc/bash_completion ] && . /etc/bash_completion

export HISTSIZE=1000000
export HISTCONTROL=ignoredups # don't put duplicate lines in the history
export HISTCONTROL=ignoreboth # ... and ignore same sucessive entries.

shopt -s checkwinsize # update LINES and COLUMNS based on window size
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)" #less on binary files, e.g. tars

#rxvt-unicode and rxvt-256color => rxvt {for legacy}
case "$TERM" in rxvt*) TERM=rxvt ;; esac

#use prompt_cmd to set the window title => $WINDOW_TITLE or "Terminal: pwd"
#only for rxvt* terms
if [ "$TERM" == "rxvt" ]; then
  p1='echo -ne "\033]0;$WINDOW_TITLE\007"'
  p2='echo -ne "\033]0;Terminal: ${PWD/$HOME/~}\007"'
  PROMPT_COMMAND='if [ "$WINDOW_TITLE" ]; then '$p1'; else '$p2'; fi'
fi

prependPath() {
  case $PATH in
    $@:* | *:$@ | *:$@:* ) ;;
    *) export PATH=$@:$PATH
  esac
}
prependPath /usr/local/bin
prependPath $HOME/bin
prependPath $HOME/.cabal/bin
meego_gnu=/opt/gnu-utils
if [ -d $meego_gnu ]; then
  prependPath /usr/local/bin
  prependPath /usr/local/sbin
  prependPath /sbin
  prependPath /usr/sbin
  prependPath /usr/libexec/git-core
  prependPath $meego_gnu/bin
  prependPath $meego_gnu/usr/bin
  prependPath $meego_gnu/usr/sbin
fi

#command prompt
if [ "$DISPLAY" == "" ]; then
  #host abbrevs
  case `hostname -s` in
    "wolke-w520"              ) h='@w520' ;;
    "wolk-desktop"            ) h='@desk' ;;
    "wolke-n9"                ) h='@n9' ;;
    "wolke-n900"              ) h='@n900' ;;
    "raspberrypi"             ) h='@raspi' ;;
    "Benjamins-MacBook-Pro"   ) h='@bensmac' ;;
    *                         ) h='@\h' ;;
  esac
else
  #if display is set, you probably know where you are
  h=""
fi

u="\u"
if [ "$USER" == "BenjaminAguayza" ]; then u=ben; fi
colon=":"
c1='\[\033[01;32m\]'
c2='\[\033[01;34m\]'
cEnd='\[\033[00m\]'
#if you have 'PS1={stuff}' then a literal colon character
#the n9 fucks with that line on reboot
PS1="$c1$u$h$cEnd$colon$c2\w$cEnd\$ "

for cmd in wconnect tether resolv mnt
do alias $cmd="sudo $cmd"; done

for sudoTypo in suod sudp
do alias $sudoTypo='sudo'; done

for exitTypo in exot exut
do alias $exitTypo='exit'; done

alias gvim='termcmd vim'
alias cx='chmod +x'
alias :q='exit'
alias shutdown='poweroff'
alias l='ls -al --color=auto'
alias ll='ls -al --color=auto'
alias ld='ls -dal --color=auto'
alias mplayer='WINDOW_TITLE=MPLAYER; mplayer'
alias perms='stat -c %a'
function spawn       { $@ & disown ; }
function spawnex     { $@ & disown && exit 0 ; }
function spawnexsudo { gksudo $@ & disown && exit 0 ; }

alias genservices='~/workspace/escribe/tools/genservices'
alias migl='gvim `~/workspace/escribe/src-sql/migrations/latest-script`'

##AUTOLOGIN START##
if [ -z "$DISPLAY" ]; then
  if [ "$(tty)" == "/dev/tty7" ]; then
    exec startx
  fi
fi
##AUTOLOGIN END##
