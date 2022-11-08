local util = require "utils"

-- neovide specific config
-- if vim.g.neovide ~= nil then
--     vim.cmd("hi normal guibg=#191724")
-- end

local function open_url(command_info)
    -- string manipulation
    local url = string.gsub(command_info.args, "\"", "")
    local splits = util.split_string(url, "/")
    local basename = splits[#splits]
    local path = string.format("/tmp/%s", basename) --could also use os.tmpname
    local w3m_command = string.format("w3m -dump \"%s\" > %s", url, path)

    -- attempt to use w3m
    local w3m_pipe = io.popen(w3m_command)
    -- local w3m_output = w3m_pipe:read('*all')
    local w3m_worked = ({ w3m_pipe:close() })[1]

    if w3m_worked then
        vim.cmd(string.format(":vs|view %s", path))
    else
        -- attempt wget instead
        local wget_command = string.format("wget \"%s\" > %s", url, path)
        -- attempt to use w3m
        local wget_pipe = io.popen(wget_command)
        -- local wget_output = wget_pipe:read('*all')
        local wget_worked = ({ wget_pipe:close() })[1]

        if not wget_worked then
            print(
                string.format("W3M and Wget failed to retrieve %s", url)
                )
        else
            print("W3M failed, defaulting to wget.")
            vim.cmd(string.format(":vs|view %s", path))
        end
    end
    -- open the wget-ed file
end

local function find_files(command_info)
    local is_okay, telescope = pcall(require, "telescope.builtin")
    if not is_okay then
        print("Telescope is not installed.")
        return
    end
    telescope.find_files()
end

vim.api.nvim_create_user_command("Url", open_url, {})
vim.api.nvim_create_user_command("Open", find_files, {})
