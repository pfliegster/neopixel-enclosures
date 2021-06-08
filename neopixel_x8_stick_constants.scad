// ****************************************************************************
//
// File: neopixel_x8_stick_constants.scad
//
// Description:
//   Some useful constants for Adafruit "NeoPixel 8 Stick" products,
//   derived from EagleCAD board file dimensions (and physical inspection)
//   of V2 circuit board (may also work with V1 boards as well):
//
//     https://github.com/adafruit/NeoPixel-Sticks
//
// Notes:
// * Original BRD units are Imperial (inches), manually converted to metric here (mm)
//
// Author: Keith Pflieger
// License: CC BY-NC-SA 4.0
//          (Creative Commons: Attribution-NonCommercial-ShareAlike)
// github: pfliegster (https://github.com/pfliegster)
//
// ****************************************************************************

// Raw PWB Dimensions:
ada_nps8_pwb_length = 50.8;
ada_nps8_pwb_width = 10.16;
ada_nps8_pwb_height = 1.5;

// Mounting Holes:
pwb_hole1_x = 12.7;
pwb_hole1_y = 8.128;
pwb_hole1_r = 1.0;
pwb_hole2_x = 38.1;
pwb_hole2_y = 8.128;
pwb_hole2_r = 1.0;

// PWB Pads for power and Data In/Out (4 pads on each end of board, back side):
pwb_pad_center_x1 = 1.524;  // center of 1st pad from edge of board
pwb_pad_center_y1 = 1.397;  // center of 1st pad from bottom edge of board
pwb_pad_pitch_y = 2.54;
pwb_pad_length = 2.54;
pwb_pad_width = 1.27;
pwb_pad_height = 0.1;  // just for mock-up model visibility, not the real PWB bottom layer thickness

// WS281x LED module dimensions (just physical body, not including leads/pads):
led_width = 5.0;
led_length = 5.0;
led_height = 1.8; // from manual measurement

// Center X/Y position of first LED module:
led_start_x = 3.175;
led_start_y = 3.81;

// Center-to-center spacing of WS281x LED Modules
num_leds = 8;
led_spacing_x = 6.35;
led_spacing_y = 0.0;

// 0805 Passive component placement/size info:
c0805_y = 8.382;    // All 0805 passives have same Y offset
c0805_x = [2.413, 8.382, 16.891, 22.225, 28.575, 33.655, 42.037, 48.26];
c0805_length = 2.0;
c0805_width = 1.3;
c0805_height = 1.14;
