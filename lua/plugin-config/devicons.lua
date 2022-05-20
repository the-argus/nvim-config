local di_present, devicons = pcall(require, 'nvim-web-devicons')
if not di_present then
    return
end

-- get all icons
local icons = devicons.get_icons()

-- -- make them monochrome
for name, icon_style in pairs(icons) do
    local higroupname = "DevIcon" .. icon_style.name
    local style = "ctermfg=7 guifg=#FFFFFF"
    vim.cmd(string.format("highlight %s %s", higroupname, style))
end

devicons.setup({
    override = icons
})

