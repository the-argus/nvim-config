local di_present, devicons = pcall(require, 'nvim-web-devicons')
if not di_present then
    vim.notify("failed to load nvim-web-devicons")
    return
end

-- get all icons
local icons = devicons.get_icons()

-- get my color scheme
local colors = require("plugin-config.base16").colors

-- -- make them monochrome
for _, icon_style in pairs(icons) do
    local higroupname = "DevIcon" .. icon_style.name
    local style = "ctermfg=7 guifg=#" .. colors.base05
    vim.cmd(string.format("highlight %s %s", higroupname, style))
end

devicons.setup({
    override = icons
})
