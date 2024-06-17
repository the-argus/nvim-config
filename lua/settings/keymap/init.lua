require "settings.keymap.buffers"
require "settings.keymap.editing"
require "settings.keymap.window"
require "settings.keymap.tree"
require "settings.keymap.debugging"
local dvorak_utils = require("settings.keymap.dvorak-overrides")
if UsingDvorak then
    dvorak_utils.enable_dvorak()
end
