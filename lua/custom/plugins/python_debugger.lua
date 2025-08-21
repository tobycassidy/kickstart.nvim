-- lua/plugins/python_debugger.lua

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
        dapui.setup {
          layouts = {
            {
              elements = {
                -- Grouping these three makes sense for state inspection
                { id = 'scopes', size = 0.6 }, -- Give scopes the most space in this panel
                { id = 'stacks', size = 0.2 },
                { id = 'watches', size = 0.2 },
              },
              size = 40,
              position = 'left',
            },
            {
              elements = { 'repl', 'console' },
              size = 0.25,
              position = 'bottom',
            },
            {
              elements = { 'breakpoints' },
              size = 20,
              position = 'right',
            },
          },
          render = {
            max_value_lines = 100, -- Show more lines for expanded values
          },
          extensions = {
            pandas_visualizer = {
              render = function(dapui_node)
                if dapui_node.variable.type ~= 'pandas.core.frame.DataFrame' then
                  return nil
                end

                local expression = string.format(
                  "print('Shape: ' .. repr(%s.shape) .. '\\n\\n' .. %s.head(10).to_markdown())",
                  dapui_node.variable.name,
                  dapui_node.variable.name
                )
                local result, bufnr = dap.repl.execute(expression)

                if result.success then
                  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                  vim.api.nvim_buf_delete(bufnr, { force = true })
                  return lines
                else
                  return { 'Error fetching DataFrame view' }
                end
              end,
            },
          },
        }

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
          text = '',
          texthl = 'DiagnosticSignError',
          linehl = '',
          numhl = '',
        })

        vim.fn.sign_define('DapStopped', {
          text = '',
          texthl = 'DiagnosticSignWarn',
          linehl = 'Visual',
          numhl = 'DiagnosticSignWarn',
        })

        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open()
        end

        dap.listeners.before.event_terminated['dapui_config'] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
          dapui.close()
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
