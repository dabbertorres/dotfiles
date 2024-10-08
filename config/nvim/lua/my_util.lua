local uv = vim.uv

local M = {}

function M.filter(tbl, filter)
    local i = 1
    local new_len = #tbl
    while i <= new_len do
        if not filter(tbl[i], i) then
            tbl[i] = tbl[new_len]
            tbl[new_len] = nil
            new_len = new_len - 1
        else
            i = i + 1
        end
    end

    return tbl
end

function M.copy_with(source, add)
    local copy = vim.deepcopy(source)
    for k, v in pairs(add) do
        copy[k] = v
    end
    return copy
end

-- is_windows and dirname copied from lspconfig/util.lua

local is_windows = uv.os_uname().version:match 'Windows'

local function dirname(path)
    local strip_dir_pat = '/([^/]+)$'
    local strip_sep_pat = '/$'
    if not path or #path == 0 then
        return
    end
    local result = path:gsub(strip_sep_pat, ''):gsub(strip_dir_pat, '')
    if #result == 0 then
        if is_windows then
            return path:sub(1, 2):upper()
        else
            return '/'
        end
    end
    return result
end

function M.buffer_dir(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if uv.fs_stat(path) == "directory" then
        return path
    end
    return dirname(path)
end

function M.parent_dir(dir)
    local last_slash = dir:find("/[^/]*$")
    if last_slash == nil or last_slash == 1 then return "/" end

    return dir:sub(1, last_slash - 1)
end

function M.find_file(start_dir, pattern, load_callback)
    local matcher = nil
    if type(pattern) == "function" then
        matcher = pattern
    else
        matcher = function(name) return name:find(pattern) end
    end

    local found = false

    local function handle_entry(entry)
        local name, file_type = uv.fs_scandir_next(entry)
        if name == nil and file_type == nil then
            if found or start_dir == "/" then return end

            local parent = M.parent_dir(start_dir)
            M.find_file(parent, pattern, load_callback)
            return
        end

        if file_type == "file" and matcher(name) then
            local full_path = start_dir .. "/" .. name
            local is_json = name:find("%.json$") ~= nil
            M.load_file(full_path, function(ok, data)
                if ok then
                    load_callback(data, is_json, full_path)
                    found = true
                end

                handle_entry(entry)
            end)
        else
            handle_entry(entry)
        end
    end

    uv.fs_scandir(start_dir, function(err, entry)
        if err then
            print(err)
            return
        end

        handle_entry(entry)
    end)
end

function M.load_file(path, callback)
    uv.fs_lstat(path, function(err, stat)
        if err or stat.type ~= "file" then
            callback(false, nil)
            return
        end

        uv.fs_open(path, "r", 0400, function(err, fd)
            if err then
                callback(false, nil)
                return
            end

            uv.fs_read(fd, stat.size, 0, function(err, data)
                if err then
                    callback(false, nil)
                    return
                end

                uv.fs_close(fd, function(err)
                    if err then
                        callback(false, nil)
                        return
                    end

                    callback(true, data)
                end)
            end)
        end)
    end)
end

function M.get_visual_range()
    local vstart = vim.fn.getpos("'<")
    local vend = vim.fn.getpos("'>")

    local start_row = vstart[2] - 1
    local start_col = vstart[3] - 1
    local end_row = vend[2] - 1
    local end_col = vend[3] - 1

    return start_row, start_col, end_row, end_col
end

function M.replace_visual_range(bufnr, callback)
    local start_row, start_col, end_row, end_col = M.get_visual_range()

    local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
    local output = callback(text)

    vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, { output })
end

function M.replace_visual_range_or_word(bufnr, callback)
    local start_row, start_col, end_row, end_col = M.get_visual_range()

    local text = nil
    if end_row == 2147483647 then                     -- max signed 32-bit int; returned when no visual selection
        local current_word = vim.fn.expand("<cWORD>") -- cWORD instead of cword to take into account potential digit separators
        local curpos = vim.fn.getcurpos()
        local line_num = curpos[2] - 1
        local col_num = curpos[3] - 1

        local lines = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)
        if #lines == 0 then
            -- nothing to do
            return
        end

        -- find start and end of current word
        local word_start, word_end = string.find(lines[1], current_word, col_num + 1 - #current_word, true)

        text = current_word
        start_row = line_num
        start_col = word_start - 1
        end_row = line_num + 1
        end_col = word_end - 1
    else
        text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
    end

    local output = callback(text)
    if output == nil then
        vim.print("failed to replace text")
        return
    end

    vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, { output })
end

local function escape_json_text(text)
    local result = string.gsub(text, "([\"\\\b\f\n\r\t])", "\\%1")
    return result
end

function M.escape_json(text)
    if type(text) == "string" then
        return escape_json_text(text)
    elseif type(text) == "table" then
        local out = {}
        for _, line in ipairs(text) do
            table.insert(out, escape_json_text(line))
        end
        return table.concat(out, "\\n")
    end
end

function M.make_augroup(name, clear, ...)
    local id = vim.api.nvim_create_augroup(name, { clear = clear })

    for _, make_cmd in ipairs({ ... }) do
        local event, opts = make_cmd()
        opts.group = id
        vim.api.nvim_create_autocmd(event, opts)
    end
end

return M
