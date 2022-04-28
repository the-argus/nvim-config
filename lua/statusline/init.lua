-- my statusline
-- adapted from https://elianiva.my.id/post/neovim-lua-statusline

require "io"

local M = {}
local api = vim.api
local fn = vim.fn


-- SEPARATORS AND SYMBOLS
local separators = {
    arrow = { '', '' },
    rounded = { '', '' },
    blank = { '', '' },
}
local active_sep = separators.blank

local symbols = {
    git = ""
}

-- COLORS ---------------------------------------------------------------------
-- (to be moved to a different file once i'm ready)
local set_hl = function(group, options)
  local bg = options.bg == nil and '' or 'guibg=' .. options.bg
  local fg = options.fg == nil and '' or 'guifg=' .. options.fg
  local gui = options.gui == nil and '' or 'gui=' .. options.gui

  vim.cmd(string.format('hi %s %s %s %s', group, bg, fg, gui))
end

local highlights = {
  {'StatusLine', { fg = '#3C3836', bg = '#EBDBB2' }},
  {'StatusLineNC', { fg = '#3C3836', bg = '#928374' }},
  {'Mode', { bg = '#928374', fg = '#1D2021', gui="bold" }},
  {'LineCol', { bg = '#928374', fg = '#1D2021', gui="bold" }},
  {'Git', { bg = '#504945', fg = '#EBDBB2' }},
  {'Filetype', { bg = '#504945', fg = '#EBDBB2' }},
  {'Filename', { bg = '#504945', fg = '#EBDBB2' }},
  {'ModeAlt', { bg = '#504945', fg = '#928374' }},
  {'GitAlt', { bg = '#3C3836', fg = '#504945' }},
  {'LineColAlt', { bg = '#504945', fg = '#928374' }},
  {'FiletypeAlt', { bg = '#3C3836', fg = '#504945' }},
}

for _, highlight in ipairs(highlights) do
  set_hl(highlight[1], highlight[2])
end

-- HIGHLIGHT GROUPS
M.colors = {
  active        = '%#StatusLine#',
  inactive      = '%#StatuslineNC#',
  mode          = '%#Mode#',
  mode_alt      = '%#ModeAlt#',
  git           = '%#Git#',
  git_alt       = '%#GitAlt#',
  filetype      = '%#Filetype#',
  filetype_alt  = '%#FiletypeAlt#',
  line_col      = '%#LineCol#',
  line_col_alt  = '%#LineColAlt#',
}

-- TRUNCATION -----------------------------------------------------------------

M.trunc_width = setmetatable({
    mode       = 80,
    git_status = 90,
    filename   = 140,
    line_col   = 60,
}, {
    __index = function()
        return 80 -- handle edge cases, if there's any
    end
})

M.is_truncated = function(_, width)
    local current_width = api.nvim_win_get_width(0)
    return current_width < width
end

-- MODES MODULES --------------------------------------------------------------
M.modes = setmetatable({
  ['n']  = {'Normal', 'N'};
  ['no'] = {'N·Pending', 'N·P'} ;
  ['v']  = {'Visual', 'V' };
  ['V']  = {'V·Line', 'V·L' };
  [''] = {'V·Block', 'V·B'};
  ['s']  = {'Select', 'S'};
  ['S']  = {'S·Line', 'S·L'};
  [''] = {'S·Block', 'S·B'};
  ['i']  = {'Insert', 'I'};
  ['ic'] = {'Insert', 'I'};
  ['R']  = {'Replace', 'R'};
  ['Rv'] = {'V·Replace', 'V·R'};
  ['c']  = {'Command', 'C'};
  ['cv'] = {'Vim·Ex ', 'V·E'};
  ['ce'] = {'Ex ', 'E'};
  ['r']  = {'Prompt ', 'P'};
  ['rm'] = {'More ', 'M'};
  ['r?'] = {'Confirm ', 'C'};
  ['!']  = {'Shell ', 'S'};
  ['t']  = {'Terminal ', 'T'};
}, {
  __index = function()
      return {'Unknown', 'U'} -- handle edge cases
  end
})

-- nvim function to actuall retrieve the current mode as a string
-- accounts for the need to truncate
M.get_current_mode = function()
  local current_mode = api.nvim_get_mode().mode

  if self:is_truncated(self.trunc_width.mode) then
    return string.format(' %s ', modes[current_mode][2]):upper()
  end

  return string.format(' %s ', modes[current_mode][1]):upper()
end



-- GIT BRANCH MODULE ----------------------------------------------------------

M.get_git_status = function (self)
    local path = vim.fn.expand('%')
    local outfile = io.popen("cd " .. path .. " && git rev-parse --abbrev-ref HEAD")
    local branchname = outfile:read("*a")
    outfile:close()
    if self:is_truncated(self.trunc_width.git_status) then
        return string.format(' ' .. symbols.git .. ' %s', branchname)
    end

    return string.format(' ' .. symbols.git .. ' %s', branchname)
end

-- FILENAME MODULE ------------------------------------------------------------

M.get_filename = function(self)
    if self:is_truncated(self.trunc_width.filename) then return " %<%f " end
    return " %<%F "
end

-- FILETYPE ICON --------------------------------------------------------------

M.get_filetype = function()
    local file_name, file_ext = fn.expand("%:t"), fn.expand("%:e")
    local icon = require'nvim-web-devicons'.get_icon(
        file_name, file_ext, { default = true })
    local filetype = vim.bo.filetype

    if filetype == '' then return '' end
    return string.format(' %s %s ', icon, filetype):lower()
end
