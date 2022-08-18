include <../scad-utils/morphology.scad>
include <./epd_565in_acep.scad>
include <./picture_frame.scad>

$fn=50;

SMP7C_SPACER_BODY=[40, 40, PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z];
SMP7C_SPACER_EPD_MOUNT_EPD_Z=EPD_MODULE_EPD_BASE.z + EPD_MODULE_BODY.z + 0.6;
SMP7C_SPACER_EPD_MOUNT=[20, 20, SMP7C_SPACER_BODY.z - SMP7C_SPACER_EPD_MOUNT_EPD_Z];
SMP7C_SPACER_BATTERY_HOLDER = [50 * 3 + 2, 14.5, SMP7C_SPACER_BODY.z+1];


module smp7c_spacer_body_base() {
  linear_extrude(height=PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z, center=!true, convexity=10, twist=0)
  rounding(r=2)
  difference(){
    // Fill inner space
    square(size=[PICTURE_FRAME_INNER_SPACE.x, PICTURE_FRAME_INNER_SPACE.y], center=true);

    // Split along x
    square(size=[PICTURE_FRAME_INNER_SPACE.x*1.2, PICTURE_FRAME_INNER_SPACE.y - SMP7C_SPACER_BODY.y * 2], center=true);

    // Split along y
    square(size=[PICTURE_FRAME_INNER_SPACE.x - SMP7C_SPACER_BODY.x * 2, PICTURE_FRAME_INNER_SPACE.y * 1.2], center=true);

    // Space for EPD
    translate_to_epd_visible_area_center(as_center=true)
    outset(d=0.5)
    square(size=[EPD_MODULE_BODY.x, EPD_MODULE_BODY.y], center=true);
  }
}

module smp7c_spacer_epd_mount_base(){
  epd_mount_edge_width=5;

  rotate([0 , 0, 180]) // -x -y
  intersection(){
    rounding(r=2)
    union(){
      circle(r=epd_mount_edge_width*2);
      difference() { // L shape
        scale([2, 2, 1])
        square(size=[SMP7C_SPACER_EPD_MOUNT.x, SMP7C_SPACER_EPD_MOUNT.y], center=true);

        translate([epd_mount_edge_width, epd_mount_edge_width, 0])
        square(size=[SMP7C_SPACER_EPD_MOUNT.x, SMP7C_SPACER_EPD_MOUNT.y], center=false);
      }
    }

    // Remove unused
    translate([-1, -1, 0])
    square(size=[SMP7C_SPACER_EPD_MOUNT.x + 1, SMP7C_SPACER_EPD_MOUNT.y + 1], center=!true);
  }
}

module smp7c_spacer_battery_holder_diff() {
  // Holder space
  translate([0, PICTURE_FRAME_INNER_SPACE.y/2 - SMP7C_SPACER_BATTERY_HOLDER.y/2 + 0.01, SMP7C_SPACER_BODY.z/2])
  difference() {
    cube(size=SMP7C_SPACER_BATTERY_HOLDER, center=true);

    // Hold batteries at the edge
    holder_edge=[10, SMP7C_SPACER_BATTERY_HOLDER.y, 5];

    mirror_x()
    translate([SMP7C_SPACER_BATTERY_HOLDER.x/2 - holder_edge.x/2, 0, 0])
    difference() {
      translate([0, 0, SMP7C_SPACER_BODY.z/2 - holder_edge.z/2])
      cube(size=[holder_edge.x, SMP7C_SPACER_BATTERY_HOLDER.y, holder_edge.z], center=true);

      rotate([0, 90, 0])
      cylinder(d=14.5, h=holder_edge.x, center=true);
    }
  }

  // Slots for terminal
  mirror_x()
  translate([SMP7C_SPACER_BATTERY_HOLDER.x/2, 0, 0])
  translate([0, PICTURE_FRAME_INNER_SPACE.y/2 - SMP7C_SPACER_BATTERY_HOLDER.y/2 , SMP7C_SPACER_BODY.z/2]){
    translate([1, 0, 0])
    cube(size=[0.8, 11, SMP7C_SPACER_BATTERY_HOLDER.z], center=true);

    translate([-1/2 + 1, 0, 0])
    cube(size=[1 + 0.01, 6, SMP7C_SPACER_BATTERY_HOLDER.z], center=true);
  }

  // Shrink the slots
  mirror_x()
  translate([SMP7C_SPACER_BATTERY_HOLDER.x/2 - 5/2 + 1, 0, 5 - SMP7C_SPACER_BATTERY_HOLDER.z])
  translate([0, PICTURE_FRAME_INNER_SPACE.y/2 - SMP7C_SPACER_BATTERY_HOLDER.y/2 , SMP7C_SPACER_BODY.z/2])
  cube(size=[5, 10, SMP7C_SPACER_BATTERY_HOLDER.z], center=true);
}

module smp7c_spacer_body(with_battery_space=true) {
  difference(){
    union(){
      smp7c_spacer_body_base();

      // EPD mount
      translate_to_epd_visible_area_center(as_center=true)
      mirror_x()
      mirror_y()
      translate([EPD_MODULE_BODY.x/2, EPD_MODULE_BODY.y/2, 0])
      translate([0, 0, SMP7C_SPACER_EPD_MOUNT_EPD_Z])
      linear_extrude(height=SMP7C_SPACER_EPD_MOUNT.z, center=!true, convexity=10, twist=0)
      smp7c_spacer_epd_mount_base();
    }

    // AAA Battery x3 holder
    if(with_battery_space){
      smp7c_spacer_battery_holder_diff();
    }

    // Space in edges
    translate_to_epd_visible_area_center(as_center=true)
    mirror_x()
    mirror_y()
    translate([EPD_MODULE_BODY.x/2, EPD_MODULE_BODY.y/2, 0])
    linear_extrude(height=SMP7C_SPACER_EPD_MOUNT_EPD_Z, center=!true, convexity=10, twist=0)
    circle(r=4);

    // Screw holes for EPD
    translate_to_epd_visible_area_center(as_center=true)
    mirror_x()
    mirror_y()
    linear_extrude(height=10, center=!true, convexity=10, twist=0)
    epd_module_holes(d=2);
  }
}

module smp7c_spacer_body_at(edge_pos=0) {
  // edge_pos: 0=top left, 1=top right, 2=bottom left, 3=bottom right
  intersection(){
    smp7c_spacer_body();

    rotate([0, 0, 90 * edge_pos])
    scale([1, 1, 2])
    cube(size=PICTURE_FRAME_BODY, center=!true);
  }
}
