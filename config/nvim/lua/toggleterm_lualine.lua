local highlight = require("lualine.highlight")
local toggleterm = require("toggleterm.terminal")

local function status_colors(options)
    local theme = require("lualine.themes." .. options.theme)

    return {
            active = highlight.create_component_highlight_group(
                theme.normal.b,
                "toggleterm_active",
                options,
                false),

            inactive = highlight.create_component_highlight_group(
                theme.normal.c,
                "toggleterm_inactive",
                options,
                false),
        }
end

local M = require("lualine.component"):extend()

function M:init(options)
    M.super.init(self, options)

    self.options = vim.tbl_deep_extend("keep", self.options or {}, {
        component_name = "toggleterm_status_" .. options.id,
    })

    if self.status_colors == nil then
        self.status_colors = status_colors(self.options)
    end
end

function M:update_status(is_focused)
     local term = toggleterm.get(self.options.id)

     local hl = nil
     if term ~= nil then
         if term:is_open() then
             hl = highlight.component_format_highlight(self.status_colors.active, is_focused)
         else
             hl = highlight.component_format_highlight(self.status_colors.inactive, is_focused)
         end
    else
        -- don't include unopened terminals
        return ""
    end

     return hl .. tostring(self.options.id % 10)
end

function M.terminal_icon()
    return "🖥"
end

return M
