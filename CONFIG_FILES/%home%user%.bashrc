[ -f /etc/bashrc ] && . /etc/bashrc
[ -n "$PS1" ] && [ -f /etc/bash_completion ] && . /etc/bash_completion

shopt -s dotglob
shopt -s extglob

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

#command prompt
if [[ -z "$DISPLAY" ]]; then
  #host abbrevs
  case `hostname` in
    "wolke-w520"              ) h='@w520' ;;
    "wolk-desktop"            ) h='@desk' ;;
    "wolke-n9"                ) h='@n9' ;;
    "wolke-n900"              ) h='@n900' ;;
    "raspberrypi"             ) h='@raspi' ;;
    "Benjamins-MacBook-Pro"   ) h='@bensmac' ;;
    ci-*.dev.*                ) h='@ci.dev' ;;
    ci-*.stage.*              ) h='@ci.stage' ;;
    *                         ) h='@\h' ;;
  esac
else
  #if display is set, you probably know where you are
  h=""
fi

#make a wild guess at the DISPLAY you might want
if [[ -z "$DISPLAY" ]]; then
  export DISPLAY=`ps -ef | grep /usr/bin/X | grep ' :[0-9] ' -o | grep :[0-9] -o`
fi

u="\u"
if [ "$USER" == "BenjaminAguayza" ]; then u=ben; fi
colon=":"
c1='\[\033[01;32m\]'
c2='\[\033[01;34m\]'
cEnd='\[\033[00m\]'
#if you have 'PS1={stuff}' then a literal colon character
#the n9 fucks with that line on reboot
if [ -n "PS1" ]; then
  PS1="$c1$u$h$cEnd$colon$c2\w$cEnd\$ "
fi

for cmd in wconnect wauto tether resolv \
           mnt optimus xorg-conf bluetooth fan intel-pstate flasher \
           tpacpi-bat sbox-umount
do alias $cmd="sudo $cmd"; done

for sudoTypo in suod sudp
do alias $sudoTypo='sudo'; done

for exitTypo in exot exut
do alias $exitTypo='exit'; done

alias time="command time"
alias mkdir="mkdir -p"
alias :q='exit'
alias :r='. /etc/profile; . ~/.bashrc;'

function vol          { pulse-vol "$@"; }
function j            { fcron-job-toggle "$@"; }
function f            { feh "$@"; }
function snapshot     { backup --snapshot "$@"; }
function qgroups-info { backup --info --quick --sort-by=size "$@"; }
function dus          { du -s * | sort -g "$@"; }
function killjobs     { kill -9 `jobs -p` 2>/dev/null; sleep 0.1; echo; }
function gvim         { term vim "$@"; }
function cx           { chmod +x "$@"; }
function shutdown     { poweroff "$@"; }
function xmb          { xmonad-bindings "$@"; }
function l            { ls -Al --color=auto "$@"; }
function ll           { ls -Al --color=auto "$@"; }
function ld           { ls -dAl --color=auto "$@"; }
function perms        { stat -c %a "$@"; }
function glxgears     { vblank_mode=0 glxgears "$@"; }
function mnto         { sudo mnt --other --no-usb --no-card "$@"; }
function gparted      { spawnexsudo gparted "$@"; }
function escape-pod   { ~/Code/escapepod/escape-pod-tool --escapepod "$@"; }
function podcastle    { ~/Code/escapepod/escape-pod-tool --podcastle "$@"; }
function pseudopod    { ~/Code/escapepod/escape-pod-tool --pseudopod "$@"; }
function g            { git "$@"; }
function gs           { g s; }
function mp           { mplayer "$@"; }

function sb           { seedbox "$@"; }
function sbr          { seedbox -r "$@"; }
function sbw          { seedbox -r ssh wolke@192.168.11.50 "$@"; }

function s            { "$@" & disown; }
function sx           { "$@" & disown && exit 0; }
function spawn        { "$@" & disown; }
function spawnex      { "$@" & disown && exit 0; }
function spawnexsudo  { gksudo "$@" & disown && exit 0; }

function m            { maven -Psdm -Pdev -Pfast-tests -Dgwt.compiler.skip=true install "$@"; }
function mtest        { maven -Psdm -Pdev test "$@"; }
function mc           { maven -Psdm -Pdev -Pfast-tests -Dgwt.draftCompile=true clean install "$@"; }
function mck          { maven checkstyle:check "$@"; }
function findmvn      { command find "$@" -not -regex '\(^\|.*/\)\(target\|gen\)\($\|/.*\)'; }
function grepmvn      { command grep "$@" --exclude-dir=target --exclude-dir=gen; }

function genservices  { ~/workspace/escribehost/legacy-tools/genservices.pl "$@"; }
function genibatis    { ~/workspace/escribehost/legacy-tools/genibatis.pl "$@"; }
function migl         { gvim `~/migs/latest-script` "$@"; }

# common typos
function mkdit        { mkdir "$@"; }
function cim          { vim "$@"; }
function bim          { vim "$@"; }

function maven() {
  args=""
  if ! [[ "$@" =~ (^| )test($| ) ]]; then
    args="$args -DskipTests"
  fi
  if ! [[ "$@" =~ (^| )checkstyle:check($| ) ]]; then
    args="$args -Dcheckstyle.skip=true"
  fi
  execAlarm mvn $args $@;
}

function find() {
  if [[ "$PWD" =~ "escribe" ]]; then
    findmvn "$@"
  else
    command find "$@"
  fi
}

function grep() {
  if [[ "$PWD" =~ "escribe" ]]; then
    grepmvn "$@"
  else
    command grep "$@"
  fi
}

function execAlarm() {
  "$@"
  exitCode="$?"
  if [ $exitCode == 0 ]; then
    alarm -s success
  else
    alarm -s failure
  fi
  bash -c "exit $exitCode"
}

function update-repo {
  repo="$1"
  shift
  sudo apt-get update \
    -o Dir::Etc::sourcelist="sources.list.d/$repo" \
    -o Dir::Etc::sourceparts="-" \
    -o APT::Get::List-Cleanup="0" \
    "$@"
}


function git-log() {
  git logn "$@"
}
function git() {
  realgit="$(which git)"
  realcmd="$1"
  fct="git-$realcmd"
  if [ "$(type -t $fct)" = "function" ]; then
    shift
    $fct "$@"
  elif [[ "$realcmd" == *-real ]]; then
    shift
    cmd=${realcmd%-real}
    $realgit $cmd "$@"
  else
    $realgit "$@"
  fi
}
