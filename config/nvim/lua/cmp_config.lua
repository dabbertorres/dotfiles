local cmp = require("cmp")
local luasnip = require("luasnip")
local util = require("my_util")

vim.opt.completeopt = { "menu", "menuone", "preview" }

vim.opt.spell = false
vim.opt.spelllang = { "en_us" }

cmp.setup {
    enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
            or require("cmp_dap").is_dap_buffer()
    end,
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs( -4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,
        ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable( -1) then
                luasnip.jump( -1)
            else
                fallback()
            end
        end,
    },
    sources = cmp.config.sources(
        {
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip" },
            { name = "nvim_lua" },
            {
                name = "path",
                option = {
                    trailing_slash = true,
                },
            },
            {
                name = "spell",
                option = {
                    keep_all_entries = false,
                    enable_in_context = function() return true end,
                },
            },
            { name = "calc" },
        },
        {
            {
                name = "buffer",
                option = {
                    get_bufnrs = function()
                        local bufs = vim.api.nvim_list_bufs()
                        -- exclude large buffers from indexing
                        return util.filter(bufs, function(bufnr)
                            local size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
                            return size < 1024 * 1024
                        end)
                    end,
                },
            },
        }
    ),
    view = {
        entries = {
            name = "custom",
            selection_order = "near_cursor",
        },
    },
}

cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
        {
            { name = "path" },
        },
        {
            { name = "cmdline" },
        }
    ),
})

cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
    sources = {
        { name = "dap" },
    },
})
