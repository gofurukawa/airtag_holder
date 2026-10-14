#!/usr/bin/env bash
# README の画像と組み立ての動画を、リポジトリの STL から作り直す。
# 出力：images/parts.png, images/assembled.png, images/assembly.gif, images/assembly.mp4
# 必要なもの：OpenSCAD、Python 3（numpy, Pillow）、Node.js、ffmpeg、Chromium（README.md を参照）
set -euo pipefail
cd "$(dirname "$0")"

OPENSCAD=${OPENSCAD:-openscad}
PYTHON=${PYTHON:-python3}
PORT=${PORT:-8765}
FPS=30
BUILD=build
mkdir -p "$BUILD/models" images
rm -rf "$BUILD/frames" "$BUILD/stills"

[ -d node_modules ] || npm install

echo "== 寸法と傘のダミー（OpenSCAD）"
"$OPENSCAD" -o "$BUILD/models/umbrella.stl" dims.scad 2> "$BUILD/openscad.log"
grep -o 'DIMS{[^}]*}' "$BUILD/openscad.log" | sed 's/^DIMS//' > "$BUILD/dims.json"
cat "$BUILD/dims.json"

echo "== STL を使用時の向きに戻す"
for p in half_a half_b handle_cap anchor grip; do
  "$PYTHON" to_use.py "$BUILD/dims.json" "../$p.stl" "$BUILD/models/$p.stl"
done

echo "== ポーズ"
"$PYTHON" poses.py "$BUILD/dims.json" "$BUILD" "$FPS"

echo "== 描画"
"$PYTHON" -m http.server "$PORT" --bind 127.0.0.1 > /dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER' EXIT
sleep 1
URL="http://127.0.0.1:$PORT/scene.html"
node shoot.mjs "$URL" "$BUILD/stills.json" "$BUILD/stills" 1800 2400     # 静止画は 2 倍で描いて縮める
node shoot.mjs "$URL" "$BUILD/anim.json" "$BUILD/frames" 900 1200

echo "== 書き出し"
"$PYTHON" crop.py "$BUILD/stills/parts.png" images/parts.png
"$PYTHON" crop.py "$BUILD/stills/assembled.png" images/assembled.png
ffmpeg -loglevel error -y -framerate "$FPS" -i "$BUILD/frames/%04d.png" \
  -vf "scale=600:800:flags=lanczos,format=yuv420p" \
  -c:v libx264 -crf 20 -preset slow -movflags +faststart images/assembly.mp4
ffmpeg -loglevel error -y -framerate "$FPS" -i "$BUILD/frames/%04d.png" \
  -vf "fps=15,scale=480:640:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  -loop 0 images/assembly.gif
ls -l images
