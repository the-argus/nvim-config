local telescope_ok, telescope = pcall(require, "telescope.builtin")
if not telescope_ok then
    return
end

-- makes telescope popups close mini.files popups first
local wrap_telescope_popup = require("perpluginconfig.popups").wrap_telescope_popup

vim.api.nvim_create_user_command("SearchCommands", wrap_telescope_popup(telescope.commands), {})

vim.api.nvim_create_user_command("SwitchBuffer",
    wrap_telescope_popup(function() telescope.buffers({ sort_mru = true, ignore_current_buffer = true }) end), {})
vim.api.nvim_create_user_command("SearchBuffers",
    wrap_telescope_popup(function() telescope.buffers({ select_current = true }) end),
    {})

vim.api.nvim_create_user_command("SearchInProject", wrap_telescope_popup(telescope.live_grep), {})
vim.api.nvim_create_user_command("SearchInOpenFiles",
    wrap_telescope_popup(function() telescope.live_grep({ grep_open_files = true }) end),
    {})

vim.api.nvim_create_user_command("ShowFileDiagnostics",
    wrap_telescope_popup(function() telescope.diagnostics({ bufnr = 0 }) end), {})
vim.api.nvim_create_user_command("ShowProjectDiagnostics", wrap_telescope_popup(telescope.diagnostics), {})

vim.api.nvim_create_user_command("Open",
    wrap_telescope_popup(function() telescope.git_files({ recurse_submodules = false }) end), {})
vim.api.nvim_create_user_command("OpenIncludingSubmodules",
    wrap_telescope_popup(function() telescope.git_files({ recurse_submodules = true }) end), {})
vim.api.nvim_create_user_command("OpenIncludingEverything",
    wrap_telescope_popup(function() telescope.live_grep({ recurse_submodules = true, hidden = true, no_ignore = true, no_ignore_parent = true }) end),
    {})

-- keybinds opening pickers that I use all the time
vim.keymap.set("n", "<Leader>g", "<Cmd>Open<CR>", { desc = "Find files", silent = true })
vim.keymap.set("n", "<Leader>h", "<Cmd>ShowFileDiagnostics<CR>", { desc = "File diagnostics", silent = true })
vim.keymap.set("n", "<Leader>j", "<Cmd>SwitchBuffer<CR>", { desc = "Buffers", silent = true })
vim.keymap.set("n", "<Leader>m", "<Cmd>SearchInProject<CR>", { desc = "Live grep", silent = true })
vim.keymap.set("n", "<Leader>k", "<Cmd>SearchCommands<CR>", { desc = "Pick from all user commands", silent = true })
