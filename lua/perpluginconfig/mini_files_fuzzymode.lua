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

local search_keys = {}
for byte = 33, 126 do
    table.insert(search_keys, string.char(byte))
end

-- get the lines (files/directories) of the current buffer (folder) as a table,
-- so it can be searched with the fuzzy algorithm
local function entries(buf)
    local result = {}
    for line = 1, vim.api.nvim_buf_line_count(buf) do
        local entry = files.get_fs_entry(buf, line)
        if entry then
            table.insert(result, { name = entry.name, line = line })
        end
    end
    return result
end

-- use vim.fn.matchfuzzy to search through the result of entries(). returns
-- all matches sorted by closeness to match
local function matches(buf, query)
    local all = entries(buf)
    if query == "" then
        return all
    end
    local line_of, names = {}, {}
    for _, entry in ipairs(all) do
        line_of[entry.name] = entry.line
        table.insert(names, entry.name)
    end
    local result = {}
    for _, name in ipairs(vim.fn.matchfuzzy(names, query)) do
        table.insert(result, { name = name, line = line_of[name] })
    end
    return result
end

local function show_query(query, has_match)
    local chunks = { { "search ", "Question" } }
    table.insert(chunks, has_match and { query } or { query, "ErrorMsg" })
    vim.api.nvim_echo(chunks, false, {})
end

local function clear_query_display()
    vim.api.nvim_echo({ { "" } }, false, {})
end

-- move the cursor to the best match and report the results of search
local function goto_match(buf, match, query)
    if match then
        vim.api.nvim_win_set_cursor(0, { match.line, 0 })
    end
    show_query(query, match ~= nil)
end

local function set_query(buf, query)
    vim.b[buf].minifiles_query = query
    goto_match(buf, matches(buf, query)[1], query)
end

-- move up or down in the list of fuzzy matches, not in the files on the screen
local function cycle(buf, step)
    local query = vim.b[buf].minifiles_query
    local found = matches(buf, query)
    if #found == 0 then
        return show_query(query, false)
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
    goto_match(buf, found[((index - 1 + step) % #found) + 1], query)
end

-- there are forward declarations in lua, apparently
local start_search

local function stop_search(buf)
    if vim.b[buf].minifiles_query == nil then
        return
    end
    vim.b[buf].minifiles_query = nil
    -- BS and escape also bound during searching process
    for _, key in ipairs(vim.list_extend(vim.deepcopy(search_keys), { "<BS>", "<Esc>" })) do
        pcall(vim.keymap.del, "n", key, { buffer = buf })
    end
    clear_query_display()
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
    if vim.b[buf].minifiles_query ~= nil then
        -- if moving from one buffer where we were querying to another, restart
        -- the search
        return set_query(buf, "")
    end
    local map = function(key, fn, desc)
        vim.keymap.set("n", key, fn, { buffer = buf, desc = desc })
    end
    for _, key in ipairs(search_keys) do
        map(key, function() set_query(buf, vim.b[buf].minifiles_query .. key) end, "Add to fuzzy search")
    end
    map("<BS>", function() set_query(buf, vim.b[buf].minifiles_query:sub(1, -2)) end, "Backspace in the search")
    map("<Esc>", function() stop_search(buf) end, "Leave fuzzy search")
    set_query(buf, "")
end

-- move one entry up or down, if searching this means up/down in results (TODO: maybe just always move up and down, have a separate action for search results)
local function move(buf, direction)
    if vim.b[buf].minifiles_query ~= nil then
        -- we are searching
        return cycle(buf, direction)
    end
    local line = vim.api.nvim_win_get_cursor(0)[1] + direction
    line = math.min(math.max(line, 1), vim.api.nvim_buf_line_count(buf))
    vim.api.nvim_win_set_cursor(0, { line, 0 })
end

local function go_in()
    files.go_in({ close_on_file = true })
end

local function go_out(buf)
    local was_searching = vim.b[buf].minifiles_query ~= nil
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
        ["<C-j>"] = { function() move(buf, 1) end, "Next entry" },
        ["<C-k>"] = { function() move(buf, -1) end, "Previous entry" },
        ["<C-l>"] = { go_in, "Go in" },
        ["<C-h>"] = { function() go_out(buf) end, "Go out" },
    }
    for key, action in pairs(navigation) do
        local fn, desc = action[1], action[2]
        vim.keymap.set({ "n", "x" }, key, fn, { buffer = buf, desc = desc })
        -- local function insertmode_fn()
        --     vim.cmd("stopinsert")
        --     vim.schedule(fn)
        -- end
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
        vim.keymap.set("n", "/", function() start_search(buf) end,
            { buffer = buf, desc = "Fuzzy search this directory" })
        map_navigation(buf)
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesExplorerClose",
    callback = clear_query_display,
})
