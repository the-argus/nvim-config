--- This file contains some common options between regular lsp and none-ls
local M = {}

M.default_off_filetypes = {
    "markdown",
}

---@param buf integer|nil buffer number, default = current buffer
---@return boolean
function M.enabled(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local override = vim.b[buf].lsp_enabled
    if override ~= nil then
        return override
    end
    return not vim.tbl_contains(M.default_off_filetypes, vim.bo[buf].filetype)
end

return M
