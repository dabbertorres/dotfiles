--local profile_start_time = vim.loop.hrtime()

local function start(bufnr, parser)
    vim.treesitter.start(bufnr, parser)

    vim.wo.foldexpr = "v:lua.vim.treesitter.folxexpr()"
    vim.wo.foldmethod = "expr"

    -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

local installed_parsers = require("nvim-treesitter").get_installed()

vim.api.nvim_create_autocmd({ "Filetype" }, {
    pattern = "*",
    callback = function(event)
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })

        if filetype == "" then return end

        local parser_name = vim.treesitter.language.get_lang(filetype)
        if not parser_name then
            vim.notify("Could not identify parser for " .. filetype,
                vim.log.levels.WARN,
                { title = "treesitter" }
            )

            return
        end

        local parser_configs = require("nvim-treesitter.parsers")
        local parser_can_be_used = parser_configs[parser_name]
        if parser_can_be_used == nil then
            return
        end

        if vim.tbl_contains(installed_parsers, parser_name) then
            start(event.buf, parser_name)
            return
        end

        vim.schedule(function()
            require("nvim-treesitter").install({ parser_name }, { summary = true }):wait(30000)

            installed_parsers = require("nvim-treesitter").get_installed()

            start(event.buf, parser_name)
        end)
    end,
})

-- local configs = require("nvim-treesitter.configs")

---@diagnostic disable-next-line: missing-fields
-- configs.setup {
--     -- ensure_installed = "all",
--     sync_install = false,
--     auto_install = true,
--     ignore_install = {},
--     highlight = {
--         enable = true,
--         additional_vim_regex_highlighting = false,
--         use_languagetree = true,
--         ---@diagnostic disable-next-line: unused-local
--         disable = function(lang, bufnr)
--             return vim.fn.strlen(vim.fn.getbufoneline(bufnr, 1)) > 300
--                 or vim.fn.getfsize(vim.fn.expand("%")) > 1024 * 1024
--         end,
--     },
--     incremental_selection = {
--         enable = true,
--         keymaps = {
--             init_selection = "gnn",
--             node_incremental = "grn",
--             scope_incremental = "grc",
--             node_decremental = "grm",
--         },
--     },
--     indent = {
--         enable = true,
--         disable = {},
--     },
--     matchup = {
--         enable = true,
--         disable = {},
--     },
--     textobjects = {
--         -- lsp_interop = {
--         --     enable = true,
--         --     floating_preview_opts = {
--         --         border = 'none',
--         --     },
--         --     peek_definition_code = {
--         --         ["<leader>pd"] = {
--         --             query = {
--         --             "@class.outer",
--         --             "@function.outer",
--         --             "@assignment.outer",
--         --             "@attribute.outer",
--         --             "@parameter.outer",
--         --             },
--         --         },
--         --     },
--         -- },
--         select = {
--             enable = true,
--             lookahead = true,
--             keymaps = {
--                 ["af"] = "@function.outer",
--                 ["if"] = "@function.inner",
--                 ["ac"] = "@class.outer",
--                 ["ic"] = "@class.inner",
--             },
--             selection_modes = {
--                 ["@parameter.outer"] = "v",
--                 ["@function.outer"] = "V",
--                 ["@class.outer"] = "V",
--             },
--         },
--     },
--     playground = {
--         enable = true,
--         disable = {},
--         updatime = 25,
--         persist_queries = false,
--         keybindings = {
--             toggle_query_editor = 'o',
--             toggle_hl_groups = 'i',
--             toggle_injected_languages = 't',
--             toggle_anonymous_nodes = 'a',
--             toggle_language_display = 'I',
--             focus_language = 'f',
--             unfocus_language = 'F',
--             update = 'R',
--             goto_node = '<cr>',
--             show_help = '?',
--         },
--     },
--     query_linter = {
--         enable = true,
--         use_virtual_text = true,
--         lint_events = { "BufWrite", "CursorHold" },
--     },
-- }

-- treesitter.define_modules {
--     nginx = {
--         attach = function(bufnr, lang)
--
--         end,
--         detach = function(bufnr)
--
--         end,
--         is_supported = function(lang)
--
--         end,
--     },
-- }

-- vim.treesitter.language.register("bash", "zsh")

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
