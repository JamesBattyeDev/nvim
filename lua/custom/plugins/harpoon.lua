return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    local function telescope_harpoon()
      local list = harpoon:list()
      local pickers = require 'telescope.pickers'
      local finders = require 'telescope.finders'
      local conf = require('telescope.config').values
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local entries = {}
      for i, item in ipairs(list.items) do
        table.insert(entries, { idx = i, value = item.value, display = i .. '. ' .. item.value })
      end

      pickers
        .new({}, {
          prompt_title = 'Harpoon',
          finder = finders.new_table {
            results = entries,
            entry_maker = function(e)
              return { value = e, display = e.display, ordinal = e.value }
            end,
          },
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local sel = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if sel then list:select(sel.value.idx) end
            end)
            map({ 'i', 'n' }, '<C-x>', function()
              local sel = action_state.get_selected_entry()
              if sel then
                list:remove_at(sel.value.idx)
                actions.close(prompt_bufnr)
                telescope_harpoon()
              end
            end)
            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = '[H]arpoon menu' })
    vim.keymap.set('n', '<leader>H', function() harpoon:list():add() end, { desc = '[H]arpoon add file' })
    vim.keymap.set('n', '<leader>sh', telescope_harpoon, { desc = '[S]earch [H]arpoon' })

    local slots = { a = 1, s = 2, d = 3, f = 4, g = 5 }
    for key, idx in pairs(slots) do
      vim.keymap.set('n', '<leader>j' .. key, function() harpoon:list():select(idx) end, { desc = '[J]ump harpoon ' .. idx })
    end
  end,
}
