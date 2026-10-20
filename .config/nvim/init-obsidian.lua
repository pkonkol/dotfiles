-- ===========================================================================
--  init-obsidian.lua — nvim dla Obsidiana, TYLKO przy wlaczonym
--  Settings -> Vim Motions -> Vim engine -> "Use Neovim backend".
--
--  Domyslnie backend jest wylaczony: most motions nie przekazuje myszy do nvima
--  (klik nie przesuwa kursora). Surround, flash, yank-ring, dial, which-key,
--  picker i snippety wtyczka ma wbudowane — wlacza sie je w jej ustawieniach,
--  a leader ustawia motions-plugin.lua.
-- ===========================================================================
vim.g.mapleader = " "
vim.o.clipboard = "unnamedplus"

-- Most wysyla Cmd+V jako <D-v>; nvim domyslnie nic z nim nie robi
vim.keymap.set({ "i", "c" }, "<D-v>", "<C-r><C-o>+", { desc = "wklej ze schowka" })
vim.keymap.set({ "n", "x" }, "<D-v>", '"+p',         { desc = "wklej ze schowka" })
