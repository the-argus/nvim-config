local keymap = vim.keymap.set

keymap('n', 't', 'j')
keymap('n', 'n', 'k')
keymap('n', 's', 'l')

local normal_mappings = {
    t = { dvorak = 'j' },
    n = { dvorak = 'k' },
    s = { dvorak = 'l' }
}

local current_normal_mappings = vim.api.nvim_get_keymap('n')

local enable_dvorak = function()
    for _, key in ipairs(normal_mappings) do
        keymap('n', key, normal_mappings[key]['dvorak'])
    end
end

local disable_dvorak = function()
    for _, key in ipairs(normal_mappings) do
        vim.api.nvim_del_keymap('n', key)
    end
end

local print_table
print_table = function(table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            print(string.format("TABLE %s: ", key))
            print_table(value)
        else
            print(string.format("%s : %s", key, value))
        end
    end
end

local query_dvorak = function()
    print_table(current_normal_mappings)
    -- confirm all keymaps are set correctly
    for key, rebindings in pairs(normal_mappings) do
        print(string.format("mapping for %s: \n\tDVORAK: %s\n\tCURRENT: %s", key, rebindings.dvorak, current_normal_mappings[key]))
        if current_normal_mappings[key] ~= rebindings.dvorak then
            return false
        end
    end
    return true
end

local toggle_dvorak = function()
    local is_dvorak = query_dvorak()
    if is_dvorak then
        disable_dvorak()
    else
        enable_dvorak()
    end
end

return {
    disable_dvorak = disable_dvorak,
    enable_dvorak = enable_dvorak,
    query_dvorak = query_dvorak,
    toggle_dvorak = toggle_dvorak
}
