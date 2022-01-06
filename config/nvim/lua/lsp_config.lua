--local profile_start_time = vim.loop.hrtime()

local lsp = require"lspconfig"
--local path = lsp.util.path
--local lightbulb = require("nvim-lightbulb")

local home = os.getenv("HOME")

lsp.bashls.setup{}

lsp.clangd.setup{}

lsp.cmake.setup{}

--lsp.csharp_ls.setup{}

lsp.dockerls.setup{}

lsp.efm.setup{
    init_options = {
        documentFormatting = true,
        hover = true,
        documentSymbol = true,
        codeAction = true,
        completion = true,
    },
    filetypes = {"markdown"},
    settings = {
        languages = {
            markdown = {
                {
                    lintCommand = "markdownlint -s",
                    lintStdin = true,
                    lintFormats = {
                        "%f:%l %m",
                        "%f:%l:%c %m",
                        "%f: %l: %m",
                    },
                },
                {
                    formatCommand = "pandoc -f markdown -t gfm -sp --tab-stop=2",
                },
            },
        },
    },
}

lsp.gopls.setup{
    cmd = {"gopls", "-remote=auto", "-logfile=auto", "-debug=:0", "-remote.debug=:0", "-remote.logfile=auto"},
    flags = {
        debounce_text_changes = 500,
    },
    settings = {
        gopls = {
            analyses = {
                asmdecl = true,
                assign = true,
                atomic = true,
                atomicalign = true,
                bools = true,
                buildtag = true,
                cgocall = true,
                composites = true,
                copylocks = true,
                deepequalerrors = true,
                errorsas = true,
                fieldalignment = false,
                fillreturns = true,
                httpresponse = true,
                ifaceassert = true,
                loopclosure = true,
                lostcancel = true,
                nilfunc = true,
                nilness = true,
                nonewvars = true,
                noresultvalues = true,
                printf = true,
                shadow = false,
                shift = true,
                simplifycompositelit = true,
                simplifyrange = true,
                simplifyslice = true,
                sortslice = true,
                stdmethods = true,
                stringintconv = true,
                structtag = true,
                testinggoroutine = true,
                tests = true,
                undeclaredname = true,
                unmarshal = true,
                unreachable = true,
                unsafeptr = true,
                unusedparams = true,
                unusedresult = true,
                unusedwrite = true,
            },
            buildFlags = {
                "-tags=wireinject"
            },
            codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = false,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = false,
            },
            directoryFilters = {
                "-node_modules",
            },
            diagnosticsDelay = "500ms",
            expandWorkspaceToModule = true,
            ["local"] = "bitbucket.org/myndshft/",
            gofumpt = true,
            hoverKind = "FullDocumentation",
            importShortcut = "Link",
            linksInHover = true,
            linkTarget = "pkg.go.dev",
            semanticTokens = true,
            symbolMatcher = "FastFuzzy",
            symbolStyle = "Dynamic",
            usePlaceholders = false,
        },
    },
}

lsp.jsonls.setup{
    commands = {
        Format = {
            function()
                lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
            end,
        }
    },
}

lsp.kotlin_language_server.setup{
    cmd = { home .. "/Code/lsps/kotlin-language-server/server/build/install/server/bin/kotlin-language-server" },
    filetypes = { "kotlin" },
    root_dir = lsp.util.root_pattern("build.gradle.kts"),
    settings = {
        kotlin = {
            compiler = {
                jvm = {
                    target = "1.8",
                },
            },
            debugAdapter = {
                enabled = false,
                path = "",
            },
            externalSources = {
                autoConvertToKotlin = false,
            },
            indexing = {
                enabled = true,
            },
            languageServer = {
                enabled = true,
                port = 0,
                transport = "tcp",
            },
        },
    },
}

local pid = vim.fn.getpid()
lsp.omnisharp.setup{
    cmd = { home .. "/Code/lsps/omnisharp/OmniSharp", "--languageserver", "--hostPID", tostring(pid) },
    root_dir = lsp.util.root_pattern("*.csproj"),
    flags = {
        debounce_text_changes = 150,
        allow_incremental_sync = true,
    },
    filetypes = { "cs", "vb" },
    init_options = {},
    on_init = function(client)
        if client.config.settings then
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
    end,
    on_new_config = function(new_config, new_root_dir)
        if new_root_dir then
            table.insert(new_config.cmd, "--source")
            table.insert(new_config.cmd, new_root_dir)
        end
    end,
}

lsp.pyright.setup{
    settings = {
        python = {
            disableLanguageServices = false,
            disableOrganizeImports = false,
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
            },
        },
    },
}

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

lsp.tsserver.setup{}

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
            completion = true,
            editor = {
                formatOnType = true,
            },
            format = {
                bracketSpacing = true,
                enable = true,
                printWidth = 120,
                proseWrap = "Always",
                singleQuote = false,
            },
            hover = true,
            schemaStore = {
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },
            validate = true,
            yamlVersion = "1.2",
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
local function set_signs_limited(diagnostics, bufnr, client_id, sign_ns, opts)
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

    if opts.priority == nil then
        opts.priority = 1000
    end

    orig_set_signs(filtered_diagnostics, bufnr, client_id, sign_ns, opts)
end

vim.lsp.diagnostic.set_signs = set_signs_limited

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        signs = true,
        virtual_text = false,
        --virtual_text = {
        --    spacing = 4,
        --    prefix = "> ",
        --},
        --update_in_insert = true,
        severity_sort = true,
    }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "single",
        focusable = true,
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = "single",
        focusable = false,
    }
)

vim.fn.sign_define("LspDiagnosticsSignError", { text = "E ", texthl = "GruvboxRed" })
vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "W ", texthl = "GruvboxYellow" })
vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "I ", texthl = "GruvboxBlue" })
vim.fn.sign_define("LspDiagnosticsSignHint", { text = "H ", texthl = "GruvboxAqua" })

local mappings_opts = {
    noremap = true,
    silent = true,
}

vim.api.nvim_set_keymap("n", "mpd", "v:lua.peek_definition()", mappings_opts)
vim.api.nvim_set_keymap("n", "mca", "<cmd>Telescope lsp_code_actions<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "mk", "<cmd>lua vim.lsp.buf.signature_help()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "gu", "<cmd>Telescope lsp_references<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "mrn", "<cmd>lua vim.lsp.buf.rename()<CR>", mappings_opts)
vim.api.nvim_set_keymap("n", "mff", "<cmd>lua vim.lsp.buf.formatting()<CR>", mappings_opts)

local diagnostic_display_opts = {
    border = "single",
    show_header = false,
    focusable = false,
}

_G.my_goto_diag_next = function()
    vim.lsp.diagnostic.goto_next({ popup_opts = diagnostic_display_opts })
end

_G.my_goto_diag_prev = function()
    vim.lsp.diagnostic.goto_prev({ popup_opts = diagnostic_display_opts })
end

vim.api.nvim_set_keymap("n", "<c-j>", [[<cmd>lua my_goto_diag_next()<CR>]], mappings_opts)
vim.api.nvim_set_keymap("n", "<c-k>", [[<cmd>lua my_goto_diag_prev()<CR>]], mappings_opts)

vim.o.updatetime = 250

_G.my_show_line_diags = function()
    --lightbulb.update_lightbulb()
    vim.lsp.diagnostic.show_line_diagnostics(diagnostic_display_opts)
end
vim.cmd[[
augroup ShowLineDiagnosticsHold
autocmd!

au CursorHold,CursorHoldI * lua my_show_line_diags()

augroup END
]]

--local function goimports(timeout_ms)
--    local ctx = { only = { "source.organizeImports" } }
--end

vim.cmd[[
augroup LSPFormatting
autocmd!

au BufWritePre *.c lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
au BufWritePre *.cpp lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
au BufWritePre Dockerfile lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"dockerls"})
au BufWritePre Dockerfile.* lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"dockerls"})
au BufWritePre *.go lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"gopls"})
au BufWritePre *.java lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"java_language_server"})
au BufWritePre *.js lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"tsserver"})
au BufWritePre *.json lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"jsonls"})
au BufWritePre *.kt lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"kotlin_language_server"})
au BufWritePre *.md lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"efm"})
au BufWritePre *.py lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"pyright"})
au BufWritePre *.sh lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"bashls"})
au BufWritePre *.tf lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"terraformls"})
au BufWritePre *.ts lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"tsserver"})
au BufWritePre *.yaml lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"yamlls"})

augroup END
]]

vim.cmd[[
augroup LSPPlugins
autocmd!

au FileType java lua require('jdtls_setup').setup()

augroup END
]]

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
