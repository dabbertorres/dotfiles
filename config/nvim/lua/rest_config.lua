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
    env_file = ".env",
    custom_dynamic_variables = {
        ["$gcloud_auth"] = function()
            local token = vim.fn.system { "gcloud", "auth", "print-access-token", "--quiet" }
            return string.gsub(token, "%s+", "")
        end,
        ["$gcloud_id_token"] = function()
            local token = vim.fn.system { "gcloud", "auth", "print-identity-token", "--quiet" }
            return string.gsub(token, "%s+", "")
        end,
    },
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
