local neorg_okay, neorg = pcall(require, "neorg")
if not neorg_okay then
    return
end

neorg.setup({
    load = {
        ["core.defaults"] = {},
        ["core.norg.dirman"] = {
            config = {
                workspaces = {
                    org = "~/NextcloudSync/org/",
                }
            }
        }
    }
})
