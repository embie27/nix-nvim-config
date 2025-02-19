local servers = {}
if nixCats('neonixdev') then
  servers.lua_ls = {
    settings = {
      Lua = {
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { 'nixCats' },
          disable = { 'missing-fields' },
        },
      },
      telemetry = { enabled = false },

    },
    filetypes = { 'lua' },
  }
  servers.nixd = {
    settings = {
      nixd = {
        nixpkgs = {
          -- nixd requires some configuration in flake based configs.
          -- luckily, the nixCats plugin is here to pass whatever we need!
          -- we passed this in via the `extra` table in our packageDefinitions
          -- for additional configuration options, refer to:
          -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
          expr = [[import (builtins.getFlake "]] .. nixCats.extra("nixdExtras.nixpkgs") .. [[") { }   ]],
        },
        formatting = {
          command = { "nixfmt" }
        },
        diagnostic = {
          suppress = {
            "sema-escaping-with"
          }
        }
      }
    }
  }
  -- If you integrated with your system flake,
  -- you should pass inputs.self as nixdExtras.flake-path
  -- that way it will ALWAYS work, regardless
  -- of where your config actually was.
  -- otherwise flake-path could be an absolute path to your system flake, or nil or false
  -- TODO
  if nixCats.extra("nixdExtras.flake-path") then
    local flakePath = nixCats.extra("nixdExtras.flake-path")
    if nixCats.extra("nixdExtras.systemCFGname") then
      -- (builtins.getFlake "<path_to_system_flake>").nixosConfigurations."<name>".options
      servers.nixd.settings.nixd.options.nixos = {
        expr = [[(builtins.getFlake "]] .. flakePath ..  [[").nixosConfigurations."]] ..
          nixCats.extra("nixdExtras.systemCFGname") .. [[".options]]
      }
    end
    if nixCats.extra("nixdExtras.homeCFGname") then
      -- (builtins.getFlake "<path_to_system_flake>").homeConfigurations."<name>".options
      servers.nixd.settings.nixd.options["home-manager"] = {
        expr = [[(builtins.getFlake "]] .. flakePath .. [[").homeConfigurations."]]
          .. nixCats.extra("nixdExtras.homeCFGname") .. [[".options]]
      }
    end
  end
end

-- This is this flake's version of what kickstarter has set up for mason handlers.
-- This is a convenience function that calls lspconfig on the lsps we downloaded via nix
-- This will not download your lsp. Nix does that.

--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--  All of them are listed in https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
--  You may do the same thing with cmd

-- servers.clangd = {},
-- servers.gopls = {},
-- servers.pyright = {},
-- servers.rust_analyzer = {},
-- servers.tsserver = {},
-- servers.html = { filetypes = { 'html', 'twig', 'hbs'} },

if nixCats('languages.bash') then
  servers.bashls = {}
end
if nixCats('languages.python') then
  servers.pyright = {}
end
if nixCats('languages.latex') then
  servers.texlab = {
    settings = {
      texlab = {
        bibtexFormatter = "texlab",
        build = {
          executable = "latexmk",
          args = { "-pdf", "-interaction=nonstopmode", "-outdir=.", "-synctex=1", "%f" },
          forwardSearchAfter = true,
          onSave = false,
        },
        chktex = {
          onEdit = false,
          onOpenAndSave = false,
        },
        diagnosticsDelay = 300,
        formatterLineLength = 80,
        forwardSearch = {
          executable = "sioyek",
          args = { "--reuse-window", "--inverse-search", 'nvim-texlabconfig -file "%1" -line %2', "--forward-search-file", "%f", "--forward-search-line", "%l", "%p" },
        },
      },
    },
    on_attach_extra = function (_, _)
      vim.keymap.set("n", "mm", "<cmd>TexlabBuild<cr>", { desc = "Compile" })
      vim.keymap.set("n", "mf", "<cmd>TexlabForward<cr>", { desc = "Forward search" })
    end,
  }
  servers.ltex = {
    on_attach_extra = function (_, _)
      require("ltex_extra").setup {
        load_langs = { "de-DE", "en-US" },
        init_check = true,
        path = "ltex_dicts",
        log_level = "none",
      }
    end,
  }
end

if nixCats('lspDebugMode') then
  vim.lsp.set_log_level("debug")
end

require('lze').load {
  {
    "nvim-lspconfig",
    for_cat = "general.always",
    event = "FileType",
    load = (require('nixCatsUtils').isNixCats and vim.cmd.packadd) or function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("mason.nvim")
      vim.cmd.packadd("mason-lspconfig.nvim")
    end,
    after = function(plugin)
      for server_name, cfg in pairs(servers) do
        require('lspconfig')[server_name].setup({
          capabilities = require('myLuaConf.LSPs.caps-on_attach').get_capabilities(server_name),
          on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach(cfg),
          settings = (cfg or {}).settings,
          filetypes = (cfg or {}).filetypes,
          cmd = (cfg or {}).cmd,
          root_pattern = (cfg or {}).root_pattern,
        })
      end
    end,
  }
}
