--local profile_start_time = vim.loop.hrtime()

local dap = require("dap")
local dapui = require("dapui")
local dapgo = require("dap-go")
local dappy = require("dap-python")

dap.defaults.fallback.terminal_win_cmd = '50vsplit new'

dap.adapters.kotlin = {
    type = "executable",
    command = os.getenv("HOME") .. "/Code/lsps/kotlin-debug-adapter/adapter/build/install/adapter/bin/kotlin-debug-adapter",
    options = {
        env = {
            JAVA_HOME = "/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home",
        },
        cwd = os.getenv("HOME") .. "/Code/lsps/kotlin-debug-adapter/adapter/build/install/adapter"
    },
}

dap.set_log_level("TRACE")

--require("dap.ext.vscode").load_launchjs()

vim.fn.sign_define("DapStopped", {text="➩", texthl="", linehl="debugPC", numhl=""})
vim.fn.sign_define("DapBreakpoint", {text="🛑", texthl="", linehl="", numhl=""})
vim.fn.sign_define("DapLogPoint", {text="ℹ", texthl="", linehl="", numhl=""})
vim.fn.sign_define("DapBreakpointRejected", {text="❌", texthl="", linehl="", numhl=""})

vim.api.nvim_set_keymap("n", "<F7>", ":lua require('dap').toggle_breakpoint()<CR>", {noremap = true, silent=true})
vim.api.nvim_set_keymap("n", "<F8>", ":lua require('dap').continue()<CR>", {noremap = true, silent=true})
vim.api.nvim_set_keymap("n", "<F9>", ":lua require('dap').step_over()<CR>", {noremap = true, silent=true})
vim.api.nvim_set_keymap("n", "<F10>", ":lua require('dap').step_into()<CR>", {noremap = true, silent=true})
vim.api.nvim_set_keymap("n", "<F11>", ":lua require('dap').step_out()<CR>", {noremap = true, silent=true})
vim.api.nvim_set_keymap("n", "mi", ":lua require('dapui').eval()<CR>", {noremap = true, silent=true})

dapui.setup{
    icons = {
        expanded = "▾",
        collapsed = "▸",
    },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
    },
    sidebar = {
        elements = {
          { id = "scopes", size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 40,
        position = "left", -- Can be "left", "right", "top", "bottom"
    },
    tray = {
        elements = { "repl" },
        size = 10,
        position = "bottom", -- Can be "left", "right", "top", "bottom"
    },
    floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
    },
    windows = {
        indent = 1,
    },
}

dapgo.setup()
dappy.setup(os.getenv("HOME") .. "/.python-venvs/debugpy/bin/python")

-- TODO call function that calls the right thing based off the filetype.
vim.api.nvim_set_keymap("n", "mdt", ":lua require('dap-go').debug_test()<CR>", {noremap = true, silent=true})

--local profile_end_time = vim.loop.hrtime()
--print("compe_config.lua:", profile_end_time - profile_start_time)
