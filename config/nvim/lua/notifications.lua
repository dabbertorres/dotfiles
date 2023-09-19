local notify = require("notify")

notify.setup {
    level = vim.log.levels.INFO,
    timeout = 5000,
    background_color = "#000000",
}

vim.notify = notify.notify

local M = {}

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
    local data = M.get(client_id, token)
    if data == nil then return end

    if data.spinner then
        local new_spinner = (data.spinner + 1) % #spinner_frames
        data.spinner = new_spinner

        data.notification = vim.notify(nil, nil, {
            hide_from_history = true,
            icon = spinner_frames[new_spinner],
            replace = data.notification,
        })

        vim.defer_fn(function() update_spinner(client_id, token) end, 100)
    end
end

local client_notifications = {}

function M.get(client_id, token)
    if not client_notifications[client_id] then
        client_notifications[client_id] = {}
    end

    if not client_notifications[client_id][token] then
        client_notifications[client_id][token] = { spinner = 1 }
    end

    local data = client_notifications[client_id][token]
    if data.spinner == nil then return nil end
    return data
end

function M.delete(client_id, token)
    if not client_notifications[client_id] then return end
    client_notifications[client_id][token] = nil
end

function M.init_spinner(client_id, token, message, notify_opts)
    local data = M.get(client_id, token)
    if data == nil then return end

    if notify_opts == nil then notify_opts = {} end

    notify_opts.icon = spinner_frames[1]
    notify_opts.timeout = false
    notify_opts.hide_from_history = false

    data.notification = vim.notify(message, vim.log.levels.INFO, notify_opts)
    data.spinner = 1

    update_spinner(client_id, token)
end

function M.update_spinner(client_id, token, message, notify_opts)
    local data = M.get(client_id, token)
    if data == nil then return end

    if notify_opts == nil then notify_opts = {} end

    notify_opts.replace = data.notification
    notify_opts.hide_from_history = false

    data.notification = vim.notify(message, vim.log.levels.INFO, notify_opts)
end

function M.stop_spinner(client_id, token, message, notify_opts)
    local data = M.get(client_id, token)
    if data == nil then return end

    if notify_opts == nil then notify_opts = {} end

    notify_opts.icon = ""
    notify_opts.replace = data.notification
    notify_opts.timeout = 3000
    notify_opts.on_close = function() M.delete(client_id, token) end

    data.notification = vim.notify(message, vim.log.levels.INFO, notify_opts)
    data.spinner = nil
end

function M.format_title(title, client_name)
    return client_name .. (title and #title > 0 and ": " .. title or "")
end

function M.format_message(message, percentage)
    return (percentage and percentage .. "%\t" or "") .. (message or "")
end

return M
