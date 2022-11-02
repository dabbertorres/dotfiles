local uv = vim.loop

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

return M
