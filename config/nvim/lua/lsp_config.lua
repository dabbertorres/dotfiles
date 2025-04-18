--local profile_start_time = vim.loop.hrtime()

require("mason").setup {}

require("mason-lspconfig").setup {
    automatic_installation = true,
}

local lsp = require("lspconfig")
local notifications = require("notifications")

local cmp_lsp = require("cmp_nvim_lsp")
local lint = require("lint")
local lightbulb = require("nvim-lightbulb")

local navbuddy = require("nvim-navbuddy")

local util = require("my_util")

local schemastore = require("schemastore")

vim.o.updatetime = 250
vim.lsp.set_log_level(vim.lsp.log_levels.ERROR)

local home = os.getenv("HOME")

local mappings_opts = {
    noremap = true,
    silent = true,
}

navbuddy.setup {
    lsp = {
        auto_attach = true,
    },
}

local _keymap_mt = {
    __call = function(km, f, buffer)
        local mode = km.mode or "n"
        local opts = mappings_opts
        if buffer ~= nil then
            opts = util.copy_with(opts, { buffer = buffer })
        end

        vim.keymap.set(mode, km.keys, f, opts)
    end,
}

local keymaps = {
    navbuddy            = { keys = "gsb" },
    preview_defintion   = { keys = "<leader>pd" },
    goto_defintion      = { keys = "gd" },
    goto_declaration    = { keys = "gD" },
    goto_implementation = { keys = "gi" },
    signature_help      = { keys = "<leader>k" },
    goto_usages         = { keys = "gu" },
    rename              = { keys = "<leader>rn" },
    format              = { keys = "<leader>fa" },
    codelens            = { keys = "<leader>cl" },
    codeaction          = { keys = "<leader>ca" },
    prev_diag           = { keys = "<c-k>" },
    next_diag           = { keys = "<c-j>" },
}

for _, km in pairs(keymaps) do
    setmetatable(km, _keymap_mt)
end

-- Prefer treesitter over LSP for highlighting - this is temporary until I actually decide what I want.
-- For some ideas, see: https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
vim.highlight.priorities.semantic_tokens = 95

keymaps.navbuddy(navbuddy.open)

local capabilities = vim.tbl_deep_extend(
    "force",
    cmp_lsp.default_capabilities(),
    {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
    }
)

lightbulb.setup {
    sign = {
        enabled = true,
        priority = 10,
    },
}

local function create_buf_augroup(name, bufnr, cmds)
    local au = vim.api.nvim_create_augroup(name, {
        clear = false,
    })

    vim.api.nvim_clear_autocmds({
        buffer = bufnr,
        group = au,
    })

    if cmds ~= nil then
        for _, cmd in ipairs(cmds) do
            vim.api.nvim_create_autocmd(cmd.events, util.copy_with(cmd.opts, {
                group = au,
                buffer = bufnr,
            }))
        end
    end

    return au
end

local function set_lsp_format_autocmd(bufnr, do_format)
    create_buf_augroup("lsp_document_format", bufnr, {
        {
            events = { "BufWritePre" },
            opts = { callback = do_format },
        },
    })
end

local lsp_autocmds_au = vim.api.nvim_create_augroup("lsp_user_config", {})

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_autocmds_au,
    callback = function(args)
        local telescope = require("telescope.builtin")

        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- if client == nil then return end
        assert(client ~= nil)

        vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        if client.supports_method("textDocument_definition") and client.server_capabilities.definitionProvider then
            keymaps.preview_defintion(function()
                local params = vim.lsp.util.make_position_params()
                return vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
                    if result == nil or vim.tbl_isempty(result) then return nil end
                    vim.lsp.util.preview_location(result[1], {})
                end)
            end, args.buf)

            keymaps.goto_defintion(function()
                telescope.lsp_definitions {
                    jump_type = nil,
                    fname_width = 120,
                    ignore_filename = false,
                    trim_text = false,
                }
            end, args.buf)
        end

        if client.supports_method("textDocument_declaration") and client.server_capabilities.declarationProvider then
            keymaps.goto_declaration(vim.lsp.buf.declaration, args.buf)
        end

        if client.supports_method("textDocument_implementation") and client.server_capabilities.implementationProvider then
            keymaps.goto_implementation(function()
                telescope.lsp_implementations {
                    jump_type = nil,
                    fname_width = 120,
                    ignore_filename = false,
                    trim_text = false,
                }
            end, args.buf)
        end

        if client.supports_method("textDocument_signatureHelp") and client.server_capabilities.signatureHelpProvider then
            keymaps.signature_help(vim.lsp.buf.signature_help, args.buf)
        end

        if client.supports_method("textDocument_references") and client.server_capabilities.referencesProvider then
            keymaps.goto_usages(function()
                telescope.lsp_references {
                    fname_width = 120,
                    include_declaration = true,
                    include_current_line = true,
                    trim_text = false,
                }
            end, args.buf)
        end

        if client.supports_method("textDocument_rename") and client.server_capabilities.renameProvider then
            keymaps.rename(vim.lsp.buf.rename, args.buf)
        end

        -- if client.supports_method("textDocument_diagnostic") then
        create_buf_augroup("lsp_diagnostics", args.buf, {
            {
                events = { "BufEnter", "CursorHold", "CursorHoldI" },
                opts = {
                    callback = function()
                        vim.diagnostic.open_float(nil, {
                            focus = false,
                            scope = "cursor",
                        })
                    end,
                }
            },
        })

        keymaps.prev_diag(vim.diagnostic.goto_prev, args.buf)
        keymaps.next_diag(vim.diagnostic.goto_next, args.buf)
        -- end

        if client.supports_method("textDocument_codeAction") and client.server_capabilities.codeActionProvider then
            create_buf_augroup("lsp_code_actions", args.buf, {
                {
                    events = { "BufEnter", "CursorHold", "InsertLeave" },
                    opts = { callback = lightbulb.update_lightbulb },
                },
            })

            keymaps.codeaction(vim.lsp.buf.code_action, args.buf)
        end

        if client.supports_method("textDocument_codeLens")
            and client.server_capabilities.codeLensProvider ~= nil
            and client.server_capabilities.codeLensProvider.resolveProvider then
            create_buf_augroup("lsp_codelens", args.buf, {
                {
                    events = { "BufEnter", "CursorHold", "InsertLeave" },
                    opts = {
                        callback = function()
                            vim.lsp.codelens.refresh({ bufnr = args.buf })
                        end,
                    },
                },
            })

            keymaps.codelens(vim.lsp.codelens.run, args.buf)
        end

        if client.supports_method("textDocument_formatting") and client.server_capabilities.documentFormattingProvider then
            local do_format = function(async)
                return function()
                    vim.lsp.buf.format {
                        formatting_options = {
                            -- tabSize                = vim.bo.tabstop,
                            tabSize                = vim.bo.shiftwidth,
                            insertSpaces           = true,
                            trimTrailingWhitespace = true,
                            insertFinalNewline     = true,
                            trimFinalNewlines      = true,
                        },
                        bufnr = args.buf,
                        async = async,
                    }
                end
            end

            set_lsp_format_autocmd(args.buf, do_format(false))
            keymaps.format(do_format(true), args.buf)
        end

        if client.supports_method("textDocument_documentHighlight") and client.server_capabilities.documentHighlightProvider then
            create_buf_augroup("lsp_document_highlight", args.buf, {
                {
                    events = { "CursorHold", "CursorHoldI" },
                    opts = { callback = vim.lsp.buf.document_highlight },
                },
                {
                    events = { "CursorMoved", "CursorMovedI" },
                    opts = { callback = vim.lsp.buf.clear_references },
                }
            })

            vim.cmd [[
                hi! LspReferenceRead guibg=#5b5e5b
                hi! LspReferenceText guibg=#5b5e5b
                hi! LspReferenceWrite guibg=#5b5e5b
            ]]
        end

        -- Semantic tokens can be slow! Disable them.
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

local on_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    on_publish_diagnostics,
    {
        underline = true,
        signs = true,
        virtual_text = false,
        severity_sort = true,
    }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {
        border = "single",
        focusable = true,
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {
        border = "single",
        focusable = false,
    }
)

-- local builtin_on_codelens = vim.lsp.codelens.on_codelens
-- vim.lsp.codelens.on_codelens = function(err, result, ctx, config)
--     builtin_on_codelens(err, result, ctx, config)

-- local client = vim.lsp.get_client_by_id(ctx.client_id)
-- if err then
--     vim.notify("Error: " .. err.message, vim.lsp.log_levels.ERROR, {
--         title = notifications.format_title(result.command.title, client.name),
--         icon = "󰅚 ",
--         timeout = 5000,
--     })
-- else
--     vim.notify("Completed", vim.lsp.log_levels.INFO, {
--         title = notifications.format_title(result.command.title, client.name),
--         icon = "",
--         timeout = 5000,
--     })
-- end
-- end

---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.handlers["$/progress"] = function(_, result, ctx, _)
    if not result.value.kind then return end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    assert(client ~= nil)
    -- if client == nil then return end

    -- ignore sonarlint spamming notifications
    if client.name == "sonarlint.nvim" then return end

    local msg = notifications.format_message(result.value.message, result.value.percentage) or "Complete"

    if result.value.kind == "begin" then
        notifications.init_spinner(ctx.client_id, result.token, msg, {
            title = notifications.format_title(result.value.title, client.name),
        })
    elseif result.value.kind == "report" then
        notifications.update_spinner(ctx.client_id, result.token, msg, {})
    elseif result.value.kind == "end" then
        notifications.stop_spinner(ctx.client_id, result.token, msg, {
            title = notifications.format_title(result.value.title, client.name),
        })
    end
end

local function lsp_message_type_to_icon_and_neovim(message_type)
    if message_type == vim.lsp.protocol.MessageType.Error then
        return vim.lsp.log_levels.ERROR, "󰅚"
    elseif message_type == vim.lsp.protocol.MessageType.Warning then
        return vim.lsp.log_levels.WARN, "󰀪"
    elseif message_type == vim.lsp.protocol.MessageType.Info then
        return vim.lsp.log_levels.INFO, ""
    elseif message_type == vim.lsp.protocol.MessageType.Log then
        return vim.lsp.log_levels.TRACE, "󰌶"
    else
        return vim.lsp.log_levels.DEBUG, "?"
    end
end

---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx, _)
    if not result then return end

    local level, icon = lsp_message_type_to_icon_and_neovim(result.type)

    if not vim.lsp.log.should_log(level) then return end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = ""
    if client ~= nil then
        client_name = client.name
    else
        client_name = "Client " .. tostring(ctx.client_id)
    end

    vim.notify(result.message, level, {
        title = client_name,
        icon = icon,
    })
end

vim.fn.sign_define("DiagnosticSignError", { text = "󰅚 ", texthl = "GruvboxRed" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "󰀪 ", texthl = "GruvboxYellow" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "GruvboxBlue" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌶", texthl = "GruvboxAqua" })

vim.diagnostic.config {
    underline = true,
    virtual_text = false,
    signs = true,
    float = {
        border = "single",
        header = "",
        scope = "line",
        focusable = false,
        focus = false,
        source = "if_many",
        zindex = 1,
        prefix = function(diagnostic, _, _)
            if diagnostic == vim.diagnostic.severity.ERROR then
                return "󰅚 ", ""
            elseif diagnostic == vim.diagnostic.severity.WARN then
                return "󰀪 ", ""
            elseif diagnostic == vim.diagnostic.severity.INFO then
                return " ", ""
            elseif diagnostic == vim.diagnostic.severity.HINT then
                return "󰌶", ""
            else
                return "", ""
            end
        end,
    },
    update_in_insert = false,
    severity_sort = true,
}

--
-- Server Configs
--

lsp.bashls.setup {
    capabilities = capabilities,
    filetypes = {
        "bash",
        "sh",
        "zsh",
    },
    settings = {
        bashIde = {
            globPattern = "**/*@(.sh|.inc|.bash|.command|.zsh|zshrc|bashrc)",
            shellcheckPath = home .. "/.local/share/nvim/mason/bin/shellcheck",
            shfmt = {
                path = home .. "/.local/share/nvim/mason/bin/shfmt",
                ignoreEditorConfig = false,
                binaryNextLine = true,
                caseIndent = false,
                funcNextLine = true,
                simplifyCode = true,
                spaceRedirects = true,
            },
        },
    },
}

lsp.clangd.setup {
    capabilities = capabilities,
    on_new_config = function(new_config, new_root_dir)
        vim.list_extend(new_config.cmd, {
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--enable-config",
            "--pch-storage=memory",
            "-j=8",
            "--offset-encoding=utf-8",
            "--query-driver=/usr/local/Cellar/llvm/**/bin/clang++",
            "--log=error",
        })
    end,
}

lsp.cmake.setup {
    capabilities = capabilities,
}

lsp.cssls.setup {
    capabilities = capabilities,
}

lsp.dockerls.setup {
    capabilities = capabilities,
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
            vim.list_extend(new_config.cmd, {
                "--source", new_root_dir,
            })
        end
    end,
}

lsp.dotls.setup {
    capabilities = capabilities,
}

lsp.efm.setup {
    capabilities = capabilities,
    filetypes = {
        "typescript",
    },
    init_options = {
        documentFormatting = true,
        documentRangeFormatting = true,
    },
    settings = {
        rootMarkers = {
            ".git/",
        },
        languages = {
            typescript = {
                {
                    -- https://github.com/creativenull/efmls-configs-nvim/blob/e44e39c962dc1629a341fc71cfc8feaa09cefa6f/lua/efmls-configs/formatters/prettier_d.lua
                    formatCanRange = true,
                    formatCommand = table.concat({
                        "prettierd",
                        "'${INPUT}'",
                        "${--range-start=charStart}",
                        "${--range-end=charEnd}",
                        "${--tab-width=tabWidth}",
                        "${--use-tabs=!insertSpaces}",
                    }, " "),
                    formatStdin = true,
                    rootMarkers = {
                        ".prettierrc",
                        ".prettierrc.cjs",
                        ".prettierrc.js",
                        ".prettierrc.json",
                        ".prettierrc.json5",
                        ".prettierrc.mjs",
                        ".prettierrc.toml",
                        ".prettierrc.yml",
                        ".prettierrc.yaml",
                        "prettier.config.js",
                        "prettier.config.cjs",
                        "prettier.config.mjs",
                    },
                },
            },
        },
    },
}

local default_on_diagnostic = vim.lsp.handlers["textDocument/diagnostic"]
if default_on_diagnostic == nil then
    default_on_diagnostic = vim.lsp.diagnostic.on_diagnostic
end

local default_on_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
if default_on_publish_diagnostics == nil then
    default_on_publish_diagnostics = vim.lsp.diagnostic.on_publish_diagnostics
end

lsp.eslint.setup {
    capabilities = capabilities,
    handlers = {
        ["textDocument/diagnostic"] = function(err, result, ctx, config)
            if result == nil then return end

            -- don't underline the whole function - just the first line
            for _, d in ipairs(result.items) do
                if d.code == "func-style" then
                    d.range.start.character = 0
                    d.range["end"] = {
                        line = d.range.start.line,
                        character = vim.fn.charcol({ d.range.start.line + 1, "$" }) - 1,
                    }
                end
            end

            default_on_diagnostic(err, result, ctx, config)
        end,
    },
}

lsp.gopls.setup {
    capabilities = capabilities,
    flags = {
        debounce_text_changes = 250,
    },
    settings = {
        gopls = {
            -- Build
            buildFlags = {
                "-tags=wireinject,integrationTest",
            },
            directoryFilters = {
                "-**/node_modules",
            },
            templateExtensions = { "gotmpl", "tmpl", "gohtml" },
            -- allowModfileModifications = false,
            -- allowImplicitNetworkAccess = true,
            -- Formatting
            gofumpt = true,
            -- UI
            codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = false,
            },
            -- Completion
            usePlaceholders = false,
            -- Diagnostic
            vulncheck = "Imports",
            staticcheck = true,
            analyses = {
                appends = true,
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
                defers = true,
                deprecated = true,
                directive = true,
                embed = true,
                errorsas = true,
                fillreturns = true,
                framepointer = true,
                httpresponse = true,
                ifaceassert = true,
                infertypeargs = true,
                loopclosure = true,
                lostcancel = true,
                nilfunc = true,
                nilness = true,
                nonewvars = true,
                noresultvalues = true,
                printf = true,
                shadow = false,
                shift = true,
                sigchanyzer = true,
                simplifycompositelit = true,
                simplifyrange = true,
                simplifyslice = true,
                slog = true,
                sortslice = true,
                stdmethods = true,
                stdversion = true,
                stringintconv = true,
                structtag = true,
                stubmethods = true,
                testinggoroutine = true,
                tests = true,
                timeformat = true,
                undeclaredname = true,
                unmarshal = true,
                unreachable = true,
                unsafeptr = true,
                unusedparams = true,
                unusedresult = true,
                unusedvariable = true,
                unusedwrite = true,
                useany = true,
            },
            annotations = {
                bounds = true,
                escape = true,
                inline = true,
                ["nil"] = true,
            },
            -- Documentation
            hoverKind = "FullDocumentation",
            linkTarget = "pkg.go.dev",
            linksInHover = true,
            -- Inlay Hint
            hints = {
                assignVariableTypes = false,
                compositeLiteralFields = true,
                compositeLiteralTypes = false,
                constantValues = true,
                functionTypeParameters = false,
                parameterNames = true,
                rangeVariableTypes = false,
            },
            -- Navigation
            importShortcut = "Link",
            -- newDiff = "new",
        },
    },
    on_new_config = function(new_config, new_root_dir)
        local Job = require("plenary.job")

        -- identify the local package for use when sorting imports
        Job:new({
            command = "go",
            args = { "list", "-m" },
            cwd = new_root_dir,
            on_stdout = function(err, output, _)
                if not err then
                    local module = string.gsub(output, "%s", "")
                    new_config.settings.gopls["local"] = module
                end
            end,
        }):sync()

        vim.list_extend(new_config.cmd, {
            "-remote=auto",
            "-logfile=auto",
            "-remote.logfile=auto",
            "-v",
        })
    end,
    on_attach = function(client, bufnr)
        local do_format = function(async)
            return function()
                local params = vim.lsp.util.make_range_params()
                params.context = { only = { "source.organizeImports" } }

                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
                for cid, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                        if r.edit then
                            local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                            vim.lsp.util.apply_workspace_edit(r.edit, enc)
                        end
                    end
                end

                vim.lsp.buf.format {
                    formatting_options = {
                        -- tabSize                = vim.bo.tabstop,
                        tabSize                = vim.bo.shiftwidth,
                        insertSpaces           = true,
                        trimTrailingWhitespace = true,
                        insertFinalNewline     = true,
                        trimFinalNewlines      = true,
                    },
                    bufnr = bufnr,
                    async = async,
                }
            end
        end

        set_lsp_format_autocmd(bufnr, do_format(false))
        keymaps.format(do_format(true), bufnr)
    end,
}

lsp.gradle_ls.setup {
    capabilities = capabilities,
    filetypes = { "groovy" }, -- TODO: kotlin-script files (e.g. build.gradle.kts)
    root_dir = lsp.util.root_pattern("build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"),
    init_options = {
        settings = {
            gradleWrapperEnabled = true,
        },
    },
}

lsp.html.setup {
    capabilities = capabilities,
    init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = {
            css = true,
            javascript = true,
        },
        provideFormatter = true,
    },
    settings = {
        editor = {
            linkedEditing = true,
        },
        html = {
            autoClosingTags = true,
            format = {
                enable = true,
                endWithNewline = true,
                indentHandlebars = true,
                indentInnerHtml = false,
                maxPreserveNewLines = 1,
                preserveNewLines = true,
                templating = true,
                unformatted = {
                    "script",
                },
                unformattedContentDelimiter = "{{}}",
                wrapAttributes = "aligned-multiple",
                wrapLineLength = 120,
            },
            hover = {
                documentation = true,
                references = true,
            },
            suggest = {
                html5 = true,
            },
            validate = {
                scripts = true,
                styles = true,
            },
        },
    },
    filetypes = { "html", "templ" },
}

lsp.jsonls.setup {
    capabilities = capabilities,
    init_options = {
        -- provideFormatter = false,
    },
    settings = {
        json = {
            -- format = { enable = false },
            schemas = schemastore.json.schemas(),
            validate = { enable = true },
        },
    },
}

lsp.kotlin_language_server.setup {
    capabilities = capabilities,
    filetypes = { "kotlin" },
    root_dir = function(fname)
        local primary = lsp.util.root_pattern("settings.gradle", "settings.gradle.kts")
        local fallback = lsp.util.root_pattern("build.gradle", "build.gradle.kts")
        return primary(fname) or fallback(fname)
    end,
    settings = {
        completion = {
            snippets = {
                enabled = true,
            },
        },
        linting = {
            debounceTime = 250,
        },
        indexing = {
            enabled = true,
        },
        externalSources = {
            useKlsScheme = false,
            autoConvertToKotlin = false,
        },
    },
}

lsp.lua_ls.setup {
    capabilities = capabilities,
    single_file_support = true,
    settings = {
        Lua = {
            completion = {
                displayContent = 2,
                -- nvim-cmp-buffer makes these unnecessary
                showWord = "Disable",
                workspaceWord = false,
            },
            diagnostics = {
                globals = {
                    "vim"
                },
            },
            format = {
                defaultConfig = {
                    indent_style                                 = "space",
                    indent_size                                  = 4,
                    quote_style                                  = "double",
                    call_arg_parentheses                         = "remove_table_only",
                    continuation_indent                          = 4,
                    max_line_length                              = 120,
                    end_of_line                                  = "unset",
                    trailing_table_separator                     = "smart",
                    -- let neovim handle newlines
                    detect_end_of_line                           = false,
                    insert_final_newline                         = false,
                    space_around_table_field_list                = false,
                    space_before_attribute                       = true,
                    space_before_function_open_parenthesis       = false, -- misspelled intentionally...
                    space_before_function_call_open_parenthesis  = false, -- misspelled intentionally...
                    space_before_closure_open_parenthesis        = false, -- misspelled intentionally...
                    space_before_function_call_single_arg        = false,
                    space_before_open_square_bracket             = false,
                    space_inside_function_call_parentheses       = false,
                    space_inside_function_param_list_parentheses = false,
                    space_inside_square_brackets                 = false,
                    space_around_table_append_operator           = false,
                    ignore_spaces_inside_function_call           = false,
                    space_before_inline_comment                  = 1,
                    space_around_math_operator                   = true,
                    space_after_comma                            = true,
                    space_after_comma_in_for_statement           = true,
                    space_around_concat_operator                 = true,
                    align_call_args                              = true,
                    align_function_params                        = true,
                    align_continuous_assign_statement            = true,
                    align_continuous_rect_table_field            = true,
                    align_if_branch                              = true,
                    align_array_table                            = true,
                    never_indent_before_if_condition             = false,
                    line_space_after_if_statement                = "fixed(1)",
                    line_space_after_do_statement                = "fixed(1)",
                    line_space_after_while_statement             = "fixed(1)",
                    line_space_after_repeat_statement            = "fixed(1)",
                    line_space_after_for_statement               = "fixed(1)",
                    line_space_after_local_or_assign_statement   = "max(1)",
                    line_space_after_function_statement          = "fixed(1)",
                    line_space_after_expression_statement        = "max(1)",
                    line_space_after_comment                     = "max(1)",
                    break_all_list_when_line_exceed              = true,
                    auto_collapse_lines                          = false,
                    ignore_space_after_colon                     = true,
                    remove_call_expression_list_finish_comma     = true,
                },
            },
            hint = {
                arrayIndex = "Disable",
                enable     = true,
                setType    = true,
            },
            hover = {
                viewStringMax = 100,
            },
            runtime = {
                version = "LuaJIT",
                path = {
                    "?.lua",
                    "?/init.lua",
                    home .. "/.local/share/nvim/plugged/?/lua/?.lua",
                    home .. "/.local/share/nvim/plugged/?/lua/init.lua",
                },
            },
            telemetry = {
                enable = false,
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
        },
    },
}

lsp.marksman.setup {
    capabilities = capabilities,
}

lsp.omnisharp.setup {
    capabilities = capabilities,
    flags = {
        allow_incremental_sync = true,
    },
    settings = {
        FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
        },
        MsBuild = {
            LoadProjectsOnDemand = false,
        },
        RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            AnalyzeOpenDocumentsOnly = true,
        },
    },
    on_init = function(client)
        if client.config.settings then
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
    end,
    on_new_config = function(new_config, new_root_dir)
        require("lspconfig.server_configurations.omnisharp").default_config.on_new_config(new_config, new_root_dir)

        if new_root_dir then
            vim.list_extend(new_config.cmd, {
                "--source", new_root_dir,
            })
        end
    end,
}

lsp.basedpyright.setup {
    capabilities = capabilities,
    settings = {
        basedpyright = {
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

lsp.rust_analyzer.setup {
    capabilities = capabilities,
}

-- lsp.sorbet.setup {
--     capabilities = capabilities,
--     on_new_config = function(new_config, new_root_dir)
--         vim.list_extend(new_config.cmd, {
--             "tc",
--             "--lsp",
--             "--disable-watchman",
--         })
--     end,
-- }

-- lsp.sqls.setup {
--     capabilities = capabilities,
--     on_attach = function(client, bufnr)
--         require('sqls').on_attach(client, bufnr)
--     end,
--     root_dir = lsp.util.root_pattern(".sqls.yaml"),
--     on_new_config = function(new_config, new_root_dir)
--         if new_root_dir then
--             local new_config_file = new_root_dir .. "/.sqls.yaml"
--             if vim.fn.filereadable(new_config_file) == 1 then
--                 table.insert(new_config.cmd, "--config")
--                 table.insert(new_config.cmd, new_config_file)
--             end
--         end
--     end,
-- }

-- official Ruby LSP
-- lsp.typeprof.setup {}

lsp.templ.setup {
    capabilities = capabilities,
}

-- TODO: move somewhere else that makes more sense
vim.filetype.add({ extension = { templ = "templ" } })

lsp.terraformls.setup {
    capabilities = capabilities,
    init_options = {
        terraform = {
            timeout = "5s",
        },
        indexing = {
            ignoreDirectoryNames = {
                "tools",
                "ops",
            },
        },
        experimentalFeatures = {
            validateOnSave = true,
            prefillRequiredFields = true,
        },
    },
}

lsp.tflint.setup {
    capabilities = capabilities,
    on_new_config = function(new_config, new_root_dir)
        vim.list_extend(new_config.cmd, {
            "--langserver",
        })
    end,
}

lsp.ts_ls.setup {
    capabilities = capabilities,
}

lsp.vimls.setup {
    capabilities = capabilities,
}

lsp.vuels.setup {
    capabilities = capabilities,
}

lsp.yamlls.setup {
    capabilities = capabilities,
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
                enable = false,
                url = "", -- "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = schemastore.yaml.schemas {
                extra = {
                    {
                        description = "Custom references to OpenAPI specs",
                        fileMatch = {
                            "docs/**/*.yaml",
                            "docs/**/*.yml",
                        },
                        name = "openapi.json",
                        url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json",
                    },
                },
            },
            validate = true,
            yamlVersion = "1.2",
        },
    },
}

lsp.zls.setup {
    root_dir = lsp.util.root_pattern("build.zig", "zls.build.json", "zls.json"),
    capabilities = capabilities,
    settings = {
        enable_snippets = true,
        enable_ast_check_diagnostics = true,
        enable_autofix = true,
        enable_import_embedfile_argument_completions = true,
        warn_style = true,
        enable_semantic_tokens = false,
        enable_inlay_hints = true,
        inlay_hints_show_builtin = true,
        inlay_hints_exclude_single_argument = false,
        inlay_hints_hide_redundant_param_names = false,
        inlay_hints_hide_redundant_param_names_last_token = false,
        operator_completions = true,
        include_at_in_builtins = true,
        max_detail_length = 1024 * 1024,
        skip_std_references = false,
        highlight_global_var_declarations = true,
        use_comptime_interpreter = true,
    },
}

require("sonarlint").setup {
    server = {
        cmd = {
            "sonarlint-language-server",
            "-stdio",
            "-analyzers",
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcsharp.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonargo.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarhtml.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonariac.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjavasymbolicexecution.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjs.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarlintomnisharp.jar"),
            vim.fn.expand("$MASON/share/sonarlint-analyzers/sonartext.jar"),
        },
    },
    filetypes = {
        "c",
        "cpp",
        "cs",
        "docker",
        "go",
        "html",
        "java",
        "javascript",
        "javascriptreact",
        "kotlin",
        "terraform",
        "text",
        "typescript",
        "typescriptreact",
    },
    settings = {
        sonarlint = {
            -- Get list of rules with :SonarlintListRules
            -- rules = {
            -- },
        },
    },
}

local trivy_root_dir = lsp.util.root_pattern("trivy.yaml", ".trivyignore", ".trivyignore.yaml")

lint.linters.trivy = {
    name = "trivy",
    cmd = "trivy",
    stdin = true, -- if false, nvim-lint automatically adds the filename as an argument, which we don't want
    args = {
        "config",
        "--exit-code=0",
        "--format=json",
        function()
            local root_dir = trivy_root_dir(util.buffer_dir(0))
            if root_dir then
                local config_file = root_dir .. "/trivy.yaml"
                if vim.fn.filereadable(config_file) == 1 then
                    return "--config=" .. config_file
                end
            end
            return nil
        end,
        function()
            local root_path = vim.api.nvim_buf_get_name(0)
            if vim.fn.isdirectory(root_path) == 0 then
                root_path = vim.fs.dirname(root_path)
            end
            return root_path
        end,
    },
    stream = "stdout",
    ignore_exitcode = false,
    env = nil,
    parser = function(output, bufnr)
        local body = vim.json.decode(output)
        if not body or body.results == vim.NIL then return {} end

        if body.SchemaVersion ~= 2 then
            vim.notify("Got Version: " .. tostring(body.SchemaVersion), vim.lsp.log_levels.WARN, {
                title = "Unexpected Trivy Schema Version",
                icon = "󰀪",
            })
            return {}
        end

        local diagnostics = {}

        for _, result in ipairs(body.Results) do
            local diag_bufnr = vim.fn.bufnr(vim.fs.normalize(result.Target))
            if diag_bufnr ~= bufnr then
                goto skip_to_next
            end

            -- exclude duplicates (e.g. for multiple values in the same block)
            -- for _, dup in ipairs(diagnostics) do
            --     if dup.lnum == result.location.start_line and
            --         dup.end_lnum == result.location.end_line and
            --         dup.code == result.long_id then
            --         goto skip_to_next
            --     end
            -- end

            if result.Misconfigurations == nil then
                goto skip_to_next
            end

            for _, misconfig in ipairs(result.Misconfigurations) do
                local severity = vim.diagnostic.severity.WARN
                if misconfig.Severity == "LOW" then
                    severity = vim.diagnostic.severity.HINT
                elseif misconfig.Severity == "MEDIUM" then
                    severity = vim.diagnostic.severity.INFO
                elseif misconfig.Severity == "HIGH" then
                    severity = vim.diagnostic.severity.WARN
                elseif misconfig.Severity == "CRITICAL" then
                    severity = vim.diagnostic.severity.ERROR
                end

                local template = table.concat({
                    "%s",
                    "Impact: %s",
                    "Resolution: %s",
                    "Details: %s",
                    "See:",
                    string.rep("* %s", #misconfig.References, "\n"),
                }, "\n")

                local refs = { misconfig.PrimaryURL }
                for _, ref in ipairs(misconfig.References) do
                    if ref ~= misconfig.PrimaryURL then
                        table.insert(refs, ref)
                    end
                end

                local msg = string.format(template,
                    misconfig.Message,
                    misconfig.Severity,
                    misconfig.Resolution,
                    misconfig.Description,
                    unpack(refs)
                )

                local diag = {
                    bufnr = diag_bufnr,
                    lnum = misconfig.CauseMetadata.StartLine,
                    end_lnum = misconfig.CauseMetadata.EndLine,
                    col = 0,
                    end_col = -1,
                    severity = severity,
                    message = msg .. "\n",
                    source = "trivy",
                    code = misconfig.ID,
                    user_data = {
                        links = misconfig.References,
                    },
                }

                table.insert(diagnostics, diag)
            end

            ::skip_to_next::
        end

        return diagnostics
    end,
}

lint.linters.terraform_validate = {
    name = "terraform_validate",
    cmd = "terraform",
    stdin = true, -- if false, nvim-lint automatically adds the filename as an argument, which we don't want
    args = {
        -- function()
        --     local root_path = vim.api.nvim_buf_get_name(0)
        --     if not lsp.util.path.is_dir(root_path) then
        --         root_path = lsp.util.path.dirname(root_path)
        --     end
        --     return "-chdir=" .. root_path
        -- end,
        "validate",
        "-json",
    },
    stream = "stdout",
    ignore_exitcode = true,
    parser = function(output, bufnr)
        local body = vim.json.decode(output)
        if not body or body.valid then return {} end

        local diagnostics = {}

        local pwd = vim.fn.getcwd()

        for _, diag in ipairs(body.diagnostics) do
            local severity = vim.diagnostic.severity.WARN
            if diag.severity == "error" then
                severity = vim.diagnostic.severity.ERROR
            end

            -- module-level issue
            if diag.range == nil then
                table.insert(diagnostics, {
                    bufnr = bufnr,
                    lnum = 0,
                    col = 0,
                    end_col = -1,
                    severity = severity,
                    message = string.format("%s\n%s\n", diag.summary, diag.detail),
                    source = "terraform_validate",
                })
                goto skip_to_next
            end

            local diag_filename = vim.fs.normalize(pwd .. "/" .. diag.range.filename)
            local diag_bufnr = vim.fn.bufnr(diag_filename)
            if diag_bufnr == -1 then
                goto skip_to_next
            end

            local fmt = [[
%s
Context: %s
Snippet:
    %s

%s
]]

            local msg = string.format(fmt,
                diag.summary,
                diag.snippet.context,
                diag.snippet.code,
                diag.detail
            )

            table.insert(diagnostics, {
                bufnr = diag_bufnr,
                lnum = diag.range.start.line - 1,
                end_lnum = diag.range["end"].line - 1,
                col = diag.range.start.column - 1,
                end_col = diag.range["end"].column - 1,
                severity = severity,
                message = msg,
                source = "terraform_validate",
            })

            ::skip_to_next::
        end

        return diagnostics
    end,
}

lint.linters_by_ft = {
    dockerfile = { "hadolint", },
    markdown = { "markdownlint", },
    ruby = { "ruby", "rubocop", },
    sh = { "shellcheck", },
    terraform = { "terraform_validate", "trivy", },
}

-- plugins for specific LSP servers
local lsp_plugins_au = vim.api.nvim_create_augroup("lsp_plugins", {})

vim.api.nvim_create_autocmd("FileType", {
    group = lsp_plugins_au,
    pattern = {
        "Dockerfile", "Dockerfile.*",
        "*.md",
        "*.ruby",
        "*.sh",
        "*.tf",
    },
    callback = function() lint.try_lint() end,
})

-- local jdtls = require("jdtls_setup")
-- vim.api.nvim_create_autocmd("FileType", {
--     group = lsp_plugins_au,
--     pattern = "java",
--     callback = jdtls.setup,
-- })

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
