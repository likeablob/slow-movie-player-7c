include <../scad-utils/morphology.scad>

module _triangle(h=6){
  polygon(points=[[-h,0],[0,h/2],[0,-h/2]]);
}

module arrow(length=20, line_width=0.5, vertical=false, head_size=2, label="", label_pos_reverse=false) {
  rotate([0, 0, vertical ? 90 : 0]){
    // head
    mirror_x()
    translate([-length/2+head_size, 0, 0])
    _triangle(head_size);

    // line
    square(size=[length - head_size, line_width], center=true);
  }

  // label
  if(vertical){
    label_halign=label_pos_reverse ? "right" : "left";
    translate([2 * (label_pos_reverse ? -1 : 1), 0, 0])
    text(label, size=2, valign="center", halign=label_halign);
  }else{
    label_halign="center";
    translate([0, 4 * (label_pos_reverse ? 1 : -1), 0])
    text(label, size=2, valign="center", halign=label_halign);
  }
}
