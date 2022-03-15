include <modules/epd_565in_acep.scad>
include <modules/picture_frame.scad>
include <modules/smp7c_spacer.scad>

$fn=50;


%
translate_to_picture_frame_available_inner_space_zplane(as_origin_plane=true){
  picture_frame_body();
  picture_frame_front_layers();
  // picture_frame_back_panel();
}


translate([0, 0, EPD_MODULE_EPD.z])
translate_to_epd_visible_area_center(as_center=true)
epd_module_body();

smp7c_spacer_body(with_battery_space=true);
