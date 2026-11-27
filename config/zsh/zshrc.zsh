# Interactive shell setup. Sourced from ~/.zshrc by mac-setup's install.sh.

# Directory of this file, so the other files load from the same place.
MAC_SETUP_ZSH="${${(%):-%x}:A:h}"

source "$MAC_SETUP_ZSH/op-sa.zsh"
source "$MAC_SETUP_ZSH/aliases.zsh"

# Starship prompt: https://starship.rs (config: config/starship/starship.toml)
command -v starship > /dev/null && eval "$(starship init zsh)"

# Atuin: Ctrl-R and the up arrow search the shell history (config: config/atuin/config.toml)
command -v atuin > /dev/null && eval "$(atuin init zsh)"

# mise: puts the runtimes from mise.toml / .tool-versions on the PATH per directory.
command -v mise > /dev/null && eval "$(mise activate zsh)"

# zoxide: `z <part of a path>` jumps to a frequently used directory.
# Keep it last: zoxide must load after compinit.
command -v zoxide > /dev/null && eval "$(zoxide init zsh)"

unset MAC_SETUP_ZSH
