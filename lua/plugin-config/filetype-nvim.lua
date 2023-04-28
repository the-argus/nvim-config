local filetype_okay, filetype = pcall(require, 'filetype')
if not filetype_okay then
    return
end

filetype.setup({
    overrides = {
        extensions = {
            -- Set the filetype of *.pn files to potion
            pn = "potion",
        },
        shebang = {
            -- Set the filetype of files with a dash shebang to sh
            dash = "sh",
        },
    },
})
