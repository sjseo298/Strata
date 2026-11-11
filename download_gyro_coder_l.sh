#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
MODEL_DIR="$DATA_DIR/models/gyro-coder-l"
PACK_DIR="$DATA_DIR/packs/gyro-coder-l"
LOG_FILE="$DATA_DIR/download_gyro_coder_l.log"
TARGET_FILE="$MODEL_DIR/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf"
URL="https://huggingface.co/agentionai/Qwen3.8-Flash-Next-Gyro-Coder-GGUF/resolve/main/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf"

mkdir -p "$MODEL_DIR"
cd "$STRATA_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Descargando Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf (83.98 GB)..." > "$LOG_FILE"

curl -C - -L --retry 5 --retry-delay 3 -o "$TARGET_FILE" "$URL" >> "$LOG_FILE" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Descarga completada. Preparando pack en $PACK_DIR..." >> "$LOG_FILE"

.venv/bin/python tools/iq_pack.py \
  --gguf "$TARGET_FILE" \
  --out "$PACK_DIR" \
  --compat-bf16 >> "$LOG_FILE" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Generando configuración strata-gyro-coder-l.json..." >> "$LOG_FILE"

cat << 'EOF' > "$STRATA_DIR/strata-gyro-coder-l.json"
{
 "exe": "/Users/atlantis/Documents/Desarrollo/Strata/build-metal/strata",
 "args": [
  "--pack",
  "/Volumes/Samsung2T/strata/packs/gyro-coder-l",
  "--native",
  "/Volumes/Samsung2T/strata/models/gyro-coder-l/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf",
  "--ple-gguf",
  "/Volumes/Samsung2T/strata/models/gyro-coder-l/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf",
  "--expert-profile",
  "/Users/atlantis/Documents/Desarrollo/Strata/data/expert-profile.bin",
  "--expert-cache",
  "64",
  "--prefill",
  "auto",
  "--spec",
  "2",
  "--suffix-draft",
  "0",
  "--max-context",
  "32768",
  "--mmap-experts",
  "--vision"
 ],
 "cwd": "/Users/atlantis/Documents/Desarrollo/Strata",
 "tokenizer": "/Volumes/Samsung2T/strata/packs/gyro-coder-l/tokenizer",
 "model_name": "qwen3.8-flash-next-gyro-coder-l",
 "log": "/Users/atlantis/Documents/Desarrollo/Strata/strata-gyro-coder-l.log",
 "lib_dirs": [],
 "port": 8080,
 "backend": "metal",
 "env": {
  "STRATA_METAL_STREAM": "1"
 },
 "vision": {
  "exe": "/Users/atlantis/Documents/Desarrollo/Strata/build-vision/bin/strata-vision",
  "mmproj": "/Volumes/Samsung2T/strata/models/mmproj-Qwen3.8-Flash-Next-BF16.gguf",
  "model": "/Volumes/Samsung2T/strata/models/gyro-coder-l/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf",
  "gpu": true,
  "max_tokens": 1024
 }
}
EOF

cat << 'EOF' > "$STRATA_DIR/run-gyro-coder-l.sh"
#!/bin/sh
cd "/Users/atlantis/Documents/Desarrollo/Strata"
exec "/Users/atlantis/Documents/Desarrollo/Strata/.venv/bin/python" "/Users/atlantis/Documents/Desarrollo/Strata/serve/server.py" "--engine" "strata" "--config" "/Users/atlantis/Documents/Desarrollo/Strata/strata-gyro-coder-l.json" "--port" "8080" "--open"
EOF
chmod +x "$STRATA_DIR/run-gyro-coder-l.sh"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Gyro-Coder-L (83.98 GB) descargado, empaquetado y listo para inferencia." >> "$LOG_FILE"
