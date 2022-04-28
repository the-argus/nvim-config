--- Utilities for debugging and convenience.

local M = {}

--- Checks if a path actually exists.
-- @param path the path that needs to be checked
-- @return boolean true if exists false, otherwise
-- @see help empty()
-- @see help glob()
function M.exists(path)
  if vim.fn.empty(vim.fn.glob(path)) > 0 then
    return false
  end
  return true
end

--- Buffer acts like browser tabs. Closing the last buffer will essentially
--- close the editor.
-- @see Adapted from https://is.gd/zosxpN
function M.delete_buffer()
  local buflisted = vim.fn.getbufinfo { buflisted = 1 }
  local cur_winnr, cur_bufnr = vim.fn.winnr(), vim.fn.bufnr()
  if #buflisted < 2 then
    cmd "confirm qall"
    return
  end
  for _, winid in ipairs(vim.fn.getbufinfo(cur_bufnr)[1].windows) do
    cmd(string.format("%d wincmd w", vim.fn.win_id2win(winid)))
    cmd(cur_bufnr == buflisted[#buflisted].bufnr and "bp" or "bn")
  end
  cmd(string.format("%d wincmd w", cur_winnr))
  local is_terminal = vim.fn.getbufvar(cur_bufnr, "&buftype") == "terminal"
  cmd(is_terminal and "bd! #" or "silent! confirm bd #")
end

return M

-- vim:ft=lua
