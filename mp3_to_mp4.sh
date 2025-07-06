#!/bin/bash

INPUT="$1"

# === Check input ===
if [ -z "$INPUT" ]; then
  echo "Usage: $0 input.mp3|input.wav"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Error: File '$INPUT' not found."
  exit 1
fi

EXT="${INPUT##*.}"
if [[ "$EXT" != "mp3" && "$EXT" != "wav" ]]; then
  echo "Error: Unsupported file type '$EXT'. Only mp3 and wav are supported."
  exit 1
fi

BASENAME=$(basename "$INPUT" .${EXT})
OUTPUT="${BASENAME}.mp4"

# === Determine encoder ===
VIDEO_CODEC=""
VIDEO_OPTS=""

echo "🔍 Checking for NVIDIA NVENC..."
if ffmpeg -hide_banner -loglevel error -f lavfi -i nullsrc=s=1280x720 -frames:v 1 -c:v h264_nvenc -f null - 2>/dev/null; then
  VIDEO_CODEC="h264_nvenc"
  VIDEO_OPTS="-preset fast -b:v 3M"
  echo "✅ NVIDIA NVENC functional: using NVIDIA GPU encoder"
else
  echo "⚠️ NVIDIA NVENC unavailable. Checking for Intel QSV..."
  if ffmpeg -hide_banner -loglevel error -f lavfi -i nullsrc=s=1280x720 -frames:v 1 -c:v h264_qsv -f null - 2>/dev/null; then
    VIDEO_CODEC="h264_qsv"
    VIDEO_OPTS="-global_quality 23"
    echo "✅ Intel QSV functional: using Intel Quick Sync encoder"
  else
    VIDEO_CODEC="libx264"
    VIDEO_OPTS="-preset veryfast -crf 23"
    echo "⚠️ Both NVIDIA NVENC and Intel QSV unavailable: using CPU encoder (libx264)"
  fi
fi

echo "🎬 Starting processing: '$INPUT' -> '$OUTPUT'"

# === Run FFmpeg ===
ffmpeg -y -i "$INPUT" \
  -filter_complex "showwaves=s=1280x720:mode=line:rate=25" \
  -c:v $VIDEO_CODEC $VIDEO_OPTS \
  -c:a aac -b:a 192k \
  "$OUTPUT"

echo "✅ Done: '$OUTPUT' created (or failed if errors above)"
