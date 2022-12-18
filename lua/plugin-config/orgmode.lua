-- Load custom treesitter grammar for org filetype
local status_ok, orgmode = pcall(require, "orgmode")
if not status_ok then
    return
end

M = {
    initial = function()
        orgmode.setup_ts_grammar()
    end,
    final = function()
        orgmode.setup({
            org_agenda_files = { '~/NextcloudSync/org/*', '~/my-orgs/**/*' },
            org_default_notes_file = '~/NextcloudSync/org/refile.org',
        })
    end
}

return M
