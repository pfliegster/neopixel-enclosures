// ****************************************************************************
//
// File: neopixel_x8_stick_assy.scad
//
// Description:
//   Top-level Assembly for Adafruit "NeoPixel 8 Stick" products,
//   along with a wiring harness and front/back case halves for
//   mounting of the NeoPixel Stick to other projects.
//
//   Comment out various design entities in the 'union()' block below
//   in order to perform fit-checks and visualize how the overall assembly
//   is put together.
//
// Author: Keith Pflieger
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

$include_front = true;
include <neopixel_x8_stick_case_front.scad>

$include_back = true;
include <neopixel_x8_stick_case_back.scad>

$include_pwb = true;
include <neopixel_x8_stick_pwb.scad>

$include_wiring_harness = true;
include <neopixel_wiring_harness.scad>

// Do we also want to turn on the Case Body Collision/cutout volume for visualization?
display_collision_body = false;

// What are we rendering? Either the Enclosure Back part by itself or installed on
// mounting plate (such as for use with MuSHR Racecar chassis components):
_include_mounting_plate = false;
// Create an 'Exploded' assembly view?
_explode_view = false;

// Set various enclosure options here:
screw_case = true;      // 'true' for screw-in version of enclosure, 'false' for simple enclosure
screw_type = "flat";    // set enclosure screw type to "none", "rounded" or "flat"
flush_case = true;      // Used to modify back enclosure piece to be flush with the top around the perimeter
front_alpha = 0.5;      // Set Alpha channel for color rendering of front enclosure part, aid in visualization
back_alpha = 1.0;       // Set Alpha channel for color rendering of back enclosure part, aid in visualization
case_screw_length = 10; // length of the physical mounting screws
include_screws = true;  // include M3 screws for assembly visualization?
include_nuts = true;    // include M3 nuts for assembly visualization?
case_thickness = 10.25; // Overall Enclosure thickness (front and back parts assembled)
case_screw_separation = 60.0;     // Center-to-Center distance of the two case mounting screws
add_back_mounting_screws = false; // Add Mounting screws to back enclosure part

wiring_harness_z   = _explode_view ?   0: 0;
enclosure_back_z   = _explode_view ? -11: 0;
enclosure_front_z  = _explode_view ?  13: 0;
enclosure_screws_z = _explode_view ?  30: 0;
enclosure_nuts_z   = _explode_view ? -25: 0;

// Derived variables:
case_screw_offset = (case_screw_separation - pwb_length)/2;
back_surface_z = case_thickness - front_surface_z;
harness_pocket_depth = wire_diam + wire_bend_r;

// Computed Positions for Mounting Hardware:
case_screw1_pos = [  -case_screw_offset,
                    pwb_width/2,
                    pwb_height + front_surface_z - case_screw_length];
case_screw2_pos = [  pwb_length + case_screw_offset,
                    pwb_width/2,
                    pwb_height + front_surface_z - case_screw_length];
case_nut1_pos = [    -case_screw_offset,
                    pwb_width/2,
                    pwb_height - back_surface_z];
case_nut2_pos = [    pwb_length + case_screw_offset,
                    pwb_width/2,
                    pwb_height - back_surface_z];
mtg_screw1_pos = [  0.31*pwb_length,
                    0.43*pwb_width,
                    -(case_screw_length + harness_pocket_depth)];
mtg_screw2_pos = [  0.69*pwb_length,
                    0.43*pwb_width,
                    -(case_screw_length + harness_pocket_depth)];

union() {
    if ($include_pwb) pwb_model($fn=40);
    if ($include_wiring_harness)  translate([0, 0, wiring_harness_z]) {
        wiring_harness(num_conductor = 4, harness_length = 20,
            connector_type = "socket", $fn=40);
    }
    if ($include_back)  translate([0, 0, enclosure_back_z]) {
        if (_include_mounting_plate) {
            neopixel_stick_case_back_on_mounting_plate (
                mounting_plate_length = 68.188,
                mounting_plate_width = 35.4773,
                mounting_plate_thickness = 6.0,
                case_screw_separation = case_screw_separation,
                include_nut_pocket = true,
                nut_pocket_depth = 3.5,
                back_alpha = back_alpha
            );
        } else {
            neopixel_stick_case_back (
                screw_case = screw_case,
                case_screw_separation = case_screw_separation,
                case_thickness = case_thickness,
                add_back_mounting_screws = add_back_mounting_screws,
                flush_perim = flush_case,
                include_nut_pocket = true,
                nut_pocket_depth = 3.5,
                back_alpha = back_alpha
            );
        }
    }
    if ($include_front) translate([0, 0, enclosure_front_z]) {
        neopixel_stick_case_front(
            screw_case = screw_case,
            screw_type = screw_type,
            case_screw_separation = case_screw_separation,
            front_alpha = front_alpha
        );
    }
    
    if (display_collision_body) {
        NeopixelCaseCutoutRegion(screw_case = true, case_screw_separation = case_screw_separation,
            case_thickness = case_thickness, clearance = 0.6, for_visualization = true);
    }

    echo("Back cover height = ", back_surface_z, " mm");
    echo("Front height (above PWB) = ", front_surface_z, " mm");
    echo("--> Overall height = ", back_surface_z + front_surface_z, " mm");
    
    if (screw_case) {
        color(c = [0.2, 0.2, 0.2] , alpha = 1.0) {
            translate([0, 0, enclosure_screws_z]) {
                if (include_screws) {
                    // Align screw flanges with front of front enclosure piece:
                    translate(case_screw1_pos)
                        generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                    translate(case_screw2_pos)
                        generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);

                    if (add_back_mounting_screws) {
                        translate(mtg_screw1_pos) {
                            generic_screw(screw_diam = 2.9, head_type = screw_type,
                                length = case_screw_length, $fn=80);
                        }
                        translate(mtg_screw2_pos) {
                            generic_screw(screw_diam = 2.9, head_type = screw_type,
                                length = case_screw_length, $fn=80);
                        }
                    }
                }
            }
            translate([0, 0, enclosure_nuts_z]) {
                if (include_nuts) {
                    // Align nuts with back of back enclosure piece (set into inset nut pocket):
                    render() translate(case_nut1_pos)
                        m3_nut(outer_diameter = 6.4);
                    render() translate(case_nut2_pos)
                        m3_nut(outer_diameter = 6.4);
                }
            }
        }
    }
}
