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
        attach_mappings = function()
            -- replace (not map) so both insert and normal mode <CR> are covered;
            -- telescope's default here is git checkout
            require("telescope.actions").select_default:replace(function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                vim.cmd("DeltaMenu " .. selection.value .. "...HEAD")
            end)
            return true
        end,
    })
end), { desc = "Deltaview picker showing current branch vs picked branch" })

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
