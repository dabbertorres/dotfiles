local lsp = require"lspconfig"

lsp.bashls.setup{}

lsp.clangd.setup{}

lsp.cmake.setup{}

lsp.dockerls.setup{}

lsp.efm.setup{}

lsp.gopls.setup{
    flags = {
        debounce_text_changes = 500,
    }
}

lsp.java_language_server.setup{
    cmd = {"/Users/aleciverson/Code/lsps/java-language-server/dist/lang_server_mac.sh"}
}

lsp.jsonls.setup{
    commands = {
        Format = {
            function()
                lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
            end
        }
    }
}

lsp.kotlin_language_server.setup{
    cmd = { "/Users/aleciverson/Code/lsps/kotlin-language-server/server/build/install/server/bin/kotlin-language-server" },
    root_dir = lsp.util.root_pattern("settings.gradle.kts"),
    settings = {
        kotlin = {
            compiler = {
                jvm = {
                    target = "1.8",
                },
            },
        },
    },
}

lsp.pyright.setup{}

lsp.sqls.setup{}

lsp.sumneko_lua.setup{
    cmd = {
        "/Users/aleciverson/Code/lsps/lua-language-server/bin/macOS/lua-language-server",
        "-E",
        "/Users/aleciverson/Code/lsps/lua-language-server/main.lua"
    },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            runtime = {
                version = "Lua 5.4",
                path = {
                    "?.lua",
                    "?/init.lua",
                }
            }
        }
    }
}

lsp.terraformls.setup{}

lsp.vimls.setup{}

lsp.vuels.setup{}

lsp.yamlls.setup{
    settings = {
        redhat = {
            telemetry = {
                enabled = false
            }
        },
        yaml = {
            format = {
                printWidth = 120
            }
        }
    }
}

vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"

local function preview_location_callback(_, _, result)
    if result == nil or vim.tbl_isempty(result) then
        return nil
    end
    vim.lsp.util.preview_location(result[1])
end

_G.peek_definition = function()
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
end

local diagnostic_cache = {}

local orig_set_signs = vim.lsp.diagnostic.set_signs
local set_signs_limited = function(diagnostics, bufnr, client_id, sign_ns, opts)
    if not diagnostics then
        diagnostics = diagnostic_cache[bufnr][client_id]
    end

    if not diagnostics then
        return
    end

    if diagnostic_cache[bufnr] == nil then
        diagnostic_cache[bufnr] = {}
    end

    diagnostic_cache[bufnr][client_id] = diagnostics

    local max_severity_per_line = {}
    for _, d in pairs(diagnostics) do
        if max_severity_per_line[d.range.start.line] then
            local current_d = max_severity_per_line[d.range.start.line]
            if d.severity < current_d.severity then
                max_severity_per_line[d.range.start.line] = d
            end
        else
            max_severity_per_line[d.range.start.line] = d
        end
    end

    local filtered_diagnostics = {}
    for _, v in pairs(max_severity_per_line) do
        table.insert(filtered_diagnostics, v)
    end

    orig_set_signs(filtered_diagnostics, bufnr, client_id, sign_ns, opts)
end

vim.lsp.diagnostic.set_signs = set_signs_limited

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = {
            spacing = 4,
            prefix = "> ",
        },
    }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "single"
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = "single"
    }
)

local virtual_text_signs = {
    Error = "E ",
    Warning = "W ",
    Hint = "H ",
    Information = "I ",
}

for type, icon in pairs(virtual_text_signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local mappings_opts = {
    noremap = true,
    silent = true,
}

vim.api.nvim_set_keymap("n", "gp", "v:lua.peek_definition()", mappings_opts)
vim.api.nvim_set_keymap("n", "mca", "<cmd>Telescope lsp_code_actions<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", mappings_opts)
vim.api.nvim_set_keymap("i", "mk", "<cmd>lua vim.lsp.buf.signature_help()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gu", "<cmd>Telescope lsp_references<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "mrn", "<cmd>lua vim.lsp.buf.rename()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "mff", "<cmd>lua vim.lsp.buf.formatting()<CR>", mappings_opts)

vim.api.nvim_set_keymap("n", "<c-j>", "<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = \"single\"}})<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "<c-k>", "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = \"single\"}})<CR>", mappings_opts)
