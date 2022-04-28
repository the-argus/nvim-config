-- Constants

-- PACKER_INSTALL_PATH = vim.fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"
-- PACKER_COMPILE_PATH = vim.fn.stdpath "config" .. "/lua/_compiled.lua"

-- Aliases
cmd = vim.api.nvim_command

-- append node binaries to path.
vim.env.PATH = vim.env.PATH .. ":./node_modules/.bin"
