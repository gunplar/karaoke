#!/bin/bash
set -euo pipefail

# Usage: ./process_audio.sh audio.mp3

if [ $# -ne 1 ]; then
    echo "Usage: $0 <audio.mp3>"
    exit 1
fi

AUDIO="$1"
ZIPFILE="${AUDIO}.zip"

# 1. Run the Python script to generate ZIP
python3 tunesplit.py "$AUDIO"

# 2. Make a temporary extraction directory
TMPDIR=$(mktemp -d)

# 3. Unzip contents there
unzip -q "$ZIPFILE" -d "$TMPDIR"

# 4. Move .wav files from inside the extracted directory (find them anywhere in TMPDIR)
find "$TMPDIR" -type f -name "*.wav" -exec mv {} . \;

# 5. Remove the temp directory
rm -rf "$TMPDIR"

# 6. Run your mp3_to_mp4 script
./mp3_to_mp4.sh vocals.wav no_vocals.wav

# 7. Remove WAV files and zip
rm -f vocals.wav no_vocals.wav "$ZIPFILE"

echo "Done."
