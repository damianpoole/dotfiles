return {
  "elanmed/fzf-lua-frecency.nvim",
  dependencies = { "ibhagwan/fzf-lua" },
  opts = {
    all_files = true, -- Allow frecency to track all files
    -- debug = true, -- Uncomment to see debug messages when files are tracked
    fzf_opts = {
      ["--no-sort"] = false,
    },
  },
  config = function(_, opts)
    opts = opts or {}
    require("fzf-lua-frecency").setup(opts)

    local helpers = require("fzf-lua-frecency.helpers")
    local algo = require("fzf-lua-frecency.algo")

    local db_dir = helpers.default(opts.db_dir, helpers.default_opts.db_dir)
    local debug = helpers.default(opts.debug, helpers.default_opts.debug)
    local stat_file = helpers.default(opts.stat_file, helpers.default_opts.stat_file)

    local augroup = vim.api.nvim_create_augroup("FzfLuaFrecency", { clear = true })
    local timer_id
    local pending_buf
    local uv = vim.uv or vim.loop
    local min_interval_ms = 5000

    vim.api.nvim_create_autocmd("BufEnter", {
      group = augroup,
      callback = function(ev)
        if timer_id then
          vim.fn.timer_stop(timer_id)
          timer_id = nil
          pending_buf = nil
        end

        if vim.bo[ev.buf].buftype ~= "" then
          return
        end

        local win = vim.fn.bufwinid(ev.buf)
        if win == -1 then
          return
        end

        local win_config = vim.api.nvim_win_get_config(win)
        if win_config.relative ~= "" then
          return
        end

        local name = vim.api.nvim_buf_get_name(ev.buf)
        if name == "" then
          return
        end

        local now = uv and uv.now and uv.now() or nil
        local last_bump = vim.b[ev.buf]._fzf_lua_frecency_last_bump or 0
        if now and last_bump > 0 and (now - last_bump) < min_interval_ms then
          return
        end

        pending_buf = ev.buf
        timer_id = vim.fn.timer_start(1000, function()
          if not vim.api.nvim_buf_is_valid(pending_buf) then
            return
          end
          algo.update_file_score(vim.fs.normalize(name), {
            update_type = "increase",
            db_dir = db_dir,
            debug = debug,
            stat_file = stat_file,
          })
          timer_id = nil

          if uv and uv.now then
            vim.b[pending_buf]._fzf_lua_frecency_last_bump = uv.now()
          else
            vim.b[pending_buf]._fzf_lua_frecency_last_bump = os.time() * 1000
          end
          pending_buf = nil
        end)
      end,
    })
  end,
  -- Keymap is defined in lua/config/keymaps.lua to override LazyVim's default
}
