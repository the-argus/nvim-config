local deltaview_ok, deltaview = pcall(require, "deltaview");
-- not returning if deltaview_ok is false until later, so we can still get
-- <Leader>n with telescope, at least.

local wrap_telescope_popup = require("perpluginconfig.popups").wrap_telescope_popup

--- Workaround for `deltaview.is_deltaview_buffer()`
local function in_deltaview_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    return vim.b[bufnr].delta_diff_data_set ~= nil
end

-- <Leader>n : pick from files with pending changes.
--   in a deltaview buffer  -> deltaview's picker (opens deltaview buffers,
--                             uses the ref currently being viewed)
--   anywhere else          -> telescope git_status (opens editable files)
-- Defined before the plugin guard so the fallback survives deltaview being
-- absent. Replaces the old mapping in perpluginconfig/telescope.lua.
vim.keymap.set("n", "<Leader>n", wrap_telescope_popup(function()
    if in_deltaview_buffer() and deltaview_ok then
        vim.cmd("DeltaMenu")
    else
        vim.cmd("Telescope git_status")
    end
end), { desc = "Pick from files that have pending changes", silent = true })

if not deltaview_ok then
    return
end

deltaview.setup({
    use_nerdfonts = true,
    fzf_picker = "telescope",
    keyconfig = {
        -- I use <Leader>d for "debug" related commands
        dv_toggle_keybind = "",
        dm_toggle_keybind = "",
        d_toggle_keybind = "",
    },
})

local function exit_deltaview()
    vim.cmd("normal q")
end

local function main_branch()
    local result = vim.fn.systemlist({ "git", "rev-parse", "--verify", "--quiet", "main" })
    local ok = vim.v.shell_error == 0 and result[1] ~= nil and result[1] ~= ""
    return ok and "main" or "master"
end

-- <Leader>v : toggle deltaview on the current file against HEAD
vim.keymap.set("n", "<Leader>vv", function()
    if in_deltaview_buffer() then
        exit_deltaview()
    else
        vim.cmd("DeltaView HEAD")
    end
end, { desc = "Toggle deltaview (working tree vs HEAD)" })

-- <Leader>va : every changed file in one mega-buffer (va == View All)
vim.keymap.set("n", "<Leader>va", function()
    if in_deltaview_buffer() then
        exit_deltaview()
    else
        vim.cmd("Delta .")
    end
end, { desc = "Toggle diff view for all currently changed files" })

-- <Leader>vm : show a changed file picker for what files are different from
-- the current branch to main/master
vim.keymap.set("n", "<Leader>vm", wrap_telescope_popup(function()
    vim.cmd("DeltaMenu " .. main_branch() .. "...HEAD")
end), { desc = "Deltaview picker showing current branch vs main/master" })

local commit_log_limit = 50

--- @param ... string extra git args
--- @return string[]
local function commit_log_args(...)
    return vim.list_extend({
        -- list doesn't get reversed until max count is applied, so this is fine
        "git", "log", "--reverse", "--max-count=" .. commit_log_limit, "--no-color",
    }, { ... })
end

--- Global variable that remembers the last commit that was reviewed, typically
--- I am reviewing one at a time in order so I want to  move by one from the
--- last one i reviewed
--- @type string|nil
local last_reviewed_commit = nil

--- tries to find the index of last_reviewed_commit, but it might be filtered
--- out by the search query, or it might be nil, in which case do the most
--- recent commit
--- TODO: probably try for the closest commit to the last_reviewed_commit
--- @return integer|nil
local function default_commit_index()
    local hashes = vim.fn.systemlist(commit_log_args("--pretty=%h"))
    if vim.v.shell_error ~= 0 or #hashes == 0 then
        return nil
    end
    for index, hash in ipairs(hashes) do
        if hash == last_reviewed_commit then
            return index
        end
    end
    return #hashes
end

-- commit review picker
vim.keymap.set("n", "<Leader>vc", wrap_telescope_popup(function()
    require("telescope.builtin").git_commits({
        prompt_title = "Commits on this branch",
        git_command = commit_log_args("--pretty=oneline", "--abbrev-commit"),
        -- oldest at the top, so moving down the list moves forward in time
        sorting_strategy = "ascending",
        default_selection_index = default_commit_index(),
        attach_mappings = function()
            -- we are using the git_commits picker so we need to override the select action
            require("telescope.actions").select_default:replace(function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                if selection == nil then
                    return
                end
                last_reviewed_commit = selection.value
                vim.cmd("DeltaMenu! " .. selection.value .. "^!")
            end)
            return true
        end,
    })
end), { desc = "Review a commit from this branch in a quickfix deltaview" })

--- Open a telescope commit picker and run a deltaview command on
--- the chosen commit
--- @param picker fun(opts: table) telescope.builtin picker
--- @param command string "DeltaView" | "DeltaMenu"
--- @param desc string
local function commit_history_keymap(lhs, picker, command, desc)
    vim.keymap.set("n", lhs, wrap_telescope_popup(function()
        picker({
            attach_mappings = function()
                require("telescope.actions").select_default:replace(function(prompt_bufnr)
                    local selection = require("telescope.actions.state").get_selected_entry()
                    require("telescope.actions").close(prompt_bufnr)
                    vim.cmd(command .. " " .. selection.value .. "^!")
                end)
                return true
            end,
        })
    end), { desc = desc })
end

-- <Leader>vf : commits the affect the current file and then the relevant hunks
-- frmo that commit
commit_history_keymap("<Leader>vf", function(opts) require("telescope.builtin").git_bcommits(opts) end,
    "DeltaView", "File history (current file)")

-- <Leader>vl : commits affecting the current line (git log -L), then any hunks
-- from that commit affecting the current buffer. Unfortunately deltaview does
-- not support limiting the diff to a line range
commit_history_keymap("<Leader>vl", function(opts) require("telescope.builtin").git_bcommits_range(opts) end,
    "DeltaView", "File history (current line)")

-- <Leader>vH : pick from all commits, then pick from a file, then show
-- deltaview for the changes to that file for that commit
commit_history_keymap("<Leader>vH", function(opts) require("telescope.builtin").git_commits(opts) end,
    "DeltaMenu", "File history (repo)")

-- <Leader>vq : quickfix review, use ]q / [q to step through changed files
vim.keymap.set("n", "<Leader>vq", "<Cmd>DeltaMenu!<CR>", { desc = "Deltaview review with quickfix" })
