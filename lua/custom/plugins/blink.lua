return {
  -- ========================================================================
  -- AUTOCOMPLETION: blink.cmp
  -- ========================================================================
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- Premade snippets for many languages (JS, TS, HTML, CSS, etc.)
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-e>'] = { 'select_prev', 'fallback' },
        ['<C-r>'] = { 'select_next', 'fallback' },
        ['<C-,>'] = { 'select_prev', 'fallback' },
        ['<C-.>'] = { 'select_next', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        -- Auto-highlight the first item so <CR> accepts it without navigating.
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        -- 'snippets' removed — friendly-snippets noise was polluting property-access completions.
        -- Re-add 'snippets' to restore LuaSnip + friendly-snippets autocompletion.
        default = { 'lsp', 'path', 'lazydev' },
        -- Org completion (headings, tags, TODO keywords) only in .org buffers.
        per_filetype = { org = { 'orgmode', 'path', 'buffer' } },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
          webflow = { name = 'Webflow', module = 'webflow-syncer.blink' },
          orgmode = { name = 'Orgmode', module = 'orgmode.org.autocompletion.blink', fallbacks = { 'buffer' } },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
}
