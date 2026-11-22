-- init.lua
local config = require("vimtex-conceal")

local M = {}

function M.setup()
  -- Setup keybinding for tex files
  config.setup_keybinding()
end

return M
