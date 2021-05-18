// ****************************************************************************
//
// File: neopixel_x8_stick_assy_animate.scad
//
// Description:
//   Top-level Assembly Animation for Adafruit "NeoPixel 8 Stick" products,
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
include <../neopixel_x8_stick_case_front.scad>

$include_back = true;
include <../neopixel_x8_stick_case_back.scad>

$include_pwb = true;
include <../neopixel_x8_stick_pwb.scad>

$include_wiring_harness = true;
include <../neopixel_wiring_harness.scad>

// Set various enclosure options here:
screw_case = true;      // 'true' for screw-in version of enclosure, 'false' for simple enclosure
screw_type = "flat";    // set enclosure screw type to "none", "rounded" or "flat"
flush_case = true;      // Used to modify back enclosure piece to be flush with the top around the perimeter
case_screw_length = 10; // length of the physical mounting screws
include_screws = true;  // include M3 screws for assembly visualization?
include_nuts = true;    // include M3 nuts for assembly visualization?
case_thickness = 10.25; // Overall Enclosure thickness (front and back parts assembled)
case_screw_separation = 60.0;     // Center-to-Center distance of the two case mounting screws
add_back_mounting_screws = false; // Add Mounting screws to back enclosure part

// Derived variables:
case_screw_offset = (case_screw_separation - pwb_length)/2;
back_surface_z = case_thickness - front_surface_z;

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

// The constants which will drive the various animation steps:
// Start with display of PWB Only
anim_t1 = 0.1;
// Next, Add Wiring Harness with Z offset and slowly move into place next to PWB
anim_t2 = 0.2;
anim_delta2 = anim_t2 - anim_t1;
anim_off_z2 = -20;
// Then, Add Enclosure Back part, offset and rotated to start
anim_t3 = 0.3;
anim_delta3 = anim_t3 - anim_t2;
anim_off_z3 = -40;
anim_rot_z3 = -90;
// ... start moving back enclosure towards PWB past connector backshell
anim_t4 = 0.4;
anim_delta4 = anim_t4 - anim_t3;
anim_off_z4 = -40;
anim_rot_z4 = -90;
// ... then rotate part to be aligned with PWB again once past the connector
anim_t5 = 0.5;
anim_delta5 = anim_t5 - anim_t4;
anim_off_z5 = -15;
anim_rot_z5 = anim_rot_z4;
// ... and finally move Back part into position with PWB sitting inside of it.
anim_t6 = 0.55;
anim_delta6 = anim_t6 - anim_t5;
anim_off_z6 = -5;
// Now Add Enclosure Front part with Z offset
anim_t7 = 0.6;
anim_delta7 = anim_t7 - anim_t6;
anim_off_z7 = 25;
// Fade transparency on front part ...
anim_t8 = 0.65;
anim_delta8 = anim_t8 - anim_t7;
// Finally, Move enclosure front part into place on top of the rest of the assembly
anim_t9 = 0.75;
anim_delta9 = anim_t9 - anim_t8;
anim_off_z9 = 25;
// Fade transparency back off on front part ...
anim_t10 = 0.80;
anim_delta10 = anim_t10 - anim_t9;

// Animation constants for mounting hardware:
anim_s1_viz = 0.75;
anim_s2_viz = 0.77;
anim_n1_viz = 0.79;
anim_n2_viz = 0.81;
anim_s1_start = 0.79;
anim_s2_start = 0.82;
anim_n1_start = 0.82;
anim_n2_start = 0.85;
anim_s1_end = 0.89;
anim_s2_end = 0.92;
anim_n1_end = 0.89;
anim_n2_end = 0.92;
anim_s1_delta = anim_s1_end - anim_s1_start;
anim_s2_delta = anim_s2_end - anim_s2_start;
anim_n1_delta = anim_n1_end - anim_n1_start;
anim_n2_delta = anim_n2_end - anim_n2_start;
anim_s1_z_offset = 20;
anim_s2_z_offset = 20;
anim_n1_z_offset = -13;
anim_n2_z_offset = -13;

union() {
    // The PWB is always there and stationary:
    if ($include_pwb) pwb_model($fn=40);

    // Animate the Wiring Harness Model:
    if ($include_wiring_harness) {
        if ($t > anim_t1) {
            translate([0, 0, ($t<anim_t2)?
                anim_off_z2*(1 - ($t - anim_t1)/anim_delta2) : 0])
                wiring_harness( num_conductor = 4, harness_length = 20,
                                connector_type = "socket", $fn=40);
        } else if ($t > 0.75*anim_t1) {
            translate([0, 0, anim_off_z2])
                wiring_harness( num_conductor = 4, harness_length = 20,
                                connector_type = "socket", $fn=40);
        }
    }
    
    // Animate the Enclosure Back Model Part in multi-stages:
    if ($include_back) {
        if ($t > anim_t5) {
            translate([0, 0, ($t<anim_t6)? anim_off_z6*(1 - ($t - anim_t5)/anim_delta6) : 0])
                neopixel_stick_case_back (
                    screw_case = screw_case,
                    case_screw_separation = case_screw_separation,
                    case_thickness = case_thickness,
                    add_back_mounting_screws = add_back_mounting_screws,
                    flush_perim = flush_case,
                    include_nut_pocket = true,
                    nut_pocket_depth = 3.5,
                    back_alpha = 1.0
                );
        } else if ($t > anim_t4) {
            translate([pwb_length/2, pwb_width/2, 0]) {
                rotate([0, 0, ($t<anim_t5)? anim_rot_z5*(1 - ($t - anim_t4)/anim_delta5) : 0]) {
                    translate([-pwb_length/2, -pwb_width/2, 
                        (anim_off_z5-anim_off_z6)*(1 - ($t - anim_t4)/anim_delta5) + anim_off_z6])
                        neopixel_stick_case_back (
                            screw_case = screw_case,
                            case_screw_separation = case_screw_separation,
                            case_thickness = case_thickness,
                            add_back_mounting_screws = add_back_mounting_screws,
                            flush_perim = flush_case,
                            include_nut_pocket = true,
                            nut_pocket_depth = 3.5,
                            back_alpha = 1.0
                        );
                }
            }
        } else if ($t > anim_t3) {
            translate([pwb_length/2, pwb_width/2, 0]) {
                rotate([0, 0, anim_rot_z4]) {
                    translate([-pwb_length/2, -pwb_width/2, 
                        (anim_off_z4-anim_off_z5)*(1 - ($t - anim_t3)/anim_delta4) + anim_off_z5])
                        neopixel_stick_case_back (
                            screw_case = screw_case,
                            case_screw_separation = case_screw_separation,
                            case_thickness = case_thickness,
                            add_back_mounting_screws = add_back_mounting_screws,
                            flush_perim = flush_case,
                            include_nut_pocket = true,
                            nut_pocket_depth = 3.5,
                            back_alpha = 1.0
                        );
                }
            }
        } else if ($t > anim_t2 + 0.75*anim_delta3) {
            translate([pwb_length/2, pwb_width/2, 0]) {
                rotate([0, 0, anim_rot_z3]) {
                    translate([-pwb_length/2, -pwb_width/2, anim_off_z3])
                        neopixel_stick_case_back (
                            screw_case = screw_case,
                            case_screw_separation = case_screw_separation,
                            case_thickness = case_thickness,
                            add_back_mounting_screws = add_back_mounting_screws,
                            flush_perim = flush_case,
                            include_nut_pocket = true,
                            nut_pocket_depth = 3.5,
                            back_alpha = 1.0
                        );
                }
            }
        }
    }
    
    // Animate the Enclosure Front Model Part:
    if ($include_front) {
        if ($t > anim_t10) {
            neopixel_stick_case_front(
                screw_case = screw_case,
                screw_type = screw_type,
                case_screw_separation = case_screw_separation,
                front_alpha = 1.0);
        } else if ($t > anim_t9) {
            neopixel_stick_case_front(
                screw_case = screw_case,
                screw_type = screw_type,
                case_screw_separation = case_screw_separation,
                front_alpha = 0.5 + 0.5*($t-anim_t9)/anim_delta10 );
        } else if ($t > anim_t8) {
            translate([0, 0, ($t<anim_t9)? anim_off_z9*(1 - ($t - anim_t8)/anim_delta9) : 0])
                neopixel_stick_case_front(
                    screw_case = screw_case,
                    screw_type = screw_type,
                    case_screw_separation = case_screw_separation,
                    front_alpha = 0.5);
        } else if ($t > anim_t7) {
            translate([0, 0, anim_off_z7])
                neopixel_stick_case_front(
                    screw_case = screw_case,
                    screw_type = screw_type,
                    case_screw_separation = case_screw_separation,
                    front_alpha = 1.0 - 0.5*($t-anim_t7)/anim_delta8 );
        } else if ($t > anim_t6 + 0.75*anim_delta7) {
            translate([0, 0, anim_off_z7])
                neopixel_stick_case_front(
                    screw_case = screw_case,
                    screw_type = screw_type,
                    case_screw_separation = case_screw_separation,
                    front_alpha = 1.0);
        }
    }
    
    // Animate the Enclosure Mounting Hardware:
    if (include_screws) {
        color(c = [0.2, 0.2, 0.2] , alpha = 1.0) {
            if ($t > anim_s1_end) {
                translate(case_screw1_pos) generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
            } else if ($t >= anim_s1_start) {
                translate([0, 0, anim_s1_z_offset*(1 - ($t - anim_s1_start)/anim_s1_delta)]) {
                    translate(case_screw1_pos) generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                }
            } else if ($t >= anim_s1_viz) {
                translate([0, 0, anim_s1_z_offset]) {
                    translate(case_screw1_pos) generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                }
            }

            if ($t > anim_s2_end) {
                translate(case_screw2_pos) generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
            } else if ($t >= anim_s2_start) {
                translate([0, 0, anim_s2_z_offset*(1 - ($t - anim_s2_start)/anim_s2_delta)]) {
                    translate(case_screw2_pos) generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                }
            } else if ($t >= anim_s2_viz) {
                translate([0, 0, anim_s2_z_offset]) {
                    translate(case_screw2_pos) generic_screw(screw_diam = 2.9, head_type = screw_type, length = 10, $fn=80);
                }
            }
        }
    }
    if (include_nuts) {
        color(c = [0.2, 0.2, 0.2] , alpha = 1.0) {
            if ($t > anim_n1_end) {
                render() translate(case_nut1_pos) m3_nut(outer_diameter = 6.4);
            } else if ($t >= anim_n1_start) {
                translate([0, 0, anim_n1_z_offset*(1 - ($t - anim_n1_start)/anim_n1_delta)]) {
                    render() translate(case_nut1_pos) m3_nut(outer_diameter = 6.4);
                }
            } else if ($t >= anim_n1_viz) {
                translate([0, 0, anim_n1_z_offset]) {
                    render() translate(case_nut1_pos) m3_nut(outer_diameter = 6.4);
                }
            }

            if ($t > anim_n2_end) {
                render() translate(case_nut2_pos) m3_nut(outer_diameter = 6.4);
            } else if ($t >= anim_n2_start) {
                translate([0, 0, anim_n2_z_offset*(1 - ($t - anim_n2_start)/anim_n2_delta)]) {
                    render() translate(case_nut2_pos) m3_nut(outer_diameter = 6.4);
                }
            } else if ($t >= anim_n2_viz) {
                translate([0, 0, anim_n2_z_offset]) {
                    render() translate(case_nut2_pos) m3_nut(outer_diameter = 6.4);
                }
            }
        }
    }
    
}
