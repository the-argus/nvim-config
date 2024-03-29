if InNix then
    return {
        cmd = { "html-languageserver", "--stdio" },
        filetypes = { "html" },
        init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = {
                css = true,
                javascript = true
            },
            provideFormatter = true
        },
        settings = {},
        single_file_support = true
    }
else
    return {}
end
