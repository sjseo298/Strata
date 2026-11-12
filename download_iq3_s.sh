#!/bin/bash
set -eo pipefail

STRATA_DIR="/Users/atlantis/Documents/Desarrollo/Strata"
DATA_DIR="/Volumes/Samsung2T/strata"
cd "$STRATA_DIR"

MODEL_DIR="$DATA_DIR/models/IQ3_S"
PACK_DIR="$DATA_DIR/packs/iq3_s"
LOG_FILE="$DATA_DIR/download_iq3_s.log"

SHARD1_FILE="$MODEL_DIR/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00001-of-00002.gguf"
SHARD2_FILE="$MODEL_DIR/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00002-of-00002.gguf"
SHARD1_URL="https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF/resolve/main/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00001-of-00002.gguf"

mkdir -p "$MODEL_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [1/3] Enlazando Shard 2 (n-gram table 28.8 GB) existente..." > "$LOG_FILE"
if [ ! -f "$SHARD2_FILE" ]; then
    if [ -f "$DATA_DIR/models/Q2_0/Qwen3.8-Flash-Next-GSQ-RCO-Q2_0-00002-of-00002.gguf" ]; then
        ln "$DATA_DIR/models/Q2_0/Qwen3.8-Flash-Next-GSQ-RCO-Q2_0-00002-of-00002.gguf" "$SHARD2_FILE"
        echo "sha256 316b46f3a2dbd68c900f43136ab9449f9dcc3725dfd8c794847c204bc161e113" > "$SHARD2_FILE.done"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✔ Shard 2 enlazado instantáneamente desde Q2_0 (ahorrando 28.8 GB de descarga y espacio)." >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Descargando Shard 2..." >> "$LOG_FILE"
        curl -C - --http1.1 -L --retry 10 --retry-delay 3 -o "$SHARD2_FILE" "https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF/resolve/main/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00002-of-00002.gguf" >> "$LOG_FILE" 2>&1
    fi
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [2/3] Descargando Shard 1 (54.82 GB) de IQ3_S (ISTA-DASLab)..." >> "$LOG_FILE"
until curl -C - --http1.1 -L --retry 10 --retry-delay 3 -o "$SHARD1_FILE" "$SHARD1_URL" >> "$LOG_FILE" 2>&1; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Conexión interrumpida, reanudando en 3s..." >> "$LOG_FILE"
    sleep 3
done
echo "done" > "$SHARD1_FILE.done"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [3/3] Generando pack nativo Metal en $PACK_DIR..." >> "$LOG_FILE"
mkdir -p "$PACK_DIR"
.venv/bin/python tools/iq_pack.py \
  --gguf "$SHARD1_FILE" \
  --out "$PACK_DIR" \
  --compat-bf16 >> "$LOG_FILE" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Generando configuración strata-iq3_s.json con --max-context 262144..." >> "$LOG_FILE"
cat << 'EOF' > "$STRATA_DIR/strata-iq3_s.json"
{
 "exe": "/Users/atlantis/Documents/Desarrollo/Strata/build-metal/strata",
 "args": [
  "--pack",
  "/Volumes/Samsung2T/strata/packs/iq3_s",
  "--native",
  "/Volumes/Samsung2T/strata/models/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00001-of-00002.gguf",
  "--ple-gguf",
  "/Volumes/Samsung2T/strata/models/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00002-of-00002.gguf",
  "--expert-profile",
  "/Users/atlantis/Documents/Desarrollo/Strata/data/expert-profile.bin",
  "--expert-cache",
  "64",
  "--prefill",
  "auto",
  "--spec",
  "3",
  "--suffix-draft",
  "0",
  "--max-context",
  "262144",
  "--mmap-experts",
  "--vision"
 ],
 "cwd": "/Users/atlantis/Documents/Desarrollo/Strata",
 "tokenizer": "/Volumes/Samsung2T/strata/packs/iq3_s/tokenizer",
 "model_name": "qwen3.8-flash-next-iq3_s",
 "log": "/Users/atlantis/Documents/Desarrollo/Strata/strata-iq3_s.log",
 "lib_dirs": [],
 "port": 8080,
 "backend": "metal",
 "env": {
  "STRATA_METAL_STREAM": "1"
 },
 "vision": {
  "exe": "/Users/atlantis/Documents/Desarrollo/Strata/build-vision/bin/strata-vision",
  "mmproj": "/Volumes/Samsung2T/strata/models/mmproj-Qwen3.8-Flash-Next-BF16.gguf",
  "model": "/Volumes/Samsung2T/strata/models/IQ3_S/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_S-00001-of-00002.gguf",
  "gpu": true,
  "max_tokens": 1024
 }
}
EOF

cat << 'EOF' > "$STRATA_DIR/run-iq3_s.sh"
#!/bin/sh
cd "/Users/atlantis/Documents/Desarrollo/Strata"
exec "/Users/atlantis/Documents/Desarrollo/Strata/.venv/bin/python" "/Users/atlantis/Documents/Desarrollo/Strata/serve/server.py" "--engine" "strata" "--config" "/Users/atlantis/Documents/Desarrollo/Strata/strata-iq3_s.json" "--port" "8080" "--open"
EOF
chmod +x "$STRATA_DIR/run-iq3_s.sh"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🎉 Qwen3.8-Flash-Next IQ3_S (ISTA-DASLab) descargado, empaquetado y listo para inferencia en Metal." >> "$LOG_FILE"
