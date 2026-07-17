return {
  -- ========================================================================
  -- OBSIDIAN: edit an Obsidian vault (wikilinks, backlinks, daily notes,
  -- tags, templates) from inside nvim. Vault lives at ~/Documents/Notes.
  --
  -- NOTE: this is the community-maintained fork (obsidian-nvim/obsidian.nvim).
  -- The original epwalsh/obsidian.nvim was ARCHIVED by its author in late
  -- 2024; the fork is a drop-in replacement that keeps up with nvim 0.11/0.12.
  -- ========================================================================
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*', -- pin to tagged releases rather than bleeding-edge main
    -- Load when a markdown buffer opens or when :Obsidian is invoked. The
    -- plugin only activates vault features inside a configured workspace
    -- path, so loading on all markdown is harmless outside ~/Documents/Notes.
    ft = 'markdown',
    cmd = 'Obsidian',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      -- telescope + blink are already in this config; used below for the
      -- picker and for wikilink/tag completion respectively.
    },
    keys = {
      { '<leader>nn', '<cmd>Obsidian new<cr>', desc = '[N]ote [N]ew' },
      { '<leader>nt', '<cmd>Obsidian today<cr>', desc = '[N]ote [T]oday (daily)' },
      { '<leader>ns', '<cmd>Obsidian search<cr>', desc = '[N]ote [S]earch (grep)' },
      { '<leader>nq', '<cmd>Obsidian quick_switch<cr>', desc = '[N]ote [Q]uick switch' },
      { '<leader>nb', '<cmd>Obsidian backlinks<cr>', desc = '[N]ote [B]acklinks' },
      { '<leader>ng', '<cmd>Obsidian tags<cr>', desc = '[N]ote ta[G]s' },
      { '<leader>no', '<cmd>Obsidian open<cr>', desc = '[N]ote [O]pen in Obsidian app' },
      { '<leader>nl', '<cmd>Obsidian link<cr>', mode = 'v', desc = '[N]ote [L]ink selection' },
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      workspaces = {
        { name = 'notes', path = '~/Documents/Notes' },
      },
      legacy_commands = false,
      -- Completion is now provided via the built-in obsidian-ls LSP server.
      -- Use telescope (already installed) for :Obsidian search / quick_switch etc.
      picker = { name = 'telescope.nvim' },
      -- Daily notes land in a dated subfolder; tweak to taste.
      daily_notes = {
        folder = 'daily',
        date_format = '%Y-%m-%d',
      },
    },
    config = function(_, opts)
      require('obsidian').setup(opts)
      -- obsidian.nvim's UI (concealed links, checkbox rendering) needs a
      -- non-zero conceallevel. This is global but only affects how markdown
      -- is displayed, which is exactly where you want it.
      vim.opt.conceallevel = 2
    end,
  },
}
