local textsubjects_ok, textsubjects = pcall(require, "nvim-treesitter-textsubjects")
if not textsubjects_ok then
    return
end

textsubjects.configure({
    prev_selection = ',',
    keymaps = {
        -- will select the most relevant part of the syntax tree depending on your location in it
        ['.'] = 'textsubjects-smart',
        -- select a syntactical container (class, function, etc.) depending on your location in the syntax tree
        [';'] = 'textsubjects-container-outer',
        -- select the body of a syntactical container depending on your location in the syntax tree
        ['i;'] = 'textsubjects-container-inner',
    },
})
