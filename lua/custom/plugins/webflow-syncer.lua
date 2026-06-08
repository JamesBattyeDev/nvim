return {
  -- ========================================================================
  -- WEBFLOW: Project syncer (local dev plugin)
  -- ========================================================================
  {
    dir = '~/Code/personal/webflow-project-syncer',
    cmd = 'WebflowSync',
    ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'html', 'css', 'vue', 'svelte', 'astro' },
    opts = {
      cmp = false, -- using blink.cmp source instead (webflow-syncer.blink)
    },
  },
}
