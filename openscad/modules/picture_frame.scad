include <../scad-utils/morphology.scad>

PICTURE_FRAME_WIDTH=20;
PICTURE_FRAME_INNER_EDGE_WIDTH=7;
PICTURE_FRAME_WALL_WIDTH=PICTURE_FRAME_WIDTH - PICTURE_FRAME_INNER_EDGE_WIDTH;

PICTURE_FRAME_INNER_SPACE=[158, 130, 22];
PICTURE_FRAME_BODY=[PICTURE_FRAME_INNER_SPACE.x + PICTURE_FRAME_WALL_WIDTH*2, PICTURE_FRAME_INNER_SPACE.y + PICTURE_FRAME_WALL_WIDTH*2, 29];

PICTURE_FRAME_FRONT_LAYERS_Z=2 + 1.2; // Glass + Sheet
PICTURE_FRAME_BACK_PANEL_Z=3;
PICTURE_FRAME_SHEET_WINDOW=[114, 86];

PICTURE_FRAME_WINDOW_Z=PICTURE_FRAME_BODY.z - PICTURE_FRAME_INNER_SPACE.z;
PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z=PICTURE_FRAME_INNER_SPACE.z - (PICTURE_FRAME_FRONT_LAYERS_Z + PICTURE_FRAME_BACK_PANEL_Z);

echo(str("PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z = ", PICTURE_FRAME_INNER_SPACE_AVAILABLE_Z));


module translate_to_picture_frame_available_inner_space_zplane(as_origin_plane=false){
  translate([0, 0, (PICTURE_FRAME_WINDOW_Z + PICTURE_FRAME_FRONT_LAYERS_Z) * (as_origin_plane ? -1 : 1) ])
  children();
}

module picture_frame_body() {
  difference(){
    translate([0, 0, PICTURE_FRAME_BODY.z/2])
    cube(size=PICTURE_FRAME_BODY, center=true);

    // window
    translate([0, 0, -0.01])
    linear_extrude(height=10 + 0.01, center=!true, convexity=10, twist=0)
    inset(d=PICTURE_FRAME_WIDTH)
    square(size=[PICTURE_FRAME_BODY.x, PICTURE_FRAME_BODY.y], center=true);

    // inner space
    translate([0, 0, PICTURE_FRAME_WINDOW_Z + 0.01])
    translate([0, 0, PICTURE_FRAME_INNER_SPACE.z/2])
    cube(size=PICTURE_FRAME_INNER_SPACE, center=true);
  }
}

module picture_frame_front_layers(){
  color("blue", 0.1)
  translate([0, 0, PICTURE_FRAME_WINDOW_Z])
  linear_extrude(height=PICTURE_FRAME_FRONT_LAYERS_Z, center=!true, convexity=10, twist=0)
  difference(){
    square(size=[PICTURE_FRAME_INNER_SPACE.x, PICTURE_FRAME_INNER_SPACE.y], center=true);

    // Sheet window
    square(size=[PICTURE_FRAME_SHEET_WINDOW.x, PICTURE_FRAME_SHEET_WINDOW.y], center=true);
  }
}

module picture_frame_back_panel(){
  color("yellow", 0.3)
  translate([0, 0, PICTURE_FRAME_BODY.z - PICTURE_FRAME_BACK_PANEL_Z])
  linear_extrude(height=PICTURE_FRAME_BACK_PANEL_Z, center=!true, convexity=10, twist=0)
  square(size=[PICTURE_FRAME_INNER_SPACE.x, PICTURE_FRAME_INNER_SPACE.y], center=true);
}
