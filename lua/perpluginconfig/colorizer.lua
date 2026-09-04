local okay, colorizer = pcall(require, 'colorizer')

if not okay then
    return
end

-- Targets the maintained fork (catgoose/nvim-colorizer.lua). The original
-- norcalli repo is unmaintained since 2021 and uses removed nvim APIs.
colorizer.setup({
    filetypes = {
        "*",
        "!txt",
    },
    options = {
        parsers = {
            -- css preset enables names, hex, rgb(), hsl(), oklch(), and CSS vars
            css = true,
            names = { enable = false },
            hex = {
                rgb = true,      -- #RGB
                rrggbb = true,   -- #RRGGBB
                rrggbbaa = true, -- #RRGGBBAA
            },
        },
        display = {
            mode = "foreground",
        },
    },
})
