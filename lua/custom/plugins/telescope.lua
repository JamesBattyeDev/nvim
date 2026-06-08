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
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git/', 'dist/', '.next/' },
          layout_config = {
            horizontal = { preview_width = 0.55 },
          },
          mappings = {
            i = {
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<C-,>'] = actions.move_selection_previous,
              ['<C-.>'] = actions.move_selection_next,
            },
            n = {
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
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
