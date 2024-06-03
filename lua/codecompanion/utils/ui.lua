local log = require("codecompanion.utils.log")

local api = vim.api

local M = {}

M.set_virtual_text = function(bufnr, ns_id, message, opts)
  local defaults = {
    hl_group = "CodeCompanionVirtualText",
    virt_text_pos = "eol",
  }

  opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  api.nvim_buf_set_extmark(bufnr, ns_id, api.nvim_buf_line_count(bufnr) - 1, 0, {
    virt_text = { { message, opts.hl_group } },
    virt_text_pos = opts.virt_text_pos,
  })
end

---@param bufnr number
---@return boolean
M.buf_is_empty = function(bufnr)
  return api.nvim_buf_line_count(bufnr) == 1 and api.nvim_buf_get_lines(bufnr, 0, -1, false)[1] == ""
end

---@param bufnr number
---@return boolean
M.buf_is_active = function(bufnr)
  return api.nvim_get_current_buf() == bufnr
end

---@param bufnr nil|integer
---@return integer[]
M.buf_list_wins = function(bufnr)
  local wins = {}

  if not bufnr or bufnr == 0 then
    bufnr = api.nvim_get_current_buf()
  end

  for _, winid in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_is_valid(winid) and api.nvim_win_get_buf(winid) == bufnr then
      table.insert(wins, winid)
    end
  end

  return wins
end

---@param winid? number
M.scroll_to_end = function(winid)
  winid = winid or 0
  local bufnr = api.nvim_win_get_buf(winid)
  local lnum = api.nvim_buf_line_count(bufnr)
  local last_line = api.nvim_buf_get_lines(bufnr, -2, -1, true)[1]
  api.nvim_win_set_cursor(winid, { lnum, api.nvim_strwidth(last_line) })
end

---@param bufnr nil|integer
M.buf_scroll_to_end = function(bufnr)
  for _, winid in ipairs(M.buf_list_wins(bufnr or 0)) do
    M.scroll_to_end(winid)
  end
end

---@param bufnr nil|integer
---@return nil|integer
M.buf_get_win = function(bufnr)
  for _, winid in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end
end

---Source: https://github.com/stevearc/oil.nvim/blob/dd432e76d01eda08b8658415588d011009478469/lua/oil/layout.lua#L22C8-L22C8
---@return integer
M.get_editor_height = function()
  local editor_height = vim.o.lines - vim.o.cmdheight
  -- Subtract 1 if tabline is visible
  if vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #api.nvim_list_tabpages() > 1) then
    editor_height = editor_height - 1
  end
  -- Subtract 1 if statusline is visible
  if vim.o.laststatus >= 2 or (vim.o.laststatus == 1 and #api.nvim_tabpage_list_wins(0) > 1) then
    editor_height = editor_height - 1
  end
  return editor_height
end

local function get_max_lengths(items, format)
  local max_lengths = {}
  for _, item in ipairs(items) do
    local formatted = format(item)
    for i, field in ipairs(formatted) do
      local field_length = string.len(field)
      max_lengths[i] = math.max(max_lengths[i] or 0, field_length)
    end
  end
  return max_lengths
end

---@param str string
---@param max_length number
---@param padding number|nil
local function pad_string(str, max_length, padding)
  local padding_needed = max_length - string.len(str)

  if padding and padding_needed < padding then
    padding_needed = padding_needed + padding
  end

  if padding_needed > 0 then
    return str .. string.rep(" ", padding_needed)
  else
    return str
  end
end

local function pad_item(item, max_lengths)
  local padded_item = {}
  for i, field in ipairs(item) do
    if max_lengths[i] then -- Skip padding if there's no max length for this field
      padded_item[i] = pad_string(field, max_lengths[i])
    else
      padded_item[i] = field
    end
  end
  return table.concat(padded_item, " │ ")
end

---@param items table
---@param opts table
function M.selector(items, opts)
  log:trace("Opening selector")

  local max_lengths = get_max_lengths(items, opts.format)

  local select_opts = {
    prompt = opts.prompt,
    kind = "codecompanion.nvim",
    format_item = function(item)
      local formatted = opts.format(item)
      return pad_item(formatted, max_lengths)
    end,
  }

  -- Check if telescope exists and add telescope-specific options if available
  if pcall(require, "telescope.themes") then
    select_opts.telescope = require("telescope.themes").get_cursor({
      layout_config = {
        width = opts.width,
        height = opts.height,
      },
    })
  end

  vim.ui.select(items, select_opts, function(selected)
    if not selected then
      return
    end

    return opts.callback(selected)
  end)
end

---@param winid number
---@param opts table
function M.get_win_options(winid, opts)
  local options = {}
  for k, _ in pairs(opts) do
    options[k] = api.nvim_get_option_value(k, { scope = "local", win = winid })
  end

  return options
end

---@param winid number
---@param opts table
function M.set_win_options(winid, opts)
  for k, v in pairs(opts) do
    api.nvim_set_option_value(k, v, { scope = "local", win = winid })
  end
end

---@param bufnr number
---@param opts table
function M.set_buf_options(bufnr, opts)
  for k, v in pairs(opts) do
    api.nvim_buf_set_option(bufnr, k, v)
  end
end

return M
