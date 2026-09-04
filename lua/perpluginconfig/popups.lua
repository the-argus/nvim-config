--- The purpose of this file is to make mini.files explorer and the telescope
--- popup mutually exclusive.

local mini_files_ok, mini_files = pcall(require, "mini.files")
local telescope_actions_ok, telescope_actions = pcall(require, "telescope.actions")

local unpack = unpack or table.unpack

local M = {}

--- Close mini.files file explorer if it is open
--- @return boolean closed whether the popup was open before the call to this
--- function
function M.close_mini_files()
    if not mini_files_ok then
        return false
    end
    local called, closed = pcall(mini_files.close)
    return called and closed == true
end

--- Close the telescope picker popup if one is open
--- @return boolean closed whether the popup was open before the call to this
--- function
function M.close_telescope()
    if not telescope_actions_ok then
        return false
    end

    -- find all telescope popups
    local prompts = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "TelescopePrompt" then
            prompts[#prompts + 1] = buf
        end
    end

    local closed = false
    for _, buf in ipairs(prompts) do
        if vim.api.nvim_buf_is_valid(buf) then
            closed = pcall(telescope_actions.close, buf) or closed
        end
    end
    return closed
end

--- Accepts a function and returns a function which is the same except it closes
--- mini.files first. If mini.files was open and is now closed, it waits to the
--- next frame to actually call the function, since telescope can only be
--- opened from a normal window
function M.wrap_telescope_popup(open)
    return function(...)
        local args = { ... }
        if M.close_mini_files() then
            vim.schedule(function()
                open(unpack(args))
            end)
        else
            open(unpack(args))
        end
    end
end

return M
