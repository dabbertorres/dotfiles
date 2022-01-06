--local profile_start_time = vim.loop.hrtime()

local actions = require("telescope.actions")
local telescope = require("telescope")

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
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
}

telescope.load_extension("fzf")
--telescope.load_extension("dap")


local mappings_opts = {
    noremap = true,
    silent = true,
}

vim.api.nvim_set_keymap("n", "msf", "<cmd>Telescope find_files<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "msl", "<cmd>Telescope live_grep<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "mss", "<cmd>Telescope grep_string<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "msb", "<cmd>Telescope buffers<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "msh", "<cmd>Telescope help_tags<CR>", mappings_opts)


--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
