local util = require "utils"

-- neovide specific config
if vim.g.neovide ~= nil then
    vim.cmd("hi normal guibg=#191724")
end

local function open_url(command_info)
    -- remove quotes that are usually passed in around the url
    local url = string.gsub(command_info.args, "\"", "")
    -- get the basename of the file being wget-ed
    local splits = util.split_string(url, "/")
    local basename = splits[#splits]
    -- set the wget out path to /tmp/filename
    local path = string.format("/tmp/%s", basename)
    -- wget the file
    local command = string.format("wget \"%s\" -O %s", url, path)
    vim.fn.system(command)
    -- open the wget-ed file
    vim.cmd(string.format(":vs|view %s", path))
end

vim.api.nvim_create_user_command("Url", open_url, {})
