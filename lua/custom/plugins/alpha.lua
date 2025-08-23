-- lua/custom/plugins/alpha.lua
return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Your new custom ASCII art for "NEOVIM"
    dashboard.section.header.val = {
      '|_   \\|_   _||_  _| |_  _||_   _||_   \\  /   _| ',
      '  |   \\ | |    \\ \\   / /    | |    |   \\/   |   ',
      '  | |\\ \\| |     \\ \\ / /     | |    | |\\  /| |   ',
      " _| |_\\   |_     \\ ' /     _| |_  _| |_\\/_| |_  ",
      '|_____|\\____|     \\_/     |_____||_____||_____|',
    }

    -- Set up the dashboard buttons
    dashboard.section.buttons.val = {
      dashboard.button('f', '󰈞  Find file', ':Telescope find_files <CR>'),
      dashboard.button('n', '  New file', ':enew <CR>'),
      dashboard.button('r', '  Recent files', ':Telescope oldfiles <CR>'),
      dashboard.button('g', '  Find text', ':Telescope live_grep <CR>'),
      dashboard.button('q', '  Quit', ':qa<CR>'),
    }

    -- Center the layout
    dashboard.opts.layout = {
      { type = 'padding', val = 4 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
      dashboard.section.buttons,
    }

    -- Send the config to alpha
    alpha.setup(dashboard.opts)
  end,
}
