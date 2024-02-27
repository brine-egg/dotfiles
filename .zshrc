# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Miniplug plugin manager
source "$HOME/.miniplug/miniplug.zsh"

# Define theme
miniplug theme 'romkatv/powerlevel10k'

# Define plugins
miniplug plugin 'zdharma-continuum/fast-syntax-highlighting'
miniplug plugin 'marlonrichert/zsh-autocomplete'
miniplug plugin 'zsh-users/zsh-autosuggestions'
miniplug plugin 'zsh-users/zsh-completions'

# Source plugins
miniplug load

# Set up zoxide
eval "$(zoxide init --cmd cd zsh)"

# Custom variables
export NVIM="$HOME/.config/nvim"

# Custom aliases
alias ls="lsd"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
