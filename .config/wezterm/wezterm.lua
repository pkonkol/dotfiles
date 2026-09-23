-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

--  Wariant "Term" = bez ligatur i bez zwezania, pod terminal.
--  Wariant "Nerd Font Mono" = z doszytymi ikonkami, staly advance.
--  Alternatywy (instaluje setup-mac.sh -b):
--    'IoskeleyMonoTerm Nerd Font Mono'  <- domyslne
--    'JetBrainsMono Nerd Font'          <- najlepszy z konwencjonalnych
--    'SauceCodePro Nerd Font'           <- Source Code Pro; nieco chudy
--    'Hack Nerd Font'                   <- grubsze kreski, klasyk
--    'Iosevka Term Nerd Font'           <- czysta Iosevka; za ciasna na kolumny
--  Porownanie w przegladarce: programmingfonts.org  /  codingfont.com
--
config.font = wezterm.font 'IoskeleyMonoTerm Nerd Font Mono'

--   wezterm ls-fonts --list-system | grep -i ioskeley
config.font_size = 14.0

config.line_height = 1.0
config.cell_width = 1.0

config.freetype_load_target = 'Normal'
config.freetype_render_target = 'HorizontalLcd'

config.color_scheme ='Srcery (Gogh)'

config.window_background_opacity = 0.99
config.window_decorations = 'TITLE|RESIZE'
config.window_padding = { left = 4, right = 4, top = 3, bottom = 2 }
config.scrollback_lines = 20000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

--config.default_prog = { '/opt/homebrew/bin/fish', '-l' }

return config
