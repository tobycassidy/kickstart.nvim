-- lua/custom/diagnostics.lua
local diagnostics_enabled = true

local function toggle_diagnostics()
  if diagnostics_enabled then
    vim.diagnostic.disable(0)
    diagnostics_enabled = false
    vim.notify('Diagnostics: [Disabled]', vim.log.levels.INFO, { title = 'LSP' })
  else
    vim.diagnostic.enable(0)
    diagnostics_enabled = true
    vim.notify('Diagnostics: [Enabled]', vim.log.levels.INFO, { title = 'LSP' })
  end
end

vim.api.nvim_create_user_command('ToggleDiagnostics', toggle_diagnostics, {
  desc = 'Enable or disable diagnostics for the current buffer',
})

local map = vim.g.map or function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
end

map('n', '<leader>tq', toggle_diagnostics, '[T]oggle [Q]uickfix Diagnostics')

return {}
