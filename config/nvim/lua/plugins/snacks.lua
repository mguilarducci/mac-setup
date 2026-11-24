-- Show dotfiles (.gitignore, .claude, ...) by default, but not the .git folder.
-- Toggle in the explorer with H (hidden) and I (git-ignored).
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { ".git" },
        },
        files = {
          hidden = true,
        },
      },
    },
  },
}
