local zenmode_okay, zenmode = pcall(require, 'zen-mode')
local twilight_okay, twilight = pcall(require, 'twilight')

if not zenmode_okay then
    return
end
if not twilight_okay then
    return
end

local M = {
    zen = {
        window = {
            backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
            -- height and width can be:
            -- * an absolute number of cells when > 1
            -- * a percentage of the width / height of the editor when <= 1
            -- * a function that returns the width or the height
            -- width = 120, -- width of the Zen window
            width = 0.75,
            height = 1, -- height of the Zen window
            -- by default, no options are changed for the Zen window
            -- uncomment any of the options below, or add other vim.wo options you want to apply
            options = {
                number = true;
                relativenumber = true;
                signcolumn = "no",
                -- signcolumn = "no", -- disable signcolumn
                -- number = false, -- disable number column
                -- relativenumber = false, -- disable relative numbers
                -- cursorline = false, -- disable cursorline
                -- cursorcolumn = false, -- disable cursor column
                -- foldcolumn = "0", -- disable fold column
                -- list = false, -- disable whitespace characters
            },
        },
        plugins = {
            -- disable some global vim options (vim.o...)
            -- comment the lines to not apply the options
            options = {
                enabled = true,
                ruler = false, -- disables the ruler text in the cmd line area
                showcmd = false, -- disables the command in the last line of the screen
            },
            -- twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
            twilight = { enabled = false },
            gitsigns = { enabled = false }, -- disables git signs
            tmux = { enabled = false }, -- disables the tmux statusline
            -- this will change the font size on kitty when in zen mode
            -- to make this work, you need to set the following kitty options:
            -- - allow_remote_control socket-only
            -- - listen_on unix:/tmp/kitty
            kitty = {
                enabled = true,
                font = "+4", -- font size increment
            },
        },
        -- callback where you can add custom code when the Zen window opens
        on_open = function(win)
        end,
        -- callback where you can add custom code when the Zen window closes
        on_close = function()
        end,
    };

    twilight = {
        dimming = {
            alpha = 0.5, -- amount of dimming
            -- we try to get the foreground from the highlight groups or fallback color
            color = { "Normal", "#ffffff" },
            -- term_bg = tostring(vim.api.nvim_get_color_by_name("Normal")),
            term_bg = "#00000000",
            inactive = true, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
        },
        context = 20, -- amount of lines we will try to show around the current line
        node_context = 0,
        treesitter = true, -- use treesitter when available for the filetype
        -- treesitter is used to automatically expand the visible text,
        -- but you can further control the types of nodes that should always be fully expanded
        expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
            "function",
            "while_statement",
            "for_statement",
            "function_definition",
            "class_definition",
            "document",
            "function_declaration",
            "method",
            "table",
            "if_statement",
        },
        exclude = {"zsh", "markdown", "help", "asciidoc", "conf", "sh", "vim"}, -- exclude these filetypes
    }
}
twilight.setup(M.twilight)
zenmode.setup(M.zen)
