#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
CODER_LOG="$DATA_DIR/download_gyro_coder_l.log"
GYRO_L_LOG="$DATA_DIR/download_gyro_l.log"

MODEL_DIR="$DATA_DIR/models/gyro-l"
PACK_DIR="$DATA_DIR/packs/gyro-l"
TARGET_FILE="$MODEL_DIR/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf"
URL="https://huggingface.co/agentionai/Qwen3.8-Flash-Next-Gyro-GGUF/resolve/main/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Esperando a que Gyro-Coder-L termine su empaquetado..." > "$GYRO_L_LOG"
while true; do
    if grep -q "listo para inferencia" "$CODER_LOG" 2>/dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gyro-Coder-L finalizado con éxito. Iniciando Gyro-L..." >> "$GYRO_L_LOG"
        break
    fi
    sleep 15
done

mkdir -p "$MODEL_DIR"
cd "$STRATA_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Descargando Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf (108.32 GB)..." >> "$GYRO_L_LOG"
curl -C - -L --retry 5 --retry-delay 3 -o "$TARGET_FILE" "$URL" >> "$GYRO_L_LOG" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Descarga de Gyro-L completada. Preparando pack en $PACK_DIR..." >> "$GYRO_L_LOG"
.venv/bin/python tools/iq_pack.py \
  --gguf "$TARGET_FILE" \
  --out "$PACK_DIR" \
  --compat-bf16 >> "$GYRO_L_LOG" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Generando configuración strata-gyro-l.json..." >> "$GYRO_L_LOG"

cat << 'EOF' > "$STRATA_DIR/strata-gyro-l.json"
{
 "exe": "/Users/atlantis/Documents/Desarrollo/Strata/build-metal/strata",
 "args": [
  "--pack",
  "/Volumes/Samsung2T/strata/packs/gyro-l",
  "--native",
  "/Volumes/Samsung2T/strata/models/gyro-l/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf",
  "--ple-gguf",
  "/Volumes/Samsung2T/strata/models/gyro-l/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf",
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
 "tokenizer": "/Volumes/Samsung2T/strata/packs/gyro-l/tokenizer",
 "model_name": "qwen3.8-flash-next-gyro-l",
 "log": "/Users/atlantis/Documents/Desarrollo/Strata/strata-gyro-l.log",
 "lib_dirs": [],
 "port": 8080,
 "backend": "metal",
 "env": {
  "STRATA_METAL_STREAM": "1"
 },
 "vision": {
  "exe": "/Users/atlantis/Documents/Desarrollo/Strata/build-vision/bin/strata-vision",
  "mmproj": "/Volumes/Samsung2T/strata/models/mmproj-Qwen3.8-Flash-Next-BF16.gguf",
  "model": "/Volumes/Samsung2T/strata/models/gyro-l/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf",
  "gpu": true,
  "max_tokens": 1024
 }
}
EOF

cat << 'EOF' > "$STRATA_DIR/run-gyro-l.sh"
#!/bin/sh
cd "/Users/atlantis/Documents/Desarrollo/Strata"
exec "/Users/atlantis/Documents/Desarrollo/Strata/.venv/bin/python" "/Users/atlantis/Documents/Desarrollo/Strata/serve/server.py" "--engine" "strata" "--config" "/Users/atlantis/Documents/Desarrollo/Strata/strata-gyro-l.json" "--port" "8080" "--open"
EOF
chmod +x "$STRATA_DIR/run-gyro-l.sh"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Gyro-L (108.32 GB) descargado, empaquetado y listo para inferencia." >> "$GYRO_L_LOG"
