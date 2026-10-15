"""印刷向きの STL を、使用時の向き（+Z が生地側、リム上端が Z0）に戻す。

usage: python3 to_use.py dims.json 入力.stl 出力.stl
.scad の print_half / print_anchor / print_grip の逆変換をかける。キャップは印刷向きのまま
"""
import json
import struct
import sys

import numpy as np

REC = np.dtype([('n', '<3f4'), ('v', '<9f4'), ('a', '<u2')])


def read_stl(path):
    data = open(path, 'rb').read()
    if data[:5] == b'solid' and b'facet' in data[:300]:
        v = [l.split()[1:4] for l in data.decode().splitlines() if l.strip().startswith('vertex')]
        return np.array(v, dtype=float)
    n = struct.unpack('<I', data[80:84])[0]
    return np.frombuffer(data[84:84 + n * 50], dtype=REC)['v'].reshape(-1, 3).astype(float)


def write_stl(path, p):
    tri = p.reshape(-1, 3, 3)
    nrm = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    nrm /= np.linalg.norm(nrm, axis=1, keepdims=True) + 1e-12
    rec = np.zeros(len(tri), dtype=REC)
    rec['n'] = nrm
    rec['v'] = tri.reshape(-1, 9)
    with open(path, 'wb') as f:
        f.write(b'\0' * 80 + struct.pack('<I', len(tri)) + rec.tobytes())


def rot_x(deg):
    t = np.radians(deg)
    c, s = np.cos(t), np.sin(t)
    return np.array([[1, 0, 0], [0, c, -s], [0, s, c]])


def main():
    dims_path, src, dst = sys.argv[1:4]
    d = json.load(open(dims_path))
    name = src.rsplit('/', 1)[-1][:-4]
    p = read_stl(src)
    if name in ('half_a', 'half_b') and d['half_on_side']:
        # print_half（横倒し）：rotate([side * 90, 0, 0]) translate([0, 0, -(body_bot_z + lip_h) / 2])
        side = 1 if name == 'half_a' else -1
        p = p @ rot_x(-side * 90).T
        p[:, 2] += (d['body_bot_z'] + d['lip_h']) / 2
    elif name in ('half_a', 'half_b'):
        # print_half（縦）：translate([0, 0, -body_bot_z])
        p[:, 2] += d['body_bot_z']
    elif name == 'anchor':
        # print_anchor：translate([0, -(bar_h + peg_len) / 2, bar_w / 2]) rotate([90, 0, 0])
        p = (p - [0, -(d['bar_h'] + d['peg_len']) / 2, d['bar_w'] / 2]) @ rot_x(-90).T
    elif name == 'grip':
        # print_grip：rotate([180, 0, 0]) translate([0, 0, -grip_top_z])
        p = p @ rot_x(-180).T
        p[:, 2] += d['grip_top_z']
    write_stl(dst, p)
    print(f'{name}: z {p[:, 2].min():.2f} .. {p[:, 2].max():.2f}')


if __name__ == '__main__':
    main()
