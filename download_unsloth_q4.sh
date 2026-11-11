#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
LOG_FILE="$DATA_DIR/download_unsloth_q4.log"

cd "$STRATA_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando descarga y preparación de Unsloth UD-Q4_K_XL (111.3 GB)..." > "$LOG_FILE"

.venv/bin/python setup.py \
  --setup \
  --family unsloth \
  --model UD-Q4_K_XL \
  --data-dir "$DATA_DIR" \
  --context 262144 \
  --vision yes \
  --no-start \
  --yes >> "$LOG_FILE" 2>&1

# Asegurar max-context 262144 en el config generado
python3 -c '
import json, glob
cfgs = glob.glob("/Users/atlantis/Documents/Desarrollo/Strata/strata-unsloth-ud-q4_k_xl*.json")
for c in cfgs:
    with open(c) as f:
        d = json.load(f)
    args = d.get("args", [])
    if "--max-context" in args:
        idx = args.index("--max-context")
        args[idx + 1] = "262144"
    else:
        args.extend(["--max-context", "262144"])
    d["args"] = args
    with open(c, "w") as f:
        json.dump(d, f, indent=1)
    print("Sincronizado 262144 en:", c)
' >> "$LOG_FILE" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Unsloth UD-Q4_K_XL preparado y listo para inferencia en Metal." >> "$LOG_FILE"
