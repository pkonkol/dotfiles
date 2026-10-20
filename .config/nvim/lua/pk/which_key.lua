-- [1] which-key — folke, 7.3k★
--     Po wcisnieciu prefiksu (<leader>, g, z, ], [, ", ') pokazuje, co dalej.
--     Sam robi za sciage do wszystkich pozostalych pluginow.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("folke/which-key.nvim") })
require("which-key").setup({})
vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "skroty tego bufora" })
