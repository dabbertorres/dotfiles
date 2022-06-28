--local profile_start_time = vim.loop.hrtime()

local lsp = require("lspconfig")
local log = require("vim.lsp.log")

local cmp_lsp = require("cmp_nvim_lsp")
local lint = require("lint")
local telescope = require("telescope.builtin")
local lightbulb = require("nvim-lightbulb")

local notifications = require("notifications")
local util = require("util")

vim.o.updatetime = 250
log.set_level(log.levels.WARN)

local home = os.getenv("HOME")

local formatting_options = {
    trimTrailingWhitespace = true,
    insertFinalNewline = true,
    trimFinalNewlines = true,
}

local mappings_opts = {
    noremap = true,
    silent = true,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_lsp.update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

lightbulb.setup{}

local function on_attach(client, bufnr)
    vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"

    vim.keymap.set("n", "<c-k>", vim.diagnostic.goto_prev, util.copy_with(mappings_opts, { buffer = bufnr }))
    vim.keymap.set("n", "<c-j>", vim.diagnostic.goto_next, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "mpd", function()
        local params = vim.lsp.util.make_position_params()
        return vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
            if result == nil or vim.tbl_isempty(result) then return nil end
            vim.lsp.util.preview_location(result[1])
        end)
    end, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "mca", vim.lsp.buf.code_action, util.copy_with(mappings_opts, { buffer = bufnr }))
    vim.keymap.set("v", "mca", vim.lsp.buf.range_code_action, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "gd", function()
        telescope.lsp_definitions{
            jump_type = nil,
            ignore_filename = false,
            trim_text = false,
        }
    end, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "gi", function()
        telescope.lsp_implementations{
            jump_type = nil,
            ignore_filename = false,
            trim_text = false,
        }
    end, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "K", vim.lsp.buf.hover, util.copy_with(mappings_opts, { buffer = bufnr }))
    vim.keymap.set("n", "mk", vim.lsp.buf.signature_help, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "gu", function()
        telescope.lsp_references({
            include_declaration = true,
            include_current_line = true,
            trim_text = false,
        })
    end, util.copy_with(mappings_opts, { buffer = bufnr }))

    vim.keymap.set("n", "mrn", vim.lsp.buf.rename, util.copy_with(mappings_opts, { buffer = bufnr } ))

    vim.keymap.set("n", "mfa", vim.lsp.buf.formatting, util.copy_with(mappings_opts, { buffer = bufnr }))

    -- vim.keymap.set({"n", "v"}, "ms", "<Plug>(sqls-execute-query)", { buffer = bufnr })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        callback = function()
            vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
        end,
    })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        callback = function()
            lightbulb.update_lightbulb()
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

    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
        vim.cmd[[
            hi! LspReferenceRead guibg=#5b5e5b
            hi! LspReferenceText guibg=#5b5e5b
            hi! LspReferenceWrite guibg=#5b5e5b
        ]]
    end
end

lsp.bashls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.clangd.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.cmake.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.cssls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.dockerls.setup{
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
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.gopls.setup{
    cmd = {"gopls", "-remote=auto", "-logfile=auto", "-debug=:0", "-remote.debug=:0", "-remote.logfile=auto"},
    capabilities = capabilities,
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
            templateExtensions = {"gotmpl", "tmpl"},
            usePlaceholders = false,
        },
    },
    on_attach = on_attach,
}

lsp.gradle_ls.setup{
    cmd = { home .. "/Code/lsps/vscode-gradle/gradle-language-server/build/install/gradle-language-server/bin/gradle-language-server" },
    capabilities = capabilities,
    filetypes = { "groovy" }, -- TODO: kotlin-script files (e.g. build.gradle.kts)
    root_dir = lsp.util.root_pattern("build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"),
    on_attach = on_attach,
}

lsp.html.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.jsonls.setup{
    capabilities = capabilities,
    single_file_support = true,
    on_attach = on_attach,
}

lsp.kotlin_language_server.setup{
    cmd = { home .. "/Code/lsps/kotlin-language-server/server/build/install/server/bin/kotlin-language-server" },
    capabilities = capabilities,
    filetypes = { "kotlin" },
    root_dir = function(fname)
        local primary = lsp.util.root_pattern("settings.gradle", "settings.gradle.kts")
        local fallback = lsp.util.root_pattern("build.gradle", "build.gradle.kts")
        return primary(fname) or fallback(fname)
    end,
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
    capabilities = capabilities,
    root_dir = lsp.util.root_pattern("*.csproj"),
    flags = {
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
    capabilities = capabilities,
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
    capabilities = capabilities,
    root_dir = lsp.util.root_pattern(".sqls.yaml"),
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        require('sqls').on_attach(client, bufnr)
    end,
    on_new_config = function(new_config, new_root_dir)
        if new_root_dir then
            table.insert(new_config.cmd, "--config")
            table.insert(new_config.cmd, new_root_dir)
        end
    end,
}

lsp.sumneko_lua.setup{
    cmd = {
        home .. "/Code/lsps/lua-language-server/bin/lua-language-server",
        "-E",
        home .. "/Code/lsps/lua-language-server/main.lua"
    },
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            -- runtime = {
            --     version = "Lua 5.4",
            --     path = {
            --         "?.lua",
            --         "?/init.lua",
            --     }
            -- },
            telemetry = {
                enable = false,
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
        },
    },
    -- on_init = function(client)
    --     if client.config.settings then
    --         client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    --     end
    -- end,
    on_attach = on_attach,
}

lsp.tsserver.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.terraformls.setup{
    capabilities = capabilities,
    flags = {
        debounce_text_changes = 1000,
    },
    init_options = {
        experimentalFeatures = {
            validateOnSave = false,
            prefillRequiredFields = true,
        },
        terraformExecTimeout = "5s",
    },
    on_attach = on_attach,
}

lsp.tflint.setup{
    cmd = { "tflint", "--config", home .. "/.config/tflint/config.hcl", "--langserver" },
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.vimls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.vuels.setup{
    capabilities = capabilities,
    on_attach = on_attach,
}

lsp.yamlls.setup{
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
                enable = true,
                url = "https://www.schemastore.org/api/json/catalog.json",
            },
            validate = true,
            yamlVersion = "1.2",
        }
    },
    on_attach = on_attach,
}

lint.linters.tfsec = {
    cmd = "tfsec",
    stdin = true, -- if false, nvim-lint automatically adds the filename as an argument, which we don't want
    args = {
        "--soft-fail",
        "--format=json",
        function()
            local root_path = vim.api.nvim_buf_get_name(0)
            if not lsp.util.path.is_dir(root_path) then
                root_path = lsp.util.path.dirname(root_path)
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

        local filename = vim.api.nvim_buf_get_name(bufnr)
        local diagnostics = {}

        for _, result in ipairs(body.results) do
            -- TODO set diagnostics for other buffers instead of skipping?
            -- tfsec is giving us all those anyways
            if result.location.filename ~= filename then
                goto skip_to_next
            end

            -- exclude duplicates (e.g. for multiple values in the same block)
            for _, dup in ipairs(diagnostics) do
                if dup.lnum == result.location.start_line and
                    dup.end_lnum == result.location.end_line and
                    dup.code == result.long_id then
                    goto skip_to_next
                end
            end

            local severity = vim.diagnostic.severity.WARN
            if result.warning then
                severity = vim.diagnostic.severity.INFO
            end

            local fmt = [[
%s (%s)
Impact (%s): %s
Resolution: %s
See:
]] .. string.rep("* %s", #result.links, "\n")
.. "\n"

            local msg = string.format(fmt,
                result.description,
                result.long_id,
                result.severity,
                result.impact,
                result.resolution,
                unpack(result.links)
            )

            local diag = {
                bufnr = bufnr,
                lnum = result.location.start_line,
                end_lnum = result.location.end_line,
                col = 0,
                severity = severity,
                message = msg,
                source = "tfsec",
                code = result.long_id,
                user_data = {
                    links = result.links,
                },
            }

            table.insert(diagnostics, diag)

            ::skip_to_next::
        end

        return diagnostics
    end,
}

lint.linters_by_ft = {
    dockerfile = { "hadolint", },
    markdown = { "markdownlint", "proselint", },
    text = { "proselint", },
    rst = { "proselint", },
    -- sh = { "shellcheck", },
    terraform = { "tfsec", },
}

-- plugins for specific LSP servers
local lsp_plugins_au = vim.api.nvim_create_augroup("lsp_plugins", {})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = lsp_plugins_au,
    callback = function() lint.try_lint() end,
})

local jdtls = require("jdtls_setup")
vim.api.nvim_create_autocmd("FileType", {
    group = lsp_plugins_au,
    pattern = "java",
    callback = jdtls.setup,
})

vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "GruvboxRed" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "GruvboxYellow" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "GruvboxBlue" })
vim.fn.sign_define("DiagnosticSignHint", { text = " ", texthl = "GruvboxAqua" })

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
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local opts = notifications.init_spinner(ctx.client_id, result.token, data, {
            title = notifications.format_title(result.value.title, client.name),
            timeout = false,
            hide_from_history = false,
        })
        data.notification = vim.notify(msg, vim.log.levels.INFO, opts)
    elseif result.value.kind == "report" and data then
        local msg = notifications.format_message(result.value.message, result.value.percentage)
        data.notification = vim.notify(msg, vim.log.levels.INFO, {
            replace = data.notification,
            hide_from_history = false,
        })
    elseif result.value.kind == "end" and data then
        local msg = result.value.message and notifications.format_message(result.value.message) or "Complete"
        data.notification = vim.notify(msg, vim.log.levels.INFO, {
            icon = "",
            replace = data.notification,
            timeout = 3000,
        })
        notifications.stop_spinner(data)
    end
end

local function lsp_message_type_to_icon_and_neovim(message_type)
    if message_type == vim.lsp.protocol.MessageType.Error then
        return log.levels.ERROR, " "
    elseif message_type == vim.lsp.protocol.MessageType.Warning then
        return log.levels.WARN, " "
    elseif message_type == vim.lsp.protocol.MessageType.Info then
        return log.levels.INFO, " "
    elseif message_type == vim.lsp.protocol.MessageType.Log then
        return log.levels.TRACE, " "
    else
        return log.levels.DEBUG, "? "
    end
end

vim.lsp.handlers["window/showMessage"] = function(_, result, ctx, _)
    if not result then return end

    local level, icon = lsp_message_type_to_icon_and_neovim(result.type)

    if not log.should_log(level) then return end

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

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
