local icons_present, icons = pcall(require, "mini.icons")
if not icons_present then
    return
end

icons.setup()

-- most stuff like telescope only works with web devicons but mini.icons has compatibility
icons.mock_nvim_web_devicons()

local function make_monochrome()
    -- make all icons monochrome, base05 in the current colorscheme
    local base16_ok, base16 = pcall(require, "base16-colorscheme")
    local has_base05 = base16_ok and base16.colors and base16.colors.base05
    local fg = has_base05 and ("#" .. has_base05:gsub("^#", "")) or vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
    for _, color in ipairs({ "Azure", "Blue", "Cyan", "Green", "Grey", "Orange", "Purple", "Red", "Yellow" }) do
        vim.api.nvim_set_hl(0, "MiniIcons" .. color, { fg = fg, ctermfg = 7 })
    end
end

local augroup = vim.api.nvim_create_augroup("MiniIconsConfig", {})

-- autocommand to make monochrome whenever the color scheme is changed
vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = make_monochrome,
})

make_monochrome()
