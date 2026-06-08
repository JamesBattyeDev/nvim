return {
  -- ========================================================================
  -- UI: Clean aesthetic extras
  -- ========================================================================

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = { char = '│' },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },
}
