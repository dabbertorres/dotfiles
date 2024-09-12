local rest = require("rest-nvim")

-- TODO: config for v3
-- vim.g.rest_nvim = {
--     custom_dynamic_variables = {
--         ["$gcloud_auth"] = function()
--             local token = vim.fn.system { "gcloud", "auth", "print-access-token", "--quiet" }
--             return string.gsub(token, "%s+", "")
--         end,
--         ["$gcloud_id_token"] = function()
--             local token = vim.fn.system { "gcloud", "auth", "print-identity-token", "--quiet" }
--             return string.gsub(token, "%s+", "")
--         end,
--     },
--     request = {
--         hooks = {
--             encode_url = true,
--             user_agent = "",
--             set_content_type = true,
--         },
--     },
--     response = {
--         hooks = {
--             decode_url = true,
--             format = true,
--         },
--     },
--     clients = {
--         curl = {
--             statistics = {
--                 time_total = { winbar = "take", title = "Time Taken" },
--                 size_download = { winbar = "size", title = "Download Size" },
--             },
--         },
--     },
--     cookies = {
--         enable = true,
--         path = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "rest-nvim.cookies"),
--     },
--     env = {
--         enable = true,
--         pattern = ".*%.env.*",
--     },
--     ui = {
--         winbar = true,
--         keybinds = {
--             prev = "H",
--             next = "L",
--         },
--     },
--     highlight = {
--         enable = true,
--         timeout = 500,
--     },
-- }
--
-- require("telescope").load_extension("rest")

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
