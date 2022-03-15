include <../scad-utils/morphology.scad>

EPD_MODULE_BODY=[138.7, 100.5, 1.6];
EPD_MODULE_EPD=[114, 86, 1.4];
EPD_MODULE_EPD_BASE=[125.5, 100.5, EPD_MODULE_EPD.z];
EPD_MODULE_SPACE_Z=8;
EPD_MODULE_TOTAL_Z=EPD_MODULE_SPACE_Z + EPD_MODULE_EPD.z;


module epd_module_holes(d=3) {
  center_to_edge=(3/2+1);

  mirror_x()
  mirror_y()
  translate([EPD_MODULE_BODY.x/2-center_to_edge, EPD_MODULE_BODY.y/2-center_to_edge, 0])
  circle(d=d);
}

module translate_to_epd_visible_area_center(as_center=false){
  translate([0, (-(EPD_MODULE_BODY.y - EPD_MODULE_EPD.y)/2 + 5.5) * (as_center ? 1 : -1), 0])
  children(0);
}

module epd_module_body(){
  linear_extrude(height=EPD_MODULE_BODY.z, center=!true, convexity=10, twist=0)
  difference() {
    rounding(r=1)
    square(size=[EPD_MODULE_BODY.x, EPD_MODULE_BODY.y], center=true);

    epd_module_holes();
  }

  // Space for connector, chips, etc.
  %
  color("orange", 0.3)
  linear_extrude(height=EPD_MODULE_SPACE_Z, center=!true, convexity=10, twist=0)
  rounding(r=1)
  square(size=[EPD_MODULE_BODY.x, EPD_MODULE_BODY.y], center=true);

  // EPD (visible area)
  color("lightgreen", 0.5)
  translate_to_epd_visible_area_center()
  translate([0, 0, -EPD_MODULE_EPD.z/2])
  cube(size=EPD_MODULE_EPD, center=true);

  // EPD base substrate
  color("white", 0.5)
  translate([0, 0, -EPD_MODULE_EPD.z/2])
  cube(size=EPD_MODULE_EPD_BASE, center=true);
}
