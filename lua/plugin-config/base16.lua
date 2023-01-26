local base16_okay, colorscheme = pcall(require, 'base16-colorscheme')
local override_palette, colors = pcall(require, 'settings.color-palette')

if not base16_okay then
    return
end

if not override_palette then
    colors = {
        base00 = "#282828";
        base01 = "#3c3836";
        base02 = "#504945";
        base03 = "#665c54";
        base04 = "#bdae93";
        base05 = "#d5c4a1";
        base06 = "#ebdbb2";
        base07 = "#fbf1c7";
        base08 = "#fb4934";
        base09 = "#fe8019";
        base0A = "#fabd2f";
        base0B = "#b8bb26";
        base0C = "#8ec07c";
        base0D = "#83a598";
        base0E = "#d3869b";
        base0F = "#d65d0e";
        confirm = "#b8bb26";
        warn = "#fabd2f";
        urgent = "#fb4934";
        link = "#8ec07c";
        highlight = "#8ec07c";
        hialt0 = "#83a598";
        hialt1 = "#8ec07c";
        hialt2 = "#83a598";
        pfg_confirm = "#282828";
        pfg_warn = "#282828";
        pfg_urgent = "#fbf1c7";
        pfg_link = "#282828";
        pfg_highlight = "#282828";
        pfg_hialt0 = "#282828";
        pfg_hialt1 = "#282828";
        pfg_hialt2 = "#282828";
    }
end

local M = {
    setup = function() colorscheme.setup(colors, {}) end,
    colors = colors
}

return M
