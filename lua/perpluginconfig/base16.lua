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

-- try to use the palette from nix, if it inserts some nix-banner-palette.lua
local nix_palette_okay, palette = pcall(require, 'nix-banner-palette')
if nix_palette_okay then
    local from_ansi = {
        base00 = "ansi00",
        base01 = "ansi0A",
        base02 = "ansi0B",
        base03 = "ansi08",
        base04 = "ansi0C",
        base05 = "ansi07",
        base06 = "ansi0D",
        base07 = "ansi0F",
        base08 = "ansi01",
        base09 = "ansi09",
        base0A = "ansi03",
        base0B = "ansi02",
        base0C = "ansi06",
        base0D = "ansi04",
        base0E = "ansi05",
        base0F = "ansi0E",
    }

    local colors = {}
    for base, ansi in pairs(from_ansi) do
        colors[base] = palette[ansi] or palette[base]
    end

    colorscheme.setup(colors, {})
end

-- Fixes base16 making all comments super faded out for some reason, I guess
-- they think comments are not important
local function assign_brighter_comment_color()
    local bright = colorscheme.colors and colorscheme.colors.base0C or "#8ec07c"
    for _, group in ipairs({ "Comment", "TSComment" }) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.fg = bright
        vim.api.nvim_set_hl(0, group, hl)
    end
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = assign_brighter_comment_color })
assign_brighter_comment_color()
