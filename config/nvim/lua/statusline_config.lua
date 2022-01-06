--local profile_start_time = vim.loop.hrtime()

local builtin = require('el.builtin')
local extensions = require('el.extensions')
local subscribe = require('el.subscribe')
local sections = require('el.sections')
local helper = require('el.helper')

local function generator()
    return {
        extensions.mode,
        extensions.git_changes,
        extensions.git_branch,
        function(window, buffer) return "" end,
        "%y %m %l/%L",
    }
end

require("el").setup{
    generator = generator,
}

--local profile_end_time = vim.loop.hrtime()
--print("lsp_config.lua:", profile_end_time - profile_start_time)
