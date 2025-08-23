-- lua/custom/plugins/dropbar.lua

return {
  'bekaboo/dropbar.nvim',
  -- The 'pick' function requires Telescope, which you already have.
  -- This dependency makes the fuzzy finding faster.
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-fzf-native.nvim',
  },
  config = function()
    -- This line is important! It activates the plugin with default settings.
    require('dropbar').setup {}

    -- Add the keymaps below this line
    local dropbar_api = require 'dropbar.api'
    vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Dropbar: Pick symbols' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Dropbar: Go to context start' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Dropbar: Select next context' })
  end,
}
