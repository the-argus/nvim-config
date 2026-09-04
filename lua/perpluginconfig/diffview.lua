local present, diffview = pcall(require, "diffview")
if not present then
    return
end

diffview.setup({
    hooks = {
        diff_buf_read = function(_bufnr)
            -- vim options specific to diff buffers
            vim.opt_local.wrap = false
            vim.opt_local.list = false
        end,
    },

    -- options from "minimal" config in RECIPES.md of diffview repo
    show_help_hints = false,
    hide_merge_artifacts = true,
    clean_up_buffers = true,
    auto_close_on_empty = true,

    default_args = {
        -- imply-local make the right side buffer editable
        DiffviewOpen = { "--imply-local" },
    },
    file_panel = {
        show_branch_name = true,
        always_show_sections = true,
    },

    enhanced_diff_hl = true,

    diffopt = { algorithm = "histogram" },

    -- persist review selections between restarts of neovim
    persist_selections = { enabled = true },
})

-- <Leader>v : toggle diff view
--  use :h diffview-maps to see options for staging + unstaging
vim.keymap.set('n', '<Leader>v', '<cmd>DiffviewToggle<cr>', { desc = 'Toggle Diffview' })

-- Diff working directory
vim.keymap.set('n', '<Leader>vo', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview open' })
vim.keymap.set('n', '<Leader>vc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })

-- File history
vim.keymap.set('n', '<Leader>vh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history (current file)' })
vim.keymap.set('n', '<Leader>vH', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history (repo)' })

-- Visual mode: history for selection
vim.keymap.set('v', '<Leader>vh', "<Esc><cmd>'<,'>DiffviewFileHistory --follow<CR>", { desc = 'Range history' })

-- Single line history
vim.keymap.set('n', '<leader>vl', '<cmd>.DiffviewFileHistory --follow<CR>', { desc = 'Line history' })

-- Diff against main/master branch (useful before merging)
vim.keymap.set('n', '<leader>vm', function()
    local result = vim.fn.systemlist({ 'git', 'rev-parse', '--verify', 'main' })
    local ok = vim.v.shell_error == 0 and result[1] ~= nil and result[1] ~= ''
    local branch = ok and 'main' or 'master'
    vim.cmd('DiffviewOpen ' .. branch)
end, { desc = 'Diff against main/master' })

-- Diff against a branch selected via Telescope
vim.keymap.set('n', '<Leader>vb', function()
    require('telescope.builtin').git_branches({
        attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
                local selection = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                vim.cmd('DiffviewOpen ' .. selection.value)
            end)
            return true
        end,
    })
end, { desc = 'Diffview branch' })

-- File history for a commit selected via Telescope
vim.keymap.set('n', '<leader>vC', function()
    require('telescope.builtin').git_commits({
        attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
                local selection = require('telescope.actions.state').get_selected_entry()
                require('telescope.actions').close(prompt_bufnr)
                vim.cmd('DiffviewOpen ' .. selection.value .. '^!')
            end)
            return true
        end,
    })
end, { desc = 'Diffview commit' })
