local present, leap = pcall(require, "leap")
if not present then
    return
end

vim.keymap.set({'n', 'x', 'o'}, 'z', '<Plug>(leap)')
vim.keymap.set('n',             'Z', '<Plug>(leap-from-window)')
vim.keymap.set('n',        'z', '<Plug>(leap-anywhere)')
-- vim.keymap.set({'x', 'o'}, 'z', '<Plug>(leap)')

-- Exclude whitespace and the middle of alphabetic words from preview:
--   foobar[baaz] = quux
--   ^----^^^--^^-^-^--^
leap.opts.preview_filter =
  function (ch0, ch1, ch2)
    return not (
      ch1:match('%s') or
      ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
    )
  end

leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }
require('leap.user').set_repeat_keys('<enter>', '<backspace>')
