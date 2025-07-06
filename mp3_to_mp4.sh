#!/bin/bash

INPUT="$1"
ALT_AUDIO="$2"

if [ -z "$INPUT" ]; then
  echo "Usage: $0 input.mp3|input.wav [alternate_audio.mp3|wav]"
  echo "Example: $0 song.mp3 narration.wav blue"
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "Error: File '$INPUT' not found."
  exit 1
fi

if [ -n "$ALT_AUDIO" ] && [ ! -f "$ALT_AUDIO" ]; then
  echo "Error: Alternate audio file '$ALT_AUDIO' not found."
  exit 1
fi

BASENAME=$(basename "$INPUT" .${INPUT##*.})
OUTPUT="${BASENAME}_spectrum.mp4"

# === Determine encoder ===
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

# === Build inputs ===
INPUTS=(-i "$INPUT")
if [ -n "$ALT_AUDIO" ]; then
  INPUTS+=(-i "$ALT_AUDIO")
fi

# === Build filter ===
FILTER="[0:a]volume=0.5,showwaves=s=1280x720:mode=line:rate=25"

# === Build FFmpeg command ===
CMD=(ffmpeg -y "${INPUTS[@]}" \
  -filter_complex "$FILTER[v]" \
  -map "[v]" \
  -map 1:a \
  -c:v $VIDEO_CODEC $VIDEO_OPTS \
  -c:a aac -b:a 192k \
  "$OUTPUT")

echo "👉 Running command:"
printf "%q " "${CMD[@]}"
echo

"${CMD[@]}"
STATUS=$?

if [ $STATUS -eq 0 ]; then
  echo "✅ Done: '$OUTPUT' created"
else
  echo "❌ FFmpeg failed — check errors above"
fi
