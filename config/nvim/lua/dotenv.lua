local plenary = require("plenary")

local M = {}

-- loads a .env file starting at your current directory, or by searching up the directory tree.

local function load_file(path, callback)
    vim.loop.fs_lstat(path, function(err, stat)
        if err or stat.type ~= "file" then return callback(false, nil) end
        -- assert(not err, err)
        -- assert(, "not a regular file")

        vim.loop.fs_open(path, "r", 0400, function(err, fd)
            if err then return callback(false, nil) end

            vim.loop.fs_read(fd, stat.size, 0, function(err, data)
                if err then return callback(false, nil) end

                vim.loop.fs_close(fd, function(err)
                    if err then return callback(false, nil) end
                    return callback(true, data)
                end)
            end)
        end)
    end)
end

local function load_data(data, key_value_callback)
    local lines = vim.split(data, "\n", { plain = true, trimempty = true })
    for _, line in pairs(lines) do
        line = vim.trim(line)

        if line == "" or vim.startswith(line, "#") then
            goto continue
        end

        local eq_idx = string.find(line, "=", 1, true)
        if eq_idx ~= nil then
            local key = vim.trim(string.sub(line, 1, eq_idx - 1))
            if key ~= "" then
                local val = vim.trim(string.sub(line, eq_idx + 1))

                local val_start = 1
                local val_end = #val
                if val[val_start] == '"' then val_start = val_start + 1 end
                if val[val_end] == '"' then val_end = val_end - 1 end
                val = string.sub(val, val_start, val_end)

                key_value_callback(key, val)
            end
        end

        ::continue::
    end
end

local function parent_dir(dir)
    local last_slash = string.find(dir, "/[^/]*$")
    if last_slash == nil then return "/" end

    return string.sub(dir, 1, last_slash - 1)
end

local function find_dotenv(start_dir, callback)
    load_file(start_dir .. "/.env", function(ok, data)
        if ok then
            callback(true, data, start_dir)
            return
        end

        if start_dir == "" then
            callback(false, nil, nil)
            return
        end

        local parent = parent_dir(start_dir)
        find_dotenv(parent, callback)
    end)
end

local function find_and_load_dotenv()
    find_dotenv(vim.loop.cwd(), function(ok, data, path)
        if not ok then
            return
        end

        vim.schedule(function()
            local total = 0
            load_data(data, function(key, val)
                vim.env[key] = val
                total = total + 1
            end)

            vim.notify("loaded " .. tostring(total) .. " variables from " .. path,
                vim.log.levels.INFO,
                { title = "dotenv" })
            -- M.loaded = true
        end)
    end)
end

-- TODO: watch the .env file for changes?

-- M.loaded = false
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
end

return M
