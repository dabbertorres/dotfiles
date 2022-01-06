local M = {}

local jdtls = require("jdtls")
local jdtls_setup = require("jdtls.setup")

function M.setup()
    local root_dir = jdtls_setup.find_root({"gradlew", "mvnw", ".git"})
    local workspace_folder = os.getenv("HOME") .. "/.local/share/jdt-workspaces/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
    local config = {
        cmd = {"jdtls", workspace_folder},
        flags = {
            allow_incremental_sync = true,
            server_side_fuzzy_completion = true,
        },
        capabilities = {
            workspace = {
                configuration = true,
            },
        },
        init_options = {
            extendedClientCapabilities = (function()
                local ext_caps = jdtls.extendedClientCapabilities
                ext_caps.resolveAdditionalTextEditsSupport = true
                return ext_caps
            end)(),
        },
        settings = {
            ["java.format.settings.profile"] = "GoogleStyle",
            java = {
                signatureHelp = { enabled = true },
                contentProvider = { preferred = "fernflower" },
                completion = {
                    favoriteStaticMembers = {
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.mockito.Mockito.*",
                    },
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    },
                },
                configuration = {
                    runtimes = {
                        {
                            name = "JavaSE-11",
                            path = "/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home",
                        },
                        {
                            name = "JavaSE-14",
                            path = "/Library/Java/JavaVirtualMachines/adoptopenjdk-14.jdk/Contents/Home",
                            default = true,
                        },
                    },
                },
            },
        },
        on_attach = function(client, bufnr)
            jdtls_setup.add_commands()
        end,
        on_init = function(client)
            if client.config.settings then
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
            end
        end,
    }

    local actions = require("telescope.actions")
    local finders = require("telescope.finders")
    local pickers = require("telescope.pickers")
    local sorters = require("telescope.sorters")
    require("jdtls.ui").pick_one_async = function(items, prompt, label_fn, cb)
        local opts = {}
        pickers.new(opts, {
            prompt_title = prompt,
            finder = finders.new_table{
                results = items,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = label_fn(entry),
                        ordinal = label_fn(entry),
                    }
                end,
            },
            sorter = sorters.get_generic_fuzzy_sorter(),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = actions.get_selected_entry(prompt_bufnr)
                    actions.close(prompt_bufnr)

                    cb(selection.value)
                end)

                return true
            end,
        }):find()
    end

    jdtls.start_or_attach(config)
end

return M
