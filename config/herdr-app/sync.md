# Herdr mods sync

The community mods and layouts installed in Herdr are listed in
`personal-mods.json`, next to this file, so a new Mac can get them back.
Herdr's own `~/.config/herdr-app/AGENTS.md` still says how to install each
one. These rules only keep the list in sync.

## Where to edit the list

`personal-mods.json` lives in the mac-setup repo
(https://github.com/mguilarducci/mac-setup), at
`config/herdr-app/personal-mods.json`. Edit it in a working checkout of that
repo, never in `~/.mac-setup`: that clone is read-only and `install.sh`
updates it. If you can't find a checkout, ask the person where it is.

## Rules

1. After installing a community mod or layout, add an entry for it.
2. After removing one, remove its entry.
3. When asked to restore the mods, install each entry at its `commit`,
   following Herdr's `AGENTS.md`, under its `as` name when set. Skip entries
   that are already installed. If a repo or commit is gone, say so and move on.

## Format

```json
{
  "mods": [
    {
      "url": "https://github.com/<owner>/<repo>/tree/main/<folder>",
      "commit": "<full commit SHA that was installed>",
      "as": "<local name, only when it differs from the original>"
    }
  ]
}
```

- `url`: the folder the mod or layout was installed from.
- `commit`: the full SHA of the version that was read and installed.
- `as`: only when the mod was renamed because its name was taken.
