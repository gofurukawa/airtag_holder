// =============================================================
//  AirTag umbrella holder（折りたたみ傘の握り端用）
//  使用時の向きでモデリング：+Z = 生地側、リム上端 = Z0
//  part を切り替えて STL を書き出す
// =============================================================

/* [出力する部品] */
part = "assembly"; // [assembly, half_a, half_b, cap, handle_cap, anchor, grip, print_all]
use_handle = true;  // assembly と print_all で、取っ手付きのキャップと取っ手（アンカー＋握り）を使う

/* [傘の実測値] */
disc_d        = 29.5;  // A 円盤の外径
recess_d      = 26.8;  // C 凹みの内径（リム内径）
disc_edge_h   = 5.6;   // B 縁での厚み（側面の平らな帯の高さ）
disc_center_h = 9.0;   // B 中央での厚み（底が膨らんでいる）
dome_R        = 0;     // 空洞の底の球面半径。0 なら縁と中央の厚みの差から自動（33.7、平らな肩なし＝実績のある形）。実物は約 28 で縁に幅約 1.5 の平らな肩があるが、再現すると印刷誤差で当たりやすい
shaft_d       = 7.7;   // E シャフト径（表示用）

/* [AirTag] */
airtag_d = 31.9;
airtag_h = 8.0;

/* [クリアランス] */
clr          = 0.2;   // 円盤まわりの片側すき間（0.2 で縁も中央もぴったり固定できた実績あり）
pocket_clr_d = 0.5;   // AirTag ポケットの直径方向すき間
pocket_clr_h = 0.3;   // AirTag ポケットの高さ方向すき間
thread_clr   = 0.35;  // ねじの半径方向すき間
thread_aclr  = 0.2;   // ねじの軸方向すき間（片側）

/* [本体] */
lip_h        = 2.0;   // 爪の上端高さ（リム上端から）
upper_wall   = 2.0;   // 円盤まわりの肉厚
partition_t  = 1.0;   // 円盤と AirTag の仕切り（中央の厚み）

/* [ねじ] */
thread_major_d = 39;
thread_pitch   = 3;
thread_depth   = 1.5;
crest_w        = 1.0;  // 山頂の幅
root_w         = 2.6;  // 山の根元の幅（< ピッチ）

/* [キャップ] */
cap_wall   = 2.0;
cap_floor  = 2.0;
window_d   = 26;
washer_gap = 1.0;  // キャップ上端と段差の間（パッキン用）

/* [取っ手（アンカー＋握り）] */
// アンカー（横棒＋八角の突起）を取っ手付きキャップの内側から窓に通し、横棒を底の溝に落とし込む。
// キャップの外で握りを突起に差し込んで接着する。キャップを締めると本体の下端が横棒を押さえる。
// 窓を通るのはアンカーだけなので、握りの太さや形は窓に縛られない
grip_len   = 40;    // 握りの全長（上端から先端まで）
grip_d     = 22;    // 握りの直径
grip_top_d = 43.7;  // 握りの上端の直径。キャップの下面に突き当たる（window_d + 4 〜 キャップの外径）
flare_len  = 20;    // 握りの上端から grip_d の太さになるまでの長さ（長いほど緩やか）
vent_n     = 4;     // 詰まった握りの上端の面に彫る、音と雨水の逃げ溝の本数（放射状）
vent_w     = 5;     // 逃げ溝の幅
vent_h     = 2;     // 逃げ溝の深さ
mesh       = true;  // 握りを網目の殻にする（中は空洞。音と雨水は網の穴から抜ける）。false で詰まった握り（逃げ溝つき）
shell_t    = 1.8;   // 網目の殻の厚さ
mesh_n     = 10;    // 1 周あたりのひし形の穴の数
strut_w    = 2.0;   // 穴と穴の間の桟の太さ
top_t      = 2.5;   // 上端の面（キャップに突き当たる輪とスポーク）の厚さ
peg_len    = 30;    // 横棒の下面から突起の先端まで
socket_clr = 0.2;   // 握りの穴の片側すき間（接着剤が入るすき間）
bar_l      = 35;    // 横棒の長さ（両端はキャップのねじ穴に入るよう円弧に丸める）
bar_w      = 10;    // 横棒の幅＝八角の突起の対辺（アンカーを寝かせて刷るときの高さ）
bar_h      = 3;     // 横棒の厚さ＝溝の深さ（キャップの底はこの分だけ厚くなる）
slot_clr   = 0.2;   // 溝の片側すき間

/* [位置決めピン（1.75mm フィラメントを流用）] */
pin_d     = 1.75;
pin_clr   = 0.08;
pin_depth = 3;
pin_x     = 12;

/* [印刷向き] */
// 挟みパーツは合わせ面を下にして印刷する。空洞の内面は横倒しのアーチになるので、
// 頂上（合わせ面から最も遠い所）を 45°の屋根と平らな橋に置き換え、たれが空洞に食い込まないようにする
bridge_relief = 0.6;  // 橋の高さ（元の円からの逃げ）。0 で真円のまま（頂上はサポートが要る）

/* [解像度] */
$fn = 96;

// ---------- 派生寸法 ----------
cavity_r       = disc_d / 2 + clr;
sag            = disc_center_h - disc_edge_h;
dome_R_eff     = dome_R > 0 ? dome_R : (pow(disc_d / 2, 2) + sag * sag) / (2 * sag);  // 自動なら縁の角を通る球面
cavity_bot_z   = -(disc_center_h + clr);   // 空洞の底（球面の頂点）
ledge_z        = -(disc_edge_h + clr);     // 球面が縁の平らな部分に移る高さ（自動の球面では縁の角に一致）
pocket_d       = airtag_d + pocket_clr_d;
pocket_h       = airtag_h + pocket_clr_h;
pocket_top_z   = cavity_bot_z - partition_t;
body_bot_z     = pocket_top_z - pocket_h;
upper_od       = 2 * cavity_r + 2 * upper_wall;
thread_top_z   = -disc_center_h;
thread_len     = thread_top_z - body_bot_z;
minor_d        = thread_major_d - 2 * thread_depth;
cap_od         = thread_major_d + 2 * thread_clr + 2 * cap_wall;
cap_inner_h    = thread_len - washer_gap;
cap_h          = cap_floor + cap_inner_h;
handle_floor   = cap_floor + bar_h;          // 取っ手付きキャップの底（溝の下に cap_floor が残る）
bar_round_d    = minor_d + 2 * thread_clr - 0.5;  // 横棒の両端の円弧（めねじの山頂より 0.25 内側）
peg_tip_z      = -bar_h - peg_len;            // 取っ手の座標（z=0 が横棒の上面）。突起の先端
grip_top_z     = -handle_floor;               // 握りの上端（キャップの下面に突き当たる）
tip_z          = grip_top_z - grip_len;       // 握りの先端
tip_c_z        = tip_z + grip_d / 2;          // 先端の半球の中心
socket_r       = (bar_w / 2 + socket_clr) / cos(22.5);   // 握りの穴（八角）の外接半径
socket_depth   = grip_top_z - peg_tip_z + 0.5;           // 握りの穴の深さ（突起の先端の下に 0.5 の逃げ）

assert(grip_len >= flare_len + grip_d / 2, "grip_len が短すぎる（flare_len を短くする）");
assert(grip_top_d >= window_d + 4, "grip_top_d が細すぎて、キャップの下面に突き当たる幅が足りない");
assert(grip_top_d <= cap_od + 0.01, "grip_top_d がキャップの外径より太い");
assert(socket_depth + socket_r + 2 <= grip_len, "握りの穴が先端に近すぎる（peg_len を短くする）");

// 頂点 apex_z・半径 R の球面の、半径 r での高さ
function dome_z(r, apex_z, R) = apex_z + R - sqrt(R * R - r * r);
// 半径 r での空洞の底面（球面と縁の平らな部分の低い方）
function cavity_z_at(r) = min(dome_z(r, cavity_bot_z, dome_R_eff), ledge_z);
pin_z = (pocket_top_z + cavity_z_at(pin_x)) / 2;

// ---------- 円盤の形（回転断面） ----------
// 底面は頂点 apex_z・半径 R の球面。球面が edge_z に達した先は edge_z の平面で、
// 半径 r_max の側面を経て top_z まで。空洞と確認用ダミーの両方で使う
module disc_profile(apex_z, R, edge_z, r_max, top_z, n = 48) {
    sag  = edge_z - apex_z;
    r_sh = sag < R ? min(r_max, sqrt(R * R - (R - sag) * (R - sag))) : r_max;  // 球面と平面の境目
    polygon(concat(
        [for (i = [0 : n]) let (r = r_sh * i / n) [r, dome_z(r, apex_z, R)]],
        [[r_max, edge_z], [r_max, top_z], [0, top_z]]));
}

// ---------- らせんのねじ山 ----------
// z=0..length の範囲に、半径 r_in→r_out の台形断面の山を生成
module helix_ridge(r_in, r_out, w_in, w_out, pitch, length, fn = 96) {
    n = ceil((length / pitch + 2) * fn);
    pts = [for (i = [0 : n])
        let (a = 360 * i / fn, z = -pitch + pitch * i / fn, c = cos(a), s = sin(a))
        each [[r_in * c, r_in * s, z - w_in / 2],
              [r_out * c, r_out * s, z - w_out / 2],
              [r_out * c, r_out * s, z + w_out / 2],
              [r_in * c, r_in * s, z + w_in / 2]]];
    side = [for (i = [0 : n - 1]) for (j = [0 : 3])
        let (a = 4 * i + j, b = 4 * i + (j + 1) % 4,
             c = 4 * (i + 1) + (j + 1) % 4, d = 4 * (i + 1) + j)
        each [[a, d, c], [a, c, b]]];
    faces = concat([[0, 1, 2], [0, 2, 3]], side,
                   [[4 * n, 4 * n + 2, 4 * n + 1], [4 * n, 4 * n + 3, 4 * n + 2]]);
    polyhedron(pts, faces, convexity = 10);
}

module ext_thread() {
    // 両端を 45°で面取りしたおねじ
    intersection() {
        helix_ridge(minor_d / 2 - 0.05, thread_major_d / 2,
                    root_w, crest_w, thread_pitch, thread_len);
        rotate_extrude() polygon([
            [0, 0], [minor_d / 2, 0], [thread_major_d / 2 + 0.01, thread_depth],
            [thread_major_d / 2 + 0.01, thread_len - thread_depth],
            [minor_d / 2, thread_len], [0, thread_len]]);
    }
}

module int_thread_void(h) {
    // めねじの空間（すき間込み）
    w_in = root_w - (root_w - crest_w) * thread_clr / thread_depth + 2 * thread_aclr;
    w_out = crest_w + 2 * thread_aclr;
    union() {
        cylinder(d = minor_d + 2 * thread_clr, h = h);
        intersection() {
            helix_ridge(minor_d / 2 + thread_clr - 0.05, thread_major_d / 2 + thread_clr,
                        w_in, w_out, thread_pitch, h + 1);
            cylinder(r = cap_od, h = h);
        }
        // 入口の面取り
        translate([0, 0, h - thread_depth])
            cylinder(r1 = minor_d / 2 + thread_clr,
                     r2 = thread_major_d / 2 + thread_clr + 0.3, h = thread_depth + 0.01);
    }
}

// ---------- 横倒し印刷用の逃げ ----------
// 半径 r の円に、±Y（合わせ面から最も遠い向き）へ 45°の屋根を足し、r + bridge_relief で平らに切る
module relief_2d(r) {
    k = r * sqrt(2);  // 屋根の頂点
    intersection() {
        hull() {
            circle(r = r);
            square([0.01, 2 * k], center = true);
        }
        square([2 * k, 2 * (r + bridge_relief)], center = true);
    }
}

// ---------- 本体（分割前） ----------
module disc_cavity() {
    rotate_extrude() disc_profile(cavity_bot_z, dome_R_eff, ledge_z, cavity_r, clr);
}

module body() {
    difference() {
        union() {
            translate([0, 0, thread_top_z - 0.01])   // ねじ部と 0.01 重ねて、段差面での面の重なりを避ける
                cylinder(d = upper_od, h = lip_h - thread_top_z + 0.01);
            translate([0, 0, body_bot_z]) {
                cylinder(d = minor_d, h = thread_len);
                ext_thread();
            }
        }
        translate([0, 0, -1]) cylinder(d = recess_d, h = lip_h + 2);   // 爪の開口
        disc_cavity();                                                  // 円盤
        translate([0, 0, body_bot_z - 1]) cylinder(d = pocket_d, h = pocket_h + 1); // AirTag
        if (bridge_relief > 0) {                                        // 横倒し印刷用の逃げ
            translate([0, 0, body_bot_z - 1]) linear_extrude(pocket_h + 1) relief_2d(pocket_d / 2);
            translate([0, 0, ledge_z]) linear_extrude(clr - ledge_z) relief_2d(cavity_r);
            translate([0, 0, -1]) linear_extrude(lip_h + 2) relief_2d(recess_d / 2);
        }
        for (x = [-pin_x, pin_x])                                       // ピン穴
            translate([x, 0, pin_z]) rotate([90, 0, 0])
                cylinder(d = pin_d + 2 * pin_clr, h = 2 * pin_depth, center = true, $fn = 24);
    }
}

module half(side) {
    intersection() {
        body();
        translate([-50, side > 0 ? 0 : -100, -50]) cube([100, 100, 100]);
    }
}

// floor：底の厚さ。slot = true で、底の上面に取っ手の横棒の溝を彫る
module cap(floor = cap_floor, slot = false) {
    difference() {
        cylinder(d = cap_od, h = floor + cap_inner_h);
        translate([0, 0, -1]) cylinder(d = window_d, h = floor + 2);
        translate([0, 0, floor]) int_thread_void(cap_inner_h + 0.01);
        // 窓の外側の面取り
        translate([0, 0, -0.01]) cylinder(d1 = window_d + 1.2, d2 = window_d, h = 0.6);
        if (slot) translate([0, 0, floor - bar_h]) linear_extrude(bar_h + 0.01) bar_2d(slot_clr);
    }
}

// ---------- 取っ手（T 字アンカー） ----------
// 横棒の平面形。両端をキャップのねじ穴に入る円弧に丸める。c は外側へのすき間
module bar_2d(c = 0) {
    intersection() {
        square([bar_l + 2 * c, bar_w + 2 * c], center = true);
        circle(d = bar_round_d + 2 * c);
    }
}

// 対辺 a の八角形。辺が x・y 軸に平行（寝かせて刷ると平らな面が下、斜めの面は 45°）
module octagon(a) rotate(22.5) circle(r = a / 2 / cos(22.5), $fn = 8);

// アンカー：横棒＋八角の突起。使用時の向きで z=0 が横棒の上面
module anchor() {
    difference() {
        union() {
            translate([0, 0, -bar_h]) linear_extrude(bar_h) bar_2d();
            translate([0, 0, peg_tip_z + 1]) linear_extrude(peg_len - 1 + 0.01) octagon(bar_w);
            translate([0, 0, peg_tip_z]) linear_extrude(1, scale = bar_w / (bar_w - 2)) octagon(bar_w - 2);  // 先端の面取り
        }
        // 空気と余った接着剤の逃げ溝（寝かせて刷るとき上を向く面に、突起の全長にわたって）
        translate([-0.75, bar_w / 2 - 0.6, peg_tip_z - 0.01]) cube([1.5, 1, grip_top_z - peg_tip_z + 0.01]);
    }
}

// 握り：上端 Ø grip_top_d の平らな面でキャップの下面に突き当たり、なだらかに grip_d まで細くなる。
// 先端は半球。中央に八角の穴、上端の面に放射状の逃げ溝
function grip_profile(n = 32) = let (rt = grip_top_d / 2, f = 1.5) concat(
    [[0, grip_top_z]],
    [for (i = [0 : 8]) let (a = 90 * i / 8) [rt - f + f * sin(a), grip_top_z - f + f * cos(a)]],   // 上端のふちの丸み
    [for (i = [1 : n]) let (t = i / n)
        [rt + (grip_d / 2 - rt) * (1 - cos(180 * t)) / 2, grip_top_z - f - (flare_len - f) * t]],
    [for (i = [0 : n]) let (a = 90 * i / n) [grip_d / 2 * cos(a), tip_c_z - grip_d / 2 * sin(a)]]);

module grip() {
    difference() {
        rotate_extrude() polygon(grip_profile());
        translate([0, 0, grip_top_z - socket_depth]) linear_extrude(socket_depth + 0.01) octagon(bar_w + 2 * socket_clr);
        // 穴の奥は 45°の屋根（逆さに刷るとき天井がサポートなしで閉じる）
        translate([0, 0, grip_top_z - socket_depth - socket_r]) cylinder(r1 = 0, r2 = socket_r, h = socket_r + 0.01, $fn = 8);
        translate([0, 0, grip_top_z - 0.6]) cylinder(r1 = socket_r - 0.2, r2 = socket_r + 0.6, h = 0.61, $fn = 32);  // 入口の面取り
        // 音と雨水の逃げ溝。横棒（x 方向）と 45°ずらして、窓の横棒にかからない所から外へ抜ける
        for (i = [0 : vent_n - 1]) rotate(45 + 360 * i / vent_n)
            translate([0, -vent_w / 2, grip_top_z - vent_h]) cube([grip_top_d, vent_w, vent_h + 0.01]);
    }
}

// ---------- 網目の握り ----------
// 高さ z での握りの外半径（上端のふちの丸みは無視）
function grip_r(z) =
    z > grip_top_z - flare_len
        ? let (t = (grip_top_z - z) / flare_len) grip_top_d / 2 + (grip_d - grip_top_d) / 2 * (1 - cos(180 * t)) / 2
        : z > tip_c_z ? grip_d / 2 : sqrt(max(0, pow(grip_d / 2, 2) - pow(tip_c_z - z, 2)));
// 穴の列：[高さ, 列番号]。列の間隔は、その高さの周方向の間隔の半分（ひし形を互い違いに並べる）
function mesh_rows(z, i = 0) = z < tip_c_z + 1 ? [] :
    concat([[z, i]], mesh_rows(z - PI * grip_r(z) / mesh_n, i + 1));
tube_r = socket_r + shell_t;   // 突起を受ける筒の外半径

module grip_mesh() {
    z0 = grip_top_z - top_t;               // 上端の面の下
    difference() {
        union() {
            difference() {
                rotate_extrude() polygon(grip_profile());
                // 中の空洞：外形を殻の厚さだけ内側へ。上端の面と、先端の半球の中心より下は残す
                intersection() {
                    rotate_extrude() offset(delta = -shell_t) polygon(grip_profile());
                    translate([0, 0, tip_c_z]) cylinder(r = grip_top_d, h = z0 - tip_c_z);
                }
            }
            translate([0, 0, tip_c_z]) cylinder(r = tube_r, h = grip_top_z - tip_c_z);          // 受け筒
            intersection() {                                                                       // 縦リブ 4 本
                rotate_extrude() polygon(grip_profile());
                for (a = [45 : 90 : 315]) rotate(a) translate([0, -1, tip_c_z]) cube([grip_top_d, 2, grip_top_z - tip_c_z]);
            }
        }
        // 受け筒の穴（八角）、奥の 45°の屋根、入口の面取り
        translate([0, 0, grip_top_z - socket_depth]) linear_extrude(socket_depth + 0.01) octagon(bar_w + 2 * socket_clr);
        translate([0, 0, grip_top_z - socket_depth - socket_r]) cylinder(r1 = 0, r2 = socket_r, h = socket_r + 0.01, $fn = 8);
        translate([0, 0, grip_top_z - 0.6]) cylinder(r1 = socket_r - 0.2, r2 = socket_r + 0.6, h = 0.61, $fn = 32);
        // 上端の面の窓：窓の下、受け筒とスポークの間を抜く（キャップに当たる外周の輪は残す）
        translate([0, 0, z0 - 0.01]) linear_extrude(top_t + 0.02) difference() {
            circle(r = window_d / 2 - 0.5);
            circle(r = tube_r);
            for (a = [45 : 90 : 315]) rotate(a) translate([0, -1.5]) square([grip_top_d, 3]);
        }
        // ひし形の穴。上下の角が 45°なので、立てて刷ってもサポートが要らない
        for (row = mesh_rows(z0 - 6)) let (z = row[0], r = grip_r(z), p = 2 * PI * r / mesh_n,
                                          d = min(9, p - strut_w * sqrt(2)))
            if (d > 2)
                for (k = [0 : mesh_n - 1]) rotate(360 * (k + (row[1] % 2) / 2) / mesh_n)
                    translate([r - shell_t - 0.6, 0, z]) rotate([0, 90, 0])
                        linear_extrude(shell_t + 3) rotate(45) square(d / sqrt(2), center = true);
    }
}

// ---------- 確認用のダミー ----------
module umbrella_dummy() {
    color("DimGray") {
        difference() {
            rotate_extrude() disc_profile(-disc_center_h, dome_R_eff, -disc_edge_h, disc_d / 2, 0);
            translate([0, 0, -4.6]) cylinder(d = recess_d, h = 5);
        }
        translate([0, 0, -5]) cylinder(d = shaft_d, h = 45);
    }
}

module airtag_dummy() {
    color("WhiteSmoke") translate([0, 0, body_bot_z + 0.15]) cylinder(d = airtag_d, h = airtag_h);
}

// ---------- 出力 ----------
// 印刷向き：挟みパーツは合わせ面を下（ねじ山が上）、キャップは底を下、
// アンカーは T の面を下に寝かせ、握りは上端の面を下に立てる
body_h = lip_h - body_bot_z;
module print_half(side)
    rotate([side * 90, 0, 0])                                 // 合わせ面（y=0）を z=0 に
        translate([0, 0, -(body_bot_z + lip_h) / 2]) half(side);  // ねじの軸方向の中央を原点に
module print_anchor()                                         // T の面（y=0）を下に寝かせる
    translate([0, -(bar_h + peg_len) / 2, bar_w / 2]) rotate([90, 0, 0]) anchor();
module grip_part() if (mesh) grip_mesh(); else grip();
module print_grip() rotate([180, 0, 0]) translate([0, 0, -grip_top_z]) grip_part();   // 上端の面を下に立てる

echo(str("取っ手：握りの全長 ", grip_len, " mm、上端 Ø", grip_top_d, "、取っ手付きキャップの高さ ", handle_floor + cap_inner_h, " mm"));

if (part == "assembly") {
    umbrella_dummy();
    airtag_dummy();
    color("MediumPurple", 0.85) translate([0, 4, 0]) half(1);
    color("SlateBlue", 0.85) translate([0, -4, 0]) half(-1);
    if (use_handle) {
        color("MediumSeaGreen") translate([0, 0, body_bot_z - handle_floor - 12]) cap(handle_floor, true);
        color("Orange") translate([0, 0, body_bot_z - 12]) anchor();
        color("Peru") translate([0, 0, body_bot_z - 12]) grip_part();
    } else {
        color("MediumSeaGreen") translate([0, 0, body_bot_z - cap_floor - 12]) cap();
    }
} else if (part == "half_a") {
    print_half(1);
} else if (part == "half_b") {
    print_half(-1);
} else if (part == "cap") {
    cap();
} else if (part == "handle_cap") {
    cap(handle_floor, true);
} else if (part == "anchor") {
    print_anchor();
} else if (part == "grip") {
    print_grip();
} else if (part == "print_all") {
    translate([0, body_h / 2 + 3, 0]) print_half(1);
    translate([0, -body_h / 2 - 3, 0]) print_half(-1);
    if (use_handle) {
        translate([cap_od + 8, 0, 0]) cap(handle_floor, true);
        translate([1.5 * cap_od + 16 + bar_l / 2, 0, 0]) print_anchor();
        translate([1.5 * cap_od + 24 + bar_l + grip_top_d / 2, 0, 0]) print_grip();
    } else {
        translate([cap_od + 8, 0, 0]) cap();
    }
}
