--local profile_start_time = vim.loop.hrtime()

local actions = require("telescope.actions")
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup {
    defaults = {
        layout_config = {
            preview_height = 50,
        },
        layout_strategy = "vertical",
        mappings = {
            i = {
                ["<C-n>"] = false,
                ["<C-p>"] = false,
                ["<C-j>"] = actions.move_selection_better,
                ["<C-k>"] = actions.move_selection_worse,
            },
            n = {
                ["<C-[>"] = actions.close,
            },
        },
        -- path_display = "smart",
        selection_strategy = "follow",
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--glob", "!vcpkg/**",
        },
    },
    extensions = {
        file_browser = {
        },
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {
        },
    },
}

telescope.load_extension("file_browser")
telescope.load_extension("fzf")
telescope.load_extension("notify")
telescope.load_extension("ui-select")
-- telescope.load_extension("dap")

local mappings_opts = {
    noremap = true,
    silent = true,
}

local file_browser_opts = {
    grouped = false,
    depth = 1,
    hidden = false,
}

vim.keymap.set("n", "<leader>fe", function()
    telescope.extensions.file_browser.file_browser(file_browser_opts)
end, mappings_opts)
vim.keymap.set("n", "<leader>ff", builtin.find_files, mappings_opts)
vim.keymap.set("n", "<leader>ss", builtin.live_grep, mappings_opts)
vim.keymap.set("n", "<leader>b", builtin.buffers, mappings_opts)
vim.keymap.set("n", "<leader>h", builtin.help_tags, mappings_opts)
vim.keymap.set("n", "<leader>C", builtin.builtin, mappings_opts)
vim.keymap.set("n", "<leader>sc", builtin.spell_suggest, mappings_opts)

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
