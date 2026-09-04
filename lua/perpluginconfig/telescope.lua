local telescope_ok, telescope = pcall(require, "telescope.builtin")
if not telescope_ok then
    return
end

vim.api.nvim_create_user_command("SearchCommands", telescope.commands, {})

vim.api.nvim_create_user_command("SwitchBuffer",
    function() telescope.buffers({ sort_mru = true, ignore_current_buffer = true }) end, {})
vim.api.nvim_create_user_command("SearchBuffers", function() telescope.buffers({ select_current = true }) end, {})

vim.api.nvim_create_user_command("SearchInProject", telescope.live_grep, {})
vim.api.nvim_create_user_command("SearchInOpenFiles", function() telescope.live_grep({ grep_open_files = true }) end, {})

vim.api.nvim_create_user_command("ShowFileDiagnostics", function() telescope.diagnostics({ bufnr = 0 }) end, {})
vim.api.nvim_create_user_command("ShowProjectDiagnostics", telescope.diagnostics, {})

vim.api.nvim_create_user_command("Open", function() telescope.git_files({ recurse_submodules = false }) end, {})
vim.api.nvim_create_user_command("OpenIncludingSubmodules",
    function() telescope.git_files({ recurse_submodules = true }) end, {})
vim.api.nvim_create_user_command("OpenIncludingEverything",
    function() telescope.live_grep({ recurse_submodules = true, hidden = true, no_ignore = true, no_ignore_parent = true }) end,
    {})

-- keybinds opening pickers that I use all the time
vim.keymap.set("n", "<Leader>g", "<Cmd>Open<CR>", { desc = "Find files", silent = true })
vim.keymap.set("n", "<Leader>h", "<Cmd>ShowFileDiagnostics<CR>", { desc = "File diagnostics", silent = true })
vim.keymap.set("n", "<Leader>j", "<Cmd>SwitchBuffer<CR>", { desc = "Buffers", silent = true })
vim.keymap.set("n", "<Leader>m", "<Cmd>SearchInProject<CR>", { desc = "Live grep", silent = true })
vim.keymap.set("n", "<Leader>k", "<Cmd>SearchCommands<CR>", { desc = "Pick from all user commands", silent = true })
