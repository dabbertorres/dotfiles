local test = require("neotest")

test.setup {
    adapters = {
        require("neotest-go"),
    },
    diagnostic = {
        enabled = true,
    },
    floating = {
        border = "rounded",
        max_height = 0.6,
        max_width = 0.6
    },
    highlights = {
        adapter_name = "NeotestAdapterName",
        border = "NeotestBorder",
        dir = "NeotestDir",
        expand_marker = "NeotestExpandMarker",
        failed = "NeotestFailed",
        file = "NeotestFile",
        focused = "NeotestFocused",
        indent = "NeotestIndent",
        namespace = "NeotestNamespace",
        passed = "NeotestPassed",
        running = "NeotestRunning",
        skipped = "NeotestSkipped",
        test = "NeotestTest"
    },
    icons = {
        child_indent = "│",
        child_prefix = "├",
        collapsed = "─",
        expanded = "╮",
        failed = "✖",
        final_child_indent = " ",
        final_child_prefix = "╰",
        non_collapsible = "─",
        passed = "✔",
        running = "🗘",
        skipped = "󰜺 ",
        unknown = "?"
    },
    output = {
        enabled = true,
        open_on_run = "short"
    },
    run = {
        enabled = true
    },
    status = {
        enabled = true
    },
    strategies = {
        integrated = {
            height = 40,
            width = 120
        }
    },
    summary = {
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            output = "o",
            run = "r",
            short = "O",
            stop = "u"
        }
    },
}

local function run_nearest_test(run)
    test.run.run {
        strategy = "integrated",
        extra_args = run.fargs,
    }
end

local function run_file_tests(run)
    test.run.run {
        vim.fn.expand("%"),
        strategy = "integrated",
        extra_args = run.fargs,
    }
end

local function run_all_tests(run)
    test.run.run {
        vim.fn.getcwd(),
        strategy = "integrated",
        extra_args = run.fargs,
    }
end

vim.api.nvim_create_user_command("Test", run_nearest_test, {
    desc = "Run the test nearest to the cursor.",
    nargs = "*",
})

vim.api.nvim_create_user_command("TestFile", run_file_tests, {
    desc = "Run all tests in the current file.",
    nargs = "*",
})

vim.api.nvim_create_user_command("TestAll", run_all_tests, {
    desc = "Run the test nearest to the cursor.",
    nargs = "*",
})

vim.api.nvim_create_user_command("TestStop", test.run.stop, {
    desc = "Stop running test(s).",
})
