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

local keymap_opts = { noremap = true, silent = true }

vim.keymap.set("n",          "<F5>",       dap.continue,          keymap_opts)
vim.keymap.set("n",          "<F6>",       dap.terminate,         keymap_opts)
vim.keymap.set("n",          "<F7>",       dap.toggle_breakpoint, keymap_opts)
vim.keymap.set("n",          "<F8>",       dap.continue,          keymap_opts)
vim.keymap.set("n",          "<F9>",       dap.step_over,         keymap_opts)
vim.keymap.set("n",          "<F10>",      dap.step_into,         keymap_opts)
vim.keymap.set("n",          "<F11>",      dap.step_out,          keymap_opts)
vim.keymap.set({ "n", "v" }, "<leader>de", dapui.eval,            keymap_opts)
vim.keymap.set("n",          "<leader>du", dap.up,                keymap_opts)
vim.keymap.set("n",          "<leader>dd", dap.down,              keymap_opts)
vim.keymap.set("n",          "<leader>dr", dap.run_to_cursor,     keymap_opts)

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
    expand_lines = true,
    layouts = {
      {
        elements = {
          'scopes',
          'breakpoints',
          'stacks',
          'watches',
        },
        size = 40,
        position = 'left',
      },
      {
        elements = {
          'repl',
          'console',
        },
        size = 10,
        position = 'bottom',
      },
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
