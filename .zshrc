#!/bin/zsh

source ~/.zsh/zinit/zinit.zsh
ZINIT[HOME_DIR]="$HOME/.zsh"
ZINIT[BIN_DIR]="$HOME/.zsh/zinit"

zstyle ':completion:*' add-space true
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate _prefix
zstyle ':completion:*' completions 0
zstyle ':completion:*' glob 0
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' max-errors 3
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 0
zstyle :compinstall filename '$HOME/.zshrc'

zmodload zsh/complist
autoload -Uz compinit
compinit

zinit wait lucid light-mode for \
  zdharma/fast-syntax-highlighting

setopt incappendhistory autocd prompt_subst
unsetopt nomatch notify
setopt extended_glob globcomplete
setopt autocd autopushd pushdignoredups
autoload -Uz colors && colors

bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^H' backward-delete-word
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' delete-word
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey '^Z'          push-input
# ctrl-opkl to move up down, back/forward words; ctrl-[] to move back forward chars
bindkey '^O' up-line-or-history
bindkey '^L' down-line-or-history
bindkey '^K' backward-word
bindkey '^[' backward-char
bindkey '^P' forward-word
bindkey '^]' forward-char
# alt-opkl to move up down, back/forward char
bindkey '^[o' up-line-or-history
bindkey '^[l' down-line-or-history
bindkey '^[k' backward-char
bindkey '^[p' forward-char
# ESC has a delay since it's used for chords and we want to use ^[ which is same as esc.
# Avoid delay when using ^[
KEYTIMEOUT=1

# kak-man() {
#   man $1 |
# }

# Set the title string at the top of your current terminal window or terminal window tab
set-title() {
    # Set the title escape sequence string with this format: `\[\e]2;new title\a\]`
    # - See: https://wiki.archlinux.org/index.php/Bash/Prompt_customization#Customizing_the_terminal_window_title
    print -nP "\e]2;"
    # avoid bug where prints with colour codes quit
    # the "set-title mode" and print into the shell
    echo $@ | ansi2txt | col -b
    print -nP "\a"
}
precmd() {
	set-title "%~"
}
preexec() {
	set-title "%# $1"
}

PROMPT='%{%1F%}%n@%m %{%3F%}%~ %{%B%4F%}%#%{%f%b%} '
RPROMPT='%0F(⮡%?) %*'

# turn off annoying ctrl+s to stop
stty -ixon
unset -f command_not_found_handler 2> /dev/null > /dev/null

HISTFILE=~/.zsh/history
HISTSIZE=50000000
SAVEHIST=10000000

while read -r line; do
  pushd -q "$line" 2> /dev/null > /dev/null
done < ~/.zsh/cd_history
zshexit() {
  dirs -lv | awk -F '\t' '{print $2}' | tac > ~/.zsh/cd_history
}

export VISUAL=/usr/bin/kak
export EDITOR=/usr/bin/kak

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export XDG_CONFIG_HOME=$HOME/.config

# default programs
alias -s pdf=evince
alias -s txt=kak
# images
alias -s png=eog
alias -s jpg=eog
alias -s jpeg=eog
alias -s bmp=eog
alias -s svg=eog

echoeval() {
	echo "$@"
	eval "$@"
}

clear-line() {
  echo "\033[2A\033[1000D"
}

fzf-shell() {
  fzf -i --ansi --height 40% --layout reverse --info inline --prompt "$(print -nP $PROMPT$1)"  ${=@[2,-1]}
}

fzftab-fzf() {
  echo "\033[1A"
  fzf_prompt=$(echo $BUFFER | sed 's/ [^ ]*$/ /')
  fzf-shell $fzf_prompt ${=@}
  # zle reset-prompt
  # if [[ $BUFFER[-1] == ' ' ]]; then
  #   print "${BUFFER%%[^ ]*}"
  # elif
  #   print 
}
zle -N fzftab-fzf
# bindkey -e '^p' fzftab-fzf

# default options
alias dnf='sudo dnf'
alias apt='sudo apt'
alias gcc='gcc -Wall -Wno-sign-compare'
alias g++='g++ -std=c++17 -Wall -Wno-sign-compare -Wshadow -Wextra -pedantic -O2'
alias g++f='g++ -Wfatal-errors'
alias rm='rm -i'
alias ln='ln -i'
alias mv='mv -i'
alias modprobe='modprobe -v --first-time'
alias diff='diff -s'
alias du='du -sh'
alias systemctl='systemctl -l'
alias ls='ls --color=tty'
alias grep='grep --color'
alias python='python3'
alias tree='tree -C' # colours on always
eval $(thefuck --alias)
alias f='fuck -y'
alias vb='echoeval kak ~/.zshrc'
alias vk='echoeval kak ~/.config/kak/kakrc'
alias vi='vim'
alias disk-usage-analyzer='baobab'
alias ranger='. ranger'
export FZF_COLORS="--color=dark,bg+:#231F33,gutter:-1,pointer:11,fg+:11,hl:1,hl+:1,prompt:4"
export FZF_DEFAULT_OPTS="--cycle --ansi $FZF_COLORS"
zstyle ':fzf-tab:*' fzf-flags "$FZF_COLORS"
zstyle ':fzf-tab:*' fzf-command fzf-shell
# alias fzf='fzf-0.24.3'
alias objdump='objdump -M intel'

#autocorrect xD
alias mvdir='echoeval mv'
alias cd..='cd ..'
alias cd~='cd ~'

clear-line() {
  echo "\033[1A\033[1000D"
}

# fzf
FZF_SHELL_DEFAULT_ARGS='-i --ansi --height=40% --layout=reverse --info=inline'

fzf_fasd_cd() {
  clear-line
  local IFS=' '
  dest=$(fasd -Rdl | sed "s#^$HOME#~#" | fzf-shell "cd " --filepath-word --tiebreak index)
  if [[ -n $dest ]]; then
    BUFFER="cd $dest"
    zle reset-prompt
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf_fasd_cd
bindkey '^t' fzf_fasd_cd

fzf_fasd_kak() {
  clear-line
  local IFS=' '
  dest=$(fasd -Rfl | sed "s#^$HOME#~#" | fzf-shell "kak " --filepath-word --tiebreak index)
  if [[ -n $dest ]]; then
    BUFFER="kak $dest"
    zle reset-prompt
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf_fasd_kak
bindkey '^e' fzf_fasd_kak

uniq_history() {
  history 0 | sort -b -s -k 2 | tac | uniq -f 1 | sort -nk 1 | sed 's/\\\\n/\\\\\\n/g'
}
fzf_history_search() {
  clear-line
  local IFS=' '
  result=$(uniq_history | sed 's/^ *[0-9]* *//' | fzf ${=FZF_SHELL_DEFAULT_ARGS} +s +m -x --tac -e -q "$BUFFER" --prompt "$(print -nP $PROMPT)")
  if [[ -n $result ]]; then
    BUFFER="$result"
  fi
  zle reset-prompt
  zle end-of-line
}
zle -N fzf_history_search
bindkey '^r' fzf_history_search

# completion
fpath=(~/.zsh/ninja-completion $fpath)
source ~/.zsh/fullpath_git_completion.zsh

# gcloud stuff
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/arjun/build/google-cloud-sdk/path.zsh.inc' ]; then . '/home/arjun/build/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/home/arjun/build/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/arjun/build/google-cloud-sdk/completion.zsh.inc'; fi

# llvm stuff
export LLVM_SYMBOLIZER_PATH='/usr/bin/llvm-symbolizer-11'
export PATH="$PATH:/home/arjun/build/arcanist/bin/"

# dotgit
alias dot="git --git-dir=$HOME/.dotgit --work-tree=$HOME"

# fasd
eval "$(fasd --init posix-alias zsh-hook)"
