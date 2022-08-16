local palette = {
    base = '#19172400',
    surface = '#1f1d2e',
    overlay = '#26233a',
    muted = '#6e6a86',
    subtle = '#908caa',
    text = '#e0def4',
    love = '#eb6f92',
    gold = '#f6c177',
    rose = '#ebbcba',
    pine = '#31748f',
    foam = '#9ccfd8',
    iris = '#c4a7e7',
    highlight_low = '#21202e',
    highlight_med = '#403d52',
    highlight_high = '#524f67',
    opacity = 0.1,
    none = 'NONE',
}

local overriden, new_palette = pcall(require, "color-override")
if overriden then
    palette = new_palette
end


local p = palette
local alias = {
    red = p.rose,
    orange = p.love,
    yellow = p.gold,
    green = p.pine,
    blue = p.foam,
    purple = p.iris,
}
palette.alias = alias

return palette
