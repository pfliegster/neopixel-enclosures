// ****************************************************************************
//
//  File: neopixel_x8_stick_pwb.scad
//
//  Description:
//      Rough 3D Model of Adafruit "NeoPixel 8 Stick" RGB/RGBW 5050 LED Assemblies,
//      based on Adafruit EagleCAD V2 board file:
//
//      https://github.com/adafruit/NeoPixel-Sticks
//
//      The PWB model includes mounting holes, LED modules, 0805 Passive components,
//      as well as visualized pads on back side of PWB for alignment/visualization
//      of PWB in case and with wiring harness model.
//
//  Parameters:
//      xy_center:  Set to 'true' in order to center the Model in the XY plane, useful for
//                  incorporation of the module into other projects so that the user does not
//                  need to be aware of the origin used by default in this project (false = align
//                  this module with NeoPixel Stick 8 PWB lower-left corner at origin).
//
//  Author:  Keith Pflieger
//  github:  pfliegster (https://github.com/pfliegster)
//  License: CC BY-NC-SA 4.0
//           (Creative Commons: Attribution-NonCommercial-ShareAlike)
//
// ****************************************************************************

include <neopixel_x8_stick_constants.scad>

$fn=40;

module pwb_model(xy_center = false) {

    // Compute translation vector if user sets 'xy_center' == true:
    xy_origin_translation = [ xy_center ? -pwb_length/2 : 0, xy_center ? -pwb_width/2  : 0, 0 ];
    
    translate(xy_origin_translation) {
        
        // Bare PWB:
        color("darkolivegreen", alpha = 1.0) {
            render() difference() {
                cube([pwb_length, pwb_width, pwb_height]);
                union() {
                    translate([pwb_hole1_x, pwb_hole1_y, 0.0])
                        cylinder(h = pwb_height, r = pwb_hole1_r);
                    translate([pwb_hole2_x, pwb_hole2_y, 0.0])
                        cylinder(h = pwb_height, r = pwb_hole2_r);

                    for (i = [ 0: 3 ]) { // 4 pads per on each end of board
                        translate([ (pwb_pad_center_x1 - pwb_pad_length/2),
                                    (pwb_pad_center_y1 + i*pwb_pad_pitch_y - pwb_pad_width/2),
                                     0])
                            cube([pwb_pad_length, pwb_pad_width, pwb_pad_height]);
                        translate([ (pwb_length - pwb_pad_center_x1 - pwb_pad_length/2),
                                    (pwb_pad_center_y1 + i*pwb_pad_pitch_y - pwb_pad_width/2),
                                     0])
                            cube([pwb_pad_length, pwb_pad_width, pwb_pad_height]);
                    }
                }
            }
        }
        
        // Solder pads (for visualization):
        for (i = [ 0: 3 ]) { // 4 pads per on each end of board
            translate([ (pwb_pad_center_x1 - pwb_pad_length/2),
                        (pwb_pad_center_y1 + i*pwb_pad_pitch_y - pwb_pad_width/2),
                         0])
                cube([pwb_pad_length, pwb_pad_width, pwb_pad_height]);
            translate([ (pwb_length - pwb_pad_center_x1 - pwb_pad_length/2),
                        (pwb_pad_center_y1 + i*pwb_pad_pitch_y - pwb_pad_width/2),
                         0])
                cube([pwb_pad_length, pwb_pad_width, pwb_pad_height]);
        }
        
        // WS281x LED Modules:
        for (i = [ 0: num_leds - 1 ]) {
            translate([ (led_start_x + i*led_spacing_x - led_length/2),
                        (led_start_y + i*led_spacing_y - led_width/2),
                         pwb_height]) {
                cube([led_length, led_width, led_height]);
            }
        }
        
        // Passive 0805 Cap/Res components:
        for (i = [ 0 : len(c0805_x) - 1 ]) {
            // V2 version of NeoPixel stick has a resistor (black) instead of capacitor (brown) in position 1:
            color((i>0) ? "sienna":"black") {
                translate([c0805_x[i], c0805_y, pwb_height + c0805_height/2])
                    cube([c0805_length, c0805_width, c0805_height], center = true);
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
if ($include_pwb == undef) {
    pwb_model();
}