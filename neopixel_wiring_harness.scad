// ****************************************************************************
//
// File: neopixel_wiring_harness.scad
//
// Description:
//   Wiring Harness model for an LED light bar using the Adafruit NeoPixel 8
//   Stick products.
//
//   The wiring harness is customizable to use either 3-pin or 4-pin cable
//   connections, such as Adafruit JST-4PH and JST-3PH socket/header end
//   connectors. Wire size, color coding and connector dimensions match those
//   used by Adafruit P/Ns:
//     4-pin socket (https://www.adafruit.com/product/4045),
//     4-pin header (https://www.adafruit.com/product/3955),
//     3-pin socket (https://www.adafruit.com/product/4046),
//     3-pin header (https://www.adafruit.com/product/3893)
//
//   The 3-pin versions are intended for setups using a single NeoPixel stick,
//   or for the last stick in a chain of them (where the DOUT signal is not
//   required).
//
//   The 4-pin variants include the additional connection to DOUT, in order to
//   daisy-chain multiple NeoPixel sticks together in series.
//
//   Pinout map:
//        Signal       4-pin       3-pin
//       ---------------------------------
//        Ground       Black       Black
//        5VDC         Red         Red
//        DIN          White       White
//        DOUT         Green
//
// Author: Keith Pflieger
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// Github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

include <neopixel_x8_stick_constants.scad>
include <wiring_harness_constants.scad>

// pre-bend wire length calculated to bring wires out of the back of the center of the pwb
wire_len = pwb_length/2 - wire_bend_r - 0.5;

// X,Y offsets for harness wire connections, relative to board 0,0 origin:
wire1_x = 0.5;
wire2_x = wire1_x;
wire3_x = wire1_x;
wire1_y = pwb_pad_center_y1;
wire2_y = wire1_y + pwb_pad_pitch_y;
wire3_y = wire2_y + pwb_pad_pitch_y;
// Wire #4 is only used in 4 conductor version of the wiring harness, when the DOUT signal is
// required for daisy-chaining NeoPixel sticks together
wire4_x = pwb_length - 0.5;
wire4_y = wire3_y;

// ****************************************************************************
//
// Module: soldered_wire()
//      A 3D model of a wire with several features including stripped end, bent tip
//      soldered to PWB, and a configurable dogleg for wire routing.
//
// Parameters:
//      wire_d (default = 0.65 for 22AWG wire such as used by Adafruit cables):
//          This is the diameter of the conductor of the wire (not including insulation).
//      insulation_d (default = 1.6 for 22AWG wire such as used by Adafruit cables):
//          This is the outer diameter of the wire's insulation
//      stripped_length (default = 1 mm):
//          Length of the stripped wire that is shown exposed.
//      soldered_length (default = 0 mm):
//          Length of the stripped wire that is bent toward the PWB solder pad;
//          this model will automatically put a bend in the exposed stripped
//          section of wire as long as soldered_length > 0 mm and stripped_length >
//          soldered_length + a small length that is required in order to bend the
//          wire towards the PWB. If these conditions are not met, then this parameter
//          will not be used & the stripped end will just be shown as a straight
//          segment.
//      prebend_length (default = 100 mm):
//          This wire model assumes that there will be a 90 degree bend for
//          routing the wire out of the NeoPixel stick case (out the back side).
//          This parameter sets the length of wire from the stripped end to the
//          90 degree bend.
//      postbend_length (default = 100 mm):
//          This is the length of wire for the 'pigtail' coming out of the back
//          side of the board, after the 90 degree bend in the wire.
//      bend_r (default = 3 mm):
//          The bend radius of the 90 degree bend in the wire, transitioning
//          from the pre-bend segment of wire to the post-bend segment of wire.
//      dogleg_dist (default = 0 mm, which means the dogleg will be disabled):
//          This wire model includes the ability to insert a single dogleg in the
//          pre-bend segment of wiring (so in between the stripped end of the wire
//          and the 90 degree bend). This is useful for controlling the routing
//          of wires in a multi-wire harness. This parameter defines the distance
//          of the start of the dogleg from the stripped segment of wire. 
//      dogleg_offset (default = 0 mm, dogleg disabled):
//          This parameter defines how much offset (+ or -) from the primary wire
//          center to perform at the distance defined above (dogleg_dist).
//      insulation_color (default = "white"):
//          an aid for visualization of non-rendered model of wire or upper-level
//          harness model.
//
// ****************************************************************************

module soldered_wire(
        wire_d=0.65, insulation_d=1.6,  // Defaults for 22 AWG wire used in Adafruit JST 4PH/3PH cables
        stripped_length = 1, soldered_length = 0,
        prebend_length = 100, postbend_length = 100, bend_r = 3,
        dogleg_dist = 0, dogleg_offset = 0,  // Default is no dogleg included in wire
        insulation_color = "white"
) {

    echo("Dogleg offset = ", dogleg_offset);
    union() {
        // Stripped end of wire, conductor, with dogleg from center of insulation to PWB pad
        color ("silver") {
            wire_dogleg_offset = (insulation_d - wire_d)/2;
            wire_dogleg_length = sqrt(2) * (wire_dogleg_offset - wire_d*(1-sin(45)));
            wire_dogleg_gap = wire_dogleg_offset + wire_d*(2*sin(45) -1);

            // First, check that the length parameters are valid and satisfy need for soldered end dogleg:
            if ((soldered_length > 0) && (stripped_length > soldered_length + wire_dogleg_gap)) {

                // soldered end of wire conductor, adjacent to PWB pad
                translate([-wire_dogleg_offset, 0, 0])
                    cylinder(h = soldered_length, d = wire_d);

                // 45 degree wedge at launch of conductor dogleg
                translate([-wire_dogleg_offset + wire_d/2, 0, soldered_length]) {
                    rotate([90, 0, 180]) {
                        rotate_extrude(angle=45) {
                            translate([wire_d/2, 0])
                                circle(d=wire_d);
                        }
                    }
                }

                // 45 deg conductor dogleg segment cylinder
                translate([wire_d/2 - wire_dogleg_offset - wire_d*sin(45)/2,
                        0, soldered_length+wire_d*sin(45)/2]) {
                    rotate([0, 45, 0]) {
                        cylinder(h = wire_dogleg_length, d = wire_d);
                    }
                }
                
                // 45 degree wedge at terminus of dogleg
                translate([-wire_d/2, 0, soldered_length+wire_dogleg_gap]) {
                    rotate([90, 45, 0]) {
                        rotate_extrude(angle=45) {
                            translate([wire_d/2, 0])
                                circle(d=wire_d);
                        }
                    }
                }

                // Remainder of stripped end of wire as it enters center of insulation
                translate([0, 0, soldered_length+wire_dogleg_gap])
                    cylinder(h = stripped_length-soldered_length-wire_dogleg_gap, d = wire_d);
            } else {
                cylinder(h = stripped_length, d = wire_d);
            }
        }
        // Insulated section of wire
        color (insulation_color) {
            // Pre-bend section of wire (adjacent to stripped end of wire), with or without dogleg:
            if ((dogleg_dist > 0.0) && (dogleg_dist <= prebend_length-abs(dogleg_offset))) {

                // Dogleg version of wire:
                dogleg_length = sqrt(2) * (abs(dogleg_offset) - insulation_d*(1-sin(45)));
                dogleg_wedge_angle = (dogleg_length > 0) ? 45 : acos(1 - abs(dogleg_offset)/insulation_d);
//                dogleg_gap = abs(dogleg_offset) + insulation_d*(2*sin(45) -1);
                dogleg_gap = (dogleg_length > 0) ? (abs(dogleg_offset) + insulation_d*(2*sin(45) -1)) :
                    (insulation_d * sin(dogleg_wedge_angle));
                
                if (dogleg_length < 0) {
                    dogleg_wedge_angle = acos(1 - abs(dogleg_offset)/insulation_d);
                    dogleg_gap = insulation_d * sin(dogleg_wedge_angle);
                    echo("WARNING: Dogleg info: len = ", dogleg_length);
                    echo("         Wedge Angle = ", dogleg_wedge_angle, " degrees");
                    echo("         Adjusted Gap = ", dogleg_gap, " mm");
                }
                union() {
                    // Pre-dogleg segment
                    translate([0, 0, stripped_length])
                        cylinder(h = dogleg_dist, d = insulation_d);

                    // 45 degree wedge at launch of dogleg
                    rotate([0, 0, (dogleg_offset > 0.0) ? -90:90]) {
                        translate([-insulation_d/2, 0, stripped_length+dogleg_dist]) {
                            rotate([90, 0, 0]) {
                                rotate_extrude(angle=dogleg_wedge_angle) {
                                    translate([insulation_d/2, 0])
                                        circle(d=insulation_d);
                                }
                            }
                        }
                    }

                    // 45 degree Dogleg cylinder segment
                    if (dogleg_length > 0) {
                        translate([0, (dogleg_offset > 0) ? (insulation_d/2):(-insulation_d/2),
                                stripped_length+dogleg_dist]) {
                            rotate([(dogleg_offset > 0.0) ? -45:45,0,0]) {
                                translate([0, (dogleg_offset > 0) ? (-insulation_d/2):(insulation_d/2), 0])
                                    cylinder(h = dogleg_length, d = insulation_d);
                            }
                        }
                    }
                    
                    // 45 degree wedge at terminus of dogleg
                    translate([0, (dogleg_offset > 0) ? (dogleg_offset-insulation_d/2):(dogleg_offset+insulation_d/2),
                            stripped_length+dogleg_dist+dogleg_gap]) {
                        rotate([-90, 0, (dogleg_offset > 0.0) ? 0:180]) {
                            rotate([0, -90, 0]) {
                                rotate_extrude(angle=dogleg_wedge_angle) {
                                    translate([insulation_d/2, 0])
                                        circle(d=insulation_d);
                                }
                            }
                        }
                    }

                    // Post-dogleg segment
//                    echo("Dogleg Gap = ", dogleg_gap, " mm");
                    translate([0, dogleg_offset, stripped_length+dogleg_dist+dogleg_gap])
                        cylinder(h = prebend_length-dogleg_dist-dogleg_gap, d = insulation_d);
                    
                }
            } else {
                // Non-dogleg version of wire:
                translate([0, 0, stripped_length])
                    cylinder(h = prebend_length, d = insulation_d);
            }
            // 90 Degree bend of wire away from board to interface with connector:
            translate([bend_r, dogleg_offset, prebend_length + stripped_length]) {
                rotate([90, -90, 0]) {
                    rotate_extrude(angle=90) {
                        translate([bend_r, 0])
                            circle(d=insulation_d);
                    }
                }
            }
            // Post-bend section of wire going to connector at right angle:
            translate([bend_r, dogleg_offset, bend_r + prebend_length + stripped_length]) {
                rotate([0, 90, 0]) {
                    cylinder(h = postbend_length, d = insulation_d);
                }
            }
        }
    }
}

// ****************************************************************************
//
// Module: wiring_harness()
//      The Wiring Harness model uses the soldered_wire() module, which has several
//      features for routing/visualization of the wiring to the NeoPixel PWB.
//
// Parameters:
//      num_conductor (default = 4):
//          only 3 or 4 conductor configurations supported.
//      harness_length (default = 10mm):
//          this defines the 'pigtail' length from the back of the PWB
//          to the connector housing;
//      connector_type (default = "unterminated"):
//          set to either "socket" or "header" style, or as "unterminated".
//          instantiation of the connector shell is useful for fit check for
//          access hole in back case/cover piece in overall assembly.
//
// ****************************************************************************

module wiring_harness(num_conductor = 4, harness_length = 10, connector_type = "unterminated") {
    
    // First some error checking:
    assert(harness_length >= 0);
    assert(((num_conductor == 3) || (num_conductor == 4)),
            "Only 3 or 4 conductor wiring harnesses supported at this time.");
    assert(((connector_type == "socket") || (connector_type == "header") ||
            (connector_type == "unterminated")),
            "Unsupported connector_type. Check spelling.");
    union() {
        translate([wire1_x, wire1_y, -wire_diam/2.0]) {
            rotate([0, 90, 0])
                soldered_wire(prebend_length = wire_len - wire_strip_length,
                    insulation_d = wire_diam,
                    postbend_length = harness_length,
                    soldered_length = wire_solder_length,
                    stripped_length = wire_strip_length,
                    dogleg_dist = 5.0, dogleg_offset = pwb_pad_pitch_y - wire_diam,
                    bend_r = wire_bend_r, insulation_color = "black");
        }
        translate([wire2_x, wire2_y, -wire_diam/2.0]) {
            rotate([0, 90, 0])
                soldered_wire(prebend_length = wire_len - wire_strip_length,
                    insulation_d = wire_diam,
                    postbend_length = harness_length,
                    soldered_length = wire_solder_length,
                    stripped_length = wire_strip_length,
                    bend_r = wire_bend_r, insulation_color = "red");
        }
        translate([wire3_x, wire3_y, -wire_diam/2.0]) {
            rotate([0, 90, 0])
                soldered_wire(prebend_length = wire_len - wire_strip_length,
                    insulation_d = wire_diam,
                    postbend_length = harness_length,
                    soldered_length = wire_solder_length,
                    stripped_length = wire_strip_length,
                    dogleg_dist = 5.0, dogleg_offset = -pwb_pad_pitch_y + wire_diam,
                    bend_r = wire_bend_r, insulation_color = "white");
        }
        
        if (num_conductor == 4) {

            // Add 4th wire to wire harness only if the parameter num_conductor = 4 is set:
            translate([wire4_x, wire4_y, -wire_diam/2.0]) {
                rotate([0, 90, 180])
                    soldered_wire(prebend_length = wire_len - wire_strip_length,
                        insulation_d = wire_diam,
                        postbend_length = harness_length,
                        soldered_length = wire_solder_length,
                        stripped_length = wire_strip_length,
                        dogleg_dist = 17.0, dogleg_offset = pwb_pad_pitch_y-2*wire_diam,
                        bend_r = wire_bend_r, insulation_color = "green");
            }

            if (connector_type == "socket") {
                // Connector backshell (Socket style connection, which includes 'interface' section too):
                color("white") {
                    translate([(pwb_length-jst4ph_inter_width)/2,
                                wire2_y + wire_diam/2 - jst4ph_inter_length/2,
                                -harness_length-wire_bend_r-(wire_diam/2)-jst4ph_inter_height])
                        cube([jst4ph_inter_width, jst4ph_inter_length, jst4ph_inter_height]);
                    translate([(pwb_length-jst4ph_socket_width)/2,
                                wire2_y + wire_diam/2 - jst4ph_socket_length/2,
                                -harness_length-wire_bend_r-(wire_diam/2)-jst4ph_inter_height-jst4ph_socket_height])
                        cube([jst4ph_socket_width, jst4ph_socket_length, jst4ph_socket_height]);
                }
            } else if (connector_type == "header") {
                // Connector backshell (Header style connection):
                color("white") {
                    translate([(pwb_length-jst4ph_header_width)/2,
                                wire2_y + wire_diam/2 - jst4ph_header_length/2,
                                -harness_length-wire_bend_r-(wire_diam/2)-jst4ph_header_height])
                        cube([jst4ph_header_width, jst4ph_header_length, jst4ph_header_height]);
                }
            }
        } else {  // 3-conductor Wire Harness (num_conductor == 3):
            if (connector_type == "socket") {
                // Connector backshell (Socket style connection, which includes 'interface' section too):
                color("white") {
                    translate([(pwb_length-jst3ph_inter_width)/2,
                                wire2_y - jst3ph_inter_length/2,
                                -harness_length-wire_bend_r-(wire_diam/2)-jst3ph_inter_height])
                        cube([jst3ph_inter_width, jst3ph_inter_length, jst3ph_inter_height]);
                    translate([(pwb_length-jst3ph_socket_width)/2,
                                wire2_y - jst3ph_socket_length/2,
                                -harness_length-wire_bend_r-(wire_diam/2)-jst3ph_inter_height-jst3ph_socket_height])
                        cube([jst3ph_socket_width, jst3ph_socket_length, jst3ph_socket_height]);
                }
            } else if (connector_type == "header") {
                // Connector backshell (Header style connection):
                color("white") {
                    translate([(pwb_length-jst3ph_header_width)/2,
                                wire2_y + wire_diam/2 - jst3ph_header_length/2,
                                -harness_length-wire_bend_r-(wire_diam/2)-jst3ph_header_height])
                        cube([jst3ph_header_width, jst3ph_header_length, jst3ph_header_height]);
                }
            }
        }

    }
}

/////////////////////////////////////////////////////////////////
//
// Preview or Render Model only if viewed directly, not called as
//   part of upper-level Assembly:
//
/////////////////////////////////////////////////////////////////
if ($include_wiring_harness == undef) {
    wiring_harness(num_conductor = 4, harness_length = 20, connector_type = "socket", $fn=80);
}
