[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc" # Load the default .bashrc

#-------------------
# Detect OS
#-------------------

platform='unknown'
unamestr=`uname`
host=`hostname`

if [[ "$unamestr" == 'Linux' ]]; then
  # Windows Linux subsystem
  platform='winubuntu'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='mac'
elif [[ "$unamestr" =~ ^MINGW64_NT-.* ]]; then
  platform='gitbash'
fi

# https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-PowerShell
# https://github.com/dahlbyk/posh-git
# choco install poshgit
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
# Import-Module posh-git
# Add-PoshGitToProfile -AllHosts

#-------------------
# Useful aliases
#-------------------

alias epoch="date +%s"

alias code.bash="code $HOME/.bash_profile"
if [[ $platform == 'gitbash' ]]; then
  alias code.ps="code $HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1"
fi

alias h='history'
alias which='type -a'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'
alias du='du -kh'       # Makes a more readable output.
alias df='df -kTh'
alias ff='find . -name'
alias psx='ps aux | grep'
alias stop="kill -9"

if [[ $platform == 'mac' ]]; then
  alias ls='ls -G'
elif [[ $platform == 'linux' ]]; then
  alias ls='ls --color=auto'
else
  alias ls='ls --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias clean='find . -name *.swp -print0 | xargs -0 rm'
alias undos='find . -exec dos2unix \{\} \; -print'

alias got='git' # because I keep mistyping this

#-------------------
# OS specific stuff
#-------------------

export EDITOR=vim
export HISTCONTROL=ignoredups

if [[ $platform == 'linux' ]]; then
  #source /etc/bash_completion.d/git
  export PS1='\[\e]0;\w\a\]\n\[\e[0m\][\[\e[36m\]\t \[\e[32m\]\u \[\e[33m\]\w\[\e[32m\]$(__git_ps1 " (%s)")\[\e[0m\]]$ '
elif [[ $platform == 'mac' ]]; then
  if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
    export PS1='\[\e]0;\w\a\]\n\[\e[0m\][\[\e[36m\]\t \[\e[32m\]\u \[\e[33m\]\w\[\e[32m\]$(__git_ps1 " (%s)")\[\e[0m\]]\n$ '
  fi
# elif [[ $platform == 'windows' ]]; then
#   export PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$'
fi

if [[ $platform == 'mac' ]]; then

  code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

  export PATH=/usr/local/sbin:/usr/local/bin:$PATH:$HOME/bin
  export COMMAND_MODE=unix2003

  export BASH_SILENCE_DEPRECATION_WARNING=1

  export PATH=$(pyenv root)/shims:$PATH

  alias xcode.which='xcode-select --print-path'
  alias fixcam='sudo killall VDCAssistant'

  alias code.vim="code $HOME/.vimrc"
  alias code.gvim="code $HOME/.gvimrc"

  [ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

elif [[ $platform == 'gitbash' ]]; then

  ## https://stackoverflow.com/questions/70998844/git-warning-encountered-old-style-home-user-gitignore-that-should-be-pre
  ## put this in ~/.gitconfig on Windows
  # [core]
  #   excludesfile = %(prefix)/Users/jerry.dantonio/.gitignore

  # export MSYS_NO_PATHCONV=1
 
  export GANDALF_ENABLE_AUTOUPGRADE=1

  alias open="explorer"
  alias open.home='explorer "$USERPROFILE"'

  alias code.vim="code $HOME/_vimrc"
  alias code.gvim="code $HOME/_gvimrc"

  # https://blog.albertarmea.com/post/115102365718/using-gvim-from-git-bash
  export GVIM_ROOT="/c/Program Files (x86)/Vim/vim90"
  alias vim='"$GVIM_ROOT/vim.exe"'
  alias view='"$GVIM_ROOT/vim.exe" -R'
  alias vimdiff='"$GVIM_ROOT/vim.exe" -d'
  alias gvim='"$GVIM_ROOT/gvim.exe"'
  alias gvimdiff='"$GVIM_ROOT/gvim.exe" -d'

  if [ `ps aux|grep ssh-agent|wc -l` -eq 0 ]; then
    ssh-agent > $HOME/.ssh/ssh-agent
    source $HOME/.ssh/ssh-agent
    ssh-add
  else
    echo 'Found an already running ssh agent'
    source $HOME/.ssh/ssh-agent
  fi

  # https://chocolatey.org/install
  # Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  #
  # https://github.com/ajeetdsouza/zoxide
  # choco install zoxide
  # choco install fzf
  eval "$(zoxide init bash)"
  alias j=z # because I use autojump on Mac
fi

#-------------------
# Git Stuff
#-------------------

alias git.snapshot="git stash && git stash apply"
alias git.snap="git.snapshot"
# alias git.yolo="git commit -am "DEAL WITH IT" && git push -f origin master"

git.get() {
  branch=${1:-$(git branch --show-current)}
  git stash
  git fetch
  git pull origin $branch
}

git.refresh() {
  root=${1:-.}

  wd=$PWD
  cd "$root"

  for dir in ./*; do
    cd "$dir"
    echo "///===>>> $dir"
    git stash
    git checkout master
    git fetch
    git remote prune origin
    git pull origin master
    echo
    cd ..
  done

  cd "$wd"
}

gut() {
  if [[ $1 == 'pull' ]]; then
    echo "FINISH HIM!"
  fi
  git "$@"
}

code.diff() {
  sha=${1:-HEAD^1}

  git diff $sha > $HOME/Desktop/$sha.diff | code $HOME/Desktop/$sha.diff
}

#-------------------
# macOS Stuff
#-------------------

if [[ $platform == 'mac' ]]; then
  xcode.update() {
    killall com.apple.CoreSimulator.CoreSimulatorService
    sudo rm -rf /Library/Developer
    sudo ./External/Toolchains/apple/<version>/Xcode.app/Contents/Developer/usr/bin/xcodebuild -runFirstLaunch    
  }


#-------------------
# Shell Start
#-------------------
# export NO_EXTERNAL=true

cd $HOME