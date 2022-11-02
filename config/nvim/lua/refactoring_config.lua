local refactoring = require("refactoring")

refactoring.setup {
    prompt_func_return_type = {
        c = true,
        cpp = true,
        cxx = true,
        go = true,
        h = true,
        hpp = true,
        java = true,
        js = true,
        python = true,
        ruby = true,
        ts = true,
    },
    prompt_func_param_type = {
        c = true,
        cpp = true,
        cxx = true,
        go = true,
        h = true,
        hpp = true,
        java = true,
        js = true,
        python = true,
        ruby = true,
        ts = true,
    },
    printf_statements = {},
    print_var_statements = {},
}

-- require("telescope").load_extension("refactoring")

vim.keymap.set("v", "<leader>rr", function()
    refactoring.select_refactor()
end, {
    silent = true,
    noremap = true,
})
