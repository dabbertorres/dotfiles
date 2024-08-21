local util = require("my_util")

-- lazy
vim.api.nvim_create_user_command("Qa", "qa", {
    nargs = 0,
    desc = "qa, but if I'm still holding shift for some reason",
})

-- exit remote session (and leave the server running)
vim.api.nvim_create_user_command("Qr", function()
    local uis = vim.api.nvim_list_uis()
    for _, ui in ipairs(uis) do
        if ui.chan and not ui.stdin_tty and not ui.stdout_tty then
            vim.fn.chanclose(ui.chan)
        end
    end
end, {
    nargs = 0,
    desc = "quit a remote session",
})

vim.api.nvim_create_user_command("EscapeJSON", function(opts)
    util.replace_visual_range(0, function(text)
        local output = util.escape_json(text)
        if opts.args == "q" or opts.args == "quote" then
            output = "\"" .. output .. "\""
        end
        return output
    end)
end, {
    desc = "Escape some text for use as as JSON string.",
    nargs = "?",
    range = true,
})

local function convert_number(text, format)
    if string.find(text, ".", 1, true) ~= nil then return nil end

    local num = tonumber(text)
    if num == nil then return nil end

    return string.format(format, num)
end

local function number_conversion(format)
    return function(text)
        if type(text) == "table" and #text == 1 then
            text = text[1]
        else
            return nil
        end

        return convert_number(text, format)
    end
end

vim.api.nvim_create_user_command("ToDec", function()
    util.replace_visual_range_or_word(0, number_conversion("%d"))
end, {
    desc = "Convert a number via visual selection or under the cursor to hexadecimal.",
    nargs = 0,
    range = true,
})

vim.api.nvim_create_user_command("ToHex", function()
    util.replace_visual_range_or_word(0, number_conversion("%#x"))
end, {
    desc = "Convert a number via visual selection or under the cursor to hexadecimal.",
    nargs = 0,
    range = true,
})

vim.api.nvim_create_user_command("ToOct", function()
    util.replace_visual_range_or_word(0, number_conversion("%#o"))
end, {
    desc = "Convert a number via visual selection or under the cursor to hexadecimal.",
    nargs = 0,
    range = true,
})
