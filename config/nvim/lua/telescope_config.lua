--local profile_start_time = vim.loop.hrtime()

local actions = require("telescope.actions")
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup{
    defaults = {
        vimgrep_arguments = {
            "ag",
            "--nocolor",
            "--noheading",
            "--filename",
            "--numbers",
            "--column",
            "--smart-case",
        },
        mappings = {
            i = {
                ["<C-n>"] = false,
                ["<C-p>"] = false,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
            },
        },
    },
    extensions = {
        file_browser = {},
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {},
    },
}

telescope.load_extension("file_browser")
telescope.load_extension("fzf")
telescope.load_extension("ui-select")
--telescope.load_extension("dap")

local mappings_opts = {
    noremap = true,
    silent = true,
}

local file_browser_opts = {
    grouped = false,
    depth = 1,
    hidden = false,
}

vim.keymap.set("n", "mfb", function()
    telescope.extensions.file_browser.file_browser(file_browser_opts)
end, mappings_opts)
vim.keymap.set("n", "mff", builtin.find_files, mappings_opts)
vim.keymap.set("n", "msl", builtin.live_grep, mappings_opts)
vim.keymap.set("n", "mss", builtin.grep_string, mappings_opts)
vim.keymap.set("n", "msb", builtin.buffers, mappings_opts)
vim.keymap.set("n", "msh", builtin.help_tags, mappings_opts)

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
