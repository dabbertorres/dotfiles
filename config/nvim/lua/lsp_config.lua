--local profile_start_time = vim.loop.hrtime()

local lsp = require("lspconfig")
local cmp_lsp = require("cmp_nvim_lsp")
local notifications = require("notifications")

vim.o.updatetime = 250
vim.lsp.set_log_level("INFO")

local home = os.getenv("HOME")

local function preview_location_callback(_, result, _, _)
    if result == nil or vim.tbl_isempty(result) then
        return nil
    end
    vim.lsp.util.preview_location(result[1])
end

_G.peek_definition = function()
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
end

local formatting_options = {
    trimTrailingWhitespace = true,
    insertFinalNewline = true,
    trimFinalNewlines = true,
}

local mappings_opts = {
    noremap = true,
    silent = true,
}

local function on_attach(client, bufnr)
    vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"

    vim.api.nvim_buf_set_keymap(bufnr, "n", "<c-k>", "<cmd>lua vim.diagnostic.goto_prev()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<c-j>", "<cmd>lua vim.diagnostic.goto_next()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "mpd", "<cmd>lua peek_definition()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "mca", "<cmd>Telescope lsp_code_actions<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>Telescope lsp_implementations<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "mk", "<cmd>lua vim.lsp.buf.signature_help()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gu", "<cmd>Telescope lsp_references<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "mrn", "<cmd>lua vim.lsp.buf.rename()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "mff", "<cmd>lua vim.lsp.buf.formatting()<CR>", mappings_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "v", "ms", "<Plug>(sqls-execute-query)", mappings_opts)

    vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
        buffer = bufnr,
        callback = function()
            vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
        end,
    })

    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.formatting_sync(formatting_options, 500)
            end,
        })
    end

    -- if client.server_capabilities.hoverProvider then
    --     local id = vim.api.nvim_create_augroup("lsp_hover", {})
    --     vim.api.nvim_create_autocmd("CursorHold,CursorHoldI", {
    --         group = id,
    --         buffer = bufnr,
    --         callback = function()
    --             vim.lsp.buf.hover()
    --         end,
    --     })
    -- end

    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
        vim.cmd[[
            hi! LspReferenceRead guibg=#5b5e5b
            hi! LspReferenceText guibg=#5b5e5b
            hi! LspReferenceWrite guibg=#5b5e5b
        ]]
    end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_lsp.update_capabilities(capabilities)

lsp.bashls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.clangd.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.cmake.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.cssls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.dockerls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    settings = {
        docker = {
            languageserver = {
                diagnostics = {
                    deprecatedMaintainer = "ignore",
                    directiveCasing = "warning",
                    emptyContinuationLine = "warning",
                    instructionCasing = "warning",
                    instructionCmdMultiple = "warning",
                    instructionEntrypointMultiple = "error",
                    instructionHealthcheckMultiple = "error",
                    instructionJSONInSingleQuotes = "error",
                },
                formatter = {
                    ignoreMultilineInstructions = true,
                },
            },
        },
    },
    on_attach = on_attach,
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

lsp.dotls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.efm.setup{
    flags = {
        debounce_text_changes = 150,
    },
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
    on_attach = on_attach,
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
    on_attach = on_attach,
}

lsp.gradle_ls.setup{
    cmd = { home .. "/Code/lsps/vscode-gradle/gradle-language-server/build/install/gradle-language-server/bin/gradle-language-server" },
    flags = {
        debounce_text_changes = 150,
    },
    filetypes = { "groovy" }, -- TODO: kotlin-script files (e.g. build.gradle.kts)
    root_dir = lsp.util.root_pattern("build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"),
    on_attach = on_attach,
}

local html_capabilities = vim.lsp.protocol.make_client_capabilities()
html_capabilities.textDocument.completion.completionItem.snippetSupport = true

lsp.html.setup{
    capabilities = html_capabilities,
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.jsonls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    single_file_support = true,
    on_attach = on_attach,
}

lsp.kotlin_language_server.setup{
    cmd = { home .. "/Code/lsps/kotlin-language-server/server/build/install/server/bin/kotlin-language-server" },
    filetypes = { "kotlin" },
    flags = {
        debounce_text_changes = 150,
    },
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
    on_attach = on_attach,
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
    on_attach = on_attach,
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
    flags = {
        debounce_text_changes = 150,
    },
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
    on_attach = on_attach,
}

lsp.sqls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        require('sqls').on_attach(client, bufnr)
    end
}

lsp.sumneko_lua.setup{
    cmd = {
        home .. "/Code/lsps/lua-language-server/bin/lua-language-server",
        "-E",
        home .. "/Code/lsps/lua-language-server/main.lua"
    },
    flags = {
        debounce_text_changes = 150,
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
    },
    on_attach = on_attach,
}

lsp.tsserver.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.terraformls.setup{
    flags = {
        debounce_text_changes = 500,
    },
    init_options = {
        experimentalFeatures = {
            validateOnSave = true,
            prefillRequiredFields = true,
        },
        terraformExecTimeout = "5s",
        terraformLogFilePath = "/Users/aleciverson/Code/myndshft/platform/load-test/ops/infra/.tflogs/{{ .Ppid }}-{{ .Pid }}-{{ .Timestamp }}.log",
    },
    on_attach = on_attach,
}

lsp.tflint.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.vimls.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.vuels.setup{
    flags = {
        debounce_text_changes = 150,
    },
    on_attach = on_attach,
}

lsp.yamlls.setup{
    flags = {
        debounce_text_changes = 150,
    },
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
    },
    on_attach = on_attach,
}

-- plugins for specific LSP servers
local lsp_plugins_au = vim.api.nvim_create_augroup("lsp_plugins", {})
local jdtls = require("jdtls_setup")
vim.api.nvim_create_autocmd("FileType", {
    group = lsp_plugins_au,
    pattern = "java",
    callback = function()
        jdtls.setup{}
    end,
})

vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "GruvboxRed" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "GruvboxYellow" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "GruvboxBlue" })
vim.fn.sign_define("DiagnosticSignHint", { text = " ", texthl = "GruvboxAqua" })

vim.diagnostic.config{
    underline = {},
    virtual_text = false,
    signs = {},
    float = {
        border = "single",
        header = "",
        scope = "line",
        focusable = false,
        focus = false,
        prefix = function(diagnostic, _, _)
            if diagnostic == vim.diagnostic.severity.ERROR then
                return " ", ""
            elseif diagnostic == vim.diagnostic.severity.WARN then
                return " ", ""
            elseif diagnostic == vim.diagnostic.severity.INFO then
                return " ", ""
            elseif diagnostic == vim.diagnostic.severity.HINT then
                return " ", ""
            else
                return "", ""
            end
        end,
    },
    update_in_insert = false,
    severity_sort = true,
}

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

vim.lsp.handlers["$/progress"] = function(_, result, ctx, _)
    if not result.value.kind then return end

    local data = notifications.get(ctx.client_id, result.token)

    if result.value.kind == "begin" then
        local msg = notifications.format_message(result.value.message, result.value.percentage)
        local opts = notifications.init_spinner(ctx.client_id, result.token, data, {
            title = notifications.format_title(result.value.title, vim.lsp.get_client_by_id(ctx.client_id).name),
            timeout = false,
            hide_from_history = false,
        })
        data.notification = vim.notify(msg, "info", opts)
    elseif result.value.kind == "report" and data then
        local msg = notifications.format_message(result.value.message, result.value.percentage)
        data.notification = vim.notify(msg, "info", {
            replace = data.notification,
            hide_from_history = false,
        })
    elseif result.value.kind == "end" and data then
        local msg = result.value.message and notifications.format_message(result.value.message) or "Complete"
        data.notification = vim.notify(msg, "info", {
            icon = "",
            replace = data.notification,
            timeout = 3000,
        })
        notifications.stop_spinner(data)
    end
end

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
