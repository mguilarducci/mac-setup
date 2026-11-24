# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A one-shot, idempotent macOS setup: `install.sh` installs Homebrew, CLI tools, casks and fonts, then wires the dotfiles in `config/` into place. There is no build step and no test suite.

## Checking changes

```bash
bash -n install.sh lib.sh          # syntax check
shellcheck install.sh lib.sh       # lint
brew info <formula>                # confirm a formula exists before adding it
brew info --cask <cask>            # confirm a cask exists before adding it
./install.sh                       # full run (real changes to this Mac; safe to re-run)
```

Running `install.sh` end to end installs software and rewrites `~/.zprofile`, `~/.zshrc` and symlinks under `~/.config`, so don't run it without asking. PR descriptions in this repo state which checks were run and say explicitly when `install.sh` was **not** run end to end.

## Architecture

- **`install.sh`** is a flat sequence of `section` blocks. It must keep working when piped from `curl` (no local checkout): it sources `lib.sh` from next to itself if present, otherwise downloads and `eval`s it from GitHub `HEAD`, and clones the repo to `~/.mac-setup` (or `git pull --ff-only` if already cloned) to get `config/`. When run from a checkout, it uses that checkout's `config/` directly.
- **`lib.sh`** holds every helper. Everything must be idempotent and report via `ok` / `skip` / `note` / `step`:
  - `install_formula <formula> <name>` / `install_cask <cask> <name> [App.app]` — skip if brew already has it; for casks, pass the `.app` name so apps installed outside Homebrew are skipped instead of making brew fail.
  - `link <src> <dst>` — symlinks a config file; existing real files are moved to `<dst>.bak.<timestamp>`.
  - `source_config <rc> <dir> <rel>` — adds a `source "<repo>/config/<rel>"` line to an rc file and removes lines pointing at the same file in another copy of the repo.
  - `add_line` / `remove_line` / `remove_block` — exact-match edits, used to migrate away from what older versions of the script wrote.
- **Logging**: `gum` is installed right after Homebrew and `enable_gum` switches the log helpers to it. Only messages are styled; `brew` and other commands must print straight to the terminal (no gum spinners/borders — they hid brew prompts).
- **Shell config**: `~/.zprofile` and `~/.zshrc` only get a single `source` line each, pointing at `config/zsh/zprofile.zsh` / `zshrc.zsh`, so other installers can still append to them. New shell setup goes into those files (or a new file under `config/zsh/` sourced from `zshrc.zsh`), not into the rc files. Tool inits in `zshrc.zsh` are guarded with `command -v`; zoxide must stay last.
- **App config**: only the config files themselves are symlinked (e.g. nvim's `init.lua`, `lua/`, `.neoconf.json`, `stylua.toml`), never whole app directories, so files the apps write (like `lazy-lock.json`) stay out of the repo. Keep the README's config-file table in sync when adding a link.
- **Migrations**: when changing where something is written, add `remove_line`/`remove_block` calls for the old form so re-running on an older setup cleans it up.

## Conventions

- Commits/PR titles use conventional prefixes (`feat:`, `fix:`, `refactor:`, `chore:`). Adding a tool is usually one `install_formula`/`install_cask` line in the right section, plus a comment if another tool depends on it.
- Comments and user-facing messages are short, plain English.
