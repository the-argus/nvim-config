if InNix then
    return {
        cmd = { "css-languageserver", "--stdio" },
        filetypes = { "css", "scss", "less" },
        settings = {
            css = {
                validate = true
            },
            less = {
                validate = true
            },
            scss = {
                validate = true
            }
        },
        single_file_support = true
    }
else
    return {}
end
