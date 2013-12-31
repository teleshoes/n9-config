[ -f /etc/bashrc ] && . /etc/bashrc
[ -f /etc/bash_completion ] && . /etc/bash_completion

shopt -s dotglob

ssh-add ~/.ssh/id_rsa 2> /dev/null

export HISTSIZE=1000000
export HISTCONTROL=ignoredups # don't put duplicate lines in the history
export HISTCONTROL=ignoreboth # ... and ignore same sucessive entries.
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

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

pathAppend ()  { for x in $@; do pathRemove $x; export PATH="$PATH:$x"; done }
pathPrepend () { for x in $@; do pathRemove $x; export PATH="$x:$PATH"; done }
pathRemove ()  { for x in $@; do
  export PATH=`\
    echo -n $PATH \
    | awk -v RS=: -v ORS=: '$0 != "'$1'"' \
    | sed 's/:$//'`;
  done
}

pathAppend          \
  $HOME/bin         \
  $HOME/.cabal/bin  \
  /usr/local/bin    \
  /usr/bin          \
  /bin              \
  /usr/local/sbin   \
  /usr/sbin         \
  /sbin             \
  /usr/local/games  \
  /usr/games        \
;

meego_gnu=/opt/gnu-utils
if [ -d $meego_gnu ]; then
  pathPrepend              \
    /usr/libexec/git-core  \
    $meego_gnu/bin         \
    $meego_gnu/usr/bin     \
    $meego_gnu/usr/sbin    \
  ;
fi

if [ `hostname -s` == "jordan-n9" ]; then
  alias apt-get="AEGIS_FIXED_ORIGIN=com.nokia.maemo apt-get"
  alias dpkg="AEGIS_FIXED_ORIGIN=com.nokia.maemo dpkg"
fi

#command prompt
if [ "$DISPLAY" == "" ]; then
  #host abbrevs
  case `hostname -s` in
    "jordan-n9"               ) h='@n9' ;;
    *                         ) h='@\h' ;;
  esac
else
  #if display is set, you probably know where you are
  h=""
fi

u="\u"
colon=":"
c1='\[\033[01;32m\]'
c2='\[\033[01;34m\]'
cEnd='\[\033[00m\]'
#if you have 'PS1={stuff}' then a literal colon character
#the n9 fucks with that line on reboot
PS1="$c1$u$h$cEnd$colon$c2\w$cEnd\$ "

for cmd in wconnect wauto tether resolv \
           mnt optimus xorg-conf bluetooth fan intel-pstate flasher
do alias $cmd="sudo $cmd"; done

for sudoTypo in suod sudp
do alias $sudoTypo='sudo'; done

for exitTypo in exot exut
do alias $exitTypo='exit'; done

alias tb='pkill -9 taffybar; taffybar; pkill -9 taffybar'

alias dus='du -s * | sort -g'
alias killjobs='kill -9 `jobs -p` 2>/dev/null; sleep 0.1; echo'
alias gvim='term vim'
alias cx='chmod +x'
alias :q='exit'
alias shutdown='poweroff'
alias l='ls -Al --color=auto'
alias ll='ls -Al --color=auto'
alias ld='ls -dAl --color=auto'
alias mplayer='WINDOW_TITLE=MPLAYER; mplayer'
alias perms='stat -c %a'
alias glxgears='vblank_mode=0 glxgears'
function mnto { sudo mnt --other --no-usb --no-card $@ ; }
alias gparted='spawnexsudo gparted'
function s           { $@ & disown ; }
function spawn       { $@ & disown ; }
function spawnex     { $@ & disown && exit 0 ; }
function spawnexsudo { gksudo $@ & disown && exit 0 ; }
function update-repo { sudo apt-get update \
                         -o Dir::Etc::sourcelist="sources.list.d/$1" \
                         -o Dir::Etc::sourceparts="-" \
                         -o APT::Get::List-Cleanup="0"
}

function git-log(){ git logn $@ ; }
function git()
{
  realgit="$(which git)"
  cmd="git-$1"
  if [ "$(type -t $cmd)" = "function" ]; then
    shift
    $cmd "$@"
  else
    $realgit "$@"
  fi
}

alias genservices='~/workspace/escribe/tools/genservices.pl'
alias genibatis='~/workspace/escribe/tools/genibatis.pl'
alias migl='gvim `~/migs/latest-script`'
