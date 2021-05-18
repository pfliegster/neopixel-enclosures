# Change Log

All notable changes to this project are documented in this file. Major/Minor release tags match GitHub.

## [v0.2.0](https://github.com/pfliegster/neopixel-enclosures/releases/tag/v0.2.0)
Updates to front/back enclosure module parameters for easier integration with other projects. Updated API (module parameters) should provide backward compatibility as reasonable defaults for new parameters are provided that closely match v0.1.0 constructs, but should be verified visually.

#### Added
- New customization parameters for front and/or back modules in order to allow for easier integration with other projects and offer instantiation-level customization (instead of relying on fixed constants in the *neopixel_case_constants.scad* include file which can't be changed independently for multiple instantiations):
  - `case_screw_separation`: added as configuration parameter to both front/back enclosure modules (instead of using a constant value defined as `case_screw_offset` in the *neopixel_case_constants.scad* include file).
  - `case_thickness`: added configuration parameter (only needed for back enclosure model part), defining overall front + back enclosure overall thickness. Easier to use than previous constant definition for `extra_back_thickness` (in *neopixel_case_constants.scad*) and can more easily set overall thickness to be slightly longer than M3 screw (for screw-in case variant) without some tedious calculations ...
- New parameter `add_back_mounting_screws`: added `boolean` option to back enclosure module to allow for easy mounting of the enclosure assembly to other objects or 3D models. Currently hard-coded to use M3 flathead screws at fixed location on each side of rear hole for the wiring harness.
- New alternate back enclosure model part was created, **neopixel_stick_case_back_on_mounting_plate()**, which now includes a mounting tab per dimensional parameters passed to the module. Useful for mounting to other projects (just add screw holes where you need them).
- New utility modules to assist with adding NeoPixel Enclosure to other projects, providing visualization and helping with creating cutout regions for wire harness and mounting screws:
  - **HarnessCutoutRegionExtended()**,
  - **MountingScrewsCutoutRegion()**, and
  - **NeopixelCaseCutoutRegion()**

### Fixed
- Enlarged default screw hole diameter for M3 case screws and mounting screws to me 3.4 mm (instead of 3.2mm) on both front/back modules to allow for easier insertion in through-hole application.

## [v0.1.0](https://github.com/pfliegster/neopixel-enclosures/releases/tag/v0.1.0)

#### Added
- Initial commits and verification complete 

   Basic functionality of enclosure design parts is completed for the Adafruit NeoPixel Stick (x8) products. Verified several customization options for front/back parts with 3D printed models and several other front/back combinations visually in the OpenSAD preview pane using *Assembly*, *Exploded Assembly*, and *Animated* visualizations.
