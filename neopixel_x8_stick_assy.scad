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
// Date:   April 2021
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// Thingiverse user: RoboticDreams
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

// Set various enclosure options here:
screw_case = true;      // 'true' for screw-in version of enclosure, 'false' for simple enclosure
screw_type = "flat";    // set enclosure screw type to "none", "rounded" or "flat"
flush_case = true;      // Used to modify back enclosure piece to be flush with the top around the perimeter
front_alpha = 0.6;      // Set Alpha channel for color rendering of front enclosure part, aid in visualization
back_alpha = 1.0;       // Set Alpha channel for color rendering of back enclosure part, aid in visualization
include_screws = true;  // include M3 screws for assembly visualization?
include_nuts = true;    // include M3 nuts for assembly visualization?
explode_view = false;   // Create Exploded Assembly view (true) or regular view (false)

wiring_harness_z = explode_view ? 0: 0;
enclosure_back_z = explode_view ? -11: 0;
enclosure_front_z = explode_view ? 13: 0;
enclosure_screws_z = explode_view ? 30: 0;
enclosure_nuts_z = explode_view ? -25: 0;

union() {
    if ($include_pwb) pwb_model($fn=40);
    if ($include_wiring_harness)  translate([0, 0, wiring_harness_z]) {
        wiring_harness(num_conductor = 4, harness_length = 20,
            connector_type = "socket", $fn=40);
    }
    if ($include_back)  translate([0, 0, enclosure_back_z]) {
        neopixel_stick_case_back(screw_case = screw_case,
            flush_perim = flush_case, back_alpha = back_alpha);
    }
    if ($include_front) translate([0, 0, enclosure_front_z]) {
        neopixel_stick_case_front(screw_case = screw_case,
            screw_type = screw_type, front_alpha = front_alpha);
    }
    
    echo("Back cover height = ", back_surface_z, " mm");
    echo("Front height (above PWB) = ", front_surface_z, " mm");
    echo("--> Overall height = ", back_surface_z + front_surface_z, " mm");
    
    if (screw_case) {
        color(c = [0.2, 0.2, 0.2] , alpha = 1.0) {
            translate([0, 0, enclosure_screws_z]) {
                if (include_screws) {
                    // Align screw flanges with front of front enclosure piece:
                    translate(mtg_screw1_pos)
                        generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                    translate(mtg_screw2_pos)
                        generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                }
            }
            translate([0, 0, enclosure_nuts_z]) {
                if (include_nuts) {
                    // Align nuts with back of back enclosure piece (set into inset nut pocket):
                    render() translate(mtg_nut1_pos)
                        m3_nut(outer_diameter = 6.4);
                    render() translate(mtg_nut2_pos)
                        m3_nut(outer_diameter = 6.4);
                }
            }
        }
    }
}
