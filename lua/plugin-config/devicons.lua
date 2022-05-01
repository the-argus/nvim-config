local is_okay, devicons = pcall(require, 'nvim-web-devicons')
if not is_okay then
    return
end

devicons.setup {
 -- your personnal icons can go here (to override)
 -- you can specify color or cterm_color instead of specifying both of them
 -- DevIcon will be appended to `name`
 override = {
  lua = {
    -- color = "#428850",
    cterm_color = "7",
    name = "Lua"
  }
 };
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
}
