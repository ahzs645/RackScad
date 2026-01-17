/*
 * CageMaker PRCG - Modular Parametric Rack Cage Generator
 * Main Entry Point
 *
 * Based on CageMaker PRCG v0.21 by WebMaka
 * Original: https://github.com/WebMaka/CageMakerPRCG
 * License: CC BY-NC-SA 4.0
 *
 * This modular version breaks the monolithic script into reusable components.
 * Include this file in your project and call the generate_rack_cage() module.
 */

// Include all component modules
use <components/constants.scad>
use <components/utilities.scad>
use <components/honeycomb.scad>
use <components/faceplate.scad>
use <components/keystone.scad>
use <components/fan.scad>
use <components/cage.scad>
use <components/validation.scad>
use <components/ruler.scad>
use <components/rack_ears.scad>

// EIA constants
_EIA_UNIT = 44.45;
_INCH_MM = 25.4;


/* [Target Device Dimensions] */

// Depth/length (front-to-back) of device in mm
device_depth = 120.0; // [15::254]

// Width (left-to-right) of device in mm
device_width = 150.0; // [15::222]

// Height (top-to-bottom) of device in mm
device_height = 45.0; // [15::200]

// Clearance in mm - lower values make for a tighter fit
device_clearance = 1; // [0.0::5.0]


/* [Rack Settings] */

// Rack cage width (inches)
rack_cage_width = 10; // [5:"5 in. Half-Width 10in",6:"6 in. Micro-Rack",6.33:"6.33 in. Outer Third-Width 19in",6.33001:"6.33 in. Center Third-Width 19in",7:"7 in. Micro-Rack",9.5:"9.5 in. Half-Width 19in",10:"10 in. Mini-Rack",19:"19 in. Full Rack"]

// Allow half-unit heights
allow_half_heights = false;


/* [Rulers/Guides] */

// Show horizontal ruler (preview only)
show_ruler = true;

// Build volume outline size in mm (0 to disable)
show_build_outline = 220;


/* [Cage Options] */

// Tap/heat-set hole diameter
tap_or_heat_set_holes = 5.25; // [3.15:"M3 Clear",4.20:"M4 Clear",5.25:"M5 Clear",6.30:"M6 Clear",2.60:"M3 Tap",3.50:"M4 Tap",4.40:"M5 Tap",5.00:"M6 Tap"]

// Horizontal offset (mm)
cage_horizontal_offset = 0.00; // [-240.00::240.0]

// Vertical offset (mm)
cage_vertical_offset = 0.00; // [-150.00::150.0]

// Heavy device wall thickness
heavy_device = 0; // [0:"Standard 4mm",1:"Thickened 5mm",2:"Super-Thick 6mm"]

// Additional center support
extra_support = false;

// Reinforce faceplate edges
reinforce_faceplate = false;

// Split cage into two halves
split_cage_into_two_halves = false;

// Add alignment pin holes
add_alignment_pin_holes = false;


/* [Rack Ears] */

// Add rack mounting ears
add_rack_ears = false;

// Rack ear style
rack_ear_style = "Simple"; // ["Simple":"Simple L-Bracket", "Fusion":"Fusion Style (detailed)"]

// Rack ear depth (mm)
rack_ear_depth = 20; // [15:1:40]

// Rack ear thickness (mm)
rack_ear_thickness = 3; // [2:0.5:5]

// Rack ear mounting hole diameter (mm)
rack_ear_hole_diameter = 5; // [3:0.5:8]

// Use countersink holes (Fusion style only)
rack_ear_countersink = true;

// Toolless mounting (no screw holes, for Ubiquiti-style racks)
rack_ear_toolless = true;


/* [Faceplate Modifications] */

// Mod Slot ONE Type
mod_one_type = "None"; // ["None","1x1Keystone","2x1Keystone","3x1Keystone","1x2Keystone","2x2Keystone","3x2Keystone","30mmFan","40mmFan","60mmFan","80mmFan"]

// Mod Slot ONE offset (mm) - 0 for auto-position
mod_one_offset = 0.00; // [-240.00::240.0]

// Mod Slot TWO Type
mod_two_type = "None"; // ["None","1x1Keystone","2x1Keystone","3x1Keystone","1x2Keystone","2x2Keystone","3x2Keystone","30mmFan","40mmFan","60mmFan","80mmFan"]

// Mod Slot TWO offset (mm) - 0 for auto-position
mod_two_offset = 0.00; // [-240.00::240.0]


/* [Ventilation Pattern] */

// Use honeycomb pattern (false = rectangular cutouts)
use_honeycomb = false;

// Honeycomb hole diameter (mm)
hex_diameter = 8; // [4:1:15]

// Honeycomb wall thickness (mm)
hex_wall = 2; // [1:0.5:5]


/* [Rarely-Changed Options] */

// Faceplate corner radius
faceplate_radius = 5; // [0.1:"Sharp",5:"Rounded"]

// Cutout corner radius (legacy - not used with honeycomb)
cutout_radius = 5; // [0.1:"Sharp",5:"Normal",10:"More",15:"Even more",20:"Very rounded"]

// Detail level for curves
this_fn = 64; // [16::360]


// Block customizer from showing internal variables
module block_customizer() {}


// Internal calculations
support_radius = 3 - heavy_device;
cutout_edge = 5;


/*
 * Generate a complete rack cage
 * This is the main entry point for the modular version
 */
module generate_rack_cage()
{
    // Calculate dimensions
    total_height_required = device_height + 16 + (heavy_device * 2);
    units_required = (ceil(total_height_required * (allow_half_heights ? 2 : 1) / _EIA_UNIT)) / (allow_half_heights ? 2 : 1);

    total_width_required = device_width + 16 + (heavy_device * 2);
    rack_width_required = calculate_required_rack_width(rack_cage_width, device_width, heavy_device);

    // Get faceplate ear configuration
    ear_type = get_faceplate_ears(rack_width_required);

    // Calculate working bounds
    bounds = calculate_working_bounds(rack_width_required, ear_type);

    // Validate offsets
    safe_h_offset = validate_horizontal_offset(cage_horizontal_offset, total_width_required, bounds);
    safe_v_offset = validate_vertical_offset(cage_vertical_offset, total_height_required, units_required);

    // Calculate slack space for mods
    outer_edge = total_width_required / 2;
    slack_a = bounds[0] - outer_edge - safe_h_offset;
    slack_b = bounds[1] + outer_edge - safe_h_offset;

    // Get mod dimensions
    mod_one_w = get_mod_width(mod_one_type);
    mod_one_h = get_mod_height(mod_one_type);
    mod_two_w = get_mod_width(mod_two_type);
    mod_two_h = get_mod_height(mod_two_type);

    // Validate mod offsets
    safe_mod_one_off = validate_mod_offset(mod_one_offset, mod_one_w, outer_edge, safe_h_offset, bounds, slack_a, slack_b);
    safe_mod_two_off = validate_mod_offset(mod_two_offset, mod_two_w, outer_edge, safe_h_offset, bounds, slack_a - mod_one_w, slack_b + mod_one_w);

    // Determine safe mod types
    safe_mod_one = (safe_mod_one_off == 0 || mod_one_h >= units_required * _EIA_UNIT) ? "None" : mod_one_type;
    safe_mod_two = (safe_mod_two_off == 0 || mod_two_h >= units_required * _EIA_UNIT) ? "None" : mod_two_type;

    // Show warnings if needed
    if (rack_cage_width != rack_width_required)
    {
        echo_warning("rack_width");
        check_console_warning(units_required);
    }
    if (cage_horizontal_offset != safe_h_offset)
    {
        echo_warning("horizontal_offset");
        check_console_warning(units_required);
    }
    if (cage_vertical_offset != safe_v_offset)
    {
        echo_warning("vertical_offset");
        check_console_warning(units_required);
    }
    if (mod_one_type != "None" && safe_mod_one == "None")
    {
        echo_warning("mod_one_offset");
        check_console_warning(units_required);
    }
    if (mod_two_type != "None" && safe_mod_two == "None")
    {
        echo_warning("mod_two_offset");
        check_console_warning(units_required);
    }

    // Build the cage
    difference()
    {
        union()
        {
            // Faceplate
            create_blank_faceplate(
                rack_width_required,
                units_required,
                ear_type,
                heavy_device,
                faceplate_radius,
                tap_or_heat_set_holes,
                add_alignment_pin_holes,
                reinforce_faceplate,
                this_fn
            );

            // Preview guides
            if (show_ruler && $preview && !split_cage_into_two_halves)
            {
                all_preview_guides(
                    rack_width_required,
                    units_required,
                    safe_h_offset,
                    device_depth,
                    heavy_device,
                    show_build_outline,
                    safe_mod_one_off,
                    safe_mod_two_off
                );
            }

            // Cage structure with optional honeycomb ventilation
            cage_structure(
                safe_h_offset,
                safe_v_offset,
                device_width,
                device_height,
                device_depth,
                device_clearance,
                heavy_device,
                extra_support,
                cutout_edge,
                cutout_radius,
                split_cage_into_two_halves,
                use_honeycomb,
                hex_diameter,
                hex_wall,
                this_fn
            );

            // Optional rack mounting ears
            if (add_rack_ears)
            {
                if (rack_ear_style == "Simple")
                {
                    simple_rack_ears_pair(
                        faceplate_width = rack_width_required * _INCH_MM,
                        unit_height = units_required,
                        ear_width = 30,
                        ear_depth = rack_ear_depth,
                        thickness = rack_ear_thickness,
                        hole_diameter = rack_ear_hole_diameter,
                        fn = this_fn
                    );
                }
                else
                {
                    rack_ears_for_rack(
                        rack_width = rack_width_required,
                        unit_height = units_required,
                        ear_depth = rack_ear_depth,
                        ear_thickness = rack_ear_thickness,
                        hole_radius = rack_ear_hole_diameter / 2,
                        countersink = rack_ear_countersink,
                        toolless = rack_ear_toolless,
                        fn = this_fn
                    );
                }
            }

            // Add modification blocks
            if (safe_mod_one != "None")
            {
                if (safe_mod_one == "1x1Keystone" || safe_mod_one == "2x1Keystone" ||
                    safe_mod_one == "3x1Keystone" || safe_mod_one == "1x2Keystone" ||
                    safe_mod_one == "2x2Keystone" || safe_mod_one == "3x2Keystone")
                {
                    keystone_block(safe_mod_one_off, safe_mod_one);
                }
                else
                {
                    fan_block_by_type(safe_mod_one_off, safe_mod_one);
                }
            }

            if (safe_mod_two != "None")
            {
                if (safe_mod_two == "1x1Keystone" || safe_mod_two == "2x1Keystone" ||
                    safe_mod_two == "3x1Keystone" || safe_mod_two == "1x2Keystone" ||
                    safe_mod_two == "2x2Keystone" || safe_mod_two == "3x2Keystone")
                {
                    keystone_block(safe_mod_two_off, safe_mod_two);
                }
                else
                {
                    fan_block_by_type(safe_mod_two_off, safe_mod_two);
                }
            }
        }

        // Cut modification openings
        if (safe_mod_one != "None")
        {
            if (safe_mod_one == "1x1Keystone" || safe_mod_one == "2x1Keystone" ||
                safe_mod_one == "3x1Keystone" || safe_mod_one == "1x2Keystone" ||
                safe_mod_one == "2x2Keystone" || safe_mod_one == "3x2Keystone")
            {
                keystone_cutout(safe_mod_one_off, safe_mod_one);
            }
            else
            {
                fan_cutout_by_type(safe_mod_one_off, safe_mod_one, 3.5, this_fn);
            }
        }

        if (safe_mod_two != "None")
        {
            if (safe_mod_two == "1x1Keystone" || safe_mod_two == "2x1Keystone" ||
                safe_mod_two == "3x1Keystone" || safe_mod_two == "1x2Keystone" ||
                safe_mod_two == "2x2Keystone" || safe_mod_two == "3x2Keystone")
            {
                keystone_cutout(safe_mod_two_off, safe_mod_two);
            }
            else
            {
                fan_cutout_by_type(safe_mod_two_off, safe_mod_two, 3.5, this_fn);
            }
        }

        // Cut the device opening through the faceplate
        translate([safe_h_offset, safe_v_offset, 5])
            cube([device_width + device_clearance, device_height + device_clearance, 20], center=true);
    }
}


// Generate the cage when this file is rendered directly
if (split_cage_into_two_halves)
{
    // Split cage mode - creates two halves
    // Note: Full split cage implementation would require additional logic
    // from the original make_half_cage() module
    echo("Split cage mode - use the original script for full split functionality");
    generate_rack_cage();
}
else
{
    generate_rack_cage();
}
