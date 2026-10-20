-- [L] LSP
--     Podstawowe skroty LSP SA JUZ WBUDOWANE w Neovim 0.11+ i dzialaja
--     teraz (masz wlaczone ty, ruff, terraformls) — bez zadnego kodu:
--       K       dokumentacja pod kursorem     CTRL-]  idz do definicji
--       grr     referencje                    grn     zmien nazwe wszedzie
--       gra     akcje / szybkie poprawki      gri     implementacja
--       grt     definicja typu                gO      symbole w pliku
--       gq{ruch} formatuj przez LSP           CTRL-S  (insert) sygnatura funkcji
--     Ponizej tylko dodatki z kickstarta.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("pk-lsp-attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function map(l, r, d) vim.keymap.set("n", l, r, { buffer = ev.buf, desc = "LSP: " .. d }) end
    map("grD", vim.lsp.buf.declaration, "deklaracja")
    -- podswietl wszystkie wystapienia symbolu pod kursorem, gdy kursor stoi
    if client and client:supports_method("textDocument/documentHighlight", ev.buf) then
      local g = vim.api.nvim_create_augroup("pk-lsp-highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { buffer = ev.buf, group = g, callback = vim.lsp.buf.document_highlight })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { buffer = ev.buf, group = g, callback = vim.lsp.buf.clear_references })
    end
    -- podpowiedzi typow wstawione w tekst (wlacz/wylacz)
    if client and client:supports_method("textDocument/inlayHint", ev.buf) then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, "przelacz podpowiedzi typow")
    end
  end,
})
