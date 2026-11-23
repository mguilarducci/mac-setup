# mac-setup

## Getting started

### Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mguilarducci/mac-setup/HEAD/install.sh)"
```

### Config files

Config lives in [`config/`](config/) and is linked into place by `install.sh`:

| File | Linked to |
|---|---|
| `config/zsh/zprofile.zsh` | sourced from `~/.zprofile` |
| `config/zsh/zshrc.zsh` | sourced from `~/.zshrc` |
| `config/starship/starship.toml` | `~/.config/starship.toml` |
| `config/atuin/config.toml` | `~/.atuin/config.toml` |
| `config/ghostty/config.ghostty` | `~/.config/ghostty/config.ghostty` |
| `config/nvim/` (LazyVim): `init.lua`, `lua/`, `.neoconf.json`, `stylua.toml` | `~/.config/nvim/` (same names) |

When run through `curl`, the script clones this repo into `~/.mac-setup` and links to that clone.
Only config files are linked, so what the apps write next to them (like `lazy-lock.json`) stays out of the repo.
Anything already at a link target is moved to `<target>.bak.<timestamp>` first.
