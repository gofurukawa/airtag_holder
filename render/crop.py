"""静止画の余白を切り詰め、高さをそろえて縮小する。

usage: python3 crop.py 入力.png 出力.png [高さ]
"""
import sys

from PIL import Image, ImageChops

src, dst = sys.argv[1:3]
height = int(sys.argv[3]) if len(sys.argv) > 3 else 900
im = Image.open(src).convert('RGB')
diff = ImageChops.difference(im, Image.new('RGB', im.size, 'white')).convert('L')
l, t, r, b = diff.point(lambda v: 255 if v > 8 else 0).getbbox()
m = int(0.07 * max(r - l, b - t))   # 余白は 7%
im = im.crop((l - m, t - m, r + m, b + m))
im = im.resize((round(im.width * height / im.height), height), Image.LANCZOS)
im.save(dst, optimize=True)
print(f'{dst}: {im.width} x {im.height}')
