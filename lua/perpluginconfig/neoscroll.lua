local present, neoscroll = pcall(require, "neoscroll")
if not present then
    return
end

-- smooth scrolling for <C-u>/<C-d>/<C-b>/<C-f>/<C-y>/<C-e>/zt/zz/zb
neoscroll.setup()
