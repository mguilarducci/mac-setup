# op-sa <keychain-item> <op args...> runs the 1Password CLI with a service
# account token read from the Keychain. The plain `op` command is left untouched.
#
# Store a token with:
#   security add-generic-password -U -a "$USER" -s <keychain-item> -w
op-sa() {
  if [ $# -lt 1 ]; then
    echo "Usage: op-sa <keychain-item> [op args...]" >&2
    return 1
  fi
  local item="$1" token
  shift
  token="$(security find-generic-password -a "$USER" -s "$item" -w)" || return
  OP_SERVICE_ACCOUNT_TOKEN="$token" command op "$@"
}
