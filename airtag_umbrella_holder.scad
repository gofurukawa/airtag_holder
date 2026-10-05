// =============================================================
//  AirTag umbrella holder（折りたたみ傘の握り端用）
//  使用時の向きでモデリング：+Z = 生地側、リム上端 = Z0
//  part を切り替えて STL を書き出す
// =============================================================

/* [出力する部品] */
part = "assembly"; // [assembly, half_a, half_b, cap, print_all]

/* [傘の実測値] */
disc_d        = 29.5;  // A 円盤の外径
recess_d      = 26.8;  // C 凹みの内径（リム内径）
disc_edge_h   = 5.6;   // B 縁での厚み（側面の平らな帯の高さ）
disc_center_h = 9.0;   // B 中央での厚み（底が膨らんでいる）
dome_R        = 27;    // 底面のふくらみの球面半径（写真の輪郭からの推定は 26。試し刷り用に 1 大きく。縁の手前までこの球面、そこから縁までは平ら）
shaft_d       = 7.7;   // E シャフト径（表示用）

/* [AirTag] */
airtag_d = 31.9;
airtag_h = 8.0;

/* [クリアランス] */
clr          = 0.3;   // 円盤まわりの片側すき間（試し刷り用に安全側。確認後は 0.2 に戻す）
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

/* [位置決めピン（1.75mm フィラメントを流用）] */
pin_d     = 1.75;
pin_clr   = 0.08;
pin_depth = 3;
pin_x     = 12;

/* [解像度] */
$fn = 96;

// ---------- 派生寸法 ----------
cavity_r       = disc_d / 2 + clr;
cavity_bot_z   = -(disc_center_h + clr);   // 空洞の底（球面の頂点）
ledge_z        = -(disc_edge_h + clr);     // 球面が縁の平らな部分に移る高さ
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

// 頂点 apex_z・半径 R の球面の、半径 r での高さ
function dome_z(r, apex_z, R) = apex_z + R - sqrt(R * R - r * r);
// 半径 r での空洞の底面（球面と縁の平らな部分の低い方）
function cavity_z_at(r) = min(dome_z(r, cavity_bot_z, dome_R), ledge_z);
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

// ---------- 本体（分割前） ----------
module disc_cavity() {
    rotate_extrude() disc_profile(cavity_bot_z, dome_R, ledge_z, cavity_r, clr);
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

module cap() {
    difference() {
        cylinder(d = cap_od, h = cap_h);
        translate([0, 0, -1]) cylinder(d = window_d, h = cap_floor + 2);
        translate([0, 0, cap_floor]) int_thread_void(cap_inner_h + 0.01);
        // 窓の外側の面取り
        translate([0, 0, -0.01]) cylinder(d1 = window_d + 1.2, d2 = window_d, h = 0.6);
    }
}

// ---------- 確認用のダミー ----------
module umbrella_dummy() {
    color("DimGray") {
        difference() {
            rotate_extrude() disc_profile(-disc_center_h, dome_R, -disc_edge_h, disc_d / 2, 0);
            translate([0, 0, -4.6]) cylinder(d = recess_d, h = 5);
        }
        translate([0, 0, -5]) cylinder(d = shaft_d, h = 45);
    }
}

module airtag_dummy() {
    color("WhiteSmoke") translate([0, 0, body_bot_z + 0.15]) cylinder(d = airtag_d, h = airtag_h);
}

// ---------- 出力 ----------
// 印刷向き：本体はポケット開口を下（=モデルの向きのまま）、キャップは底を下
module print_half(side) translate([0, 0, -body_bot_z]) half(side);

if (part == "assembly") {
    umbrella_dummy();
    airtag_dummy();
    color("MediumPurple", 0.85) translate([0, 4, 0]) half(1);
    color("SlateBlue", 0.85) translate([0, -4, 0]) half(-1);
    color("MediumSeaGreen") translate([0, 0, body_bot_z - cap_floor - 12]) cap();
} else if (part == "half_a") {
    print_half(1);
} else if (part == "half_b") {
    print_half(-1);
} else if (part == "cap") {
    cap();
} else if (part == "print_all") {
    translate([0, 3, 0]) print_half(1);
    translate([0, -3, 0]) print_half(-1);
    translate([cap_od + 8, 0, 0]) cap();
}
