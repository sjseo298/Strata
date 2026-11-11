#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
LOG_FILE="/Volumes/Samsung2T/strata/download_suite.log"

cd "$STRATA_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [4/4] Descargando y preparando Qwen3.8-Flash-Next IQ3_XXS..." >> "$LOG_FILE"
.venv/bin/python setup.py --setup --family qwen --model IQ3_XXS --data-dir "$DATA_DIR" --no-start --yes >> "$LOG_FILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [4/4] ✔ IQ3_XXS completado con éxito." >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Suite completa de 4 modelos Strata descargada y lista en $DATA_DIR." >> "$LOG_FILE"
