include <modules/epd_565in_acep.scad>
include <modules/picture_frame.scad>
include <modules/smp7c_spacer.scad>
include <modules/annotation.scad>

$fn=50;

module cut_half_yz() {
  intersection(){
    children();

    translate([-1000/2, 0, 0])
    cube(size=[1000, 1000, 1000], center=true);
  }
}

// Models
cut_half_yz()
picture_frame_body();

translate([0.01, 0, 0])
color("red", 0.8)
cut_half_yz()
picture_frame_front_layers();

translate([0.02, 0, 0])
color("yellow", 0.8)
cut_half_yz()
picture_frame_back_panel();

// Annotations
// on YZ plane
rotate([90, 0, 90]){
  color("black")
  translate([PICTURE_FRAME_BODY.y/2 - PICTURE_FRAME_WIDTH/2, 0, 1]){
    translate([0, -2, 0])
    arrow(length=PICTURE_FRAME_WIDTH ,label="PICTURE_FRAME_WIDTH", label_pos_reverse=false);

    translate([PICTURE_FRAME_WIDTH/2 + 2, PICTURE_FRAME_BODY.z/2, 0])
    arrow(length=PICTURE_FRAME_BODY.z, vertical=true, label="PICTURE_FRAME_BODY.z", label_pos_reverse=false);

    translate([-PICTURE_FRAME_WIDTH/2 + PICTURE_FRAME_INNER_EDGE_WIDTH/2, PICTURE_FRAME_BODY.z - 1, 0])
    arrow(length=PICTURE_FRAME_INNER_EDGE_WIDTH, label="PICTURE_FRAME_INNER_EDGE_WIDTH", label_pos_reverse=true);

    translate([-PICTURE_FRAME_WIDTH/2 - 2, PICTURE_FRAME_INNER_SPACE.z/2 + PICTURE_FRAME_WINDOW_Z, 0])
    arrow(length=PICTURE_FRAME_INNER_SPACE.z, vertical=true, label="PICTURE_FRAME_INNER_SPACE.z", label_pos_reverse=true);
  }

  translate([2, PICTURE_FRAME_BODY.z + 1, 0])
  color("yellow")
  text("BACK_PANEL", size=3);

  translate([2, PICTURE_FRAME_WINDOW_Z + 1, 0])
  color("red")
  text("FRONT_LAYERS", size=3);

  color("black")
  translate([0, PICTURE_FRAME_BODY.z + 8, 0])
  arrow(length=PICTURE_FRAME_INNER_SPACE.y, vertical=false, label="PICTURE_FRAME_INNER_SPACE.y", label_pos_reverse=true);
}
