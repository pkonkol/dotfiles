-- [4] gitsigns — lewis6991, 7.1k★
--     Zmiany gita przy numerach linii + operacje na hunkach.
--     ]h/[h jak w LazyVim (README gitsigns proponuje ]c, ale ten koliduje z diffem).
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
require("gitsigns").setup({
  on_attach = function(buf)
    local gs = require("gitsigns")
    local function map(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
    map("]h", function() gs.nav_hunk("next") end, "nastepny hunk")
    map("[h", function() gs.nav_hunk("prev") end, "poprzedni hunk")
    map("<leader>hs", gs.stage_hunk,          "stage hunk")
    map("<leader>hr", gs.reset_hunk,          "cofnij hunk")
    map("<leader>hp", gs.preview_hunk_inline, "podglad hunka")
    map("<leader>hb", gs.blame_line,          "blame linii")
  end,
})
require("which-key").add({ { "<leader>h", group = "git hunk" } })
