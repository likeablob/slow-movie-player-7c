include <modules/picture_frame.scad>

$fn=50;


module smp7c_battery_spacer_body() {
  difference(){
    cube(size=[80, 14.5, PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z], center=true);

    // Space for batteries
    rotate([0, 90, 0])
    cylinder(d=14.5, h=80 + 1, center=true);

    // Slice it
    translate([0, 0, 5])
    cube(size=[80 + 1, 14.5 + 1, PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z], center=true);
  }
}

smp7c_battery_spacer_body();
