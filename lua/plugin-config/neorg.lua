local neorg_okay, neorg = pcall(require, "neorg")
if not neorg_okay then
    return
end

neorg.setup({
    load = {
        ["core.defaults"] = {},
        ["core.completion"] = { config = { engine = "nvim-cmp" } },
        ["core.dirman"] = {
            config = {
                workspaces = {
                    org = "~/NextcloudSync/norg/",
                }
            }
        }
    }
})
