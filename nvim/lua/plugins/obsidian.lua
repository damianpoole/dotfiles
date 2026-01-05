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
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/second-brain",
      },
    },
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
