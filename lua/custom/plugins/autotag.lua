return {
  -- Auto close/rename HTML/JSX tags
  {
    'tronikelis/ts-autotag.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
}
