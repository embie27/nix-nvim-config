vim.opt_local.iskeyword:append("\\")  -- Add '\' to iskeyword
vim.opt_local.iskeyword:remove("_")   -- Remove '_' from iskeyword

if nixCats("general.always") and nixCats("general.treesitter") then
  local spec_treesitter = require('mini.ai').gen_spec.treesitter
  vim.b.miniai_config = {
    custom_textobjects = {
      m = spec_treesitter { a = "@math.outer", i = "@math.inner" },
    }
  }
end

if nixCats("general.extra") and nixCats("general.treesitter") then
  local spec_treesitter = require('mini.surround').gen_spec.input.treesitter
  vim.b.minisurround_config = {
    custom_surroundings = {
      m = { input = spec_treesitter { outer = "@math.outer", inner = "@math.inner" }, output = { left = "\\( ", right = " \\)" } }
    }
  }
end
