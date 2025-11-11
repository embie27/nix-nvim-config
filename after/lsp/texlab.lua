return {
  settings = {
    texlab = {
      bibtexFormatter = "texlab",
      -- TODO figure out how to use flake and fallback to latexmk
      -- build = _G.TeXMagicBuildConfig,
      chktex = {
        onEdit = false,
        onOpenAndSave = false,
      },
      diagnosticsDelay = 300,
      formatterLineLength = 80,
      forwardSearch = {
        executable = "sioyek",
        args = { "--execute-command", "turn_on_synctex", "--inverse-search", 'nvim-texlabconfig -file "%%1" -line %%2 -server "' .. vim.v.servername .. '" -cache_root "' .. vim.fn.stdpath('cache') .. '"', "--forward-search-file", "%f", "--forward-search-line", "%l", "%p" },
      },
      experimental = {
        labelReferenceRangeCommands = { "labelcrefrange" },
      },
      inlayHints = {
        maxLength = 15,
      },
    },
  },
}
