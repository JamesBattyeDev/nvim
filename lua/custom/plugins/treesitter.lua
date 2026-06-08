return {
  -- ========================================================================
  -- TREESITTER: Syntax highlighting + code understanding
  -- ========================================================================
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'css',
        'diff',
        'glsl',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'rust',
        'scss',
        'typescript',
        'tsx',
        'vim',
        'vimdoc',
        'yaml',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
