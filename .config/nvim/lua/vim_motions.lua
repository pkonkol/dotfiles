-- vim-motions:generated
--
-- Generated from your Vim Motions settings. Regenerating overwrites
-- this file, so edit your own configuration instead of this one.
--
-- Opt in by adding this line to your init.lua:
--     require('vim_motions')
--
-- Every block below is guarded, so requiring this file is safe even
-- with none of these plugins installed. Vim Motions never installs
-- them; it only configures what you already have. If you already
-- configure one of them yourself, delete that block or place your
-- own setup after the require.

vim.g.mapleader = ' '
vim.opt.textwidth = 100

-- Surround
if pcall(require, 'nvim-surround') then
    require('nvim-surround').setup({})
end

-- Yank-ring paste cycling
if pcall(require, 'yanky') then
    require('yanky').setup({})
    vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
    vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
    vim.keymap.set('n', '<C-p>', '<Plug>(YankyPreviousEntry)')
    vim.keymap.set('n', '<C-n>', '<Plug>(YankyNextEntry)')
end

-- Flash motions
if pcall(require, 'flash') then
    require('flash').setup({})
    vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
        require('flash').jump()
    end)
end

-- EasyMotion / Hop
if pcall(require, 'flash') then
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader><leader>', function()
        require('flash').jump({ search = { mode = 'search' } })
    end)
end

-- Snippets
if pcall(require, 'luasnip') then
    local luasnip = require('luasnip')
    local from_vscode = require('luasnip.loaders.from_vscode')
    for _, path in ipairs({ '/Users/piotr.konkol/.config/nvim/lua/vim-motions-snippets/global.json', '/Users/piotr.konkol/.config/nvim/lua/vim-motions-snippets/obsidian-markdown.json' }) do
        pcall(from_vscode.load_standalone, { path = path })
    end
    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
        if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            vim.api.nvim_feedkeys(vim.keycode('<Tab>'), 'n', false)
        end
    end)
    vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
        if luasnip.jumpable(-1) then luasnip.jump(-1) end
    end)
end

-- Replace-with-register
if pcall(require, 'mini.operators') then
    require('mini.operators').setup({ replace = { prefix = 'gr' } })
end
