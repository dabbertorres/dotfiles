local kulala = require("kulala")
local util = require("my_util")

kulala.setup {
    default_view = "headers_body",
    vscode_rest_client_environmentvars = true,
}

vim.filetype.add {
    extension = {
        ["http"] = "http",
    },
}

util.make_augroup("http_files", true,
    function()
        return { "BufFilePre", "BufNewFile", "BufReadPost" }, {
            pattern = "*.http",
            callback = function(args)
                vim.api.nvim_buf_set_keymap(args.buf, "n", "<CR>", kulala.run, {
                    noremap = true,
                    silent = true,
                    desc = "Execute the request",
                })
            end,
        }
    end
)
