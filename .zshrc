if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

alias qldsup="sudo systemctl enable --now docker-compose-qlds.service"
alias qldsdown="sudo systemctl disable --now docker-compose-qlds.service"
alias qldsrestart="sudo systemctl disable --now docker-compose-qlds.service; sudo systemctl enable --now docker-compose-qlds.service"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh