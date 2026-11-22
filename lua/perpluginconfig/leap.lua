local present, leap = pcall(require, "leap")
if not present then
    return
end

vim.keymap.set('n', 'z', '<Plug>(leap-anywhere)')
vim.keymap.set({ 'x', 'o' }, 'z', '<Plug>(leap)')

vim.keymap.set({ 'x', 'o' }, 'at', '<Plug>(leap-visit-text-object)')
vim.keymap.set({ 'x', 'o' }, 'it', '<Plug>(leap-visit-inner-text-object)')

vim.keymap.set({ 'n', 'x', 'o' }, 'rr', function()
    require('leap').visit { input = (vim.fn.mode(true) == 'n') and 'v' or '' }
end)

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
leap.opts.preview_filter = preview_filter -- old name, from before october 2025

leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

vim.keymap.set({ 'n', 'x', 'o' }, ']w', function()
    leap.leap({ ['repeat'] = true })
end, { desc = "Repeat last leap forwards" })
vim.keymap.set({ 'n', 'x', 'o' }, '[w', function()
    leap.leap({ ['repeat'] = true, backward = true })
end, { desc = "Repeat last leap backwards" })

-- fixes a problem where pressing enter to jump in the quickfix window didn't
-- work because leap had remapped <CR> in normal buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(args)
        vim.keymap.set("n", "<enter>", "<CR>", { buffer = args.buf, remap = false })
    end,
})
