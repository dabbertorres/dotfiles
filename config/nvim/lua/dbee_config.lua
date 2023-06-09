local util = require("my_util")
local dbee = require("dbee")
local dbee_sources = require("dbee.sources")

local sources = {
    dbee_sources.EnvSource:new("DBEE_CONNECTIONS"),
    dbee_sources.FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
}

util.find_file(
    vim.loop.cwd(),
    function(name) return name:find("%.dbee.json$") end,
    function(_, _, path)
        table.insert(sources, dbee_sources.FileSource:new(path))
    end)

dbee.setup {
    lazy = true,
    sources = sources,
    ui = {
        -- Layout saving and restoring appears to be broken (2023-05-22), which is done in the default
        -- implementations of these functions. So, override them to do nothing.
        pre_open_hook = function()
        end,
        post_open_hook = function()
        end,
        post_close_hook = function()
        end,
    },
}

vim.api.nvim_create_user_command("DBOpen", dbee.open, {
    desc = "Open the dbee UI.",
})

vim.api.nvim_create_user_command("DBClose", dbee.close, {
    desc = "Close the dbee UI.",
})

vim.api.nvim_create_user_command("DBNext", dbee.next, {
    desc = "Go to next page of results.",
})

vim.api.nvim_create_user_command("DBPrev", dbee.prev, {
    desc = "Go to previous page of results.",
})

if not table.unpack then
    table.unpack = unpack
end

vim.api.nvim_create_user_command("DBExec",
    function(arg)
        local selected_text = vim.api.nvim_buf_get_lines(0, arg.line1 - 1, arg.line2, false)
        local query = table.concat(selected_text, " ")
        dbee.execute(query)
    end,
    {
        desc = "Execute a query.",
        range = "%",
        nargs = 0,
    })

vim.api.nvim_create_user_command("DBSave",
    function(arg)
        local format = nil
        local file = nil
        if arg.fargs == nil or #arg.fargs == 0 then
            file = "output.csv"
            format = "csv"
        else
            file = arg.fargs[1]
            _, _, format = string.find(file, "%.(.+)$")
            if format == nil or (format ~= "json" and format ~= "csv") then
                format = "csv"
            end
        end

        dbee.save(format, file)
    end,
    {
        desc = "Save results to a file.",
        nargs = "?",
    })
