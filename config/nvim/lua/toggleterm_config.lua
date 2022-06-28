local toggleterm = require("toggleterm")
local terminals = require("toggleterm.terminal")

-- local function on_open(terminal)
--     local keymap_opts = {
--         buffer = terminal.bufnr,
--         remap = false,
--     }
-- end

toggleterm.setup{
    -- on_open = on_open,
    -- open_mapping = [[<C-\>]],
    hide_numbers = true,
    shade_terminals = true,
    start_in_insert = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    float_opts = {
        border = "single",
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.9),
    },
}

local function toggle(i)
    return function()
        local this = terminals.get(i)
        if this ~= nil and this:is_open() then
            this:close()
            return
        end

        local all = terminals.get_all(false)

        for _, t in ipairs(all) do
            if t.id ~= i then
                t:close()
            end
        end

        toggleterm.toggle(i)
    end
end

vim.keymap.set({ "n", "t" }, "<C-n>", toggle(1), {
    remap = false,
})

for i = 1, 10, 1 do
    vim.keymap.set({ "n", "t" }, "<C-Space>" .. (i % 10), toggle(i), {
        remap = false,
    })
end
