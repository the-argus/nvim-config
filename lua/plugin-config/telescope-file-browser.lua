local telescope_okay, telescope = pcall(require, "telescope")
if not telescope_okay then
    vim.notify("failed to load telescope file browser")
    return
end

telescope.setup {
    extensions = {
        file_browser = {
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
                ["i"] = {
                    -- your custom insert mode mappings
                },
                ["n"] = {
                    -- your custom normal mode mappings
                },
            },
        },
    },
}

vim.api.nvim_set_keymap(
    "n",
    "-",
    ":Telescope file_browser",
    { noremap = true }
)

-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
    "n",
    "<space>-",
    ":Telescope file_browser path=%:p:h select_buffer=true",
    { noremap = true }
)
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
telescope.load_extension "file_browser"
