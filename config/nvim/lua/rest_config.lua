local rest = require("rest-nvim")

rest.setup {
    result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
        formatters = {
            json = "jq",
            html = function(body)
                return vim.fn.system({
                    "prettier",
                    "--parser=html",
                    "--print-width=120",
                }, body)
            end,
        },
    },
    jump_to_request = true,
    custom_dynamic_variables = {},
}

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "http",
    callback = function()
        vim.keymap.set("n", "<leader>rh", rest.run, {
            buffer = true,
            silent = true,
        })
    end,
})
