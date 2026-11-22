--[[
  vimtex-conceal – cycle through LaTeX concealment levels (off / light / full)
  Configures conceal_levels, keybindings, and symbols for Neovim.
]]

-- Conceal levels for VimTeX syntax highlighting.
-- Cycling order: off → light → full → off …
-- Each level sets vim.o.conceallevel and a table of conceal options that control
-- which parts of LaTeX markup are replaced by Unicode glyphs (e.g. `α` for Greek, `⅓` for fractions).
local conceal_levels = {
  {
    name = "off",
    conceallevel = 0,
    conceal_delims = {},
    -- No characters are hidden; raw LaTeX commands remain visible.
  },
  {
    name = "light",
    conceallevel = 2,
    conceal_delims = {},
    conceal = {
      accents = 1,       -- e.g. \acute{x} → ́
      ligatures = 1,     -- fi, fl, etc.
      cites = 0,         % citations shown as raw \cite{}
      fancy = 0,         % \subfloat, etc.
      texTabularChar = 0,
      spacing = 0,       % thin spaces, etc.
      greek = 1,         % Greek letters → α, β, …
      math_bounds = 0,   % delimiters like |, ⌊
      math_fracs = 1,    % fractions → ½, ⅓, etc.
      math_super_sub = 1,% superscripts/subscripts
      math_symbols = 1,  % +, =, ∫, etc.
      sections = 0,      % \section, etc.
      styles = 0,        % \mathrm, \mathcal, etc.
    },
  },
  {
    name = "full",
    conceallevel = 2,
    conceal_delims = {},
    conceal = {
      accents = 1,
      ligatures = 1,
      cites = 1,         % [ author, title ] instead of \cite{}
      fancy = 1,
      texTabularChar = 1,
      spacing = 1,
      greek = 1,
      math_bounds = 1,
      math_fracs = 1,
      math_super_sub = 1,
      math_symbols = 1,
      sections = 0,
      styles = 1,        % \mathrm → ℝ, etc.
    },
  },
}

-- Index of the currently active conceal level (starts at "light", i.e. conceal_levels[2]).
local conceal_idx = 2

-- Apply the alphabet conceal pairs for \mathsf and \vec commands (from original plugin).
local function sym(entries)
  local out = {}
  for i = 1, #entries do
    out[i] = { name = entries[i][1], mathmode = 1, concealchar = entries[i][2] }
  end
  return out
end

local function alphabet_pairs(base_cap, base_low)
  local out = {}
  for i = 0, 25 do
    out[#out + 1] = { string.char(65 + i), vim.fn.nr2char(base_cap + i) }
    out[#out + 1] = { string.char(97 + i), vim.fn.nr2char(base_low + i) }
  end
  return out
end

local sans_pairs = alphabet_pairs(0x1D5A0, 0x1D5CA)
local bold_pairs = alphabet_pairs(0x1D400, 0x1D41A)

local function apply_alphabet_conceals()
  if vim.bo.filetype ~= "tex" then
    return
  end
  pcall(vim.fn["vimtex#syntax#core#conceal_cmd_pairs"], "mathsf", sans_pairs)
  pcall(vim.fn["vimtex#syntax#core#conceal_cmd_pairs"], "vec", bold_pairs)
end

-- Math symbols extension (arrows, relations, etc.)
local math_symbols_ext = sym({
  { "longleftarrow", "⟵" }, { "longrightarrow", "⟶" }, { "longleftrightarrow", "⟷" },
  { "Longleftarrow", "⟸" }, { "Longrightarrow", "⟹" }, { "Longleftrightarrow", "⟺" },
  { "longmapsto", "⟼" },
  -- Variants
  { "mapsfrom", "↤" }, { "twoheadleftarrow", "↞" }, { "twoheadrightarrow", "↠" },
  { "leftarrowtail", "↢" }, { "rightarrowtail", "↣" }, { "leftleftarrows", "⇇" },
  { "rightrightarrows", "⇉" }, { "upuparrows", "⇈" }, { "downdownarrows", "⇊" },
  { "leftrightarrows", "⇆" }, { "rightleftarrows", "⇄" }, { "leftharpoons", "⇋" },
  { "nLeftarrow", "⇍" }, { "nRightarrow", "⇏" }, { "nLeftrightarrow", "⇎" },
  { "nleftarrow", "↚" }, { "nrightarrow", "↛" }, { "nleftrightarrow", "↮" },
  { "leftrightsquigarrow", "↭" }, { "rightsquigarrow", "⇝" },
  { "looparrowleft", "↫" }, { "looparrowright", "↬" },
  { "curvearrowleft", "↶" }, { "curvearrowright", "↷" },
  { "circlearrowleft", "↺" }, { "circlearrowright", "↻" },
  { "Lsh", "↰" }, { "Rsh", "↱" },
  -- Relations
  { "Subset", "⋐" }, { "Supset", "⋑" },
  { "precsim", "≾" }, { "succsim", "≿" },
  { "precapprox", "⪷" }, { "succapprox", "⪸" },
  { "lesssim", "≲" }, { "gtrsim", "≳" },
  { "lessapprox", "⪅" }, { "gtrapprox", "⪆" },
  { "nmid", "∤" }, { "nparallel", "∦" },
  { "Vdash", "⊩" }, { "Vvdash", "⊪" },
  { "Dashv", "⊫" }, { "nvdash", "⊬" }, { "nVdash", "⊮" },
  { "nvDash", "⊭" }, { "nDashv", "⊯" },
  { "trianglelefteq", "⊴" }, { "trianglerighteq", "⊵" },
  { "napprox", "≉" }, { "ncong", "≇" }, { "nequiv", "≢" },
  { "nsubset", "⊄" }, { "nsupset", "⊅" },
  { "nsubseteq", "⊈" }, { "nsupseteq", "⊉" },
  { "nprec", "⊀" }, { "nsucc", "⊁" },
  { "npreceq", "⋠" }, { "nsucceq", "⋡" },
  { "nleq", "≰" }, { "ngeq", "≱" },
  { "nsim", "≁" }, { "therefore", "∴" }, { "because", "∵" },
  { "between", "≬" }, { "pitchfork", "⋔" }, { "square", "□" },
  { "blacksquare", "■" }, { "lozenge", "◇" }, { "Diamond", "◇" },
  { "blacklozenge", "⧫" }, { "bigstar", "★" }, { "maltese", "✠" },
  { "checkmark", "✓" }, { "measuredangle", "∡" },
  { "sphericalangle", "∢" }, { "diameter", "⌀" },
  -- Operators
  { "dotplus", "∔" }, { "rtimes", "⋊" }, { "ltimes", "⋉" },
  { "divideontimes", "⋇" }, { "circledast", "⊛" }, { "circledcirc", "⊚" },
  { "circleddash", "⊝" }, { "boxdot", "⊡" }, { "boxminus", "⊟" },
  { "boxplus", "⊞" }, { "boxtimes", "⊠" }, { "barwedge", "⊼" },
  { "curlyvee", "⋏" }, { "curlywedge", "⋎" }, { "veebar", "⊻" },
  { "intercal", "⊺" }, { "uplus", "⊎" }, { "smallsetminus", "∖" },
  -- Integrals
  { "fint", "⨍" }, { "oiint", "∯" }, { "oiiint", "∰" },
  -- Macros propias del preámbulo de tareaestaca/soluciones
  { "eps", "ε" }, { "omg", "ω" }, { "Lmb", "Λ" }, { "hp", "ℏ" },
  { "vn", "𝐧" }, { "vp", "𝐩" }, { "vq", "𝐪" }, { "vr", "𝐫" },
  { "vx", "𝐱" },
})

-- Fraction and delimiter definitions for full conceal
local frac_guard = "1,2|1,3|2,3|1,4|1,5|2,5|3,5|4,5|1,6|5,6|1,8|3,8|5,8|7,8"
local math_delims_full = {}
for _, name in ipairs({ "frac", "dfrac", "tfrac" }) do
  math_delims_full[#math_delims_full + 1] = {
    name = name,
    nargs = 2,
    mathmode = 1,
    cchar_open = "",
    cchar_mid = "⁄",
    cchar_close = "",
    cmdre = name .. ">(" .. frac_guard .. ")@!",
  }
end
for _, item in ipairs({
  { name = "binom", nargs = 2, cchar_open = "(", cchar_mid = "|", cchar_close = ")" },
  { name = "bra", nargs = 1, cchar_open = "⟨", cchar_close = "|" },
  { name = "ket", nargs = 1, cchar_open = "|", cchar_close = "⟩" },
  { name = "braket", nargs = 2, cchar_open = "⟨", cchar_mid = "|", cchar_close = "⟩" },
  { name = "expval", nargs = 1, cchar_open = "⟨", cchar_close = "⟩" },
  { name = "mel", nargs = 3, cchar_open = "⟨", cchar_mid = "|", cchar_close = "⟩" },
}) do
  item.mathmode = 1
  item.argspell = 0
  math_delims_full[#math_delims_full + 1] = item
end

-- Set up conceal levels and keybindings for tex files.
local function setup()
  -- Apply alphabet concealments
  apply_alphabet_conceals()

  -- Set initial conceal level to "light" (conceal_levels[2])
  vim.g.vimtex_syntax_conceal = conceal_levels[2].conceal
  vim.g.vimtex_syntax_custom_cmds = math_symbols_ext
  vim.g.vimtex_syntax_custom_cmds_with_concealed_delims = conceal_levels[2].conceal_delims or {}
  vim.opt_local.conceallevel = conceal_levels[2].conceallevel
  if conceal_levels[2].conceal then
    vim.cmd("syntax clear")
    vim.cmd("runtime! syntax/tex.vim")
  end

  -- Keybinding to cycle conceal levels
  vim.keymap.set("n", "<localleader>lz", function()
    conceal_idx = conceal_idx % #conceal_levels + 1
    local lvl = conceal_levels[conceal_idx]
    vim.g.vimtex_syntax_custom_cmds = math_symbols_ext
    vim.g.vimtex_syntax_custom_cmds_with_concealed_delims = lvl.conceal_delims or {}
    vim.opt_local.conceallevel = lvl.conceallevel
    if lvl.conceal then
      vim.g.vimtex_syntax_conceal = lvl.conceal
      vim.cmd("syntax clear")
      vim.cmd("runtime! syntax/tex.vim")
    end
    apply_alphabet_conceals()
    vim.notify("Conceal: " .. lvl.name, vim.log.levels.INFO)
  end, { noremap = true, silent = true, desc = "Cycle conceal level (off/light/full)" })

  -- Optional: also map to leader if needed
  -- vim.keymap.set("n", "<leader>lz", ...)
end

return {
  setup = setup,
}