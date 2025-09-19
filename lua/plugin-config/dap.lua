local dap = require("dap")
local k = vim.keymap.set

vim.g.breakpoints_by_filepath = {
    -- each item here should be of the following format:
    -- "string/path/to/file.cpp" = {
    --   123 = true, -- true if enabled, false otherwise
    -- }
}

dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" }
}

dap.configurations.c = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}

dap.adapters.godot = {
    type = "server",
    host = '127.0.0.1',
    port = 6006,
}

dap.configurations.gdscript = {
    {
        type = "godot",
        request = "launch",
        name = "Launch scene",
        project = "${workspaceFolder}",
    }
}

local function write_gdb_script()
    local cwd = vim.fn.getcwd()

    local home_dir = os.getenv("HOME") or os.getenv("USERPROFILE")
    if not home_dir then
        return
    end

    local base_data_dir
    if vim.fn.has("win32") == 1 then
        base_data_dir = os.getenv("LOCALAPPDATA") or os.getenv("APPDATA")
        if not base_data_dir then
            vim.notify("Can't find appdata folder for placing breakpoints on windows", vim.log.ERROR)
            return
        end
    else
        base_data_dir = home_dir .. "/.local/share"
    end

    local script_root_dir = base_data_dir .. "/nvim_dap_breakpoints"
    local script_path

    if cwd:sub(1, #home_dir) == home_dir then
        -- create some path like $HOME/.local/share/nvim_dap_breakpoints/Desktop/Programming/c/projectname/project.gdb or whatever
        local path_from_home_to_cwd = cwd:sub(#home_dir + 2)
        local breakpoints_dir = vim.fs.joinpath(script_root_dir, path_from_home_to_cwd)
        vim.fn.mkdir(breakpoints_dir, "p")
        script_path = vim.fs.joinpath(breakpoints_dir, "project.gdb")
    else
        -- /tmp fallback
        local temp_dir = vim.loop.os_tmpdir()
        script_path = vim.fs.joinpath(temp_dir, "nvim-breakpoints.gdb")
    end

    local file = io.open(script_path, "w")
    if not file then
        vim.notify("Failed to create GDB script file at: " .. script_path, vim.log.ERROR)
        return
    end

    for fpath, bplist in pairs(vim.g.breakpoints_by_filepath) do
        for linenumber_str, enabled in pairs(bplist) do
            if enabled then
                file:write(string.format("break %s:%s\n", fpath, linenumber_str))
            end
        end
    end

    file:close()
    return script_path
end

-- k('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
k('n', '<Leader>lb', function() dap.list_breakpoints() end)
k('n', '<Leader>b', function()
    local cwd = vim.fn.getcwd()
    -- local bufnr = api.nvim_get_current_buf()
    local lnum = tostring(vim.api.nvim_win_get_cursor(0)[1])
    local filepath = vim.fn.expand('%')
    local breakpoints_by_filepath = vim.g.breakpoints_by_filepath
    if breakpoints_by_filepath[filepath] ~= nil then
        local enabled = breakpoints_by_filepath[filepath][lnum]
        if enabled == nil then
            enabled = false
        end
        breakpoints_by_filepath[filepath][lnum] = not enabled
    else
        breakpoints_by_filepath[filepath] = {}
        breakpoints_by_filepath[filepath][lnum] = true
    end
    vim.g.breakpoints_by_filepath = breakpoints_by_filepath
    dap.toggle_breakpoint()
    write_gdb_script()
end)

vim.api.nvim_create_user_command(
    "CopyBreakpointPath",
    function()
        local path = write_gdb_script()
        if path then
            vim.fn.setreg('+', path)
            vim.notify("copying " .. path .. " to clipboard", vim.log.INFO)
        end
    end,
    { desc = "Copy the path to the breakpoint file for the current working directory" } -- table
)
