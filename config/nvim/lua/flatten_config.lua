local flatten = require("flatten")

local saved_terminal = nil

flatten.setup {
    block_for = {
        gitcommit = true,
        gitrebase = true,
    },
    allow_cmd_passthrough = true,
    nest_if_no_args = false,
    window = {
        open = "alternate",
    },
    callbacks = {
        pre_open = function()
            -- if we have a terminal open, save it so we can close it
            -- when opening a file

            local term = require("toggleterm.terminal")
            local termid = term.get_focused_id()
            saved_terminal = term.get(termid)
        end,
        post_open = function(bufnr, winnr, ft, is_blocking)
            if is_blocking and saved_terminal then
                -- hide terminal while blocking
                saved_terminal:close()
            else
                -- norma file? switch to the window
                vim.api.nvim_set_current_win(winnr)
            end

            -- automatically delete a git buffer after writing
            if ft == "gitcommit" or ft == "gitrebase" then
                vim.api.nvim_create_autocmd("BufWritePost", {
                    buffer = bufnr,
                    once = true,
                    callback = vim.schedule_wrap(function()
                        vim.api.nvim_buf_delete(bufnr, {})
                    end),
                })
            end
        end,
        block_end = function()
            -- reopen the terminal (if one was open)
            if saved_terminal then
                vim.schedule(function()
                    saved_terminal:open()
                    saved_terminal = nil
                end)
            end
        end,
    },
}
