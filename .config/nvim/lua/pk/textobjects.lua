-- [5] nvim-treesitter-textobjects — 2.8k★, branch MAIN
--     Wspolny dla init.lua (terminal) i init-vscode.lua (VS Code).
--     Obiekty: af/if funkcja, ac/ic klasa, aa/ia argument (ia/aa jak w VSCodeVim).
--     Ruchy:   ]f/[f funkcja, ]c/[c klasa (konwencja LazyVim; w trybie diff
--              ]c/[c zostaja natywne).
--     NIE ustawiamy vim.g.no_plugin_maps — zabiloby ]] / [[ w markdownie.
--     Parsery instaluje pk/treesitter.lua (init.lua); VS Code korzysta z tych samych.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
})
require("nvim-treesitter-textobjects").setup({ select = { lookahead = true }, move = { set_jumps = true } })
for key, q in pairs({ af = "@function.outer", ["if"] = "@function.inner",
                      ac = "@class.outer",    ic = "@class.inner",
                      aa = "@parameter.outer", ia = "@parameter.inner" }) do
  vim.keymap.set({ "x", "o" }, key, function()
    require("nvim-treesitter-textobjects.select").select_textobject(q, "textobjects")
  end, { desc = q })
end
local function move(dir, q, native)
  return function()
    if native and vim.wo.diff then return vim.cmd.normal({ native, bang = true }) end
    require("nvim-treesitter-textobjects.move")["goto_" .. dir .. "_start"](q, "textobjects")
  end
end
vim.keymap.set({ "n", "x", "o" }, "]f", move("next",     "@function.outer"),       { desc = "nastepna funkcja" })
vim.keymap.set({ "n", "x", "o" }, "[f", move("previous", "@function.outer"),       { desc = "poprzednia funkcja" })
vim.keymap.set({ "n", "x", "o" }, "]c", move("next",     "@class.outer", "]c"),    { desc = "nastepna klasa" })
vim.keymap.set({ "n", "x", "o" }, "[c", move("previous", "@class.outer", "[c"),    { desc = "poprzednia klasa" })

-- ; i , powtarzaja tez ostatni ]f [f ]c [c — tak jak f/t. Kierunek jak w vimie:
-- ; = w te sama strone co ostatni ruch, , = w przeciwna.
-- f F t T trzeba owinac, inaczej ; po fx przestaje dzialac (pamieta tylko ruchy treesittera).
-- [[ ]] z markdowna sa natywne i tego nie obejmuje.
local rm = require("nvim-treesitter-textobjects.repeatable_move")
vim.keymap.set({ "n", "x", "o" }, ";", rm.repeat_last_move,          { desc = "powtorz ruch" })
vim.keymap.set({ "n", "x", "o" }, ",", rm.repeat_last_move_opposite, { desc = "powtorz ruch wstecz" })
vim.keymap.set({ "n", "x", "o" }, "f", rm.builtin_f_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "F", rm.builtin_F_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "t", rm.builtin_t_expr, { expr = true })
vim.keymap.set({ "n", "x", "o" }, "T", rm.builtin_T_expr, { expr = true })
