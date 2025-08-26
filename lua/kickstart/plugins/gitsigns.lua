-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>td', gitsigns.toggle_deleted, { desc = '[T]oggle git show [d]eleted' })

        local function select_file(files, prompt, callback)
          if vim.tbl_isempty(files) then
            vim.notify(prompt .. ' has no files to view.', vim.log.levels.INFO, { title = 'Git' })
            return
          end
          vim.ui.select(files, { prompt = prompt .. ':' }, function(choice)
            if choice then
              callback(choice)
            end
          end)
        end

        local function diff_against_branch()
          require('telescope.builtin').git_branches {
            attach_mappings = function(prompt_bufnr, map)
              local actions = require 'telescope.actions'
              local state = require 'telescope.actions.state'

              local custom_select_action = function(bufnr)
                actions.close(bufnr)

                local selection = state.get_selected_entry()
                local branch = selection.value

                if not branch or branch == '' then
                  return
                end

                local files = vim.fn.systemlist('git diff --name-only ' .. branch)

                select_file(files, 'Changed files in ' .. branch, function(file)
                  vim.cmd.edit(file)
                  vim.cmd 'diffoff'
                  vim.defer_fn(function()
                    gitsigns.diffthis(branch)
                  end, 100)
                end)
              end

              map('i', '<CR>', custom_select_action)
              return true
            end,
          }
        end

        local function resolve_conflicts()
          local files = vim.fn.systemlist 'git diff --name-only --diff-filter=U'
          select_file(files, 'Conflicting files', function(file)
            vim.cmd.edit(file)
          end)
        end

        vim.keymap.set('n', '<leader>gvd', diff_against_branch, { desc = '[V]iew [D]iff against branch' })
        vim.keymap.set('n', '<leader>gvm', resolve_conflicts, { desc = '[V]iew [M]erge conflicts' })
      end,
    },
  },
}
