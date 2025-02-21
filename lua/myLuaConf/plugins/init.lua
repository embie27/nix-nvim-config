local colorschemeName = nixCats('colorscheme')
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!
vim.cmd.colorscheme(colorschemeName)

local ok, notify = pcall(require, "notify")
if ok then
  notify.setup({
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  })
  vim.notify = notify
  vim.keymap.set("n", "<Esc>", function()
      notify.dismiss({ silent = true, })
  end, { desc = "dismiss notify popup" })
end

if nixCats('general.extra') then
  vim.g.loaded_netrwPlugin = 1
end

require('lze').load {
  { import = "myLuaConf.plugins.telescope", },
  { import = "myLuaConf.plugins.treesitter", },
  { import = "myLuaConf.plugins.completion", },
  {
    "lazydev.nvim",
    for_cat = 'neonixdev',
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(plugin)
      require('lazydev').setup({
        library = {
          { words = { "nixCats" }, path = (require('nixCats').nixCatsPath or "") .. '/lua' },
        },
      })
    end,
  },
  {
    "ltex_extra.nvim",
    for_cat = "languages.latex",
    on_require = "ltex_extra",
  },
  {
    "texlabconfig",
    for_cat = "languages.latex",
    ft = "tex",
    after = function (_)
      require("texlabconfig").setup()
    end
  },
  {
    "markdown-preview.nvim",
    -- NOTE: for_cat is a custom handler that just sets enabled value for us,
    -- based on result of nixCats('cat.name') and allows us to set a different default if we wish
    -- it is defined in luaUtils template in lua/nixCatsUtils/lzUtils.lua
    -- you could replace this with enabled = nixCats('cat.name') == true
    -- if you didnt care to set a different default for when not using nix than the default you already set
    for_cat = 'general.markdown',
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "undotree",
    for_cat = 'general.extra',
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "mini.basics",
    for_cat = "general.always",
    event = "DeferredUIEnter",
    after = function (_)
      require("mini.basics").setup {
        mappings = {
          basic = true,
          windows = true,
        }
      }
    end
  },
  {
    "mini.ai",
    for_cat = "general.always",
    event = "DeferredUIEnter",
    on_require = "mini.ai",
    after = function (_)
      require("mini.ai").setup {
        search_method = 'cover',
      }
    end
  },
  {
    "mini.jump",
    for_cat = "general.always",
    event = "DeferredUIEnter",
    after = function (_)
      require("mini.jump").setup {}
    end
  },
  {
    "mini.surround",
    for_cat = "general.extra",
    event = "DeferredUIEnter",
    on_require = "mini.surround",
    after = function (_)
      require("mini.surround").setup {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal and Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      }
    end
  },
  {
    "mini.splitjoin",
    for_cat = "general.extra",
    event = "DeferredUIEnter",
    after = function (_)
      require("mini.splitjoin").setup {}
    end
  },
  {
    "mini.files",
    for_cat = "general.extra",
    event = "DeferredUIEnter",
    after = function (_)
      require("mini.files").setup {
        preview = true,
      }
      vim.keymap.set("n", "<leader>e", MiniFiles.open, { desc = "Open Explorer" })
    end
  },
  {
    "comment.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('Comment').setup()
    end,
  },
  {
    "indent-blankline.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require("ibl").setup()
    end,
  },
  {
    "vim-startuptime",
    for_cat = 'general.extra',
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "fidget.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require('fidget').setup({
        progress = {
          suppress_on_insert = true,
          ignore = { "ltex", },
        },
      })
    end,
  },
  -- {
  --   "hlargs",
  --   for_cat = 'general.extra',
  --   event = "DeferredUIEnter",
  --   -- keys = "",
  --   dep_of = { "nvim-lspconfig" },
  --   after = function(plugin)
  --     require('hlargs').setup {
  --       color = '#32a88f',
  --     }
  --     vim.cmd([[hi clear @lsp.type.parameter]])
  --     vim.cmd([[hi link @lsp.type.parameter Hlargs]])
  --   end,
  -- },
  -- {
  --   "lualine.nvim",
  --   for_cat = 'general.always',
  --   -- cmd = { "" },
  --   event = "DeferredUIEnter",
  --   -- ft = "",
  --   -- keys = "",
  --   -- colorscheme = "",
  --   after = function (plugin)
  --
  --     require('lualine').setup({
  --       options = {
  --         icons_enabled = false,
  --         theme = colorschemeName,
  --         component_separators = '|',
  --         section_separators = '',
  --       },
  --       sections = {
  --         lualine_c = {
  --           {
  --             'filename', path = 1, status = true,
  --           },
  --         },
  --       },
  --       inactive_sections = {
  --         lualine_b = {
  --           {
  --             'filename', path = 3, status = true,
  --           },
  --         },
  --         lualine_x = {'filetype'},
  --       },
  --     })
  --   end,
  -- },
  {
    "gitsigns.nvim",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (plugin)
      require('gitsigns').setup({
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })

          if nixCats('general.which-key') then
            require('which-key').add {
              { "<leader>g", group = "Git" },
            }
          end
        end,
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end,
  },
  {
    "which-key.nvim",
    for_cat = 'general.which-key',
    -- cmd = { "" },
    event = "DeferredUIEnter",
    on_require = "which-key",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (plugin)
      require('which-key').setup({
      })
      if nixCats('general.markdown') then
        require('which-key').add {
          { "<leader>m", group = "Markdown" },
        }
      end
    end,
  },
  {
    "snacks.nvim",
    for_cat = 'snacks',
    event = "DeferredUIEnter",
    after = function (plugin)
      local config = {}

      if nixCats("general.extra") then
        config.lazygit = {}

        vim.keymap.set("n", "<leader>gg", Snacks.lazygit.open, { desc = "Open Lazygit" })
      end
      
      require('snacks').setup(config)
    end,
  },
}
