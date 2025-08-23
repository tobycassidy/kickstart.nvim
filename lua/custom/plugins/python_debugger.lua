-- lua/plugins/python_debugger.lua

return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'mfussenegger/nvim-dap-python',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local dap_python = require 'dap-python'

      dap.adapters.python = {
        type = 'executable',
        command = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python',
        args = { '-m', 'debugpy.adapter' },
      }

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          console = 'internalConsole',
          pythonPath = function()
            return vim.fn.exepath 'python3' or vim.fn.exepath 'python'
          end,
        },
      }

      dapui.setup {
        controls = {
          icons = {
            pause = '',
            play = '',
            step_into = '',
            step_over = '',
            step_out = '',
            step_back = '',
            run_last = '↻',
            terminate = '',
          },
        },
        layouts = {
          {
            elements = {
              { id = 'scopes', size = 0.55 },
              { id = 'stacks', size = 0.05 },
              { id = 'breakpoints', size = 0.05 },
              { id = 'console', size = 0.05 },
              { id = 'watches', size = 0.3 },
            },
            size = 0.5,
            position = 'right',
          },
          { elements = { { id = 'repl' } }, size = 0.33, position = 'bottom' },
        },
        render = { max_value_lines = 100 },
        extensions = {},
      }

      require('nvim-dap-virtual-text').setup { commented = true }

      vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticSignError' })
      vim.fn.sign_define('DapBreakpointConditional', { text = 'C', texthl = 'DiagnosticSignWarn' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticSignError' })
      vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticSignWarn', linehl = 'Visual' })

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      local function map(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { desc = desc })
      end

      map('n', '<leader>dbb', dap.toggle_breakpoint, '[D]ebug toggle [B]reakpoint (Basic)')

      map('n', '<leader>dbc', function()
        local condition = vim.fn.input 'Breakpoint Condition: '
        if condition and condition ~= '' then
          dap.toggle_breakpoint(condition)
        end
      end, '[D]ebug toggle [B]reakpoint (Conditional)')

      map('n', '<leader>dr', function()
        local dir = vim.fn.input('Run debugger from directory: ', vim.fn.getcwd(), 'dir')
        if dir and dir ~= '' then
          local config = {
            type = 'python',
            request = 'launch',
            name = 'Launch with custom dir',
            program = '${file}',
            cwd = dir,
            console = 'internalConsole',
            pythonPath = function()
              return vim.fn.exepath 'python3' or vim.fn.exepath 'python'
            end,
          }
          dap_python.test_runner = 'pytest'
          dap.run(config)
        end
      end, '[D]ebug [R]un from directory')

      map('n', '<leader>dc', dap.continue, '[D]ebug [C]ontinue')
      map('n', '<leader>do', dap.step_over, '[D]ebug Step [O]ver')
      map('n', '<leader>di', dap.step_into, '[D]ebug Step [I]nto')
      map('n', '<leader>dO', dap.step_out, '[D]ebug Step [O]ut')
      map('n', '<leader>dq', dap.terminate, '[D]ebug [Q]uit')
      map('n', '<leader>du', dapui.toggle, '[D]ebug toggle [U]I')
    end,
  },
}
