#!/usr/bin/env bash
# ============================================================================
#  Scala dotfiles-settings.json do settings.json VS Code.
#  - robi backup przed kazda zmiana
#  - klucze z dotfiles NADPISUJA istniejace; reszta twoich ustawien zostaje
#  - UWAGA: VS Code uzywa JSONC (komentarze + trailing commas). Skrypt je
#    usuwa przed parsowaniem, wiec KOMENTARZE Z TWOJEGO settings.json ZNIKNA.
#    Backup zostaje, wiec nic nie tracisz bezpowrotnie.
# ============================================================================
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/dotfiles-settings.json"
case "$(uname -s)" in
    Darwin) DST="$HOME/Library/Application Support/Code/User/settings.json" ;;
    Linux)  DST="$HOME/.config/Code/User/settings.json" ;;
    *) echo "Nieobslugiwany system"; exit 1 ;;
esac

[[ -f "$SRC" ]] || { echo "Brak $SRC"; exit 1; }
mkdir -p "$(dirname "$DST")"
[[ -f "$DST" ]] || echo '{}' > "$DST"

BAK="${DST}.bak.$(date +%Y%m%d-%H%M%S)"
cp "$DST" "$BAK"

python3 - "$SRC" "$DST" <<'PY'
import json, re, sys

def load_jsonc(path):
    with open(path, encoding='utf-8') as fh:
        raw = fh.read()
    # usun // komentarze (poza tymi w stringach) i /* */
    out, i, n = [], 0, len(raw)
    in_str = esc = False
    while i < n:
        c = raw[i]
        if in_str:
            out.append(c)
            if esc:            esc = False
            elif c == '\\':    esc = True
            elif c == '"':     in_str = False
            i += 1; continue
        if c == '"':
            in_str = True; out.append(c); i += 1; continue
        if c == '/' and i + 1 < n and raw[i+1] == '/':
            while i < n and raw[i] != '\n': i += 1
            continue
        if c == '/' and i + 1 < n and raw[i+1] == '*':
            i += 2
            while i + 1 < n and not (raw[i] == '*' and raw[i+1] == '/'): i += 1
            i += 2; continue
        out.append(c); i += 1
    txt = ''.join(out)
    txt = re.sub(r',(\s*[}\]])', r'\1', txt)   # trailing commas
    return json.loads(txt) if txt.strip() else {}

src_path, dst_path = sys.argv[1], sys.argv[2]
src, dst = load_jsonc(src_path), load_jsonc(dst_path)

added   = [k for k in src if k not in dst]
changed = [k for k in src if k in dst and dst[k] != src[k]]
dst.update(src)

with open(dst_path, 'w', encoding='utf-8') as fh:
    json.dump(dst, fh, indent=2, ensure_ascii=False)
    fh.write('\n')

for k in added:   print(f"  + {k}")
for k in changed: print(f"  ~ {k}")
print(f"\nDodane: {len(added)}, nadpisane: {len(changed)}")
PY

echo "Backup: $BAK"
echo "Cel:    $DST"
