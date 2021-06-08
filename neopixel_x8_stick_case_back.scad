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
//      wiring harness is routed. The center access hole is large enough to allow 
//      the cover to be removed even when the wiring harness is mounted to the 
//      PWB. It therefore is slightly larger than the 4-pin socket configuration
//      of the wiring harness (JST-4PH).
//
// Author: Keith Pflieger
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

include <neopixel_case_constants.scad>

$include_wiring_harness = false;
include <neopixel_wiring_harness.scad>

$include_pwb = false;
include <neopixel_x8_stick_pwb.scad>

// What are we rendering? Either the Enclosure Back part by itself or installed on
// mounting plate (such as for use with MuSHR Racecar chassis components):
_include_mounting_plate = false;

// Do we also want to turn on the Case Body Collision/cutout volume for visualization?
display_collision_body = false;

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
//      1) Some changes here (such as to 'screw_case' and 'case_screw_separation')
//         require a corresponding change to the front enclosure part in order for 
//         the case to function correctly. Otherwise you could end up with dissimilar 
//         part types for front and back parts.
//      2) Changing enclosure options here does not change them in the top-level
//         assembly or animation design files. So if  you need to verify a change
//         in these settings, you will have to duplicate the change there too.
//
///////////////////////////////////////////////////////////////////////////////////////
if ($include_back == undef) {
    if (!_include_mounting_plate) {
        neopixel_stick_case_back (
            screw_case = true,
            xy_center  = false,
            screw_hole_diameter = 3.4,
            screw_depth = 6.5,
            case_screw_separation = 60,
            case_thickness = 10.25,
            add_back_mounting_screws = false,
            flush_perim = true,
            include_nut_pocket = true,
            nut_pocket_depth = 3.5,
            back_alpha = 1.0
        );
    } else {
        neopixel_stick_case_back_on_mounting_plate (
            mounting_plate_length = 68.188,
            mounting_plate_width = 35.4773,
            mounting_plate_thickness = 6.0,
            screw_hole_diameter = 3.4,
            screw_depth = 10,
            case_screw_separation = 60,
            include_nut_pocket = true,
            nut_pocket_depth = 3.5,
            back_alpha = 1.0
        );
    }
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
//      xy_center:  Set to 'true' in order to center the Model in the XY plane, useful for
//                  incorporation of the module into other projects so that the user does not
//                  need to be aware of the origin used by default in this project (false = align
//                  this module with NeoPixel Stick 8 PWB lower-left corner at origin).
//      screw_hole_diameter: Diameter of screw hole in enclosure part, only used if 
//                  screw_case = true. For M3 hardware, set this to 3.4 mm in order to have
//                  a little clearance for the screw when using an M3 Nut also. Otherwise,
//                  you this can be slightly smaller if screwing directly into the plastic and
//                  the nut is left off (include_nut_pocket = false).
//      flush_perim: Set to true to "Bump out" back-most section of back enclosure piece
//                  such that the perimeter is flush with the front enclosure piece.
//      add_back_mounting_screws: Set to true in order to add M3 Mounting screw moles in back
//                  model part in order to mount lightbar to other objects or models.
//      include_nut_pocket: set to true to add a cutout/pocket in back of part for M3 nut.
//      nut_pocket_depth: depth to inset the nut pocket in the back of the enclosure.
//      screw_depth: depth (from front surface) to make the screw hole, useful if nut pocket
//                  is not included and you plan to screw M3 hardware directly into plastic.
//      case_screw_separation: Distance between the two case screws, center to center (for 
//                  attaching front enclosure part to the back). Only used when 'screw_case
//                  = true'. Must be > PWB Length + 6.0 mm. Default = 60 mm.
//      case_thickness: Desired overall thickness of the NeoPixel Enclosure Assembly (front
//                  plus bottom part). Used to drive some extra thickness on the back enclosure
//                  model part.
//      back_alpha: Setting used for visualization of preview for assembly fit-check
//                  or animation.
//
//  Notes:
//      1) The Enclosure is slightly bigger for screw_case = true. This option adds
//          extra material to the right & left of the NeoPixel for enclosure screw
//          hardware to be mounted. The enclosure is also slightly thicker.
//
///////////////////////////////////////////////////////////////////////////////////////

module neopixel_stick_case_back (
            screw_case = true,
            xy_center  = false,
            screw_hole_diameter = 3.4,
            flush_perim = true,
            add_back_mounting_screws = false,
            include_nut_pocket = true,
            nut_pocket_depth = 4,
            screw_depth = 10.5,
            case_screw_separation = 60,
            case_thickness = 10.5,
            back_alpha = 1.0
        ) {
                
    // First some error checking and variable computation:
    minimum_case_thickness = bottom_cover_base_height + rounding_radius + front_surface_z;
    assert(case_thickness >= minimum_case_thickness);
    extra_back_thickness = case_thickness - minimum_case_thickness;

    // Compute overall back enclosure part height from passed parameter:
    bottom_cover_height = bottom_cover_base_height + extra_back_thickness;

    echo("Min Thickness = ", minimum_case_thickness);
    back_surface_z = case_thickness - front_surface_z;

    if (screw_case) assert(case_screw_separation > ada_nps8_pwb_length + 6.0);
    case_screw_offset = (case_screw_separation - ada_nps8_pwb_length)/2;

    harness_pocket_depth = wire_diam + wire_bend_r;
                
    // Echo some dimensional information to console window:
    echo("Back Enclosure Part height = ", back_surface_z, " mm");
    echo("of which portion is flush bump = ", back_surface_z - cover_overlap_depth, " mm");
    echo("  --> Plus Peg Extension = ", peg_extension, " mm");
    echo("extra_back_thickness = ", extra_back_thickness, " mm");

    color("dimgray", alpha = back_alpha) {
        // Compute translation vector if user sets 'xy_center' == true:
        xy_origin_translation = [ xy_center ? -ada_nps8_pwb_length/2 : 0, xy_center ? -ada_nps8_pwb_width/2  : 0, 0 ];
        
        translate(xy_origin_translation) {
            render() difference() {
                union() {
                    // Main body of the back cover model:
                    back_cover_body(screw_case = screw_case, 
                                    case_screw_offset = case_screw_offset,
                                    extra_back_thickness = extra_back_thickness);

                    // Add flush perimeter extra "bumpout" volume if selected:
                    if (flush_perim) 
                        back_cover_body(screw_case = screw_case,
                                        delta = 2 * cover_overlap_width,
                                        case_screw_offset = case_screw_offset,
                                        extra_back_thickness = extra_back_thickness,
                                        remove_extra_height = cover_overlap_depth);
                }
                union() {
                    // Pocket for the PWB to sit in, with a little bit of margin around PWB edges:
                    translate([-pwb_pocket_margin, -pwb_pocket_margin, 0])
                        cube([ada_nps8_pwb_length + 2*pwb_pocket_margin,
                            ada_nps8_pwb_width + 2*pwb_pocket_margin, ada_nps8_pwb_height]);

                    // Another pocket to allow for wire thickness using 'lip' constants,
                    // so the PWB will sit on the edges:
                    translate([pwb_lip_sides, pwb_lip_bottom + pwb_lip_bottom_indent,
                            -harness_pocket_depth])
                        cube([ada_nps8_pwb_length - 2*pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_bottom - pwb_lip_bottom_indent - pwb_lip_top,
                            harness_pocket_depth]);

                    // Another cutout to allow for clearance around wire #1:
                    translate([pwb_lip_sides, pwb_lip_bottom, -harness_pocket_depth])
                        cube([pwb_lip_bottom_indent_dist,
                            ada_nps8_pwb_width - pwb_lip_bottom - pwb_lip_top,
                            harness_pocket_depth]);

                    // Another cutout to allow for clearance around wire #4 at 90 degree bend:
                    translate([pwb_lip_top_outdent_dist + pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_top, -harness_pocket_depth])
                        cube([ada_nps8_pwb_length - 2*pwb_lip_top_outdent_dist - 2*pwb_lip_sides,
                            pwb_lip_top_outdent,
                            harness_pocket_depth]);
                            
                    // Cut corners for internal, convex, vertical pocket corners
                    translate([pwb_lip_top_outdent_dist + pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_top, -harness_pocket_depth/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_top_outdent/sqrt(2), 2*pwb_lip_top_outdent/sqrt(2),
                                harness_pocket_depth], center=true);
                        }
                    }
                    translate([ada_nps8_pwb_length - pwb_lip_top_outdent_dist - pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_top, -harness_pocket_depth/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_top_outdent/sqrt(2), 2*pwb_lip_top_outdent/sqrt(2),
                                harness_pocket_depth], center=true);
                        }
                    }
                    translate([pwb_lip_bottom_indent_dist + pwb_lip_sides,
                            pwb_lip_bottom + pwb_lip_bottom_indent, -harness_pocket_depth/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_bottom_indent/sqrt(2), 2*pwb_lip_bottom_indent/sqrt(2),
                                harness_pocket_depth], center=true);
                        }
                    }

                    // Cutout through back of case for wire harness:
                    translate([ada_nps8_pwb_length/2, pwb_pad_center_y1 + pwb_pad_pitch_y + wire_diam/2,
                            -bottom_cover_height/2]) {
                        minkowski() {
                            cube([wire_harness_opening_length,
                                4*wire_diam + pwb_pocket_margin - 2*rounding_radius,
                                bottom_cover_height], center = true);
                            sphere(rounding_radius, $fn=80);
                        }
                    }
                    // Drill holes through the model for screws and cutout pockets for nuts
                    // for screw together variant of enclosure:
                    if (screw_case) {
                        translate([-case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height - screw_depth/2])
                            cylinder(h = screw_depth, d = screw_hole_diameter, center = true, $fn=80);
                        translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height - screw_depth/2])
                            cylinder(h = screw_depth, d = screw_hole_diameter, center = true, $fn=80);
                        if (include_nut_pocket) {
                            translate([-case_screw_offset, ada_nps8_pwb_width/2,
                                ada_nps8_pwb_height + nut_pocket_depth/2 - back_surface_z])
                                cylinder(h = nut_pocket_depth, d = 7, center = true, $fn=6);
                            translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2,
                                ada_nps8_pwb_height + nut_pocket_depth/2 - back_surface_z])
                                cylinder(h = nut_pocket_depth, d = 7, center = true, $fn=6);
                        }
                    }
                    
                    // Add inset mounting screw for mounting enclosure to other objects:
                    mtg_screw_length = case_thickness;
                    ff = 0.01;  // This "Fudge Factor" shouldn't be needed, but I had trouble
                                 // without a slight adjustment in OpenSCAD
                    
                    if (add_back_mounting_screws) {
                        translate([0.31*ada_nps8_pwb_length, 0.43*ada_nps8_pwb_width, ff - (mtg_screw_length + harness_pocket_depth)]) {
                            generic_screw_model(screw_diam = 3.4, screw_type = "flat", cutout_region = true,
                                head_diam = 6.1, head_height = 2.1, length = mtg_screw_length, $fn=80);
                        }
                        translate([0.69*ada_nps8_pwb_length, 0.43*ada_nps8_pwb_width, ff - (mtg_screw_length + harness_pocket_depth)]) {
                            generic_screw_model(screw_diam = 3.4, screw_type = "flat", cutout_region = true,
                                head_diam = 6.1, head_height = 2.1, length = mtg_screw_length, $fn=80);
                        }
                    }
                }
            }

            // Add mounting pegs (through PWB mounting holes) + shoulders to sit on:
            mounting_pegs(extra_back_thickness = extra_back_thickness);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Module: neopixel_stick_case_back_on_mounting_plate
//      Mounting Plate Variant of the Enclosure Back Part for NeoPixel Stick 8 products;
//      Incorporates an extra rectangular volume off of the bottom edge of the back enclosure
//      part for use in mounting to other projects or 3D models, like the MuSHR.io Racecar
//      chassis.
//
//      This version of the enclosure back part is currently fixed to use the screw-in case
//      settings ('screw_case' is true), and the 'flush_perim' configuration (also true).
//
//      Note: As opposed to specifying the overall 'case_thickness', such as for regular
//          back enclosure part above, the user specifies the 'mounting_plate_thickness'
//          which is currently set to be equal to the flush bumpout segment of the back part.
//          The case_thickness (and other dimensional parameters) are then computed from
//          that one dimension.
//
//  Parameters:
//      mounting_plate_length: Length of mounting plate rectangular body;
//      mounting_plate_width:  Width of mounting plate rectangular body;
//      mounting_plate_thickness: Thickness (or height dimension) of mounting plate,
//                  also used to fix the dimension of the 'flush_perim' bump section of
//                  the back enclosure part;
//      screw_hole_diameter: Diameter of screw hole in enclosure part, only used if 
//                  screw_case = true. For M3 hardware, set this to 3.4 mm in order to have
//                  a little clearance for the screw when using an M3 Nut also. Otherwise,
//                  you this can be slightly smaller if screwing directly into the plastic and
//                  the nut is left off (include_nut_pocket = false).
//      include_nut_pocket: set to true to add a cutout/pocket in back of part for M3 nut.
//      nut_pocket_depth: depth to inset the nut pocket in the back of the enclosure.
//      screw_depth: depth (from front surface) to make the screw hole, useful if nut pocket
//                  is not included and you plan to screw M3 hardware directly into plastic.
//      case_screw_separation: Distance between the two case screws, center to center (for 
//                  attaching front enclosure part to the back). Only used when 'screw_case
//                  = true'. Must be > PWB Length + 6.0 mm. Default = 60 mm.
//      back_alpha: Setting used for visualization of preview for assembly fit-check
//                  or animation.
//
//  Notes:
//      1) The Enclosure is slightly bigger for screw_case = true. This option adds
//          extra material to the right & left of the NeoPixel for enclosure screw
//          hardware to be mounted. The enclosure is also slightly thicker.
//
///////////////////////////////////////////////////////////////////////////////////////

module neopixel_stick_case_back_on_mounting_plate (
        mounting_plate_length = 60.0,
        mounting_plate_width = 35.0,
        mounting_plate_thickness = 6.0, // We use this to compute our 'case_thickness' and 'extra_back_thickness'
        case_screw_separation = 60.0,
        screw_hole_diameter = 3.4,
        include_nut_pocket = true,
        nut_pocket_depth = 4,
        screw_depth = 10,
        back_alpha = 1.0) {
            
    // First some error checking and variable computation:
    assert(case_screw_separation > ada_nps8_pwb_length + 6.0);
    case_screw_offset = (case_screw_separation - ada_nps8_pwb_length)/2;

    case_thickness = mounting_plate_thickness + cover_overlap_depth + front_surface_z;
    minimum_case_thickness = bottom_cover_base_height + rounding_radius + front_surface_z;
    assert(case_thickness >= minimum_case_thickness);
    extra_back_thickness = case_thickness - minimum_case_thickness;

    // Compute overall back enclosure part height from passed parameter:
    bottom_cover_height = bottom_cover_base_height + extra_back_thickness;
    back_surface_z = case_thickness - front_surface_z;

    // Echo some dimensional information to console window:
    echo("Back Enclosure Part height = ", back_surface_z, " mm");
    echo("of which portion is flush bump = ", back_surface_z - cover_overlap_depth, " mm");
    echo("  --> Plus Peg Extension = ", peg_extension, " mm");
    echo("extra_back_thickness = ", extra_back_thickness, " mm");
    echo("Overall case_thickness = ", case_thickness, " mm");

    color("dimgray", alpha = back_alpha){
        union() {
            render() difference() {
                union() {
                    // Main body of the back cover model:
                    back_cover_body(screw_case = true,
                                    case_screw_offset = case_screw_offset,
                                    extra_back_thickness = extra_back_thickness);
                    // Add flush perimeter extra "bumpout" volume:
                    back_cover_body(screw_case = true,
                        delta = 2 * cover_overlap_width,
                        case_screw_offset = case_screw_offset,
                        extra_back_thickness = extra_back_thickness,
                        remove_extra_height = cover_overlap_depth);
                    // Add Mounting Plate Body:
                    translate([(ada_nps8_pwb_length - mounting_plate_length)/2,
                        ada_nps8_pwb_width + cover_wall_thickness + cover_overlap_width + rounding_radius - mounting_plate_width,
                        ada_nps8_pwb_height - back_surface_z]) {
                        cube([mounting_plate_length, mounting_plate_width-5, mounting_plate_thickness]);
                        }
                }
                union() {
                    // Pocket for the PWB to sit in, with a little bit of margin around PWB edges:
                    translate([-pwb_pocket_margin, -pwb_pocket_margin, 0])
                        cube([ada_nps8_pwb_length + 2*pwb_pocket_margin,
                            ada_nps8_pwb_width + 2*pwb_pocket_margin, ada_nps8_pwb_height]);

                    // Another pocket to allow for wire thickness using 'lip' constants,
                    // so the PWB will sit on the edges:
                    translate([pwb_lip_sides,
                            pwb_lip_bottom + pwb_lip_bottom_indent,
                            -wire_diam - wire_bend_r])
                        cube([ada_nps8_pwb_length - 2*pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_bottom - pwb_lip_bottom_indent - pwb_lip_top,
                            wire_diam + wire_bend_r]);

                    // Another cutout to allow for clearance around wire #1:
                    translate([pwb_lip_sides, pwb_lip_bottom, -wire_diam - wire_bend_r])
                        cube([pwb_lip_bottom_indent_dist,
                            ada_nps8_pwb_width - pwb_lip_bottom - pwb_lip_top,
                            wire_diam + wire_bend_r]);

                    // Another cutout to allow for clearance around wire #4 at 90 degree bend:
                    translate([pwb_lip_top_outdent_dist + pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_top,
                            -wire_diam - wire_bend_r])
                        cube([ada_nps8_pwb_length - 2*pwb_lip_top_outdent_dist - 2*pwb_lip_sides,
                            pwb_lip_top_outdent,
                            wire_diam + wire_bend_r]);
                            
                    // Cut corners for internal, convex, vertical pocket corners
                    translate([pwb_lip_top_outdent_dist + pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_top, -(wire_diam + wire_bend_r)/2]) {
                        rotate([0, 0, 45]) {
                            cube([2*pwb_lip_top_outdent/sqrt(2),
                                2*pwb_lip_top_outdent/sqrt(2),
                                wire_diam + wire_bend_r], center=true);
                        }
                    }
                    translate([ada_nps8_pwb_length - pwb_lip_top_outdent_dist - pwb_lip_sides,
                            ada_nps8_pwb_width - pwb_lip_top, -(wire_diam + wire_bend_r)/2]) {
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
                    translate([ada_nps8_pwb_length/2, pwb_pad_center_y1 + pwb_pad_pitch_y + wire_diam/2,
                            -bottom_cover_height/2]) {
                        minkowski() {
                            cube([wire_harness_opening_length,
                                4*wire_diam + pwb_pocket_margin - 2*rounding_radius,
                                bottom_cover_height], center = true);
                            sphere(rounding_radius, $fn=80);
                        }
                    }
                    // Drill holes through the model for screws and cutout pockets for nuts
                    // for screw together variant of enclosure:
                    translate([-case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height - screw_depth/2])
                        cylinder(h = screw_depth, d = screw_hole_diameter, center = true, $fn=80);
                    translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height - screw_depth/2])
                        cylinder(h = screw_depth, d = screw_hole_diameter, center = true, $fn=80);
                    if (include_nut_pocket) {
                        translate([-case_screw_offset, ada_nps8_pwb_width/2,
                            ada_nps8_pwb_height + nut_pocket_depth/2 - back_surface_z])
                            cylinder(h = nut_pocket_depth, d = 7, center = true, $fn=6);
                        translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2,
                            ada_nps8_pwb_height + nut_pocket_depth/2 - back_surface_z])
                            cylinder(h = nut_pocket_depth, d = 7, center = true, $fn=6);
                    }
                }
            }

            // Add mounting pegs (through PWB mounting holes) + shoulders to sit on:
            mounting_pegs(extra_back_thickness = extra_back_thickness);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Accessory Functions:
//      Useful for implementing NeoPixel Stick enclosures in other 3D Models in OpenSCAD,
//      Such as for adding lightbars to the MuSHR.io racecar chassis.
//
///////////////////////////////////////////////////////////////////////////////////////

module HarnessCutoutRegionExtended(length = 20, xy_center = false) {
    // Compute translation vector if user sets 'xy_center' == true:
    xy_origin_translation = [ xy_center ? -ada_nps8_pwb_length/2 : 0, xy_center ? -ada_nps8_pwb_width/2  : 0, 0 ];

    translate(xy_origin_translation) {
        translate([ada_nps8_pwb_length/2, pwb_pad_center_y1 + pwb_pad_pitch_y + wire_diam/2, -length/2]) {
            minkowski() {
                cube([wire_harness_opening_length,
                    4*wire_diam + pwb_pocket_margin - 2*rounding_radius,
                    length], center = true);
                sphere(rounding_radius, $fn=80);
            }
        }
    }
}

module MountingScrewsCutoutRegion(screw_depth = 20, xy_center = false, case_thickness = 10.25) {
    // First some error checking and variable computation:
    minimum_case_thickness = bottom_cover_base_height + rounding_radius + front_surface_z;
    assert(case_thickness >= minimum_case_thickness);
    back_surface_z = case_thickness - front_surface_z;

    // Compute translation vector if user sets 'xy_center' == true:
    xy_origin_translation = [ xy_center ? -ada_nps8_pwb_length/2 : 0, xy_center ? -ada_nps8_pwb_width/2  : 0, 0 ];

    translate(xy_origin_translation) {
        extra_stub = 6;
        translate([0.31*ada_nps8_pwb_length, 0.43*ada_nps8_pwb_width,
            ada_nps8_pwb_height - screw_depth - back_surface_z + (extra_stub+screw_depth)/2]) {
                cylinder(h = screw_depth + extra_stub, d = 2.8, center = true);
        }
        translate([0.69*ada_nps8_pwb_length, 0.43*ada_nps8_pwb_width,
            ada_nps8_pwb_height - screw_depth - back_surface_z + (extra_stub+screw_depth)/2]) {
                cylinder(h = screw_depth + extra_stub, d = 2.8, center = true);
        }
    }
}

// This case "cutout region" model is used to snip volume from other models
// or ensure collision avoidance or fit-check with other model parts (like MuSHR Cover part).
// It also allows a little extra clearance around the body to ensure space for mounting and
// does not use minkowski() for rounded body edges: 
module NeopixelCaseCutoutRegion(screw_case = true, 
            case_screw_separation = 60,
            case_thickness = 10.25,
            xy_center = false,
            clearance = 1,          // clearance is extra region around body
            for_visualization = false ) {

    // Compute translation vector if user sets 'xy_center' == true:
    xy_origin_translation = [ xy_center ? -ada_nps8_pwb_length/2 : 0, xy_center ? -ada_nps8_pwb_width/2  : 0, 0 ];

    translate(xy_origin_translation) {
        if (for_visualization) {
            color("red", alpha =  0.6) render() {
                enclosure_body_cutout(screw_case = screw_case, case_screw_separation = case_screw_separation,
                    case_thickness = case_thickness, clearance = clearance);
            }
        } else {
            render() {
                enclosure_body_cutout(screw_case = screw_case, case_screw_separation = case_screw_separation,
                    case_thickness = case_thickness, clearance = clearance);
            }
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
if ($include_back == undef) {
    if (display_collision_body) {
        NeopixelCaseCutoutRegion(screw_case = true, case_screw_separation = 60,
            case_thickness = 10.25, clearance = 0.6, for_visualization = true);
    }
    if ($include_pwb) ada_nps8_pwb_model($fn=40);
    if ($include_wiring_harness)
        neopixel_wiring_harness(
            num_conductor = 4,
            harness_length = 20,
            connector_type = "socket", $fn=40);

*    HarnessCutoutRegionExtended(length = 20);
*    MountingScrewsCutoutRegion(screw_depth = 20);
    
    // Some Mounting Hardware models ...
*    color(c = [0.2, 0.2, 0.2] , alpha = 1.0) render() union() {
        // Mounting Hardware variables:
        case_thickness = 10.25;
        case_screw_length = 10;
        case_screw_separation = 60;
        case_screw_offset = (case_screw_separation - ada_nps8_pwb_length)/2;
        back_surface_z = case_thickness - front_surface_z;

        // Align screw flanges with front of front enclosure piece:
        translate([-case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
        translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
        // Align nuts with back of back enclosure piece (set into inset nut pocket):
        translate([-case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height - back_surface_z])
            m3_nut(outer_diameter = 6.4);
        translate([pwb_length + case_screw_offset, pwb_width/2, ada_nps8_pwb_height - back_surface_z])
            m3_nut(outer_diameter = 6.4);
    }
}

// Set this here to indicate the design file is properly loaded and available.
$neopixel_back_parts_are_available = true;
