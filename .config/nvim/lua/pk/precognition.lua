-- precognition — nauka vima: podpowiedzi, gdzie wyladujesz po ruchu
-- Bylo: opts = { highlightFullVirtLine = true } w specu (ignorowane przez
-- vim.pack) + toggle() bez setup(). startVisible domyslnie = true.
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({ gh("tris203/precognition.nvim") })
require("precognition").setup({ highlightFullVirtLine = true })

-- ===========================================================================
--  [P] PODPOWIEDZI SKOKOW W KOLUMNIE ZNAKOW — dopelnienie precognition
--  precognition ma na sztywno tylko 4 podpowiedzi w kolumnie: gg G { }
--  (hint_plan.lua, bez API do dodawania nowych). Ten blok dorysowuje obok
--  nich: ]] [[ (naglowki markdown) oraz ]f [f ]c [c (funkcje, klasy).
--  Liczone treesitterem tylko w widocznym fragmencie — nie zmienia stanu
--  ; , ani pozycji kursora. Wlacza/wylacza sie razem z :Precognition toggle.
-- ===========================================================================
local jh_ns = vim.api.nvim_create_namespace("pk-jump-hints")
local jh_md = vim.treesitter.query.parse("markdown", "(atx_heading) @h (setext_heading) @h")

local function jh_rows(query, capture, buf, root, top, bot)
  local rows = {}
  for id, node in query:iter_captures(root, buf, top, bot) do
    if query.captures[id] == capture then rows[#rows + 1] = (node:range()) end
  end
  table.sort(rows)
  return rows
end

local function jh_render()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, jh_ns, 0, -1)
  if vim.bo[buf].buftype ~= "" or not require("precognition").is_visible() then return end
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local top, bot = vim.fn.line("w0") - 1, vim.fn.line("w$")
  local root = parser:parse({ top, bot })[1]:root()
  local lang = parser:lang()
  local marks = {}
  local function nearest(rows, nxt_txt, prv_txt)
    local prv, nxt
    for _, r in ipairs(rows) do
      if r < row then prv = r elseif r > row and not nxt then nxt = r end
    end
    if nxt then marks[nxt] = marks[nxt] or nxt_txt end
    if prv then marks[prv] = marks[prv] or prv_txt end
  end
  if lang == "markdown" then nearest(jh_rows(jh_md, "h", buf, root, top, bot), "]]", "[[") end
  local tq = vim.treesitter.query.get(lang, "textobjects")
  if tq then
    nearest(jh_rows(tq, "function.outer", buf, root, top, bot), "]f", "[f")
    nearest(jh_rows(tq, "class.outer", buf, root, top, bot), "]c", "[c")
  end
  for r, txt in pairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, jh_ns, r, 0, { sign_text = txt, sign_hl_group = "Comment", priority = 5 })
  end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter", "WinScrolled", "TextChanged", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("pk-jump-hints", { clear = true }),
  callback = function() pcall(jh_render) end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "pk-jump-hints",
  callback = function(ev) vim.api.nvim_buf_clear_namespace(ev.buf, jh_ns, 0, -1) end,
})
