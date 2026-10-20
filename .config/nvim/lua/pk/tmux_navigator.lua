-- vim-tmux-navigator — 6.3k★. Ctrl+h/j/k/l przechodzi miedzy oknami nvima,
-- a na krawedzi przeskakuje do sasiedniego panelu tmuxa (druga polowa siedzi
-- w .tmux.conf jako plugin tpm). Poza tmuxem dziala jak zwykle Ctrl+w h/j/k/l.
-- Skroty ustawiamy sami, bez domyslnego Ctrl+\ (poprzedni panel).
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("christoomey/vim-tmux-navigator") })
vim.g.tmux_navigator_no_mappings = 1
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  { desc = "okno/panel tmux w lewo" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>",  { desc = "okno/panel tmux w dol" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>",    { desc = "okno/panel tmux w gore" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "okno/panel tmux w prawo" })
