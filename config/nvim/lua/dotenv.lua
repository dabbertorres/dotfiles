local util = require("my_util")

local M = {}

-- loads the first .env (or .env.json) file found in the directory tree starting from your current directory.

local function iterate_json(parent_path, object, key_value_callback)
    if parent_path then
        parent_path = parent_path .. "."
    else
        parent_path = ""
    end

    for k, v in pairs(object) do
        local key = parent_path .. k

        local type = type(v)
        if type == "table" then
            iterate_json(key, v, key_value_callback)
        elseif type == "nil" or type == "thread" or type == "function" or type == "userdata" then
            -- do nothing
        else
            key_value_callback(key, v)
        end
    end
end

local function load_data(data, is_json, key_value_callback)
    if is_json then
        local object = vim.json.decode(data, { luanil = { object = true, array = true } })
        iterate_json(nil, object, key_value_callback)
        return
    end

    local lines = vim.split(data, "\n", { plain = true, trimempty = true })
    for _, line in pairs(lines) do
        line = vim.trim(line)

        if line == "" or vim.startswith(line, "#") then
            goto continue
        end

        local eq_idx = line:find("=", 1, true)
        if eq_idx ~= nil then
            local key = vim.trim(line:sub(1, eq_idx - 1))
            if key ~= "" then
                local val = vim.trim(line:sub(eq_idx + 1))

                local val_start = 1
                local val_end = #val
                if val[val_start] == '"' then val_start = val_start + 1 end
                if val[val_end] == '"' then val_end = val_end - 1 end
                val = val:sub(val_start, val_end)

                key_value_callback(key, val)
            end
        end

        ::continue::
    end
end

local function find_and_load_dotenv()
    util.find_file(
        vim.loop.cwd(),
        function(name) return name:find("%.env$") or name:find("%.env%.json$") end,
        function(data, is_json, path)
            vim.schedule(function()
                local total = 0
                load_data(data, is_json, function(key, val)
                    vim.env[key] = val
                    total = total + 1
                end)

                vim.notify("loaded " .. tostring(total) .. " variables from " .. path,
                    vim.log.levels.INFO,
                    { title = "dotenv" })
            end)
        end)
end

M.setup = function()
    local group = vim.api.nvim_create_augroup("Dotenv", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        pattern = "*",
        callback = find_and_load_dotenv,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.env",
        callback = find_and_load_dotenv,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.env.json",
        callback = find_and_load_dotenv,
    })
end

return M
