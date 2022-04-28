local opt = { expr = true, remap = true }
local k = vim.keymap.set

-- Comment.nvim ---------------------------------------------------------------

-- Toggle using count
k('n', 'gcc', "v:count == 0 ? '<Plug>(comment_toggle_current_linewise)' : '<Plug>(comment_toggle_linewise_count)'", opt)
k('n', 'gbc', "v:count == 0 ? '<Plug>(comment_toggle_current_blockwise)' : '<Plug>(comment_toggle_blockwise_count)'", opt)

-- Toggle in Op-pending mode
k('n', 'gc', '<Plug>(comment_toggle_linewise)')
k('n', 'gb', '<Plug>(comment_toggle_blockwise)')

-- Toggle in VISUAL mode
k('x', 'gc', '<Plug>(comment_toggle_linewise_visual)')
k('x', 'gb', '<Plug>(comment_toggle_blockwise_visual)')
