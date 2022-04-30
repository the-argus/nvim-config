local util = require('colors.util')

local M = {}
local show_init_messages = true

---@class RosePineConfig
---@field bold_vert_split boolean
---@field dark_variant 'main'|'moon'
---@field dim_nc_background boolean
---@field disable_background boolean
---@field disable_float_background boolean
---@field disable_italics boolean
---@field groups RosePineGroups

---@class RosePineGroups
---@field border string
---@field comment string
---@field link string
---@field punctuation string
---@field error string
---@field hint string
---@field info string
---@field warn string
---@field git RosePineGit
---@field headings string|RosePineHeadings

---@class RosePineGit
---@field add string
---@field change string
---@field delete string
---@field dirty string
---@field ignore string
---@field merge string
---@field rename string
---@field stage string
---@field text string

---@class RosePineHeadings
---@field h1 string
---@field h2 string
---@field h3 string
---@field h4 string
---@field h5 string
---@field h6 string

---@type RosePineConfig
local config = {
	bold_vert_split = false,
	dark_variant = 'main',
	dim_nc_background = false,
	disable_background = false,
	disable_float_background = false,
	disable_italics = false,

	groups = {
		border = 'highlight_med',
		comment = 'muted',
		link = 'iris',
		punctuation = 'muted',

		error = 'love',
		hint = 'iris',
		info = 'foam',
		warn = 'gold',

		git_add = 'foam',
		git_change = 'rose',
		git_delete = 'love',
		git_dirty = 'rose',
		git_ignore = 'muted',
		git_merge = 'iris',
		git_rename = 'pine',
		git_stage = 'iris',
		git_text = 'rose',

		headings = {
			h1 = 'iris',
			h2 = 'foam',
			h3 = 'rose',
			h4 = 'gold',
			h5 = 'pine',
			h6 = 'foam',
		},
	},
}

---@param opts RosePineConfig
function M.setup(opts)
	opts = opts or {}
	vim.g.rose_pine_variant = opts.dark_variant or 'main'

	if opts.groups and type(opts.groups.headings) == 'string' then
		opts.groups.headings = {
			h1 = opts.groups.headings,
			h2 = opts.groups.headings,
			h3 = opts.groups.headings,
			h4 = opts.groups.headings,
			h5 = opts.groups.headings,
			h6 = opts.groups.headings,
		}
	end

	config.user_variant = opts.dark_variant or nil
	config = vim.tbl_deep_extend('force', config, opts)
end

function M.colorscheme()
	if vim.g.colors_name then
		vim.cmd('hi clear')
	end

	vim.g.colors_name = 'rose-pine'

	if show_init_messages then
		show_init_messages = false
	end

	local theme = require('colors.theme').get(config)
	for group, color in pairs(theme) do
		util.highlight(group, color)
	end
end

return M
