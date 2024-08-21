math.randomseed(os.time())

local uuid_metatable = {
    __tostring = function(value)
        return string.format("%x%x%x%x-%x%x-%x%x-%x%x-%x%x%x%x%x%x", unpack(value))
    end,
}

local function gen_uuid_v4()
    local value = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    for i in ipairs(value) do
        value[i] = math.random(0, 255)
    end

    -- version 4, variant 10
    value[7] = bit.bor(bit.band(value[7], 15), 64)
    value[9] = bit.bor(bit.band(value[9], 63), 128)

    return setmetatable(value, uuid_metatable)
end

-- generate a UUID
vim.api.nvim_create_user_command("UUID", function()
    local value = gen_uuid_v4()
    vim.api.nvim_put({ tostring(value) }, "c", true, true)
end, {
    nargs = 0,
    desc = "generate and insert a uuid into the current buffer",
})
