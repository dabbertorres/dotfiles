--local profile_start_time = vim.loop.hrtime()

local dap = require("dap")
local dapui = require("dapui")
local dapgo = require("dap-go")
local dappy = require("dap-python")
local notifications = require("notifications")
local dapvs = require("dap.ext.vscode")

local home = os.getenv("HOME")

local function pick_executable()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    return coroutine.create(function(coro)
        local opts = {}
        pickers.new(opts, {
            prompt_title = "Path to executable",
            finder = finders.new_oneshot_job({ "fd", "--hidden", "--no-ignore", "--type", "x" }, {}),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(buffer_number)
                actions.select_default:replace(function()
                    actions.close(buffer_number)
                    coroutine.resume(coro, action_state.get_selected_entry()[1])
                end)
                return true
            end,
        })
            :find()
    end)
    -- return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

dap.adapters.kotlin = {
    type    = "executable",
    command = home .. "/Code/lsps/kotlin-debug-adapter/adapter/build/install/adapter/bin/kotlin-debug-adapter",
    options = {
        env = {
            JAVA_HOME = "/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home",
        },
        cwd = home .. "/Code/lsps/kotlin-debug-adapter/adapter/build/install/adapter"
    },
}

dap.adapters.gdb = {
    type = "executable",
    name = "gdb",
    command = "gdb", --does this need be absolute?
    args = { "-i", "dap" },
}

dap.adapters.lldb = {
    type = "executable",
    name = "lldb",
    command = "/usr/local/opt/llvm/bin/lldb-dap", -- can this be not absolute?
}

dap.configurations.cpp = {
    {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = pick_executable,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
    },
}

dapgo.setup()
dappy.setup(home .. "/.python-venvs/debugpy/bin/python")
dapvs.load_launchjs()

dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
dap.set_log_level("INFO")

vim.fn.sign_define("DapStopped", { text = "➩", texthl = "DiffAdd", linehl = "Cursor", numhl = "" })
vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "❓", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "📜", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "❌", texthl = "", linehl = "", numhl = "" })

local keymap_opts = { noremap = true, silent = true }

vim.keymap.set("n", "<F5>", dap.continue, keymap_opts)
vim.keymap.set("n", "<F6>", dap.terminate, keymap_opts)
vim.keymap.set("n", "<F7>", dap.toggle_breakpoint, keymap_opts)
vim.keymap.set("n", "<F8>", dap.continue, keymap_opts)
vim.keymap.set("n", "<F9>", dap.step_over, keymap_opts)
vim.keymap.set("n", "<F10>", dap.step_into, keymap_opts)
vim.keymap.set("n", "<F11>", dap.step_out, keymap_opts)
vim.keymap.set({ "n", "v" }, "<leader>de", dapui.eval, keymap_opts)
vim.keymap.set("n", "<leader>du", dap.up, keymap_opts)
vim.keymap.set("n", "<leader>dd", dap.down, keymap_opts)
vim.keymap.set("n", "<leader>dr", dap.run_to_cursor, keymap_opts)

-- hide annoying dap-repl buffer on startup when not used
-- NOTE: this needs to be defined before dapui.setup() is called
vim.api.nvim_create_autocmd("FileType", {
    pattern = "dap-repl",
    callback = function(args)
        vim.api.nvim_buf_set_option(args.buf, "buflisted", false)
    end,
})

dapui.setup {
    controls = {
        element = "repl",
        enabled = true,
        icons = {
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = ""
        },
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
        max_height = nil,
        max_width  = nil,
        border     = "single",
        mappings   = {
            close = { "q", "<Esc>" },
        },
    },
    icons = {
        collapsed = "",
        current_frame = "",
        expanded = ""
    },
    layouts = {
        {
            elements = {
                { id = 'scopes',      size = 0.25 },
                { id = 'breakpoints', size = 0.25 },
                { id = 'stacks',      size = 0.25 },
                { id = 'watches',     size = 0.25 },
            },
            size = 40,
            position = 'left',
        },
        {
            elements = {
                { id = 'repl',    size = 0.5 },
                { id = 'console', size = 0.5 },
            },
            size = 10,
            position = 'bottom',
        },
    },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open   = "o",
        remove = "d",
        edit   = "e",
        repl   = "r",
    },
    render = {
        indent = 1,
        max_value_lines = 100,
    },
}

dap.listeners.after.event_progressStart["progress-notifications"] = function(session, body)
    local data = notifications.get("dap", body.progressId)

    local msg = notifications.format_message(body.message, body.percentage)
    local opts = notifications.init_spinner("dap", body.progressId, data, {
        title = notifications.format_title(body.title, session.config.type),
        timeout = false,
        hide_from_history = false,
    })

    data.notification = vim.notify(msg, "info", opts)
end

dap.listeners.after.event_progressUpdate["progress-notifications"] = function(_, body)
    local data = notifications.get("dap", body.progressId)
    local msg = notifications.format_message(body.message, body.percentage)
    data.notification = vim.notify(msg, "info", {
        replace = data.notification,
        hide_from_history = false,
    })
end

dap.listeners.after.event_progressEnd["progress-notifications"] = function(_, body)
    local data = notifications.get("dap", body.progressId)
    local msg = body.message and notifications.format_message(body.message) or "Complete"
    data.notification = vim.notify(msg, "info", {
        icon = "",
        replace = data.notification,
        timeout = 3000,
    })
    notifications.stop_spinner(data)
end

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

--local profile_end_time = vim.loop.hrtime()
--print("compe_config.lua:", profile_end_time - profile_start_time)
