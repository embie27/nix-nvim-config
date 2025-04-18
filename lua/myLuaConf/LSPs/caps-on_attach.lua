local M = {}
local function on_attach(_, bufnr)
  -- we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>lr', vim.lsp.buf.rename, 'Rename')
  nmap('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

  -- NOTE: why are these functions that call the telescope builtin?
  -- because otherwise they would load telescope eagerly when this is defined.
  -- due to us using the on_require handler to make sure it is available.
  if nixCats('general.telescope') then
    nmap('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
    nmap('gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
    nmap('<leader>lds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
    nmap('<leader>lws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
  end -- TODO: someone who knows the builtin versions of these to do instead help me out please.

  nmap('<leader>lD', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-K>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  -- Enable inlay hints
  vim.lsp.inlay_hint.enable(true)

  if nixCats('general.which-key') then
    require('which-key').add {
      { "<leader>l", group = "Lsp" },
    }
  end

end

function M.on_attach(cfg, client, bufnr)
  return function(client, bufnr)
    on_attach(client, bufnr)
    if cfg['on_attach_extra'] then
      cfg['on_attach_extra'](client, bufnr)
    end
  end
end

function M.get_capabilities(server_name)
  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  -- if you make a package without it, make sure to check if it exists with nixCats!
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if nixCats('general.cmp') then
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  end
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end
return M
