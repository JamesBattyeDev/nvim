return {
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better text objects (va), ci', etc.)
      require('mini.ai').setup { n_lines = 500 }

      -- Surround operations (sa, sd, sr)
      require('mini.surround').setup()

      -- Comment toggle (gcc for line, gc in visual mode)
      require('mini.comment').setup {
        options = {
          custom_commentstring = function() return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring end,
        },
      }

      -- Statusline (minimal: mode + filename + git branch)
      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode { trunc_width = 9999 }
            local filename = statusline.section_filename { trunc_width = 9999 }
            local git = statusline.section_git { trunc_width = 9999 }
            local lines = '%L lines'
            return statusline.combine_groups {
              { hl = mode_hl, strings = { ' ' .. mode .. ' ' } },
              { hl = 'MiniStatuslineFilename', strings = { ' ' .. filename .. ' ' } },
              '%=',
              { hl = 'MiniStatuslineDevinfo', strings = { ' ' .. lines .. '  ' .. git .. ' ' } },
            }
          end,
          inactive = function()
            local filename = statusline.section_filename { trunc_width = 9999 }
            return statusline.combine_groups {
              { hl = 'MiniStatuslineInactive', strings = { ' ' .. filename .. ' ' } },
            }
          end,
        },
      }

      -- Stronger contrast: dim inactive, bold active filename
      vim.api.nvim_set_hl(0, 'MiniStatuslineInactive', { fg = '#45475a', bg = '#11111b' })
      vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', { fg = '#cdd6f4', bg = '#313244', bold = true })
    end,
  },
}
