local gitsigns = require("gitsigns")

local function next_hunk(gs)
    return function()
        if vim.wo.diff then return "]c" end

        vim.schedule(function()
            gs.next_hunk { wrap = true, foldopen = true, preview = true }
        end)
        return "<Ignore>"
    end
end

local function prev_hunk(gs)
    return function()
        if vim.wo.diff then return "]c" end

        vim.schedule(function()
            gs.prev_hunk { wrap = true, foldopen = true, preview = true }
        end)
        return "<Ignore>"
    end
end

gitsigns.setup {
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 250,
    },
    numhl = true,
    signcolumn = false,
    watch_gitdir = {
        interval = 1000,
        follow_files = true,
    },
    -- word_diff = true,
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        vim.keymap.set("n", "<leader>gj", next_hunk(gs), { buffer = bufnr, expr = true })
        vim.keymap.set("n", "<leader>gk", prev_hunk(gs), { buffer = bufnr, expr = true })

        vim.keymap.set({ "n", "v" }, "<leader>gs", gs.stage_hunk, { buffer = bufnr })
        vim.keymap.set({ "n", "v" }, "<leader>gr", gs.reset_hunk, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gd", gs.diffthis, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gD", function() gs.diffthis("~") end, { buffer = bufnr })

        vim.keymap.set("n", "<leader>bl", function() gs.blame_line { full = true } end, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gc", gs.toggle_deleted, { buffer = bufnr })
    end,
}
