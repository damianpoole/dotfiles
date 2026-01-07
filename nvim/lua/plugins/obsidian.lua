return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "ibhagwan/fzf-lua", -- Ensure fzf-lua is a dependency
  },
  keys = {
    -- Use fzf-lua to search files in the vault
    -- Search Files: Uses fd to respect .gitignore and excludes the .obsidian folder explicitly
    {
      "<leader>op",
      function()
        require("fzf-lua").files({
          cwd = "~/vaults/second-brain",
          -- fd_opts is the standard way to pass flags to the fd command
          fd_opts = "--type f --exclude .obsidian --exclude .git --exclude .gitignore --strip-cwd-prefix",
        })
      end,
      desc = "Search Notes (respecting gitignore)",
    },

    -- Live Grep: Searches inside the content of your notes
    {
      "<leader>og",
      function()
        require("fzf-lua").live_grep({
          cwd = "~/vaults/second-brain",
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096",
        })
      end,
      desc = "Grep Notes",
    },
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Create New Note" },
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Daily Note" },
    {
      "<leader>oN",
      function()
        local title = vim.fn.input("Enter Name (Clean): ")
        if title ~= "" then
          -- Sanitize filename
          local fname = title:gsub(" ", "-"):lower()
          fname = fname:match("%.md$") and fname or fname .. ".md"

          -- FORCE path to Vault (Update this path!)
          local vault = vim.fn.expand("~/vaults/second-brain/")

          -- Open file at absolute path
          vim.cmd("edit " .. vault .. "/" .. fname)
        end
      end,
      desc = "New Named Note (Clean)",
    },
    {
      "<leader>ow",
      function()
        -- 1. CONFIGURATION
        -- We use your specific vault path
        local vault_path = vim.fn.expand("~/vaults/second-brain")
        local template_path = vault_path .. "/Templates/Weekly.md"
        local weekly_folder = "Weekly"

        -- 2. HELPER: Calculate ISO Week and "Previous Week" correctly
        local function get_week_info()
          local current_time = os.time()
          local date_table = os.date("*t", current_time)
          -- Logic to force Monday as start of week for ISO calculation
          local wday = date_table.wday == 1 and 7 or date_table.wday - 1
          local nearest_thursday = current_time - (wday - 4) * 24 * 3600

          local year = os.date("%Y", nearest_thursday)
          local week = os.date("%V", nearest_thursday)

          -- Calculate Previous Week by subtracting 7 days
          -- This handles year rollovers (e.g. 2026-W01 -> 2025-W52) automatically
          local prev_thursday = nearest_thursday - (7 * 24 * 3600)
          local prev_year = os.date("%Y", prev_thursday)
          local prev_week = os.date("%V", prev_thursday)

          return year, week, prev_year .. "-W" .. prev_week
        end

        -- 3. HELPER: Read the template file
        local function read_file(path)
          local file = io.open(path, "r")
          if not file then
            return nil
          end
          local content = file:read("*a")
          file:close()
          return content
        end

        -- 4. MAIN LOGIC
        local year, week, prev_week_str = get_week_info()
        local filename = string.format("%s-W%s.md", year, week)
        local filepath = vault_path .. "/" .. weekly_folder .. "/" .. filename

        -- Ensure directory exists
        vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")

        -- Check if file exists
        local f = io.open(filepath, "r")
        if f ~= nil then
          io.close(f)
          vim.cmd("edit " .. filepath)
          print("Opened existing: " .. filename)
        else
          -- Create new from template
          local content = read_file(template_path)
          if content then
            -- Replace variables
            content = content:gsub("{{year}}", year)
            content = content:gsub("{{week}}", week)
            content = content:gsub("{{prev_week}}", prev_week_str)

            local new_file = io.open(filepath, "w")
            if new_file then
              new_file:write(content)
              new_file:close()

              vim.cmd("edit " .. filepath)
              print("Created new: " .. filename)

              -- Jump to first checkbox
              if vim.fn.search("- \\[ \\]", "w") > 0 then
                vim.cmd("norm! A") -- Move to end of line
                vim.cmd("startinsert") -- Start typing
              end
            else
              print("Error: Could not write file at " .. filepath)
            end
          else
            print("Error: Template not found at " .. template_path)
          end
        end
      end,
      desc = "Obsidian Weekly Note",
    },
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/second-brain",
      },
    },
    -- FORCE new notes to go to the root (or specific 'notes_subdir' if configured)
    -- This stops them from being created in the 'Weekly' folder when you are inside a weekly note.
    new_notes_location = "notes_subdir",

    -- Setting picker to nil or a custom function
    picker = {
      name = "fzf-lua",
    },
    daily_notes = {
      folder = "dailies",
      date_format = "%Y-%m-%d",
    },
    completion = {
      nvim_cmp = false,
      min_chars = 2,
    },
    ui = {
      enable = false,
    },
    note_id_func = function(title)
      local prefix = os.date("%Y-%m-%d-%H%M")
      if title ~= nil and title ~= "" then
        -- If title is passed, appending it ensures unique ID + context
        return prefix .. "-" .. title:gsub(" ", "-"):lower()
      end
      return prefix
    end,
  },
}
