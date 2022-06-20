-- useful functions
require "utils"

-- load plugins
require "plugins"
-- vim.lsp.set_log_level 'debug'
-- require('vim.lsp.log').set_format_func(vim.inspect)
require "colors"
vim.cmd "colorscheme rose-pine"

-- setup vim options, auto-commands, user commands, etc.
require "settings"

-- custom commands
require "custom"
