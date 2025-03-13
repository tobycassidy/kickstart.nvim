return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'rcarriga/nvim-dap-ui',
      'mfussenegger/nvim-dap-python',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local dap_python = require 'dap-python'

      local function setup_dap()
        dapui.setup()
        require('nvim-dap-virtual-text').setup {
          commented = true,
        }

        dap_python.setup 'python'

        vim.fn.sign_define('DapBreakpoint', {
          text = '',
          texthl = 'DiagnosticSignError',
          linehl = '',
          numhl = '',
        })

        vim.fn.sign_define('DapBreakpointRejected', {
          text = '', -- or "❌"
          texthl = 'DiagnosticSignError',
          linehl = '',
          numhl = '',
        })

        vim.fn.sign_define('DapStopped', {
          text = '', -- or "→"
          texthl = 'DiagnosticSignWarn',
          linehl = 'Visual',
          numhl = 'DiagnosticSignWarn',
        })

        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open()
        end
      end

      local function map(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { desc = desc })
      end

      setup_dap()

      map('n', '<leader>db', function()
        dap.toggle_breakpoint()
      end, '[D]ebug toggle [B]reakpoint')

      map('n', '<leader>dr', function()
        local dir = vim.fn.input('Run debugger from directory: ', vim.fn.getcwd(), 'dir')
        if dir ~= '' then
          dap_python.test_runner = 'pytest'
          dap.configurations.python = {
            {
              type = 'python',
              request = 'launch',
              name = 'Launch with custom dir',
              program = '${file}',
              pythonPath = function()
                return vim.fn.exepath 'python'
              end,
              cwd = dir,
            },
          }
          dap.continue()
        end
      end, '[D]ebug [R]un from directory')

      map('n', '<leader>dc', function()
        dap.continue()
      end, '[D]ebug [C]ontinue')

      map('n', '<leader>do', function()
        dap.step_over()
      end, '[D]ebug Step [O]ver')

      map('n', '<leader>di', function()
        dap.step_into()
      end, '[D]ebug Step [I]nto')

      map('n', '<leader>dO', function()
        dap.step_out()
      end, '[D]ebug Step [O]ut')

      map('n', '<leader>dq', function()
        dapui.close()
        dap.terminate()
        dap.configurations = {}
        dap.adapters = {}
        setup_dap()
      end, '[D]ebug [Q]uit')

      map('n', '<leader>du', function()
        dapui.toggle()
      end, '[D]ebug toggle [U]I')
    end,
  },
}
