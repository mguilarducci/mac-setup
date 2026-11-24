-- Show dotfiles (.gitignore, .claude, ...) by default.
-- Toggle in the explorer with H (hidden) and I (git-ignored).
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
        },
        files = {
          hidden = true,
        },
      },
    },
  },
}
