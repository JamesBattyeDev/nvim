return {
  -- ========================================================================
  -- TELESCOPE: Fuzzy finder (your #1 priority - fast navigation)
  -- ========================================================================
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local send_to_harpoon = function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local picks = picker:get_multi_selection()
        if vim.tbl_isempty(picks) then picks = { action_state.get_selected_entry() } end
        local list = require('harpoon'):list()
        local count = 0
        for _, entry in ipairs(picks) do
          local path = entry.path or entry.filename or entry.value
          if type(path) == 'string' and path ~= '' then
            local rel = vim.fn.fnamemodify(path, ':.')
            list:add { value = rel, context = { row = entry.lnum or 1, col = entry.col or 0 } }
            count = count + 1
          end
        end
        actions.close(prompt_bufnr)
        vim.notify(('Harpooned %d file%s'):format(count, count == 1 and '' or 's'))
      end

      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/', 'dist/', '.next/' },
          layout_config = {
            horizontal = { preview_width = 0.55 },
          },
          mappings = {
            i = {
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<C-h>'] = send_to_harpoon,
              ['<C-,>'] = actions.move_selection_previous,
              ['<C-.>'] = actions.move_selection_next,
            },
            n = {
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<C-h>'] = send_to_harpoon,
              ['<C-,>'] = actions.move_selection_previous,
              ['<C-.>'] = actions.move_selection_next,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- Prefer shorter / more contiguous file matches.
      -- fzf-native already penalises skipped chars (the "webflow." gap), but only
      -- weakly. We wrap the file sorter so that, among similarly-scored matches,
      -- the shorter path floats to the top: searching `TeamRecognition.tsx` puts
      -- the exact file above `TeamRecognition.webflow.tsx`, while typing `.web`
      -- shrinks that gap and lets the webflow file rise. Raise LENGTH_WEIGHT to
      -- make length matter more, lower it to lean back on pure fzf relevance.
      local ok_fzf, make_fzf = pcall(function() return require('telescope').extensions.fzf.native_fzf_sorter end)
      if ok_fzf and make_fzf then
        local LENGTH_WEIGHT = 0.0001
        require('telescope.config').values.file_sorter = function(opts)
          -- Telescope passes the picker's opts (no case_mode/fuzzy); merge fzf's defaults in.
          local sorter = make_fzf(vim.tbl_extend('keep', opts or {}, { case_mode = 'smart_case', fuzzy = true }))
          local inner = sorter.scoring_function
          sorter.scoring_function = function(self, prompt, line, entry)
            local score = inner(self, prompt, line, entry)
            if score < 0 then return score end -- -1 means "no match", leave it filtered out
            return score + #line * LENGTH_WEIGHT
          end
          return sorter
        end
      end

      local builtin = require 'telescope.builtin'

      -- Search keymaps (all prefixed with <leader>s for [S]earch)
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })

      -- Search in current buffer
      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )

      -- Search in open files
      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      -- Search neovim config files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

      -- Project switcher: fuzzy find folders in your Code directory
      vim.keymap.set('n', '<leader>sp', function()
        builtin.find_files {
          cwd = '~/Code',
          find_command = { 'fd', '--type', 'd', '--max-depth', '3' },
          prompt_title = 'Switch Project',
          attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
              require('telescope.actions').close(prompt_bufnr)
              local project_path = vim.fn.expand('~/Code/' .. selection.value)
              vim.cmd('cd ' .. project_path)
              vim.cmd('Neotree dir=' .. project_path)
              builtin.find_files { cwd = project_path }
            end)
            return true
          end,
        }
      end, { desc = '[S]earch [P]roject' })
    end,
  },
}
