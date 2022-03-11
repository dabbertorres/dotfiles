--local profile_start_time = vim.loop.hrtime()

local lsp = require"lspconfig"
--local path = lsp.util.path
--local lightbulb = require("nvim-lightbulb")

local home = os.getenv("HOME")

vim.lsp.set_log_level("INFO")

lsp.bashls.setup{}

lsp.clangd.setup{}

lsp.cmake.setup{}

--lsp.csharp_ls.setup{}

lsp.cssls.setup{}

lsp.dockerls.setup{
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

lsp.dotls.setup{}

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

lsp.gradle_ls.setup{
    cmd = { home .. "/Code/lsps/vscode-gradle/gradle-language-server/build/install/gradle-language-server/bin/gradle-language-server" },
    filetypes = { "groovy", "kotlin" },
    root_dir = lsp.util.root_pattern("build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"),
}

local html_capabilities = vim.lsp.protocol.make_client_capabilities()
html_capabilities.textDocument.completion.completionItem.snippetSupport = true

lsp.html.setup{
    capabilities = html_capabilities,
}

lsp.jsonls.setup{
    commands = {
        Format = {
            function()
                lsp.buf.range_formatting({}, {0, 0}, {vim.fn.line("$"), 0})
            end,
        }
    },
    single_file_support = true,
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
        home .. "/Code/lsps/lua-language-server/bin/lua-language-server",
        "-E",
        home .. "/Code/lsps/lua-language-server/main.lua"
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
}

lsp.tflint.setup{}

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

vim.diagnostic.config{
    underline = true,
    virtual_text = false,
    signs = true,
    float = {
        border = "single",
        header = "",
        scope = "line",
        focusable = false,
        focus = false,
        prefix = function(diagnostic, i, total)
            if diagnostic == vim.diagnostic.severity.ERROR then
                return "E: ", ""
            elseif diagnostic == vim.diagnostic.severity.WARN then
                return "W: ", ""
            elseif diagnostic == vim.diagnostic.severity.INFO then
                return "I: ", ""
            elseif diagnostic == vim.diagnostic.severity.HINT then
                return "H: ", ""
            else
                return "", ""
            end
        end,
    },
    update_in_insert = false,
    severity_sort = true,
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

local diagnostics_goto_opts = {
    wrap = true,
}

_G.my_goto_diag_next = function() vim.diagnostic.goto_next(diagnostics_goto_opts) end
_G.my_goto_diag_prev = function() vim.diagnostic.goto_prev(diagnostics_goto_opts) end

vim.api.nvim_set_keymap("n", "<c-j>", [[<cmd>lua my_goto_diag_next()<CR>]], mappings_opts)
vim.api.nvim_set_keymap("n", "<c-k>", [[<cmd>lua my_goto_diag_prev()<CR>]], mappings_opts)

vim.o.updatetime = 250

vim.cmd[[
augroup ShowLineDiagnosticsHold
autocmd!

au CursorHold,CursorHoldI * lua vim.diagnostic.open_float()

augroup END
]]

function GoImports(timeout_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    if not result or next(result) == nil then return end

    local actions = result[1].result
    if not actions then return end

    local action = actions[1]

    local is_table = type(action.command) == "table"
    if action.edit or is_table then
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit)
        end

        if is_table then
            vim.lsp.buf.execute_command(action.command)
        end
    else
        vim.lsp.buf.execute_command(action)
    end
end

vim.cmd[[
augroup LSPFormatting
autocmd!

au BufWritePre *.h lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
au BufWritePre *.c lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
au BufWritePre *.hpp lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
au BufWritePre *.cpp lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"clangd"})
au BufWritePre CMakeLists.txt lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"cmake"})
au BufWritePre Dockerfile lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"dockerls"})
au BufWritePre Dockerfile.* lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"dockerls"})
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
augroup FormatGo
autocmd!

au BufWritePre *.go :silent! lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"gopls"})
"au BufWritePre *.go :silent! lua GoImports(1000)

augroup END
]]

vim.cmd[[
augroup FormatDotNet
autocmd!

au BufWritePre *.cs :silent! lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"omnisharp"})
au BufWritePre *.csproj :silent! lua vim.lsp.buf.formatting_seq_sync(nil, 500, {"omnisharp"})

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
