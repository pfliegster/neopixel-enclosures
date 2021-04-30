// ****************************************************************************
//
// File: neopixel_x8_stick_case_back.scad
//
// Description:
//      Back cover for the LED Light bar assembly built with NeoPixel 8 Stick 
//      products from Adafruit.
//
//      This back cover is designed to include 2 mounting pegs which protrude
//      through the two 2mm mounting holes in the NeoPixel Stick PWB.
//
//      This back cover also has an access hole in the center through which the 
//      wiring harnedd is routed. The center access hole is large enough to allow 
//      the cover to be removed even when the wiring harness is mounted to the 
//      PWB. It therefore is slightly larger than the 4-pin socket configuration
//      of the wiring harness (JST-4PH).
//
// Author: Keith Pflieger
// Date:   April 2021
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// Thingiverse user: RoboticDreams
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

include <neopixel_case_constants.scad>

$include_wiring_harness = false;
include <neopixel_wiring_harness.scad>

$include_pwb = false;
include <neopixel_x8_stick_pwb.scad>

///////////////////////////////////////////////////////////////////////////////////////
//
//  Preview or Render Model only if viewed directly, not called as
//  part of upper-level Assembly:
//
//  This section can be used to render and export an STL for
//  printing, using the enclosure options listed as id or modified
//  as desired.
//
//  Notes:
//      1) Some changes here (such as to 'screw_case') require a corresponding
//         change to the front enclosure part in order for the case to operate
//         correctly. Otherwise you could end up with dissimilar part types for
//         front and back parts.
//      2) Changing enclosure options here does not change them in the top-level
//         assembly or animation design files. So if  you need to verify a change
//         in these settings, you will have to duplicate the change there too.
//
///////////////////////////////////////////////////////////////////////////////////////
if ($include_back == undef) {
    neopixel_stick_case_back(
        screw_case = true,
        screw_hole_diameter = 3.2, // Slightly bigger than M3 screw diameter 
        screw_depth = 6.5,         // Set this to at least 'back_surface_z' to go all the way through
        flush_perim = true,
        include_nut_pocket = true,
        nut_pocket_depth = 3.5,
        back_alpha = 1.0
    );
    // Echo some dimensional information to console window:
    echo("Back Enclosure Part height = ", back_surface_z, " mm");
    echo("  --> Plus Peg Extension = ", peg_extension, " mm");
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Module: neopixel_stick_case_back
//      Enclosure Back Part for NeoPixel Stick 8 products.
//
//  Parameters:
//      screw_case: Set to true for the enclosure that attaches front & back part
//                  with mounting screws (M3 screws and nuts); False yields the Simple
//                  Enclosure type.
//      screw_hole_diameter: Diameter of screw hole in enclosure part, only used if 
//                  screw_case = true. For M3 hardware, set thie to 3.2mm in order to have
//                  a little clearance for the screw when using an M3 Nut also. Otherwise,
//                  you this can be slightly smaller if screwing directly into the plastic and
//                  the nut is left off (include_nut_pocket = false).
//      flush_perim: Set to true to "Bump out" back-most section of back enclosure piece
//                  such that the perimeter is flush with the front enclosure piece.
//      include_nut_pocket: set to true to add a cutout/pocket in back of part for M3 nut.
//      nut_pocket_depth: depth to inset the nut pocket in the back of the enclosure.
//      screw_depth: depth (from front surface) to make the screw hole, useful if nut pocket
//                  is not included and you plan to screw M3 hardware directly into plastic.
//      back_alpha: Setting used for visualization of preview for assembly fit-check
//                  or animation.
//
//  Notes:
//      1) The Enclosure is slightly bigger for screw_case = true. This option adds
//          extra material to the right & left of the NeoPixel for enclosure screw
//          hardware to be mounted. The enclosure is also slightly thicker.
//
///////////////////////////////////////////////////////////////////////////////////////

module neopixel_stick_case_back(screw_case = false, screw_hole_diameter = 3.2, flush_perim = false,
            include_nut_pocket = true, nut_pocket_depth = 4, screw_depth = back_surface_z, back_alpha = 1.0) {
    color("dimgray", alpha = back_alpha){
        union() {
            render() difference() {
                union() {
                    // Main body of the back cover model:
                    back_cover_body(screw_case = screw_case);
                    // Add flush perimeter extra "bumpout" volume if selected:
                    if (flush_perim) 
                        back_cover_body(screw_case = screw_case,
                                        delta = 2 * cover_overlap_width,
                                        remove_extra_height = cover_overlap_depth);
                }
                union() {
                    // Pocket for the PWB to sit in, with a little bit of margin around PWB edges:
                    translate([-pwb_pocket_margin, -pwb_pocket_margin, 0])
                        cube([pwb_length + 2*pwb_pocket_margin,
                            pwb_width + 2*pwb_pocket_margin, pwb_height]);

                    // Another pocket to allow for wire thickness using 'lip' constants,
                    // so the PWB will sit on the edges:
                    translate([pwb_lip_sides,
                            pwb_lip_bottom + pwb_lip_bottom_indent,
                            -wire_diam - wire_bend_r])
                        cube([pwb_length - 2*pwb_lip_sides,
                            pwb_width - pwb_lip_bottom - pwb_lip_bottom_indent - pwb_lip_top,
                            wire_diam + wire_bend_r]);

                    // Another cutout to allow for clearance around wire #1:
                    translate([pwb_lip_sides, pwb_lip_bottom, -wire_diam - wire_bend_r])
                        cube([pwb_lip_bottom_indent_dist,
                            pwb_width - pwb_lip_bottom - pwb_lip_top,
                            wire_diam + wire_bend_r]);

                    // Another cutout to allow for clearance around wire #4 at 90 degree bend:
                    translate([pwb_lip_top_outdent_dist + pwb_lip_sides,
                            pwb_width - pwb_lip_top,
                            -wire_diam - wire_bend_r])
                        cube([pwb_length - 2*pwb_lip_top_outdent_dist - 2*pwb_lip_sides,
                            pwb_lip_top_outdent,
                            wire_diam + wire_bend_r]);
                            
                    // Cut corners for internal, convex, vertical pocket corners
                    translate([pwb_lip_top_outdent_dist + pwb_lip_sides,
                            pwb_width - pwb_lip_top, -(wire_diam + wire_bend_r)/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_top_outdent/sqrt(2),
                                2*pwb_lip_top_outdent/sqrt(2),
                                wire_diam + wire_bend_r], center=true);
                        }
                    }
                    translate([pwb_length - pwb_lip_top_outdent_dist - pwb_lip_sides,
                            pwb_width - pwb_lip_top, -(wire_diam + wire_bend_r)/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_top_outdent/sqrt(2),
                                2*pwb_lip_top_outdent/sqrt(2),
                                wire_diam + wire_bend_r], center=true);
                        }
                    }
                    translate([pwb_lip_bottom_indent_dist + pwb_lip_sides,
                            pwb_lip_bottom + pwb_lip_bottom_indent, -(wire_diam + wire_bend_r)/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_bottom_indent/sqrt(2),
                                2*pwb_lip_bottom_indent/sqrt(2),
                                wire_diam + wire_bend_r], center=true);
                        }
                    }

                    // Cutout through back of case for wire harness:
                    translate([pwb_length/2, pwb_pad_center_y1 + pwb_pad_pitch_y + wire_diam/2,
                            -bottom_cover_height/2]) {
                        minkowski() {
                            cube([jst4ph_socket_length,
                                4*wire_diam + pwb_pocket_margin - 2*rounding_radius,
                                bottom_cover_height], center = true);
                            sphere(rounding_radius, $fn=80);
                        }
                    }
                    // Drill holes through the model for screws and cutout pockets for nuts
                    // for screw together variant of enclosure:
                    if (screw_case) {
                        translate([-case_screw_offset, pwb_width/2, pwb_height - screw_depth/2])
                            cylinder(h = screw_depth, d = screw_hole_diameter, center = true, $fn=80);
                        translate([pwb_length + case_screw_offset, pwb_width/2, pwb_height - screw_depth/2])
                            cylinder(h = screw_depth, d = screw_hole_diameter, center = true, $fn=80);
                        if (include_nut_pocket) {
                            translate([-case_screw_offset, pwb_width/2,
                                pwb_height + nut_pocket_depth/2 - back_surface_z])
                                cylinder(h = nut_pocket_depth, d = 7, center = true, $fn=6);
                            translate([pwb_length + case_screw_offset, pwb_width/2,
                                pwb_height + nut_pocket_depth/2 - back_surface_z])
                                cylinder(h = nut_pocket_depth, d = 7, center = true, $fn=6);
                        }
                    }
                }
            }

            // Add mounting pegs (through PWB mounting holes) + shoulders to sit on:
            mounting_pegs();
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
if ($include_back == undef) {
    if ($include_pwb) pwb_model($fn=40);
    if ($include_wiring_harness) wiring_harness(
        num_conductor = 4,
        harness_length = 20,
        connector_type = "socket", $fn=40);

    // Some Mounting Hardware models ...
*    color(c = [0.2, 0.2, 0.2] , alpha = 1.0) render() union() {
        // Align screw flanges with front of front enclosure piece:
        translate([-case_screw_offset, pwb_width/2, pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
        translate([pwb_length + case_screw_offset, pwb_width/2, pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
        // Align nuts with back of back enclosure piece (set into inset nut pocket):
        translate([-case_screw_offset, pwb_width/2, pwb_height - back_surface_z])
            m3_nut(outer_diameter = 6.4);
        translate([pwb_length + case_screw_offset, pwb_width/2, pwb_height - back_surface_z])
            m3_nut(outer_diameter = 6.4);
    }
}
