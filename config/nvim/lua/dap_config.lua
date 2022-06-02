--local profile_start_time = vim.loop.hrtime()

local dap = require("dap")
local dapui = require("dapui")
local dapgo = require("dap-go")
local dappy = require("dap-python")
local notifications = require("notifications")
--local dapvs = require("dap.ext.vscode")

local home = os.getenv("HOME")

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

dapgo.setup()
dappy.setup(home .. "/.python-venvs/debugpy/bin/python")
--dapvs.load_launchjs()

dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
dap.set_log_level("INFO")

vim.fn.sign_define("DapStopped",             { text = "➩",  texthl = "DiffAdd", linehl = "Cursor", numhl = "" })
vim.fn.sign_define("DapBreakpoint",          { text = "🛑", texthl = "",        linehl = "",       numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "❓", texthl = "",        linehl = "",       numhl = "" })
vim.fn.sign_define("DapLogPoint",            { text = "📜", texthl = "",        linehl = "",       numhl = "" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "❌", texthl = "",        linehl = "",       numhl = "" })

vim.keymap.set("n", "<F5>",  dap.continue,          { noremap = true, silent = true })
vim.keymap.set("n", "<F6>",  dap.terminate,         { noremap = true, silent = true })
vim.keymap.set("n", "<F7>",  dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set("n", "<F8>",  dap.continue,          { noremap = true, silent = true })
vim.keymap.set("n", "<F9>",  dap.step_over,         { noremap = true, silent = true })
vim.keymap.set("n", "<F10>", dap.step_into,         { noremap = true, silent = true })
vim.keymap.set("n", "<F11>", dap.step_out,          { noremap = true, silent = true })
vim.keymap.set("n", "mi",    dapui.eval,            { noremap = true, silent = true })

dapui.setup{
    icons = {
        expanded  = "▾",
        collapsed = "▸",
    },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open   = "o",
        remove = "d",
        edit   = "e",
        repl   = "r",
    },
    sidebar = {
        elements = {
          { id = "scopes",      size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks",      size = 0.25 },
          { id = "watches",     size = 0.25 },
        },
        size     = 40,
        position = "left", -- Can be "left", "right", "top", "bottom"
    },
    tray = {
        elements = { "repl" },
        size     = 10,
        position = "bottom", -- Can be "left", "right", "top", "bottom"
    },
    floating = {
        max_height = nil,
        max_width  = nil,
        border     = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
    },
    windows = {
        indent = 1,
    },
}

dap.listeners.before.event_progressStart["progress-notifications"] = function(session, body)
    local data = notifications.get("dap", body.progressId)

    local msg = notifications.format_message(body.message, body.percentage)
    local opts = notifications.init_spinner("dap", body.progressId, data, {
        title = notifications.format_title(body.title, session.config.type),
        timeout = false,
        hide_from_history = false,
    })

    data.notification = vim.notify(msg, "info", opts)
end

dap.listeners.before.event_progressUpdate["progress-notifications"] = function(_, body)
    local data = notifications.get("dap", body.progressId)
    local msg = notifications.format_message(body.message, body.percentage)
    data.notification = vim.notify(msg, "info", {
        replace = data.notification,
        hide_from_history = false,
    })
end

dap.listeners.before.event_progressEnd["progress-notifications"] = function(_, body)
    local data = notifications.get("dap", body.progressId)
    local msg = body.message and notifications.format_message(body.message) or "Complete"
    data.notification = vim.notify(msg, "info", {
        icon = "",
        replace = data.notification,
            timeout = 3000,
    })
    notifications.stop_spinner(data)
end

dap.listeners.before.event_initialized["dapui_config"] = function()
    dapui.open()
end

dap.listeners.after.event_terminated["dapui_config"] = function()
    dapui.close()
end

dap.listeners.after.event_exited["dapui_config"] = function()
    dapui.close()
end

--local profile_end_time = vim.loop.hrtime()
--print("compe_config.lua:", profile_end_time - profile_start_time)
