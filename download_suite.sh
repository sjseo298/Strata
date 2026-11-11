#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
LOG_FILE="/Volumes/Samsung2T/strata/download_suite.log"

cd "$STRATA_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reanudando descarga de la suite en $DATA_DIR..." >> "$LOG_FILE"

# 1. Qwen3.8-Flash-Next Q2_0 (ya completado)
if [ -d "$DATA_DIR/packs/q2_0" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [1/4] ✔ Q2_0 ya está completado y preparado." >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [1/4] Descargando Q2_0..." >> "$LOG_FILE"
    .venv/bin/python setup.py --setup --family qwen --model Q2_0 --data-dir "$DATA_DIR" --no-start --yes >> "$LOG_FILE" 2>&1
fi

# 2. Unsloth Dynamic UD-IQ1_M (68.0 GB - Modelo Coder / 1-bit)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [2/4] Descargando y preparando Unsloth UD-IQ1_M..." >> "$LOG_FILE"
.venv/bin/python setup.py --setup --family unsloth --model UD-IQ1_M --data-dir "$DATA_DIR" --no-start --yes >> "$LOG_FILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [2/4] ✔ Unsloth UD-IQ1_M completado con éxito." >> "$LOG_FILE"

# 3. Gyro-S (58.5 GB - Trellis / Compacto)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [3/4] Descargando y preparando Gyro-S..." >> "$LOG_FILE"
.venv/bin/python setup.py --setup --family gyro --model Gyro-S --data-dir "$DATA_DIR" --no-start --yes >> "$LOG_FILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [3/4] ✔ Gyro-S completado con éxito." >> "$LOG_FILE"

# 4. Qwen3.8-Flash-Next IQ3_XXS (75.8 GB - Alta precisión)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [4/4] Descargando y preparando Qwen3.8-Flash-Next IQ3_XXS..." >> "$LOG_FILE"
.venv/bin/python setup.py --setup --family qwen --model IQ3_XXS --data-dir "$DATA_DIR" --no-start --yes >> "$LOG_FILE" 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [4/4] ✔ IQ3_XXS completado con éxito." >> "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Suite completa de modelos Strata descargada y lista en $DATA_DIR." >> "$LOG_FILE"
