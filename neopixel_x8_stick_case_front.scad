// ****************************************************************************
//
// File: neopixel_x8_stick_case_front.scad
//
// Description:
//      Front cover for the LED Light bar assembly built with NeoPixel 8 Stick 
//      products from Adafruit.
//
//      This front cover is designed to fit around and overlap the back case section
//      and has alignment holes for the pegs which also hold the PWB in place.
//
//      This front case has cutouts for the 8 LED modules.
//
// Author: Keith Pflieger
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

include <neopixel_case_constants.scad>

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
//      1) Some changes here (such as to 'screw_case' and 'case_screw_separation')
//         require a corresponding change to the back enclosure part in order for 
//         the case to function correctly. Otherwise you could end up with dissimilar 
//         part types for front and back parts.
//      2) Changing enclosure options here does not change them in the top-level
//         assembly or animation design files. So if  you need to verify a change
//         in these settings, you will have to duplicate the change there too.
//
///////////////////////////////////////////////////////////////////////////////////////
if ($include_front == undef) {
    neopixel_stick_case_front(
        screw_case = true,
        screw_type = "flat",
        xy_center = false,
        case_screw_separation = 60 );
/*    neopixel_stick_case_front_on_mounting_plate(
        screw_case = true,
        screw_type = "flat",
        mounting_plate_length = 80,
        mounting_plate_width = 40,
        mounting_plate_thickness = 6,
        case_screw_separation = 60 );*/
}

///////////////////////////////////////////////////////////////////////////////////////
//
//  Module: neopixel_stick_case_front
//      Enclosure Front Part for NeoPixel Stick 8 products.
//
//  Parameters:
//      screw_case: Set to true to build an enclosure that attaches front & back parts
//                  with mounting screws (M3 screws and nuts); False yields the Simple
//                  Enclosure type.
//      xy_center:  Set to 'true' in order to center the Model in the XY plane, useful for
//                  incorporation of the module into other projects so that the user does not
//                  need to be aware of the origin used by default in this project (false = align
//                  this module with NeoPixel Stick 8 PWB lower-left corner at origin).
//      screw_type: Can be "none" (default, for fit check), "round" (panel or button
//                  heads), "cylinder" or "flat" (e.g. 90 deg. inset/flush-mount screws).
//      case_screw_separation: Distance between the two case screws, center to center (for 
//      front_alpha: Setting used for visualization of preview for assembly fit-check
//                  or animation.
//
//  Notes:
//      1) The enclosure is slightly bigger for screw_case = true. This option adds
//          extra material to the right & left of the NeoPixel for enclosure screw
//          hardware to be mounted. The enclosure is also slightly thicker.
//      2) screw_type is only used if screw_case is set to true;
//      3) screw_type = "none" will yield same results as "rounded", both resulting in
//          a simple cylinder hole added to part for each screw hole. "flat" screw_type
//          will enable extra conical cutout in screw hole for head inset.
//
///////////////////////////////////////////////////////////////////////////////////////

module neopixel_stick_case_front(screw_case = false, screw_type = "none",
            xy_center = false, case_screw_separation = 60, front_alpha = 1.0) {

    if (screw_case) {
        assert(((screw_type == "round") || (screw_type == "flat") ||
                (screw_type == "cylinder")  || (screw_type == "none")),
                "Unsupported screw_type for enclosure mounting! Please check spelling.");
        assert(case_screw_separation > ada_nps8_pwb_length + 6.0);
    }
    
    case_screw_offset = (case_screw_separation - ada_nps8_pwb_length)/2;
    
    color("dimgray", alpha = front_alpha) {
        // Compute translation vector if user sets 'xy_center' == true:
        xy_origin_translation = [ xy_center ? -ada_nps8_pwb_length/2 : 0,
                                  xy_center ? -ada_nps8_pwb_width/2  : 0,
                                  0 ];
        
        render() translate(xy_origin_translation) difference() {
            union() {
                difference() {
                    // First, add the main volume of the front enclosure part and hollow out
                    //  the volume taken up by the back enclosure body ...
                    front_cover_body(screw_case = screw_case, case_screw_offset = case_screw_offset);
                    union() {
                        back_cover_body(delta = 0.3, screw_case = screw_case, case_screw_offset = case_screw_offset);
                        translate([rounding_radius + pwb_lip_sides,
                                rounding_radius + 0.75, ada_nps8_pwb_height - rounding_radius]) {
                            minkowski() {
                                cube([ada_nps8_pwb_length - 2*rounding_radius - 2*pwb_lip_sides,
                                    ada_nps8_pwb_width - 2*rounding_radius - 1,
                                    led_height - 0.4]);
                                sphere(rounding_radius, $fn=80);
                            }
                        }
                    }
                }
                
                // Now add cylinder and stem sections for the alignment pegs coming from the back part:
                translate([pwb_hole1_x, pwb_hole1_y, ada_nps8_pwb_height + led_height/2])
                    cylinder(h = led_height, r = pwb_hole1_r + mtg_peg_front_shoulder,
                        center = true, $fn=80);
                translate([pwb_hole1_x, pwb_hole1_y + pwb_hole1_r + mtg_peg_front_shoulder,
                        ada_nps8_pwb_height + led_height/2])
                    cube([2*pwb_hole1_r + 2*mtg_peg_front_shoulder,
                        2*pwb_hole1_r + 2*mtg_peg_front_shoulder,
                        led_height], center = true);
                translate([pwb_hole2_x, pwb_hole2_y, ada_nps8_pwb_height + led_height/2])
                    cylinder(h = led_height, r = pwb_hole2_r + mtg_peg_front_shoulder,
                        center = true, $fn=80);
                translate([pwb_hole2_x, pwb_hole2_y + pwb_hole2_r + mtg_peg_front_shoulder,
                        ada_nps8_pwb_height + led_height/2])
                    cube([2*pwb_hole2_r + 2*mtg_peg_front_shoulder,
                        2*pwb_hole2_r + 2*mtg_peg_front_shoulder,
                        led_height], center = true);

            }
            // Cutout regions ...
            union() {
                // Add little pockets/indents to align with top of mounting pegs from case back:
                mounting_pegs(delta = mtg_peg_front_clearance/2, $fn=80);
                // Holes through front cover for WS281x LED Modules:
                for (i = [ 0: num_leds - 1 ]) {
                    translate([led_start_x + i*led_spacing_x - led_length/2 - cover_led_clearance/2,
                               led_start_y + i*led_spacing_y - led_width/2 - cover_led_clearance/2,
                               ada_nps8_pwb_height]) {
                        cube([led_length + cover_led_clearance,
                              led_width + cover_led_clearance,
                              2*led_height]);
                    }
                }
                // Add holes for enclosure screws, either with inset head or not:
                if (screw_case) {
                    case_screw_length = 10;
                    translate([-case_screw_offset, ada_nps8_pwb_width/2,
                        ada_nps8_pwb_height + front_surface_z - case_screw_length])
                        generic_screw_model(screw_diam = 3.4, screw_type = screw_type,
                            head_diam = 6.1, head_height = 2.0,
                            cutout_region = true, length = case_screw_length, $fn=80);
                    translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2,
                        ada_nps8_pwb_height + front_surface_z - case_screw_length])
                        generic_screw_model(screw_diam = 3.4, screw_type = screw_type,
                        head_diam = 6.1, head_height = 2.0,
                        cutout_region = true, length = case_screw_length, $fn=80);
                }
            }
        }
    }
}

/////////////////////////////////////////////////////////////////
//
//  Module: neopixel_stick_case_front_on_mounting_plate()
//      Accessory module used to help align front enclosure model in
//      projects using the neopixel_stick_case_back_on_mounting_plate()'.
//
//      This module performs a final 3D translation based on the back
//      part mounting plate dimensions. All other front enclosure
//      parameters are passed on directly to the underlying design
//      module 'neopixel_stick_case_front()' defined above.
//
/////////////////////////////////////////////////////////////////
module neopixel_stick_case_front_on_mounting_plate(
            screw_case = true,
            screw_type = "flat",
            mounting_plate_length = 60,
            mounting_plate_width = 35,
            mounting_plate_thickness = 6,
            case_screw_separation = 60,
            front_alpha = 1.0) {

    // Compute some back enclosure part parameters for use in translation of front part:
    case_thickness = mounting_plate_thickness + cover_overlap_depth + front_surface_z;
    minimum_case_thickness = bottom_cover_base_height + rounding_radius + front_surface_z;
    extra_back_thickness = case_thickness - minimum_case_thickness;
    bottom_cover_height = bottom_cover_base_height + extra_back_thickness;
    back_surface_z = case_thickness - front_surface_z;

    xyz_translation = [
        -ada_nps8_pwb_length/2,
         mounting_plate_width/2 - ada_nps8_pwb_width - cover_wall_thickness -
             cover_overlap_width - rounding_radius,
         back_surface_z - ada_nps8_pwb_height - mounting_plate_thickness/2
    ];

    translate(xyz_translation) {
        neopixel_stick_case_front(
                screw_case = screw_case,
                screw_type = screw_type,
                xy_center = false,
                case_screw_separation = case_screw_separation,
                front_alpha = front_alpha);
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
if ($include_front == undef) {
    if ($include_pwb) ada_nps8_pwb_model($fn=40);

    // Some Mounting Hardware models ...
*    color(c = [0.2, 0.2, 0.2] , alpha = 1.0) union() {
        // Mounting Hardware variables:
        case_screw_length = 10;
        case_screw_separation = 60;
        case_screw_offset = (case_screw_separation - ada_nps8_pwb_length)/2;

        // Align screw flanges with front of front enclosure piece:
        translate([-case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
        translate([ada_nps8_pwb_length + case_screw_offset, ada_nps8_pwb_width/2, ada_nps8_pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
    }
}

// Set this here to indicate the design file is properly loaded and available to other design entities.
$neopixel_front_parts_are_available = true;
