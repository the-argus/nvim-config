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
            org_agenda_files = { '~/Dropbox/org/*', '~/my-orgs/**/*' },
            org_default_notes_file = '~/Documents/Notes/refile.org',
        })
    end
}

return M
