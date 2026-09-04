local brk_ok, brk = pcall(require, "brk")
if not brk_ok then
    return
end

vim.keymap.set({'n', 'i'}, '<Leader>b', brk.toggle_breakpoint, {
    desc = "Toggle breakpoint"
})
vim.keymap.set('n', '<Leader>dc', brk.toggle_conditional_breakpoint, {
    desc = "Toggle conditional breakpoint"
})
vim.keymap.set('n', '<Leader>ds', brk.toggle_symbol_breakpoint, {
    desc = "Toggle symbol breakpoint"
})
vim.keymap.set('n', '<Leader>dl', brk.list_breakpoints, {
    desc = "List breakpoints"
})
vim.keymap.set('n', '<Leader>dC', brk.delete_all_breakpoints, {
    desc = "Delete all breakpoints"
})

-- I generally use gdb except on my mac
local preferred_debugger_format = "gdb"
if vim.loop.os_uname().sysname == "Darwin" then
    preferred_debugger_format = "lldb"
end

-- see brk.nvim/lua/brk/config.lua for more options
brk.setup {
    default_bindings = false,
    -- auto_start can be enabled per language. most of the time auto start is
    -- enabled by default. if I was setting breakpoints in the debugger itself
    -- this would be a problem as I need to pause there to set them, but since
    -- this plugin lets me do it in the editor, that is probably fine. though
    -- manually setting a breakpoint in main() in the editor might get a bit
    -- annoying
    breakpoint_sign = '󰝥 ',
    conditional_breakpoint_sign = '󰝥 ',
    breakpoint_color = 'Error',
    conditional_breakpoint_color = 'Comment',

    preferred_debugger_format,
}
