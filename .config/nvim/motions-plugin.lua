-- ===========================================================================
--  motions-plugin.lua — config WTYCZKI Vim Motions (Obsidian), nie nvima.
--  Wtyczka wykonuje go we wlasnej piaskownicy Lua 5.3:
--  Settings -> Vim Motions -> Lua config path. nvim laduje init-obsidian.lua.
--
--  Leader stad trafia do wtyczki (picker <leader>f*, grupy which-key) i do
--  generowanego lua/vim_motions.lua, ktory ustawia go nvimowi.
--  Domyslny leader wtyczki to '\'; spacja jak w init.lua i kickstart.nvim.
-- ===========================================================================
vim.g.mapleader = " "
