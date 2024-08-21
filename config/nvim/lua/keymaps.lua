-- easy align
vim.keymap.set({ "n", "x" }, "ga", "<Plug>(EasyAlign)", {
    desc = "Invoke vim-easy-align",
})

-- navigate buffers
vim.keymap.set("n", "gb", "<Cmd>bp<CR>", {
    desc = "switch to previous buffer",
    silent = true,
})

vim.keymap.set("n", "gB", "<Cmd>bn<CR>", {
    desc = "switch to next buffer",
    silent = true,
})

-- move tabs around
vim.keymap.set("n", "ght", "<Cmd>-tabmove<CR>", {
    desc = "move tab left",
    silent = true,
})

vim.keymap.set("n", "glt", "<Cmd>+tabmove<CR>", {
    desc = "move tab right",
    silent = true,
})
