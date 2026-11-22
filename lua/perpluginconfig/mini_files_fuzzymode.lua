-- this module tries to add something like telescope-file-browser to
-- mini.files, where the default behavior is that you type the name of the file
-- you want, and then pressing escape takes you to normal mode and then press i
-- to start editing. And press / to return to the fuzzy search
--
-- Ctrl + hjkl can be used to navigate while in the fuzzy mode
local files_ok, files = pcall(require, "mini.files")
if not files_ok then
    return;
end

-- this is a table of all the keys which are valid to use in search, basically
-- ascii chars, we create a keybinding for each one...
-- TODO: figure out how to do text input without creating a mapping for every
-- key...
local search_keys = {}
for byte = 33, 126 do
    table.insert(search_keys, string.char(byte))
end

-- get the lines (files/directories) of the current buffer (folder) as a table
local function get_filesystem_entries(buf)
    local result = {}
    for line = 1, vim.api.nvim_buf_line_count(buf) do
        local entry = files.get_fs_entry(buf, line)
        if entry then
            table.insert(result, { name = entry.name, line = line })
        end
    end
    return result
end

--- returns a list of sorted matches against the pattern from best to worst match
local function get_matches_for_pattern(buf, pattern)
    local all_filesystem_entries = get_filesystem_entries(buf)
    if pattern == "" then
        return all_filesystem_entries
    end
    local entry_line_numbers, entry_names = {}, {}
    for _, entry in ipairs(all_filesystem_entries) do
        entry_line_numbers[entry.name] = entry.line
        table.insert(entry_names, entry.name)
    end
    local result = {}
    for _, name in ipairs(vim.fn.matchfuzzy(entry_names, pattern)) do
        table.insert(result, { name = name, line = entry_line_numbers[name] })
    end
    return result
end

--- show the current search pattern at the bottom of the buffer
local function display_pattern(pattern, has_match)
    local chunks = { { "search ", "Question" } }
    table.insert(chunks, has_match and { pattern } or { pattern, "ErrorMsg" })
    vim.api.nvim_echo(chunks, false, {})
end

local function clear_pattern_display()
    vim.api.nvim_echo({ { "" } }, false, {})
end

-- move the cursor to the best match for pattern and display the result
local function goto_match(match, pattern)
    if match then
        vim.api.nvim_win_set_cursor(0, { match.line, 0 })
    end
    display_pattern(pattern, match ~= nil)
end

local function store_search_pattern(buf, pattern)
    vim.b[buf].minifiles_search_pattern = pattern
    goto_match(get_matches_for_pattern(buf, pattern)[1], pattern)
end

-- move up or down in the list of fuzzy matches
local function cycle_through_matches(buf, step)
    local pattern = vim.b[buf].minifiles_search_pattern
    local found = get_matches_for_pattern(buf, pattern)
    if #found == 0 then
        display_pattern(pattern, false)
        return
    end
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local index = 0
    for i, match in ipairs(found) do
        if match.line == cursor_line then
            index = i
        end
    end
    if index == 0 then
        index = step > 0 and 0 or 1
    end
    goto_match(found[((index - 1 + step) % #found) + 1], pattern)
end

--- we stash key mappings when overriding stuff for the custom fuzzy mode so we
--- can restore them when exiting
--- @type table<integer, table<string, table|false>>
local not_fuzzymode_mappings = {}

local function override_mapping(buf, key, fn, desc)
    local replaced = not_fuzzymode_mappings[buf]
    if replaced[key] == nil then
        local existing = vim.api.nvim_buf_call(buf, function()
            return vim.fn.maparg(key, "n", false, true)
        end)
        replaced[key] = existing.buffer == 1 and existing or false
    end
    vim.keymap.set("n", key, fn, { buffer = buf, desc = desc })
end

local function restore_mappings(buf)
    for key, mapping in pairs(not_fuzzymode_mappings[buf] or {}) do
        pcall(vim.keymap.del, "n", key, { buffer = buf })
        if mapping then
            vim.api.nvim_buf_call(buf, function() vim.fn.mapset("n", false, mapping) end)
        end
    end
    not_fuzzymode_mappings[buf] = nil
end

-- there are forward declarations in lua, apparently
local start_search

local function stop_search(buf)
    if vim.b[buf].minifiles_search_pattern == nil then
        return
    end
    vim.b[buf].minifiles_search_pattern = nil
    restore_mappings(buf)
    clear_pattern_display()
    -- once out of fuzzy search, we want to bind / in this buffer to go back to it
    vim.keymap.set("n", "/", function() start_search(buf) end,
        { buffer = buf, desc = "Fuzzy search this directory" })
end

-- start the fuzzy files mode and bind keys for navigating through the fuzzy
-- matches
function start_search(buf)
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "minifiles" then
        return
    end
    if vim.b[buf].minifiles_search_pattern ~= nil then
        -- if moving from one buffer where we were patterning to another, restart
        -- the search
        return store_search_pattern(buf, "")
    end
    not_fuzzymode_mappings[buf] = {}
    local map = function(key, fn, desc)
        override_mapping(buf, key, fn, desc)
    end
    for _, key in ipairs(search_keys) do
        map(key, function() store_search_pattern(buf, vim.b[buf].minifiles_search_pattern .. key) end,
            "Add to fuzzy search")
    end
    map("<BS>", function() store_search_pattern(buf, vim.b[buf].minifiles_search_pattern:sub(1, -2)) end,
        "Backspace in the search")
    map("<Esc>", function() stop_search(buf) end, "Leave fuzzy search")
    map("<C-n>", function() cycle_through_matches(buf, 1) end, "Next fuzzy match")
    map("<C-p>", function() cycle_through_matches(buf, -1) end, "Previous fuzzy match")
    store_search_pattern(buf, "")
end

-- move one entry up or down, works the same whether searching or not
local function move_cursor(buf, direction)
    local line = vim.api.nvim_win_get_cursor(0)[1] + direction
    line = math.min(math.max(line, 1), vim.api.nvim_buf_line_count(buf))
    vim.api.nvim_win_set_cursor(0, { line, 0 })
end

local function go_in()
    files.go_in({ close_on_file = true })
end

local function go_out(buf)
    local was_searching = vim.b[buf].minifiles_search_pattern ~= nil
    files.go_out()
    if was_searching then
        -- no BufEnter happens when going out so the search has to be restarted
        -- by hand. Doesn't make sense at the root of the filesystem, but that
        -- does not usually happen
        vim.schedule(function() start_search(vim.api.nvim_get_current_buf()) end)
    end
end

local function map_navigation(buf)
    local navigation = {
        ["<C-j>"] = { function() move_cursor(buf, 1) end, "Next entry" },
        ["<C-k>"] = { function() move_cursor(buf, -1) end, "Previous entry" },
        ["<C-l>"] = { go_in, "Go in" },
        ["<C-h>"] = { function() go_out(buf) end, "Go out" },
    }
    for key, action in pairs(navigation) do
        local fn, desc = action[1], action[2]
        vim.keymap.set({ "n", "x" }, key, fn, { buffer = buf, desc = desc })
        vim.keymap.set("i", key, fn, { buffer = buf, desc = desc })
    end
end

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        local buf = args.data.buf_id
        -- always restart search when going into a new directory
        vim.api.nvim_create_autocmd("BufEnter", {
            buffer = buf,
            callback = function()
                -- this might be an unfocused buffer in which case don't start
                -- the search
                if vim.api.nvim_get_current_buf() == buf then
                    start_search(buf)
                end
            end,
        })
        vim.api.nvim_create_autocmd("BufWipeout", {
            buffer = buf,
            callback = function() not_fuzzymode_mappings[buf] = nil end,
        })
        vim.keymap.set("n", "/", function() start_search(buf) end,
            { buffer = buf, desc = "Fuzzy search this directory" })
        map_navigation(buf)
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesExplorerClose",
    callback = clear_pattern_display,
})
