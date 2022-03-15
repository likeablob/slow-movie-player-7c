include <scad-utils/morphology.scad>

$fn=50;

STAPLER_SIZE=10;
WALL_HOOK_BODY=[50, 20, 1];


module smp7c_stapler_wall_hook_stapler_holes() {
  mirror_y()
  translate([0, STAPLER_SIZE/2, 0])
  circle(d=2);
}

module smp7c_stapler_wall_hook_body() {
  linear_extrude(height=WALL_HOOK_BODY.z, center=!true, convexity=10, twist=0)
  difference() {
    rounding(r=3)
    square(size=[WALL_HOOK_BODY.x, WALL_HOOK_BODY.y], center=true);

    // Stapler holes
    mirror_x()
    translate([WALL_HOOK_BODY.x/4 + 2, 0, 0])
    smp7c_stapler_wall_hook_stapler_holes();

    mirror_x()
    translate([WALL_HOOK_BODY.x/4 + 7, 0, 0])
    smp7c_stapler_wall_hook_stapler_holes();
  }

  // Hook
  wall_hook_width=WALL_HOOK_BODY.x/4;
  translate([0, 0, WALL_HOOK_BODY.z])
  hull() {
    translate([0, WALL_HOOK_BODY.y/2, 0])
    rotate([0, 90, 0])
    cylinder(d=0.1, h=wall_hook_width, center=true);

    translate([0, WALL_HOOK_BODY.y/2 + 5, 5])
    rotate([0, 90, 0])
    cylinder(d=1, h=wall_hook_width, center=true);

    translate([0, -WALL_HOOK_BODY.y/2, 0])
    rotate([0, 90, 0])
    cylinder(d=0.1, h=wall_hook_width, center=true);

  }
}

smp7c_stapler_wall_hook_body();
