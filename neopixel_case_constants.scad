// ****************************************************************************
//
// Constants and utility modules for Neopixel Enclosure models.
//
// Author: Keith Pflieger
// Date:   April 2021
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
//
// Thingiverse user: RoboticDreams
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

include <neopixel_x8_stick_constants.scad>
include <wiring_harness_constants.scad>

///////////////////////////////////////////////////////////////////////////////////////
//
// Constant definitions for various parameters defining how the front/back
// enclosure parts are created. These can be modified to tailor the enclosure
// parts to your needs, but should be verified (e.g. using the top-level Assembly
// model file) before the 3D models are rendered, exported or printed.
//
///////////////////////////////////////////////////////////////////////////////////////
cover_wall_thickness = 1.5;
rounding_radius = 1;     // Rounding of all exterior corners using minkowski()
pwb_pocket_margin = 0.5; // Allow for a reasonable manufacturing tolerance for PWB envelope
mtg_peg_margin = 0.4;    // reduce peg diameter in back part slightly for easy fit into PWM mounting hole
mtg_peg_front_shoulder = 0.55; // Shoulder around peg underneath PWB on back enclosure part
mtg_peg_front_clearance = 0.4; // Increase clearance for peg cylinder diameter in front part indent/curout region

// Some constants defining how the perimeter 'lip' is constructed for the PWB to sit on in the back part:
pwb_lip_sides = 0.2;
pwb_lip_bottom = 0.4;
pwb_lip_bottom_indent = 0.9;
pwb_lip_bottom_indent_dist = 15;
pwb_lip_top = 2.5;
pwb_lip_top_outdent = 1.5;
pwb_lip_top_outdent_dist = 20;

// A few more definitions used in constructing the front enclosure part:
peg_extension = 1.5;  // Additional height on mounting pegs above PWB top surface for alignment with front part
cover_overlap_depth = 4;
cover_overlap_width = 1;
cover_led_clearance = 0.6;

// Definitions for mounting hardware:
case_screw_offset = 6;  // From each end of PWB
case_screw_length = 10;
extra_back_thickness = 0.25; // used to make overall case assembly a little thicker than the case screw length.

// Comuted constants useful for creation of front/back enclosure parts:
bottom_cover_height = pwb_height + wire_diam + wire_bend_r + cover_wall_thickness + extra_back_thickness;
top_cover_height = led_height + cover_overlap_depth - rounding_radius/2;
front_surface_z = led_height + rounding_radius/2;
back_surface_z = bottom_cover_height + rounding_radius;

// Computed Positions for Mounting Hardware:
mtg_screw1_pos = [  -case_screw_offset,
                    pwb_width/2,
                    pwb_height + front_surface_z - case_screw_length];
mtg_screw2_pos = [  pwb_length + case_screw_offset,
                    pwb_width/2,
                    pwb_height + front_surface_z - case_screw_length];
mtg_nut1_pos = [    -case_screw_offset,
                    pwb_width/2,
                    pwb_height - back_surface_z];
mtg_nut2_pos = [    pwb_length + case_screw_offset,
                    pwb_width/2,
                    pwb_height - back_surface_z];

///////////////////////////////////////////////////////////////////////////////////////
//
//  module: back_cover_body
//      Utility module for creation of Main body of the back enclosure piece
//
//      Optional parameter 'screw_case' (default = false):
//          Indicates whether extra body sections should be added on
//          each end of the PWB to attach case screws.
//      Optional parameter 'delta' (default = 0mm):
//          * This option can be used if this 3D body module is used to cut out
//          a portion of the front_cover_body() in order to provide a little
//          relief to account for tolerances in the 3D print process.
//          * This setting can also be used in the creation of an additional 'bumpout'
//          volume of the back enclosure piece in order to make the back part flush
//          with the front part around the perimeter of the enclosure (used together
//          with the next setting (remove_extra_height).
//      Optional parameter 'remove_extra_height' (default = 0mm):
//          This setting can be used to reduce the height of this 3D model segment,
//          for use specifically in the creation of flush perimeter version of the case.
//
///////////////////////////////////////////////////////////////////////////////////////
module back_cover_body(screw_case = false, delta = 0, remove_extra_height = 0) {
    assert(delta >= 0);
    assert((remove_extra_height >= 0) && (remove_extra_height < bottom_cover_height));
    
    // Compute the diameter of the extra "tab" material added to each side of the PWB
    // for the inclusion of mounting hardware for the screw-in version of the enclosure:
    attach_tab_diameter = pwb_width + 2*cover_wall_thickness + delta;

    translate([ -cover_wall_thickness - delta/2,
                -cover_wall_thickness - delta/2,
                pwb_height - bottom_cover_height]) {
        intersection() {
            minkowski() {
                union() {
                    cube([pwb_length + 2*cover_wall_thickness + delta,
                        pwb_width + 2*cover_wall_thickness + delta, bottom_cover_height]);
                    if (screw_case) {
                        // Left "Tab" cylindrical element:
                        translate([cover_wall_thickness + delta/2 - case_screw_offset,
                            pwb_width/2 + cover_wall_thickness + delta/2,
                            bottom_cover_height/2])
                                cylinder(h = bottom_cover_height, d = attach_tab_diameter,
                                    center = true, $fn=80);
                        // Left "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + delta/2 - case_screw_offset/2,
                            pwb_width/2 + cover_wall_thickness + delta/2, bottom_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, bottom_cover_height],
                                    center = true);
                        // Right "Tab" cylindrical element:
                        translate([cover_wall_thickness + delta/2 + pwb_length + case_screw_offset,
                            pwb_width/2 + cover_wall_thickness + delta/2, bottom_cover_height/2])
                                cylinder(h = bottom_cover_height, d = attach_tab_diameter,
                                    center = true, $fn=80);
                        // Right "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + delta/2 + pwb_length + case_screw_offset/2,
                            pwb_width/2 + cover_wall_thickness + delta/2, bottom_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, bottom_cover_height],
                                    center = true);
                    }
                }
                sphere(rounding_radius, $fn=80);
            }
            // intersect with this larger, shifted cube to give it a flat top:
            translate([ -case_screw_offset - pwb_length/2, -pwb_width/2, -remove_extra_height - 3*rounding_radius])
                cube([  2*pwb_length + 2*case_screw_offset, 3*pwb_width,
                        bottom_cover_height + 3*rounding_radius]);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  module: front_cover_body
//      Utility module for creation of main body of the front enclosure piece
//
//      Optional parameter 'screw_case' (default = false):
//          Indicates whether extra body sections should be added on
//          each end of the PWB to attach case screws.
//
///////////////////////////////////////////////////////////////////////////////////////
module front_cover_body(screw_case = false) {

    // Compute the diameter of the extra "tab" material added to each side of the PWB
    // for the inclusion of mounting hardware for the screw-in version of the enclosure:
    attach_tab_diameter = pwb_width + 2*cover_wall_thickness + 2*cover_overlap_width;

    translate([ -cover_wall_thickness - cover_overlap_width,
                -cover_wall_thickness - cover_overlap_width,
                pwb_height - cover_overlap_depth]) {
        difference() {
            minkowski() {
                union() {
                    cube([pwb_length + 2*cover_wall_thickness + 2*cover_overlap_width,
                        pwb_width + 2*cover_wall_thickness + 2*cover_overlap_width,
                        top_cover_height]);
                    if (screw_case) {
                        // Left "Tab" cylindrical element:
                        translate([cover_wall_thickness + cover_overlap_width - case_screw_offset,
                            pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cylinder(h = top_cover_height, d = attach_tab_diameter, center = true, $fn=80);
                        // Left "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + cover_overlap_width - case_screw_offset/2,
                            pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, top_cover_height],
                                    center = true);
                        // Right "Tab" cylindrical element:
                        translate([pwb_length + cover_wall_thickness + cover_overlap_width + case_screw_offset,
                            pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cylinder(h = top_cover_height, d = attach_tab_diameter, center = true, $fn=80);
                        // Right "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + cover_overlap_width + pwb_length + case_screw_offset/2,
                            pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, top_cover_height],
                                    center = true);
                    }
                }
                sphere(rounding_radius, $fn=80);
            }
            translate([ -case_screw_offset - pwb_length/2, -pwb_width/2, -3*rounding_radius])
                cube([2*pwb_length + 2*case_screw_offset, 3*pwb_width, 3*rounding_radius]);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  module: mounting_pegs
//      Utility module for creation of mounting pegs + shoulders for NeoPixel Stick
//      to sit on and be held in place.
//
//      Optional parameter 'delta' (default = 0mm):
//          can be used if 3D body is used to cut out sections of the
//          front_cover_body() in order to provide a little relief to
//          account for tolerances in the 3D print process.
//
///////////////////////////////////////////////////////////////////////////////////////
module mounting_pegs(delta = 0) {
    assert(delta >= 0);
    
    translate([pwb_hole1_x, pwb_hole1_y,
                pwb_height + (peg_extension - bottom_cover_height)/2])
        cylinder(h = bottom_cover_height + peg_extension,
                r = pwb_hole1_r + delta - mtg_peg_margin/2, center = true);
    translate([pwb_hole1_x, pwb_hole1_y, (pwb_height-bottom_cover_height)/2])
        cylinder(h = bottom_cover_height - pwb_height, r = pwb_hole1_r + 0.5, center = true);
    translate([pwb_hole2_x, pwb_hole2_y,
                pwb_height + (peg_extension - bottom_cover_height)/2])
        cylinder(h = bottom_cover_height  + peg_extension,
                r = pwb_hole2_r + delta - mtg_peg_margin/2, center = true);
    translate([pwb_hole2_x, pwb_hole2_y, (pwb_height-bottom_cover_height)/2])
        cylinder(h = bottom_cover_height - pwb_height, r = pwb_hole2_r + 0.5, center = true);
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Generic Screw Model
//
//  Parameters:
//      screw_diam: Screw Diameter (e.g. set to 3.0 for M3 screw);
//      head_type:  can be "none" (for fit check), "rounded" (panel or button heads), or 
//                  "flat" (e.g. 90 deg. inset/flush-mount screws).
//      head_diam:  Widest diameter of head or 'flange' (the top of a "flat" head or
//                  the bottom of "rounded" head types (panel, button, etc.), per convention.
//      head_height: The height of rounded heads, or the inset depth of the flat head type.
//      length:     Length of screw, from the bottom of the screw to either the
//                  a) bottom of "rounded" head types, or
//                  b) top of "flat" head screws
//
///////////////////////////////////////////////////////////////////////////////////////
module generic_screw(screw_diam = 3.0, head_type = "rounded", head_diam = 6,
                    head_height = 1.9, length = 8) {
    // First, some error checking on parameters:
    assert(screw_diam > 0);
    if (head_type != "none") {
        assert(head_diam > 0);
        assert(head_height > 0);
    }
    assert(length > 0);
    assert(((head_type == "rounded") || (head_type == "flat") ||
            (head_type == "none")),
            "Unsupported head_type! Please check spelling.");
    
    // Now let's create the screw shaft itself:
    translate([0, 0, length/2])
        cylinder(h = length, d = screw_diam, center = true);
    // Next, create the screw head:
    if (head_type == "rounded") { // for now, this is just approximated by a conical section
        translate([0, 0, length + head_height/2])
            cylinder(h = head_height, d1 = head_diam, d2 = head_diam/3, center = true);
    } else if (head_type == "flat") {
        translate([0, 0, length - head_height/2])
            cylinder(h = head_height, d1 = screw_diam, d2 = head_diam, center = true);
    }
}

// Some pre-defined screws for use in the enclosure designs:
module m3x8mm_panhead_screw()       generic_screw($fn=80); // This one just uses all the defaults :-)
module m3x10mm_panhead_screw()      generic_screw(length = 10, $fn=80);
module m3x10mm_flathead_screw()     generic_screw(head_type = "flat", head_height = 1.7, length = 10, $fn=80);
module test_align_shaft_1x10mm()    generic_screw(screw_diam = 1, head_type = "none", length = 10, $fn=40);
module m3_panhead_screw(length = 8) generic_screw(length = length, $fn=80);
module m3_flathead_screw(length = 8) generic_screw(head_type = "flat", length = length, $fn=80);


/////////////////////////////////////////////////////////////////
//
// Model for M3 Nut:
//  Inner hole diameter set to 3mm; although again, it is slightly smaller
//  Parameters: thick (default = 2.5mm)
//              outer_diameter (default = 6.25mm)
//  Notes: Default values based on an M3 nut I just happened to have and measured
//      manually. However they are configurable for use elsewhere.
//
//      Outer shape is hexagonal with opposing sides being 5.4mm from each other and
//      opposing vertices being about 6.2mm distance. I will approximate this with
//      a cylindrical shape of Outer Diameter = 6.25mm, with $fn = 6
//
/////////////////////////////////////////////////////////////////
module m3_nut(thick = 2.5, outer_diameter = 6.25) {
    translate([0, 0, thick/2]) {
        difference() {
            cylinder(h = thick, d = outer_diameter, center = true, $fn=6);
            cylinder(h = thick, d = 2.9, center = true, $fn = 80);
        }
    }
}

/////////////////////////////////////////////////////////////////
//
// Testing:
//   Temporary placement of other modules for visualization/fit-
//   check or general testing purposes.
//
//   CAUTION: Enabling or modifying anything below can make the
//      rendered or 3D model contained in this file unusable
//      unless you disable it again before rendor/export of STL.
//
/////////////////////////////////////////////////////////////////

//back_cover_body(screw_case = true);
//color("gray", alpha = 0.5) back_cover_body(screw_case = true, delta = 3, remove_extra_height = 3);
*m3x8mm_panhead_screw();
*m3x10mm_flathead_screw();
*test_align_shaft_1x10mm();
