local neorg_okay, neorg = pcall(require, "neorg")
if not neorg_okay then
    return
end

neorg.setup({
    load = {
        ["core.defaults"] = {},
        ["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
        ["core.norg.dirman"] = {
            config = {
                workspaces = {
                    org = "~/NextcloudSync/norg/",
                }
            }
        }
    }
})
