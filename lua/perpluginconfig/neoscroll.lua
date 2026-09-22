local present, neoscroll = pcall(require, "neoscroll")
if not present then
    return
end

neoscroll.setup({
    -- zt/zz/zb purposefully left out because I don't use them and want z
    -- motion prefix for leaping
    mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>" },
})
