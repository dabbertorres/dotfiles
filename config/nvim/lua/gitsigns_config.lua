local gitsigns = require("gitsigns")

local function next_hunk(gs)
    return function()
        if vim.wo.diff then return "]c" end

        vim.schedule(function()
            gs.next_hunk{ wrap = true, foldopen = true, preview = true }
        end)
        return "<Ignore>"
    end
end

local function prev_hunk(gs)
    return function()
        if vim.wo.diff then return "]c" end

        vim.schedule(function()
            gs.prev_hunk{ wrap = true, foldopen = true, preview = true }
        end)
        return "<Ignore>"
    end
end

local function stage_hunk(gs)
    return function()
        local range = nil

        local start_line, _ = vim.api.nvim_buf_get_mark(0, "<")
        if start_line ~= 0 then
            local end_line, _ = vim.api.nvim_buf_get_mark(0, ">")
            range = { start_line, end_line }
        end

        gs.stage_hunk(range)
    end
end

local function reset_hunk(gs)
    return function()
        local range = nil

        local start_line, _ = vim.api.nvim_buf_get_mark(0, "<")
        if start_line ~= 0 then
            local end_line, _ = vim.api.nvim_buf_get_mark(0, ">")
            range = { start_line, end_line }
        end

        gs.reset_hunk(range)
    end
end

gitsigns.setup{
    signcolumn = false,
    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 500,
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        vim.keymap.set("n", "mgj", next_hunk(gs), { buffer = bufnr, expr = true })
        vim.keymap.set("n", "mgk", prev_hunk(gs), { buffer = bufnr, expr = true })

        vim.keymap.set({"n", "v"}, "<leader>gs", stage_hunk(gs), { buffer = bufnr })
        vim.keymap.set({"n", "v"}, "<leader>gr", reset_hunk(gs), { buffer = bufnr })

        vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gd", gs.diffthis, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gD", function() gs.diffthis("~") end, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gb", function() gs.blame_line{ full = true } end, { buffer = bufnr })

        vim.keymap.set("n", "<leader>gc", gs.toggle_deleted, { buffer = bufnr })
    end,
}
