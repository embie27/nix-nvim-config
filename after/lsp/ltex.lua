return {
  settings = {
    ltex = {
      latex = {
        commands = {
          ["\\todo[]{}"] = "ignore",
          ["\\todo{}"] = "ignore",
          ["\\labelcref{}"] = "dummy", -- can be removed once I upgrade to ltex-ls-plus
          ["\\labelcrefrange{}{}"] = "dummy",
          ["\\MD{}"] = "dummy", -- only necessary for master thesis; find a more suitable solution for similar cases in the future
        },
      },
    },
  },
  on_attach = function (client, bufnr)
    require("ltex_extra").setup {
      load_langs = { "de-DE", "en-US" },
      init_check = true,
      path = (client.root_dir or ".") .."/ltex_dicts",
      log_level = "none",
    }
  end,
}
