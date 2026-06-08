return {
  -- ========================================================================
  -- FILE EXPLORER: Neo-tree (sidebar file tree)
  -- ========================================================================
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      -- Notify LSP on rename/move/delete so TS imports get auto-updated.
      { 'antosha417/nvim-lsp-file-operations', config = true },
    },
    cmd = 'Neotree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'File [E]xplorer' },
      { '\\', '<cmd>Neotree toggle<CR>', desc = 'File Explorer' },
    },
    opts = {
      default_component_configs = {
        container = { enable_character_fade = false },
      },
      source_selector = { statusline = false },
      filesystem = {
        follow_current_file = { enabled = true }, -- Auto-reveal current file
        filtered_items = {
          visible = true, -- Show hidden files (dimmed)
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = { '.git', 'node_modules', '.DS_Store' },
        },
      },
      window = {
        width = 35,
        mappings = {
          ['<space>'] = 'none', -- Don't conflict with leader key
          ['l'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              if not node:is_expanded() then require('neo-tree.sources.filesystem').toggle_directory(state, node) end
            end
          end,
          ['h'] = 'close_node', -- Collapse folder / go to parent
          ['Y'] = function(state)
            local node = state.tree:get_node()
            local filename = node.name
            vim.fn.setreg('+', filename)
            vim.notify('Copied: ' .. filename)
          end,
          ['y'] = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local relative = vim.fn.fnamemodify(filepath, ':.')
            vim.fn.setreg('+', relative)
            vim.notify('Copied: ' .. relative)
          end,
        },
      },
    },
  },
}
