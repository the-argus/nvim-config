local okay, highlight_colors = pcall(require, 'nvim-highlight-colors')

if not okay then
    return
end

-- shows colors and hexcodes by rendering the text of the color in that color
highlight_colors.setup({
    render = "foreground",
    enable_named_colors = false, -- don't highlight a word like "red"
    exclude_filetypes = { "txt" },
})
