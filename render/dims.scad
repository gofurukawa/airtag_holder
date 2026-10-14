// 本体の .scad を読み込み、傘のダミーを書き出す。描画に使う寸法も JSON で echo する
include <../airtag_umbrella_holder.scad>
part = "none";

echo(str("DIMS{",
    "\"body_bot_z\":", body_bot_z, ",\"lip_h\":", lip_h,
    ",\"bar_h\":", bar_h, ",\"bar_w\":", bar_w, ",\"peg_len\":", peg_len,
    ",\"grip_top_z\":", grip_top_z, ",\"handle_floor\":", handle_floor,
    ",\"cap_inner_h\":", cap_inner_h, ",\"thread_pitch\":", thread_pitch,
    ",\"airtag_d\":", airtag_d, ",\"airtag_h\":", airtag_h, "}"));

umbrella_dummy();
