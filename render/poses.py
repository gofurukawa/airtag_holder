"""各フレームの部品の位置とカメラを JSON に書き出す。

usage: python3 poses.py dims.json 出力先ディレクトリ [fps]
  stills.json：分解図（parts）と組み上がり（assembled）
  anim.json  ：組み立ての動画のフレーム列
座標は使用時の向き（+Z が生地側、リム上端が Z0、単位 mm）
"""
import json
import sys

dims_path, out_dir = sys.argv[1:3]
FPS = int(sys.argv[3]) if len(sys.argv) > 3 else 30
d = json.load(open(dims_path))

BODY_BOT = d['body_bot_z']                 # 本体の下端
CAP_ASM = BODY_BOT - d['handle_floor']     # 組み付け後の、取っ手付きキャップの下面
SCREW_LEN = d['cap_inner_h']               # ねじがかかってから締め終わるまでの長さ
SCREW_DEG = SCREW_LEN / d['thread_pitch'] * 360
GRIP_TOP = d['grip_top_z']                 # 握りの上端（握りのローカル座標）

# 分解図での位置
SPREAD = 24          # 挟みパーツを左右に開く量
AT_EXP = -38         # AirTag の下面
ANC_EXP = -48        # アンカーの横棒の上面
CAP_EXP = -100       # 取っ手付きキャップの下面
GRIP_GAP = 10        # 握りの上端とキャップの下面の間

# カメラ（az：+X から反時計回り、el：仰角、tz：注視点の高さ、dist：距離）
CAM_EXP = dict(az=-38, el=14, tz=-62, dist=510, fov=22)
CAM_ASM = dict(az=-38, el=14, tz=-21, dist=300, fov=22)


def ease(t):
    t = min(1.0, max(0.0, t))
    return t * t * (3 - 2 * t)


def lerp(a, b, t):
    return a + (b - a) * t


def pose(halves=0.0, airtag=0.0, anchor=0.0, grip=0.0, lift=0.0, screw=0.0, cam=0.0, spin=0.0, name=None):
    """各段の進み具合（0..1）から 1 フレームを作る。

    halves：挟みパーツを閉じる / airtag：AirTag をポケットへ / anchor：アンカーをキャップへ /
    grip：握りを突起へ / lift：キャップ一式をねじの入口まで持ち上げる / screw：回しながら締める /
    cam：カメラを組み上がりの画角へ / spin：組み上がりを 1 回転
    """
    cap_z = lerp(lerp(CAP_EXP, CAP_ASM - SCREW_LEN, lift), CAP_ASM, screw)
    rz = -(1 - screw) * SCREW_DEG          # 右ねじ。締め終わりで 0°（組み付けの向き）
    if lift > 0:                            # 持ち上げ始めたら、アンカーと握りはキャップと一体で動く
        anc_z, grip_top = cap_z + d['handle_floor'], cap_z
    else:
        anc_z = lerp(ANC_EXP, CAP_EXP + d['handle_floor'], anchor)
        grip_top = lerp(CAP_EXP - GRIP_GAP, CAP_EXP, grip)
    c = {k: lerp(CAM_EXP[k], CAM_ASM[k], ease(cam)) for k in CAM_EXP}
    out = {
        'parts': {
            'umbrella': {},
            'half_a': {'y': SPREAD * (1 - halves)},
            'half_b': {'y': -SPREAD * (1 - halves)},
            'airtag': {'z': lerp(AT_EXP, BODY_BOT + 0.15, airtag)},
            'handle_cap': {'z': cap_z, 'rz': rz},
            'anchor': {'z': anc_z, 'rz': rz},
            'grip': {'z': grip_top - GRIP_TOP, 'rz': rz},
        },
        'camera': c,
        'spin': 360 * spin,
    }
    if name:
        out['name'] = name
    return out


ALL = dict(halves=1, airtag=1, anchor=1, grip=1, lift=1, screw=1, cam=1)
stills = [pose(name='parts'), pose(name='assembled', **ALL)]   # 分解図は動画の最初のフレームと同じ

# タイムライン（秒）：(段, 開始, 終了)
TL = [('airtag', 0.8, 1.8), ('halves', 2.2, 3.4), ('anchor', 3.8, 4.8), ('grip', 5.0, 5.8),
      ('lift', 6.0, 7.0), ('screw', 7.2, 9.4), ('cam', 9.8, 10.8), ('spin', 10.8, 14.8)]
END = 15.4
anim = []
for i in range(int(END * FPS)):
    t = i / FPS
    k = {}
    for key, a, b in TL:
        x = min(1.0, max(0.0, (t - a) / (b - a)))
        k[key] = x if key == 'screw' else ease(x)   # ねじ込みは一定の速さで回す
    anim.append(pose(**k))

json.dump(stills, open(f'{out_dir}/stills.json', 'w'))
json.dump(anim, open(f'{out_dir}/anim.json', 'w'))
print(f'stills: {len(stills)}, anim: {len(anim)} frames @ {FPS} fps')
