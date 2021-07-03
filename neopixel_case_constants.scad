// ****************************************************************************
//
// Constants and utility modules for Neopixel Enclosure models.
//
// Author: Keith Pflieger
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
//
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

include <neopixel_x8_stick_constants.scad>

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
mtg_peg_front_clearance = 0.4; // Increase clearance for peg cylinder diameter in front part indent/cutout region

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

// Computed constants useful for creation of front/back enclosure parts:
wire_diam  = 1.6;
wire_bend_r = 2;
wire_harness_opening_length = 10;   // Equal to maximum Socket dimension (for JST4-PH connector)
bottom_cover_base_height = ada_nps8_pwb_height + wire_diam + wire_bend_r + cover_wall_thickness;
top_cover_height = led_height + cover_overlap_depth - rounding_radius/2;
front_surface_z = led_height + rounding_radius/2;

///////////////////////////////////////////////////////////////////////////////////////
//
//  module: back_cover_body
//      Utility module for creation of Main body of the back enclosure piece
//
//      Optional parameters:
//      'screw_case' (default = true):
//          Indicates whether extra body sections should be added on
//          each end of the PWB to attach case screws.
//      'delta' (default = 0 mm):
//          * This option can be used if this 3D body module is used to cut out
//          a portion of the front_cover_body() in order to provide a little
//          relief to account for tolerances in the 3D print process.
//          * This setting can also be used in the creation of an additional 'bumpout'
//          volume of the back enclosure piece in order to make the back part flush
//          with the front part around the perimeter of the enclosure (used together
//          with the next setting (remove_extra_height).
//      'case_screw_offset' (default = 4.6 mm):
//          Specifies the distance from each PWB edge to the center of the enclosure attachment
//          screws. The default value of 4.6 yields a 60.0 mm enclosure screw separation.
//          Only used for screw-in enclosure variant. Must be > 3 mm to allow for M3 mounting screws.
//      'extra_back_thickness' (default = 0 mm):
//          Use this parameter to increase the depth of the back enclosure part to suit
//          your needs (like matching the screw length, or that of another object). Added
//          to the 'back' side (rounded side) of model.
//      'remove_extra_height' (default = 0 mm):
//          This setting can be used to reduce the height of this 3D model segment, from
//          the 'front' side (flat side). Used specifically in the creation of the flush
//          version of the case.
//
///////////////////////////////////////////////////////////////////////////////////////
module back_cover_body (
            screw_case = true,
            delta = 0,
            case_screw_offset = 4.6,
            extra_back_thickness = 0,
            remove_extra_height = 0
        ) {
            
    assert(delta >= 0);
    if (screw_case) assert(case_screw_offset > 3);
    assert(extra_back_thickness >= 0);
    assert((remove_extra_height >= 0) && (remove_extra_height < bottom_cover_base_height));
    
    // Compute the diameter of the extra "tab" material added to each side of the PWB
    // for the inclusion of mounting hardware for the screw-in version of the enclosure:
    attach_tab_diameter = ada_nps8_pwb_width + 2*cover_wall_thickness + delta;

    // Compute overall back enclosure part height from passed parameter:
    bottom_cover_height = bottom_cover_base_height + extra_back_thickness;

    translate([ -cover_wall_thickness - delta/2,
                -cover_wall_thickness - delta/2,
                ada_nps8_pwb_height - bottom_cover_height]) {
        intersection() {
            minkowski() {
                union() {
                    cube([ada_nps8_pwb_length + 2*cover_wall_thickness + delta,
                        ada_nps8_pwb_width + 2*cover_wall_thickness + delta, bottom_cover_height]);
                    if (screw_case) {
                        // Left "Tab" cylindrical element:
                        translate([cover_wall_thickness + delta/2 - case_screw_offset,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + delta/2,
                            bottom_cover_height/2])
                                cylinder(h = bottom_cover_height, d = attach_tab_diameter,
                                    center = true, $fn=80);
                        // Left "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + delta/2 - case_screw_offset/2,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + delta/2, bottom_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, bottom_cover_height],
                                    center = true);
                        // Right "Tab" cylindrical element:
                        translate([cover_wall_thickness + delta/2 + ada_nps8_pwb_length + case_screw_offset,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + delta/2, bottom_cover_height/2])
                                cylinder(h = bottom_cover_height, d = attach_tab_diameter,
                                    center = true, $fn=80);
                        // Right "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + delta/2 + ada_nps8_pwb_length + case_screw_offset/2,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + delta/2, bottom_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, bottom_cover_height],
                                    center = true);
                    }
                }
                sphere(rounding_radius, $fn=80);
            }
            // intersect with this larger, shifted cube to give it a flat top:
            translate([ -case_screw_offset - ada_nps8_pwb_length/2, -ada_nps8_pwb_width/2, -remove_extra_height - 3*rounding_radius])
                cube([  2*ada_nps8_pwb_length + 2*case_screw_offset, 3*ada_nps8_pwb_width,
                        bottom_cover_height + 3*rounding_radius]);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  module: front_cover_body
//      Utility module for creation of main body of the front enclosure piece
//
//      Parameters:
//      'screw_case' (default = true):
//          Indicates whether extra body sections should be added on
//          each end of the PWB to attach case screws.
//      'case_screw_offset' (default = 4.6 mm):
//          Specifies the distance from each PWB edge to the center of the enclosure attachment
//          screws. The default value of 4.6 yields a 60.0 mm enclosure screw separation.
//          Only used for screw-in enclosure variant. Must be > 3 mm to allow for M3 mounting screws.
//
///////////////////////////////////////////////////////////////////////////////////////
module front_cover_body(screw_case = true, case_screw_offset = 4.6) {

    // First, some error checking:
    if (screw_case) assert(case_screw_offset > 3);

    // Compute the diameter of the extra "tab" material added to each side of the PWB
    // for the inclusion of mounting hardware for the screw-in version of the enclosure:
    attach_tab_diameter = ada_nps8_pwb_width + 2*cover_wall_thickness + 2*cover_overlap_width;

    translate([ -cover_wall_thickness - cover_overlap_width,
                -cover_wall_thickness - cover_overlap_width,
                ada_nps8_pwb_height - cover_overlap_depth]) {
        difference() {
            minkowski() {
                union() {
                    cube([ada_nps8_pwb_length + 2*cover_wall_thickness + 2*cover_overlap_width,
                        ada_nps8_pwb_width + 2*cover_wall_thickness + 2*cover_overlap_width,
                        top_cover_height]);
                    if (screw_case) {
                        // Left "Tab" cylindrical element:
                        translate([cover_wall_thickness + cover_overlap_width - case_screw_offset,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cylinder(h = top_cover_height, d = attach_tab_diameter, center = true, $fn=80);
                        // Left "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + cover_overlap_width - case_screw_offset/2,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, top_cover_height],
                                    center = true);
                        // Right "Tab" cylindrical element:
                        translate([ada_nps8_pwb_length + cover_wall_thickness + cover_overlap_width + case_screw_offset,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cylinder(h = top_cover_height, d = attach_tab_diameter, center = true, $fn=80);
                        // Right "Tab" cube/connection to main body:
                        translate([cover_wall_thickness + cover_overlap_width + ada_nps8_pwb_length + case_screw_offset/2,
                            ada_nps8_pwb_width/2 + cover_wall_thickness + cover_overlap_width,
                            top_cover_height/2])
                                cube([case_screw_offset, attach_tab_diameter, top_cover_height],
                                    center = true);
                    }
                }
                sphere(rounding_radius, $fn=80);
            }
            translate([ -case_screw_offset - ada_nps8_pwb_length/2, -ada_nps8_pwb_width/2, -3*rounding_radius])
                cube([2*ada_nps8_pwb_length + 2*case_screw_offset, 3*ada_nps8_pwb_width, 3*rounding_radius]);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  module: mounting_pegs
//      Utility module for creation of mounting pegs + shoulders for NeoPixel Stick
//      to sit on and be held in place.
//
//      Parameters:
//      'delta' (default = 0 mm):
//          can be used if 3D body is used to cut out sections of the
//          front_cover_body() in order to provide a little relief to
//          account for tolerances in the 3D print process.
//      'extra_back_thickness' (default = 0 mm):
//          Use this parameter to increase the depth of the back enclosure part to suit
//          your needs (like matching the screw length, or that of another object). Added
//          to the 'back' side (rounded side) of model.
//
///////////////////////////////////////////////////////////////////////////////////////
module mounting_pegs(delta = 0, extra_back_thickness = 0) {

    // First some error checking and variable computation:
    assert(delta >= 0);
    assert(extra_back_thickness >= 0);
    
    // Compute overall back enclosure part height from passed parameter:
    bottom_cover_height = bottom_cover_base_height + extra_back_thickness;
        
    translate([pwb_hole1_x, pwb_hole1_y,
                ada_nps8_pwb_height + (peg_extension - bottom_cover_height)/2])
        cylinder(h = bottom_cover_height + peg_extension,
                r = pwb_hole1_r + delta - mtg_peg_margin/2, center = true);
    translate([pwb_hole1_x, pwb_hole1_y, (ada_nps8_pwb_height-bottom_cover_height)/2])
        cylinder(h = bottom_cover_height - ada_nps8_pwb_height, r = pwb_hole1_r + 0.5, center = true);
    translate([pwb_hole2_x, pwb_hole2_y,
                ada_nps8_pwb_height + (peg_extension - bottom_cover_height)/2])
        cylinder(h = bottom_cover_height  + peg_extension,
                r = pwb_hole2_r + delta - mtg_peg_margin/2, center = true);
    translate([pwb_hole2_x, pwb_hole2_y, (ada_nps8_pwb_height-bottom_cover_height)/2])
        cylinder(h = bottom_cover_height - ada_nps8_pwb_height, r = pwb_hole2_r + 0.5, center = true);
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Generic Screw Model
//
//  Parameters:
//      screw_diam: Screw Diameter (e.g. set to 3.0 for M3 screw);
//      screw_type: This can be "none (for fit check), "round" (panel or button heads), 
//                  "cylinder" (socket head) or "flat" (e.g. 90 deg. flush-mount) screws.
//      cutout_region: Boolean, set to true if using generic_screw_model() to create a
//                  screw hole or other cutout_region (does not implement socket/screw
//                  driver cutout).
//      head_diam:  Widest diameter of head or 'flange' (the top of a "flat" head or
//                  the bottom of "rounded" head types (panel, button, etc.), per convention.
//      head_height: The height of rounded heads, or the inset depth of the flat head type.
//      length:     Length of screw, from the bottom of the screw to either the
//                  a) bottom of "round" and "cylinder" head types, or
//                  b) top of "flat" head screws
//
///////////////////////////////////////////////////////////////////////////////////////
module generic_screw_model(screw_diam = 3.0, screw_type = "round", cutout_region = false,
                    head_diam = 6, head_height = 1.9, length = 8) {
    // First, some error checking on parameters:
    assert(screw_diam > 0);
    assert(head_diam > 0);
    assert(head_height > 0);
    assert(length > 0);
    assert(((screw_type == "round") || (screw_type == "cylinder") ||
            (screw_type == "none")  || (screw_type == "flat") ),
            "Unsupported screw_type! Please check spelling.");
    
    difference() {
        union() {
            // Now let's create the screw shaft itself:
            translate([0, 0, length/2])
                cylinder(h = length, d = screw_diam, center = true);
            // Next, create the screw head:
            if (screw_type == "round") {
                translate([0, 0, length]) {
                    scale([1, 1, 2*head_height/head_diam]) {
                        difference() {
                            sphere(d = head_diam, $fn = 100);
                            translate([0, 0, -head_diam/2]) cube(head_diam, center = true);
                        }
                    }
                }
            } else if (screw_type == "cylinder") {
                translate([0, 0, length + head_height/2])
                    cylinder(h = head_height, d = head_diam, center = true);
            } else if (screw_type == "flat") {
                translate([0, 0, length - head_height/2])
                    cylinder(h = head_height, d1 = screw_diam, d2 = head_diam, center = true);
            }
        }
        if (!cutout_region) {
            translate([0, 0, (screw_type == "flat") ? length : length + head_height])
                cylinder(h = head_height, d = screw_diam, center = true, $fn = 6);
        }
    }
}

// Some pre-defined screws for use in the enclosure designs:
module m3x8mm_panhead_screw()       generic_screw_model($fn=80); // This one just uses all of the defaults :-)
module m3x10mm_panhead_screw()      generic_screw_model(length = 10, $fn=80);
module m3x10mm_flathead_screw()     generic_screw_model(screw_type = "flat", head_height = 1.7, length = 10, $fn=80);
module test_align_shaft_1x10mm()    generic_screw_model(screw_diam = 1, screw_type = "none", length = 10, $fn=40);
module m3_panhead_screw(length = 8)  generic_screw_model(length = length, $fn=80);
module m3_flathead_screw(length = 8) generic_screw_model(screw_type = "flat", length = length, $fn=80);

/////////////////////////////////////////////////////////////////
//
// Model for M3 Nut:
//  Inner hole diameter set to 3 mm; although again, it is slightly smaller
//  Parameters: thick (default = 2.5 mm)
//              outer_diameter (default = 6.25 mm)
//  Notes: Default values based on an M3 nut I just happened to have and measured
//      manually. However they are configurable for use elsewhere.
//
//      Outer shape is hexagonal with opposing sides being 5.4 mm from each other and
//      opposing vertices being about 6.2 mm distance. I will approximate this with
//      a cylindrical shape of Outer Diameter = 6.25 mm, with $fn = 6
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
//      unless you disable it again before render/export of STL.
//
/////////////////////////////////////////////////////////////////

//back_cover_body(screw_case = true);
//color("gray", alpha = 0.5) back_cover_body(screw_case = true, delta = 3, remove_extra_height = 3);
*m3x8mm_panhead_screw();
*m3x10mm_flathead_screw();
*test_align_shaft_1x10mm();

///////////////////////////////////////////////////////////////////////////////////////
//
//  Accessory Functions:
//      Useful for implementing NeoPixel Stick enclosures in other 3D Models in OpenSCAD,
//      Such as for adding lightbars to the MuSHR.io racecar chassis.
//
///////////////////////////////////////////////////////////////////////////////////////

// used for cutout of other volume or collision detection, when mounting enclosure to other
//  surfaces or models (like MuSHR Racecar Chassis):
module enclosure_body_cutout(screw_case = true, case_screw_separation = 60,
        case_thickness = 10.5, clearance = 0) {

    // First some error checking and variable computation:
    assert(clearance >= 0);
    if (screw_case) assert(case_screw_separation > ada_nps8_pwb_length + 6.0);
    case_screw_offset = (case_screw_separation - ada_nps8_pwb_length)/2;

    minimum_case_thickness = bottom_cover_base_height + rounding_radius + front_surface_z;
    
    assert(case_thickness >= minimum_case_thickness);
    extra_back_thickness = case_thickness - minimum_case_thickness;
    // Compute overall back enclosure part height from passed parameter:
    bottom_cover_height = bottom_cover_base_height + extra_back_thickness;
    
    // Compute the diameter of the extra "tab" material added to each side of the PWB
    // for the inclusion of mounting hardware for the screw-in version of the enclosure:
    extra_dimension = cover_wall_thickness + cover_overlap_width + rounding_radius + clearance;
    body_length = ada_nps8_pwb_length + 2*extra_dimension;
    body_width  = ada_nps8_pwb_width + 2*extra_dimension;

    translate([ -extra_dimension, -extra_dimension,
                ada_nps8_pwb_height - bottom_cover_height - rounding_radius]) {
        union() {
            cube([body_length, body_width, case_thickness]);
            if (screw_case) {
                // Left "Tab" cylindrical element:
                translate([extra_dimension - case_screw_offset,
                    extra_dimension + ada_nps8_pwb_width/2, case_thickness/2])
                        cylinder(h = case_thickness, d = body_width, center = true, $fn=80);
                // Left "Tab" cube/connection to main body:
                translate([extra_dimension - case_screw_offset/2,
                    extra_dimension + ada_nps8_pwb_width/2, case_thickness/2])
                        cube([case_screw_offset, body_width, case_thickness], center = true);
                // Right "Tab" cylindrical element:
                translate([extra_dimension + ada_nps8_pwb_length + case_screw_offset,
                    extra_dimension + ada_nps8_pwb_width/2, case_thickness/2])
                        cylinder(h = case_thickness, d = body_width, center = true, $fn=80);
                // Right "Tab" cube/connection to main body:
                translate([extra_dimension + ada_nps8_pwb_length + case_screw_offset/2,
                    extra_dimension + ada_nps8_pwb_width/2, case_thickness/2])
                        cube([case_screw_offset, body_width, case_thickness], center = true);
            }
        }
    }
}
