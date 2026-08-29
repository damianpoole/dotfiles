return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      opts = opts or {}
      opts.winopts = opts.winopts or {}
      opts.defaults = opts.defaults or {}
      opts.defaults.keymap = opts.defaults.keymap or {}

      opts.defaults.keymap.builtin = vim.tbl_deep_extend("force", opts.defaults.keymap.builtin or {}, {
        ["?"] = "toggle-help",
        ["<F1>"] = false,
      })

      if opts.help_open_win == nil then
        opts.help_open_win = function(buf, enter, winopts)
          winopts = winopts or {}
          local help_height = math.min(
            math.max(10, math.floor(vim.o.lines * 0.3)),
            vim.api.nvim_buf_line_count(buf)
          )
          local help_width = math.min(vim.o.columns, winopts.width or vim.o.columns)

          local help_opts = vim.tbl_deep_extend("force", winopts, {
            relative = "editor",
            style = "minimal",
            row = 0,
            col = math.max(0, math.floor((vim.o.columns - help_width) / 2)),
            height = help_height,
            width = help_width,
            border = "single",
            zindex = 999,
          })

          return vim.api.nvim_open_win(buf, enter, help_opts)
        end
      end

      return opts
    end,
    keys = {
      {
        "<leader>fh",
        function()
          local config = require("fzf-lua.config")
          local defaults = config.defaults

          local function normalize_action(action)
            if type(action) == "table" then
              return action.desc or action[1] or action.fn or vim.inspect(action)
            end
            return tostring(action)
          end

          local function collect(section, tbl)
            local list = {}
            for lhs, rhs in pairs(tbl or {}) do
              if rhs and rhs ~= false then
                table.insert(list, { lhs = lhs, rhs = normalize_action(rhs) })
              end
            end
            table.sort(list, function(a, b)
              return a.lhs < b.lhs
            end)
            local lines = { section }
            for _, item in ipairs(list) do
              table.insert(lines, string.format("  %-12s %s", item.lhs, item.rhs))
            end
            return lines
          end

          local lines = {}
          vim.list_extend(lines, collect("Builtin window:", defaults.keymap.builtin))
          table.insert(lines, "")
          vim.list_extend(lines, collect("FZF view:", defaults.keymap.fzf))

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].bufhidden = "wipe"
          vim.bo[buf].filetype = "help"

          local width = math.floor(math.min(vim.o.columns * 0.7, 100))
          local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.6))

          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            style = "minimal",
            border = "rounded",
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            width = width,
            height = height,
            zindex = 1000,
          })

          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
          vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })

          return win
        end,
        desc = "Show FzfLua default keymaps",
      },
    },
  },
}
-- return {
--   {
--     "ibhagwan/fzf-lua",
--     opts = function(_, opts)
--       opts = opts or {}
--       opts.winopts = opts.winopts or {}
--       opts.defaults = opts.defaults or {}
--       opts.defaults.keymap = opts.defaults.keymap or {}
--
--       opts.defaults.keymap.builtin = vim.tbl_deep_extend("force", opts.defaults.keymap.builtin or {}, {
--         ["?"] = "toggle-help",
--       })
--
--       if opts.help_open_win == nil then
--         opts.help_open_win = function(buf, enter, winopts)
--           winopts = winopts or {}
--           winopts.row = 0
--           winopts.col = winopts.col or 0
--           winopts.border = winopts.border or "single"
--           local base = winopts.zindex or opts.winopts.zindex or 50
--           winopts.zindex = base + 10
--           winopts.height = math.min(winopts.height or math.floor(vim.o.lines * 0.3), math.floor(vim.o.lines * 0.5))
--           return vim.api.nvim_open_win(buf, enter, winopts)
--         end
--       end
--
--       return opts
--     end,
--   },
-- }
--
