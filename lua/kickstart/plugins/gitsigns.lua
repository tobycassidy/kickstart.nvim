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
          local branch = vim.fn.input 'Diff against branch: '
          if not branch or branch == '' then
            return
          end
          local files = vim.fn.systemlist('git diff --name-only ' .. branch)
          select_file(files, 'Changed files', function(file)
            vim.cmd.edit(file)
            require('gitsigns').diffthis(branch)
          end)
        end

        local function resolve_conflicts()
          local files = vim.fn.systemlist 'git diff --name-only --diff-filter=U'
          select_file(files, 'Conflicting files', function(file)
            vim.cmd.edit(file)
          end)
        end

        vim.keymap.set('n', '<leader>gvd', diff_against_branch, { desc = '[V]iew [D]iff against branch' })
        vim.keymap.set('n', '<leader>gvm', resolve_conflicts, { desc = '[V]iew [M]erge conflicts' })

        -- This function stages the correct hunk AND updates the buffer to match
        local function resolve_and_apply_hunk(version)
          -- Find which line to stage based on 'ours' or 'theirs'
          local start_marker = vim.fn.search('^<<<<<<<', 'bnW')
          if start_marker == 0 then
            vim.notify('Not inside a conflict.', vim.log.levels.WARN, { title = 'Gitsigns' })
            return
          end

          local line_to_stage
          if version == 'ours' then
            line_to_stage = start_marker + 1
          else -- 'theirs'
            local original_cursor_pos = vim.api.nvim_win_get_cursor(0)
            vim.api.nvim_win_set_cursor(0, { start_marker, 0 })
            local middle_marker = vim.fn.search('^=======', 'nW')
            vim.api.nvim_win_set_cursor(0, original_cursor_pos)
            if middle_marker == 0 then
              vim.notify('Could not find middle marker for conflict.', vim.log.levels.WARN, { title = 'Gitsigns' })
              return
            end
            line_to_stage = middle_marker + 1
          end

          gitsigns.stage_hunk { line_to_stage, line_to_stage }

          local filepath = vim.fn.expand '%:p'
          if filepath and filepath ~= '' then
            vim.fn.system('git checkout -- ' .. vim.fn.shellescape(filepath))
            vim.cmd 'checktime'
          end
        end

        map('n', '<leader>hco', function()
          resolve_and_apply_hunk 'ours'
        end, { desc = 'Choose & Apply [O]urs' })

        map('n', '<leader>hct', function()
          resolve_and_apply_hunk 'theirs'
        end, { desc = 'Choose & Apply [T]heirs' })
      end,
    },
  },
}
