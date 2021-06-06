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
        case_screw_separation = 60 );
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
//      screw_type: Can be "none" (default, for fit check), "rounded" (panel or button
//                  heads), or "flat" (e.g. 90 deg. inset/flush-mount screws).
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
            case_screw_separation = 60, front_alpha = 1.0) {

    if (screw_case) {
        assert(((screw_type == "rounded") || (screw_type == "flat") ||
                (screw_type == "none")),
                "Unsupported screw_type for enclosure mounting! Please check spelling.");
        assert(case_screw_separation > pwb_length + 6.0);
    }
    
    case_screw_offset = (case_screw_separation - pwb_length)/2;
    
    color("dimgray", alpha = front_alpha){
        render() difference() {
            union() {
                difference() {
                    // First, add the main volume of the front enclosure part and hollow out
                    //  the volume taken up by the back enclosure body ...
                    front_cover_body(screw_case = screw_case, case_screw_offset = case_screw_offset);
                    union() {
                        back_cover_body(delta = 0.3, screw_case = screw_case, case_screw_offset = case_screw_offset);
                        translate([rounding_radius + pwb_lip_sides,
                                rounding_radius + 0.75, pwb_height - rounding_radius]) {
                            minkowski() {
                                cube([pwb_length - 2*rounding_radius - 2*pwb_lip_sides,
                                    pwb_width - 2*rounding_radius - 1,
                                    led_height - 0.4]);
                                sphere(rounding_radius, $fn=80);
                            }
                        }
                    }
                }
                
                // Now add cylinder and stem sections for the alignment pegs coming from the back part:
                translate([pwb_hole1_x, pwb_hole1_y, pwb_height + led_height/2])
                    cylinder(h = led_height, r = pwb_hole1_r + mtg_peg_front_shoulder,
                        center = true, $fn=80);
                translate([pwb_hole1_x, pwb_hole1_y + pwb_hole1_r + mtg_peg_front_shoulder,
                        pwb_height + led_height/2])
                    cube([2*pwb_hole1_r + 2*mtg_peg_front_shoulder,
                        2*pwb_hole1_r + 2*mtg_peg_front_shoulder,
                        led_height], center = true);
                translate([pwb_hole2_x, pwb_hole2_y, pwb_height + led_height/2])
                    cylinder(h = led_height, r = pwb_hole2_r + mtg_peg_front_shoulder,
                        center = true, $fn=80);
                translate([pwb_hole2_x, pwb_hole2_y + pwb_hole2_r + mtg_peg_front_shoulder,
                        pwb_height + led_height/2])
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
                               pwb_height]) {
                        cube([led_length + cover_led_clearance,
                              led_width + cover_led_clearance,
                              2*led_height]);
                    }
                }
                // Add holes for enclosure screws, either with inset head or not:
                if (screw_case) {
                    case_screw_length = 10;
                    translate([-case_screw_offset, pwb_width/2,
                        pwb_height + front_surface_z - case_screw_length])
                        generic_screw(screw_diam = 3.4, head_type = screw_type,
                            head_diam = 6.1, head_height = 2.0, length = case_screw_length, $fn=80);
                    translate([pwb_length + case_screw_offset, pwb_width/2,
                        pwb_height + front_surface_z - case_screw_length])
                        generic_screw(screw_diam = 3.4, head_type = screw_type,
                        head_diam = 6.1, head_height = 2.0, length = case_screw_length, $fn=80);
                }
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
if ($include_front == undef) {
    if ($include_pwb) pwb_model($fn=40);

    // Some Mounting Hardware models ...
*    color(c = [0.2, 0.2, 0.2] , alpha = 1.0) union() {
        // Mounting Hardware variables:
        case_screw_length = 10;
        case_screw_separation = 60;
        case_screw_offset = (case_screw_separation - pwb_length)/2;

        // Align screw flanges with front of front enclosure piece:
        translate([-case_screw_offset, pwb_width/2, pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
        translate([pwb_length + case_screw_offset, pwb_width/2, pwb_height + front_surface_z - case_screw_length])
            test_align_shaft_1x10mm();
    }
}

// Set this here to indicate the design file is properly loaded and available.
$neopixel_front_parts_are_available = true;
