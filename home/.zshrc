# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Preconfigure Zsh Vi Mode
function zvm_config() { 
  ZVM_VI_HIGHLIGHT_BACKGROUND=#585b70
  ZVM_VI_HIGHLIGHT_FOREGROUND=#f5c2e7
  ZVM_VI_SURROUND_BINDKEY=s-prefix 
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
  ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
  ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
}

# Source Miniplug plugin manager
source "$HOME/.miniplug.zsh"

# Define theme
miniplug theme "romkatv/powerlevel10k"

# Define plugins
miniplug plugin "zdharma-continuum/fast-syntax-highlighting"
miniplug plugin "zsh-users/zsh-autosuggestions"
miniplug plugin "zsh-users/zsh-completions"
miniplug plugin "jeffreytse/zsh-vi-mode"

# Source plugins
miniplug load

# Make Zsh command history persistent
HISTFILE=~/.zsh_history
HISTSIZE=500
SAVEHIST=500
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt incappendhistory

# Catppuccin theme for Fast Syntax Highlighting
fast-theme XDG:catppuccin-mocha -q

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Catppuccin theme for fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Set editor to Neovim
export EDITOR="nvim"
export SUDO_EDITOR="nvim"

# Set up Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Custom variables
export NVIM="$HOME/.config/nvim"
export SHADA="$HOME/.local/state/nvim/shada"

# Custom aliases
alias ls="lsd"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -e /home/brine/.nix-profile/etc/profile.d/nix.sh ]; then . /home/brine/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
