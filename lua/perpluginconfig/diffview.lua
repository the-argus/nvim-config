local present, diffview = pcall(require, "diffview")
if not present then
    return
end

diffview.setup()

-- <Leader>v : toggle diff view
--  use :h diffview-maps to see options for staging + unstaging
vim.keymap.set("n", "<Leader>v", function()
    local lib = require("diffview.lib")
    if lib.get_current_view() then
        vim.cmd("DiffviewClose")
    else
        vim.cmd("DiffviewOpen")
    end
end)
