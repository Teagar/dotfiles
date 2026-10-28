 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#111111',
    base02 = '#1b1b1b',
    base03 = '#5a5a5a',
    base04 = '#8c8c8c',
    base05 = '#c8c8c8',
    base06 = '#c8c8c8',
    base07 = '#c8c8c8',
    base08 = '#c75c5c',
    base09 = '#8e70a6',
    base0A = '#6e9f45',
    base0B = '#7b4baf',
    base0C = '#c496e9',
    base0D = '#be96e9',
    base0E = '#bce996',
    base0F = '#d6f4be',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#c8c8c8',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#5a5a5a',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#c8c8c8',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#5a5a5a',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#7b4baf',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#8c8c8c',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#7b4baf' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#6e9f45' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#8e70a6' })
  hi('TelescopeSelection',      { fg = '#c8c8c8',          bg = '#1b1b1b' })
  hi('TelescopeSelectionCaret', { fg = '#7b4baf',             bg = '#1b1b1b' })
  hi('TelescopeMatching',       { fg = '#7b4baf',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#c8c8c8',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#5a5a5a',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#c8c8c8',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#7b4baf',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#7b4baf' })
  hi('MiniPickMatchCurrent',      { fg = '#c8c8c8',          bg = '#1b1b1b' })
  hi('MiniPickPromptCaret', { fg = '#7b4baf',             bg = '#1b1b1b' })
  hi('MiniPickMatchRanges',       { fg = '#7b4baf',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
