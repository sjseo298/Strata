#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
cd "$STRATA_DIR"

# ==========================================
# 1. Completar Gyro-Coder-L (restan ~8.5 GB)
# ==========================================
CODER_DIR="$DATA_DIR/models/gyro-coder-l"
CODER_PACK="$DATA_DIR/packs/gyro-coder-l"
CODER_FILE="$CODER_DIR/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf"
CODER_URL="https://huggingface.co/agentionai/Qwen3.8-Flash-Next-Gyro-Coder-GGUF/resolve/main/Qwen3.8-Flash-Next-Gyro-Coder-L-TQ3_0.gguf"
CODER_LOG="$DATA_DIR/download_gyro_coder_l.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reanudando descarga de Gyro-Coder-L con HTTP/1.1 (restan ~8.5 GB)..." >> "$CODER_LOG"

until curl -C - --http1.1 -L --retry 10 --retry-delay 3 -o "$CODER_FILE" "$CODER_URL" >> "$CODER_LOG" 2>&1; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Conexión interrumpida, reanudando en 3s..." >> "$CODER_LOG"
    sleep 3
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gyro-Coder-L descargado al 100%. Generando pack..." >> "$CODER_LOG"

.venv/bin/python tools/iq_pack.py \
  --gguf "$CODER_FILE" \
  --out "$CODER_PACK" \
  --compat-bf16 >> "$CODER_LOG" 2>&1

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
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Gyro-Coder-L listo para inferencia." >> "$CODER_LOG"

# ==========================================
# 2. Descargar y preparar Gyro-L (108.32 GB)
# ==========================================
GYRO_L_DIR="$DATA_DIR/models/gyro-l"
GYRO_L_PACK="$DATA_DIR/packs/gyro-l"
GYRO_L_FILE="$GYRO_L_DIR/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf"
GYRO_L_URL="https://huggingface.co/agentionai/Qwen3.8-Flash-Next-Gyro-GGUF/resolve/main/Qwen3.8-Flash-Next-Gyro-L-TQ3_0.gguf"
GYRO_L_LOG="$DATA_DIR/download_gyro_l.log"

mkdir -p "$GYRO_L_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Descargando Gyro-L con HTTP/1.1 (108.32 GB)..." > "$GYRO_L_LOG"

until curl -C - --http1.1 -L --retry 10 --retry-delay 3 -o "$GYRO_L_FILE" "$GYRO_L_URL" >> "$GYRO_L_LOG" 2>&1; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Conexión interrumpida, reanudando en 3s..." >> "$GYRO_L_LOG"
    sleep 3
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gyro-L descargado al 100%. Generando pack..." >> "$GYRO_L_LOG"

.venv/bin/python tools/iq_pack.py \
  --gguf "$GYRO_L_FILE" \
  --out "$GYRO_L_PACK" \
  --compat-bf16 >> "$GYRO_L_LOG" 2>&1

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

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Gyro-L listo para inferencia." >> "$GYRO_L_LOG"
