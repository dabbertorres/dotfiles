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

return M
