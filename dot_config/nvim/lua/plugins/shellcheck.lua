return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "shellcheck", "shfmt", "bash-language-server" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          settings = {
            bashIde = {
              shellcheckPath = "shellcheck",
            },
          },
        },
      },
    },
  },
}
