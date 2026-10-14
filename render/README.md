# README の画像と動画

親ディレクトリの [README](../README.md) に載せている画像と動画、およびそれを作るスクリプトです。`.stl` や `.scad` を変えたら `./render.sh` で作り直せます。

| ファイル | 内容 |
| --- | --- |
| `images/parts.png` | パーツを使用時の向き（取っ手が下）で上から並べた分解図 |
| `images/assembled.png` | 組み上がった状態 |
| `images/assembly.gif` | 組み上がる様子（README に埋め込む用、480×640、15 fps） |
| `images/assembly.mp4` | 同じ動画の高画質版（600×800、30 fps） |
| `render.sh` | 下の手順をまとめて実行する |
| `dims.scad` | 本体の `.scad` を読み込み、傘のダミーを書き出し、描画に使う寸法を echo する |
| `to_use.py` | 印刷向きの STL を、使用時の向きに戻す（`.scad` の `print_*` の逆変換） |
| `poses.py` | 部品の位置とカメラを、静止画と動画の各フレームについて JSON に書き出す。分解図の間隔やタイムラインはここで変える |
| `scene.html` | three.js で STL を描くページ。部品の色や光、AirTag のダミーの形はここ |
| `shoot.mjs` | `scene.html` をヘッドレス Chromium で開いて、ポーズごとに PNG を撮る |
| `crop.py` | 静止画の余白を切り詰めて縮める |

途中のファイル（`build/`）と `node_modules/` はコミットしません。

## 仕組み

1. OpenSCAD で `dims.scad` を書き出し、傘の持ち手のダミー（円盤とシャフト）の STL と寸法の JSON を得ます。
2. `to_use.py` で、リポジトリの `half_a` / `half_b` / `handle_cap` / `anchor` / `grip` の STL を使用時の向き（+Z が生地側、リム上端が Z0）に戻します。
3. `poses.py` が、分解図・組み上がり・動画の各フレームでの部品の位置とカメラを決めます。
4. ローカルの HTTP サーバーで `scene.html` を配信し、`shoot.mjs` がヘッドレス Chromium で 1 フレームずつ撮ります。WebGL は GPU に依らないソフトウェア描画（SwiftShader）です。
5. 静止画は 2 倍の大きさで描いてから `crop.py` で縮め、動画のフレームは ffmpeg で MP4 と GIF にします。

動画の流れは、挟みパーツで円盤を挟む → AirTag をポケットへ → アンカーをキャップへ → 握りを突起へ → キャップ一式を持ち上げ、ねじがかかってからはピッチに合わせて回しながら締める → 寄って 1 回転、です。

## 必要なもの（Mac）

```sh
brew install --cask openscad@snapshot
brew install node ffmpeg
python3 -m pip install numpy Pillow

cd render
npm install
npx playwright-core install chromium   # 描画に使う Chromium
```

## 実行

```sh
cd render
OPENSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ./render.sh
```

数分かかります（静止画 2 枚と動画 462 フレーム）。結果は `images/` に上書きされます。

| 環境変数 | 初期値 | 内容 |
| --- | --- | --- |
| `OPENSCAD` | `openscad` | OpenSCAD のコマンド。Mac ではアプリ内のパスを指定する |
| `PYTHON` | `python3` | numpy と Pillow が入った Python |
| `PORT` | `8765` | `scene.html` を配信するローカルの HTTP サーバーのポート |
| `CHROMIUM_PATH` | なし | 使う Chromium の実行ファイル。未指定なら `npx playwright-core install chromium` で入れたもの |
