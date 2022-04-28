-- useful functions
utils = require "utils"
-- setup vim options, auto-commands, user commands, etc.
require "settings"
require "plugins"

-- bootstrap
-- if packer doesn't exists then clone and generate plugins spec
-- if packer plugin spec file doesn't exist then generate it
--[[
if not utils.exists(PACKER_INSTALL_PATH) or not utils.exists(PACKER_COMPILE_PATH) then
  require "plugins"
end
]]--

-- Load plugin specs and statusline
--[[ 
pcall(require, "configs.core.impatient")
require "statusline"
]]--
