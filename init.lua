-- this will be replaced with "true" by the nix derivation
InNix = false

if not InNix then
    require "install-plugins"
end

-- setup vim options, auto-commands, user commands, etc.
require "settings"

-- configure plugins
require "plugin-config"

-- custom commands
require "custom"
