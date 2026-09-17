local present, precognition = pcall(require, "precognition")
if not present then
    return
end

--- AlwaysOff: no precognition
--- PartialOn: on when an operator is pending
--- AlwaysOn: always on in normal and visual modes
local states = { "AlwaysOff", "PartialOn", "AlwaysOn" }
local state = "PartialOn"

precognition.setup({ startVisible = false })

local group = vim.api.nvim_create_augroup("UserPrecognition", { clear = true })

--- no, nov, noV, no^V are all operator pending modes
local function operator_pending()
    return vim.startswith(vim.api.nvim_get_mode().mode, "no")
end

--- update precognition to match the value of the state variable
local function refresh()
    local want = state == "AlwaysOn" or (state == "PartialOn" and operator_pending())
    if want == precognition.is_visible() then
        return
    end
    if want then
        precognition.show()
    else
        precognition.hide()
    end
end

vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = refresh,
})

local function set_state(new_state)
    state = new_state
    refresh()
end

-- make a usercommand that sets the state, like PrecognitionSetAlwaysOn,
-- PrecognitionSetAlwaysOff, PrecognitionSetPartialOn
for _, name in ipairs(states) do
    vim.api.nvim_create_user_command("PrecognitionSet" .. name, function()
        set_state(name)
    end, { desc = "Set precognition hints to " .. name })
end

-- debug which state is current
vim.api.nvim_create_user_command("PrecognitionState", function()
    vim.notify("Precognition: " .. state)
end, { desc = "Report which precognition state is active" })

-- <Leader>pp to toggle between on all the time, or on during operator pending
-- mode only. But PrecognitionSetAlwaysOff is there to get to the mode where it
-- is always disabled
vim.keymap.set("n", "<Leader>pp", function()
    set_state(state == "PartialOn" and "AlwaysOn" or "PartialOn")
    vim.notify("Precognition: " .. state)
end, { desc = "Toggle inline motion hints between operator-pending only and always", silent = true })
