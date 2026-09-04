local present, leap = pcall(require, "leap")
if not present then
    return
end

vim.keymap.set('n', 'z', '<Plug>(leap-anywhere)')
vim.keymap.set({ 'x', 'o' }, 'z', '<Plug>(leap)')

-- Exclude whitespace and the middle of alphabetic words from preview:
--   foobar[baaz] = quux
--   ^----^^^--^^-^-^--^
local function preview_filter(ch0, ch1, ch2)
    return not (
        ch1:match('%s') or
        ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
    )
end
leap.opts.preview = preview_filter
leap.opts.preview_filter = preview_filter -- old name, for checkouts before 2025-10

leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

local leap_user_ok, leap_user = pcall(require, 'leap.user')
if not leap_user_ok then
    return
end

-- <enter>/<backspace> repeat the previous search forwards/backwards without
-- re-invoking leap. `set_repeat_keys` is deprecated upstream in favour of
-- traversal keys (see :h leap-repeat); fall back for older checkouts.
if leap_user.with_traversal_keys then
    vim.keymap.set({ 'n', 'x', 'o' }, '<enter>', function()
        leap.leap({ ['repeat'] = true, opts = leap_user.with_traversal_keys('<enter>', '<backspace>') })
    end)
    vim.keymap.set({ 'n', 'x', 'o' }, '<backspace>', function()
        leap.leap({ ['repeat'] = true, backward = true, opts = leap_user.with_traversal_keys('<backspace>', '<enter>') })
    end)
else
    leap_user.set_repeat_keys('<enter>', '<backspace>')
end
