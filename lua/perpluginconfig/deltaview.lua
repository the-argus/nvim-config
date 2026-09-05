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

-- <Leader>vb : Show a picker to select a branch, then show a diff view between
-- the current branch and that branch
vim.keymap.set("n", "<Leader>vb", wrap_telescope_popup(function()
    require("telescope.builtin").git_branches({
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                vim.cmd("DeltaMenu " .. selection.value .. "...HEAD")
            end)
            return true
        end,
    })
end), { desc = "Deltaview picker showing current branch vs picked branch" })

-- <Leader>vC : open a picker to choose a commit, then a changed files picker
-- for that commit, then show the changes in that file on that commit
vim.keymap.set("n", "<Leader>vC", wrap_telescope_popup(function()
    require("telescope.builtin").git_commits({
        attach_mappings = function(_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                vim.cmd("DeltaMenu " .. selection.value .. "^!")
            end)
            return true
        end,
    })
end), { desc = "Deltaview picker showing changes for a specific file in a specific commit" })

-- <Leader>vq : quickfix review, use ]q / [q to step through changed files
vim.keymap.set("n", "<Leader>vq", "<Cmd>DeltaMenu!<CR>", { desc = "Deltaview review with quickfix" })
