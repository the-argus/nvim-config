local present, surround = pcall(require, "nvim-surround")
if not present then
    return
end

-- vim-surround style bindings. ys{motion}{char}, ds{char}, cs{old}{new}
surround.setup()
