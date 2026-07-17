return {
  -- ========================================================================
  -- ORG MODE: personal task / project / time management in plain text
  -- Data lives in ~/org/ (NOT in this config repo). The agenda scans that
  -- glob with an absolute path, so every nvim instance — from any cwd —
  -- shares the same task list. Save a file to have other instances see it.
  -- ========================================================================
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
      require('orgmode').setup {
        org_agenda_files = '~/org/**/*',
        org_default_notes_file = '~/org/inbox.org',
        -- Open files fully expanded — headings AND their bodies (checkbox lists,
        -- notes). 'content' folds bodies (hides checkboxes); 'overview' (default)
        -- collapses to top level. 'showeverything' = nothing folded.
        org_startup_folded = 'showeverything',
        -- Pressing <CR> (Enter) at the end of a list/checkbox item creates the
        -- next item automatically — so typing a checkbox then Enter gives a new one.
        mappings = {
          org_return_uses_meta_return = true,
        },
        -- Extra TODO states: NEXT = next actionable, WAITING = blocked on someone.
        -- The '|' separates active (left) from done (right) states.
        org_todo_keywords = { 'TODO', 'NEXT', 'WAITING', '|', 'DONE', 'CANCELLED' },
        -- <leader>oc capture menu: press the key, pick a template, jot, save.
        org_capture_templates = {
          t = {
            description = 'Todo (inbox)',
            template = '* TODO %?\n  %u',
            target = '~/org/inbox.org',
          },
          a = {
            description = 'Admin task',
            template = '* TODO %? :admin:',
            target = '~/org/admin.org',
          },
          p = {
            description = 'Personal task',
            template = '* TODO %? :personal:',
            target = '~/org/personal.org',
          },
          d = {
            description = 'Side project task',
            template = '* TODO %? :side_projects:',
            target = '~/org/side-projects.org',
          },
          -- Client tasks
          s = {
            description = 'Superfiliate task',
            template = '* TODO %? :superfiliate:',
            target = '~/org/superfiliate.org',
          },
          m = {
            description = 'Makebuild task',
            template = '* TODO %? :makebuild:',
            target = '~/org/makebuild.org',
          },
          y = {
            description = 'YesChef task',
            template = '* TODO %? :yeschef:',
            target = '~/org/yeschef.org',
          },
          o = {
            description = 'Offbrand task',
            template = '* TODO %? :offbrand:',
            target = '~/org/offbrand.org',
          },
        },
      }

      -- ====================================================================
      -- DAY PLANNER (<leader>od  or  :OrgDayPlan)
      -- orgmode's agenda can't render the :Effort: property inline, so this
      -- builds our own view: every scheduled, not-yet-DONE task grouped by
      -- day, showing its effort estimate and a per-day total. Opens in its
      -- own full-screen tab as plain text — easy to eyeball and copy the
      -- estimates straight into a Notion calendar. Press q to close.
      -- ====================================================================
      local function effort_to_min(s)
        if not s then return nil end
        local h, m = s:match '^(%d+):(%d+)$' -- "1:30"
        if h then return tonumber(h) * 60 + tonumber(m) end
        local mins = s:match '^(%d+)$' -- bare minutes, e.g. "45"
        return mins and tonumber(mins) or nil
      end

      local function min_to_effort(mins)
        return string.format('%d:%02d', math.floor(mins / 60), mins % 60)
      end

      local function build_day_plan()
        local api = require 'orgmode.api'
        local by_day = {}
        for _, file in ipairs(api.load()) do
          for _, hl in ipairs(file.headlines) do
            -- keyworded task, has a SCHEDULED date, not DONE/CANCELLED
            if hl.scheduled and hl.todo_value and hl.todo_type ~= 'DONE' then
              local key = hl.scheduled:format '%Y-%m-%d'
              by_day[key] = by_day[key] or { header = hl.scheduled:format '%A  %Y-%m-%d', items = {} }
              table.insert(by_day[key].items, {
                effort = hl.properties and hl.properties.effort or nil,
                file = vim.fn.fnamemodify(file.filename, ':t:r'),
                title = hl.title,
              })
            end
          end
        end

        local days = vim.tbl_keys(by_day)
        table.sort(days) -- 'YYYY-MM-DD' strings sort chronologically

        local lines = { 'Day Plan — scheduled tasks + effort estimates', '' }
        for _, key in ipairs(days) do
          local day = by_day[key]
          -- biggest estimates first (untimed tasks sink to the bottom)
          table.sort(day.items, function(a, b)
            local am, bm = effort_to_min(a.effort) or -1, effort_to_min(b.effort) or -1
            if am ~= bm then return am > bm end
            return a.title < b.title
          end)
          local total = 0
          for _, it in ipairs(day.items) do
            total = total + (effort_to_min(it.effort) or 0)
          end
          table.insert(lines, ('─'):rep(64))
          table.insert(lines, string.format('%-44s  total %s', day.header, min_to_effort(total)))
          table.insert(lines, ('─'):rep(64))
          for _, it in ipairs(day.items) do
            local m = effort_to_min(it.effort)
            table.insert(lines, string.format('  %5s  [%s]  %s', m and min_to_effort(m) or '--', it.file, it.title))
          end
          table.insert(lines, '')
        end
        if #days == 0 then
          table.insert(lines, '(no scheduled TODOs found)')
        end
        return lines
      end

      local function open_day_plan()
        local lines = build_day_plan()
        vim.cmd 'tabnew'
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].buftype = 'nofile'
        vim.bo[buf].bufhidden = 'wipe'
        vim.bo[buf].swapfile = false
        vim.bo[buf].modifiable = false
        vim.api.nvim_buf_set_name(buf, 'OrgDayPlan')
        vim.keymap.set('n', 'q', '<cmd>tabclose<CR>', { buffer = buf, nowait = true, silent = true })
      end

      vim.api.nvim_create_user_command('OrgDayPlan', open_day_plan, { desc = 'Scheduled tasks with effort, grouped by day' })
      vim.keymap.set('n', '<leader>od', open_day_plan, { desc = '[O]rg [d]ay plan (effort by day)' })
    end,
  },
}
