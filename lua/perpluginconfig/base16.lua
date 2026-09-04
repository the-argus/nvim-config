local base16_okay, colorscheme = pcall(require, 'base16-colorscheme')

if not base16_okay then
    return
end

vim.cmd('colorscheme base16-gruvbox-dark-hard')

colorscheme.with_config({
    telescope = true,
    indentblankline = true,
    -- notify = true,
    ts_rainbow = true,
    cmp = true,
    -- illuminate = true,
});
