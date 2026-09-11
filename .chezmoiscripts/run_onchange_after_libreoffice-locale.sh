#!/bin/bash
# Pin LibreOffice locale / currency / date / decimal-separator defaults.
#
# These live in the user profile's registrymodifications.xcu, a 2.8 MB file
# LibreOffice rewrites wholesale on exit -- so it can't be checked in directly
# without churning on every unrelated setting change. Instead this patches just
# the keys below, idempotently. Edit a value here and chezmoi re-runs the
# script (run_onchange_ hashes its own contents).
set -euo pipefail

# --- desired settings -------------------------------------------------------
# path|name|value
SETTINGS='
/org.openoffice.Setup/L10N|ooSetupSystemLocale|de-DE
/org.openoffice.Setup/L10N|ooSetupCurrency|EUR-de-DE
/org.openoffice.Setup/L10N|DecimalSeparatorAsLocale|true
/org.openoffice.Setup/L10N|DateAcceptancePatterns|D.M.;D.M.Y
'
# ooLocale is deliberately left alone -- that is the UI language (en-US).
# ---------------------------------------------------------------------------

XCU="$HOME/.config/libreoffice/4/user/registrymodifications.xcu"

if [ ! -f "$XCU" ]; then
  echo "libreoffice-locale: no profile at $XCU yet, skipping"
  exit 0
fi

# LibreOffice holds the whole registry in memory and writes it back on exit,
# so patching underneath a running instance silently loses the changes.
if pgrep -x soffice.bin >/dev/null 2>&1; then
  echo "libreoffice-locale: LibreOffice is running -- close it and re-run 'chezmoi apply'"
  exit 0
fi

cp -f "$XCU" "$XCU.bak"

SETTINGS="$SETTINGS" python3 - "$XCU" <<'PY'
import os, re, sys

xcu = sys.argv[1]
with open(xcu, encoding="utf-8") as fh:
    doc = fh.read()

changed = []
for line in os.environ["SETTINGS"].strip().splitlines():
    path, name, want = line.split("|", 2)
    prop = (
        r'(<item oor:path="%s"><prop oor:name="%s"[^>]*>)'
        r'(?:<value[^>]*/>|<value[^>]*>.*?</value>)'
        % (re.escape(path), re.escape(name))
    )
    new = "<value>%s</value>" % want
    doc, n = re.subn(prop, lambda m: m.group(1) + new, doc, count=1)
    if n:
        changed.append("%s = %s" % (name, want))
    else:
        # Property absent from the profile -- append a fresh item.
        item = (
            '<item oor:path="%s"><prop oor:name="%s" oor:op="fuse">%s</prop></item>\n'
            % (path, name, new)
        )
        doc = doc.replace("</oor:items>", item + "</oor:items>", 1)
        changed.append("%s = %s (added)" % (name, want))

with open(xcu, "w", encoding="utf-8") as fh:
    fh.write(doc)

for c in changed:
    print("libreoffice-locale: %s" % c)
PY
