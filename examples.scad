/*
 * CageMaker PRCG - Component Usage Examples
 * Demonstrates how to use individual modular components
 *
 * Based on CageMaker PRCG v0.21 by WebMaka
 * License: CC BY-NC-SA 4.0
 *
 * Use the Customizer to select which example to view
 */

use <components/utilities.scad>
use <components/faceplate.scad>
use <components/keystone.scad>
use <components/fan.scad>
use <components/cage.scad>
use <components/ruler.scad>
use <components/honeycomb.scad>
use <components/rack_ears.scad>
use <components/joiners.scad>

/* [Example Selection] */

// Select which example to display
example = 21; // [1:Basic Shapes, 2:Standalone Faceplate, 3:Faceplate with Ears, 4:Keystone Jacks, 5:Fan Grills, 6:Fan Cutout with Holes, 7:Cage Structure, 8:Cage with Honeycomb, 9:Preview Guides, 10:Two Stacked Cages, 11:Side-by-Side Cages, 12:Dual Fan Faceplate, 13:Keystone Patch Panel, 14:Simple Rack Ears, 15:Fusion Rack Ears, 16:Faceplate with Rack Ears, 17:Full Cage with Fusion Ears, 18:Faceplate with Bottom Hooks, 19:Joiner Parts, 20:Joiner Assembled View, 21:Modular Faceplate Sections]


/* [Hide] */
// Block customizer from showing internal variables
_dummy = 0;


// ============================================================
// EXAMPLE 1: Basic Shapes
// Demonstrates the utility shape modules
// ============================================================
module example_basic_shapes()
{
    // Four rounded corner plate (like a faceplate)
    translate([0, 0, 0])
        color("silver")
            four_rounded_corner_plate(
                plate_height = 88.9,    // 2U height
                plate_width = 254,      // 10" rack
                plate_thickness = 4,
                corner_radius = 5
            );

    // Two rounded corner plate (like a side panel)
    translate([150, 0, 10])
        color("gray")
            two_rounded_corner_plate(
                plate_height = 60,
                plate_width = 100,
                plate_thickness = 4,
                corner_radius = 3
            );
}


// ============================================================
// EXAMPLE 2: Standalone Faceplate
// Create just a faceplate with EIA-310 screw holes
// ============================================================
module example_standalone_faceplate()
{
    // Simple 10" rack, 2U faceplate
    create_blank_faceplate(
        desired_width = 10,        // 10 inch rack
        unit_height = 2,           // 2U tall
        ear_type = "None",         // No bolt-together ears
        heavy_device = 0,          // Standard 4mm thickness
        faceplate_radius = 5,      // Rounded corners
        tap_hole_diameter = 0,     // Standard clearance holes
        add_alignment_pins = false,
        reinforce_faceplate = false
    );
}


// ============================================================
// EXAMPLE 3: Faceplate with Bolt-Together Ears
// For half-width rack cages
// ============================================================
module example_faceplate_with_ears()
{
    // Half-width 19" rack faceplate (9.5")
    create_blank_faceplate(
        desired_width = 9.5,
        unit_height = 1,
        ear_type = "One Side",     // Bolt-together ear on right
        heavy_device = 0,
        faceplate_radius = 5,
        tap_hole_diameter = 5.25,  // M5 clearance holes in ears
        add_alignment_pins = true,
        reinforce_faceplate = true // Add edge bracing
    );
}


// ============================================================
// EXAMPLE 4: Keystone Jack Receptacles
// Various Keystone module configurations
// ============================================================
module example_keystone_jacks()
{
    // Single Keystone receptacle
    translate([-80, 0, 0])
        keystone_receptacle();

    // Show Keystone cutout shape (for visualization)
    translate([-40, 0, 0])
        color("red", 0.5)
            keystone_module();

    // 2x1 Keystone block
    translate([20, 0, 0])
        keystone_2x1(0);

    // 3x2 Keystone block
    translate([100, 0, 0])
        keystone_3x2(0);
}


// ============================================================
// EXAMPLE 5: Fan Grill Patterns
// Decorative fan cutouts of various sizes
// ============================================================
module example_fan_grills()
{
    // 40mm fan grill
    translate([-100, 0, 0])
        fan_grill_cutout(40);

    // 60mm fan grill
    translate([0, 0, 0])
        fan_grill_cutout(60);

    // 80mm fan grill
    translate([120, 0, 0])
        fan_grill_cutout(80);
}


// ============================================================
// EXAMPLE 6: Complete Fan Cutout with Screw Holes
// Ready for mounting a fan
// ============================================================
module example_fan_cutout_complete()
{
    // Create a plate and cut a 60mm fan opening
    difference()
    {
        // Base plate
        translate([0, 0, 2])
            four_rounded_corner_plate(100, 100, 4, 5);

        // Fan cutout with mounting holes
        fan_cutout_complete(
            offset_x = 0,
            fan_size = 60,
            screw_hole_diameter = 3.5  // M3 mounting screws
        );
    }
}


// ============================================================
// EXAMPLE 7: Cage Structure Only
// Just the cage box without faceplate
// ============================================================
module example_cage_structure()
{
    cage_structure(
        offset_x = 0,
        offset_y = 0,
        device_width = 100,
        device_height = 40,
        device_depth = 80,
        device_clearance = 1,
        heavy_device = 0,
        extra_support = false,
        cutout_edge = 5,
        cutout_radius = 5,
        is_split = false,
        use_honeycomb = false  // Rectangular ventilation
    );
}


// ============================================================
// EXAMPLE 8: Cage with Extra Support and Honeycomb
// For heavier devices with honeycomb ventilation
// ============================================================
module example_cage_honeycomb()
{
    cage_structure(
        offset_x = 0,
        offset_y = 0,
        device_width = 150,
        device_height = 60,
        device_depth = 120,
        device_clearance = 1.5,
        heavy_device = 1,          // Thickened walls
        extra_support = true,      // Center reinforcing
        cutout_edge = 5,
        cutout_radius = 10,
        is_split = false,
        use_honeycomb = true,      // Honeycomb ventilation pattern
        hex_dia = 8,               // Hexagon diameter
        hex_wall = 2               // Wall between hexagons
    );
}


// ============================================================
// EXAMPLE 9: Preview Guides
// Rulers and markers (only visible in preview mode)
// ============================================================
module example_preview_guides()
{
    // These only show in F5 preview, not F6 render
    all_preview_guides(
        rack_width = 10,
        units_required = 2,
        cage_offset_x = 15,
        cage_depth = 100,
        heavy_device = 0,
        build_size = 220,
        mod_one_offset = 80,
        mod_two_offset = -60
    );
}


// ============================================================
// EXAMPLE 10: Two Stacked Cages
// Multiple device cages on a single faceplate
// ============================================================
module example_stacked_cages()
{
    // Two smaller cages stacked vertically on a 3U faceplate
    difference()
    {
        union()
        {
            // 3U faceplate (10" wide)
            create_blank_faceplate(
                desired_width = 10,
                unit_height = 3,
                ear_type = "None",
                heavy_device = 0,
                faceplate_radius = 5,
                tap_hole_diameter = 0,
                add_alignment_pins = false,
                reinforce_faceplate = false
            );

            // Upper cage - small device with honeycomb ventilation
            cage_structure(
                offset_x = 0,
                offset_y = 35,             // Offset upward
                device_width = 100,
                device_height = 40,
                device_depth = 80,
                device_clearance = 1,
                heavy_device = 0,
                extra_support = false,
                cutout_edge = 5,
                cutout_radius = 5,
                is_split = false,
                use_honeycomb = true,      // Honeycomb vents
                hex_dia = 6,
                hex_wall = 1.5
            );

            // Lower cage - different device with rectangular vents
            cage_structure(
                offset_x = 0,
                offset_y = -35,            // Offset downward
                device_width = 120,
                device_height = 45,
                device_depth = 100,
                device_clearance = 1,
                heavy_device = 0,
                extra_support = false,
                cutout_edge = 5,
                cutout_radius = 5,
                is_split = false,
                use_honeycomb = false      // Rectangular vents
            );
        }

        // Cut device openings through faceplate
        // Upper device opening
        translate([0, 35, 5])
            cube([100 + 1, 40 + 1, 20], center=true);

        // Lower device opening
        translate([0, -35, 5])
            cube([120 + 1, 45 + 1, 20], center=true);
    }
}


// ============================================================
// EXAMPLE 11: Side-by-Side Cages
// Two cages placed horizontally on a wide faceplate
// ============================================================
module example_side_by_side_cages()
{
    // Two cages side by side on a 19" 2U faceplate
    difference()
    {
        union()
        {
            // Full 19" 2U faceplate
            create_blank_faceplate(
                desired_width = 19,
                unit_height = 2,
                ear_type = "None",
                heavy_device = 0,
                faceplate_radius = 5,
                tap_hole_diameter = 0,
                add_alignment_pins = false,
                reinforce_faceplate = false
            );

            // Left cage
            cage_structure(
                offset_x = -120,           // Offset left
                offset_y = 0,
                device_width = 100,
                device_height = 50,
                device_depth = 90,
                device_clearance = 1,
                heavy_device = 0,
                extra_support = false,
                cutout_edge = 5,
                cutout_radius = 5,
                is_split = false,
                use_honeycomb = true,
                hex_dia = 8,
                hex_wall = 2
            );

            // Right cage
            cage_structure(
                offset_x = 120,            // Offset right
                offset_y = 0,
                device_width = 100,
                device_height = 50,
                device_depth = 90,
                device_clearance = 1,
                heavy_device = 0,
                extra_support = false,
                cutout_edge = 5,
                cutout_radius = 5,
                is_split = false,
                use_honeycomb = true,
                hex_dia = 8,
                hex_wall = 2
            );
        }

        // Cut device openings through faceplate
        translate([-120, 0, 5])
            cube([100 + 1, 50 + 1, 20], center=true);

        translate([120, 0, 5])
            cube([100 + 1, 50 + 1, 20], center=true);
    }
}


// ============================================================
// EXAMPLE 12: Custom Composite Design - Dual Fan Faceplate
// Combining components for a custom enclosure
// ============================================================
module example_dual_fan_faceplate()
{
    // A custom 10" 2U faceplate with dual 40mm fans
    difference()
    {
        union()
        {
            // Faceplate
            create_blank_faceplate(
                desired_width = 10,
                unit_height = 2,
                ear_type = "None",
                heavy_device = 0,
                faceplate_radius = 5,
                tap_hole_diameter = 0,
                add_alignment_pins = false,
                reinforce_faceplate = false
            );

            // Fan mounting blocks
            fan_block(80, 40);
            fan_block(-80, 40);
        }

        // Cut fan openings
        fan_cutout_complete(80, 40, 3.5);
        fan_cutout_complete(-80, 40, 3.5);
    }
}


// ============================================================
// EXAMPLE 13: Faceplate with Keystone Ports
// Network patch panel style
// ============================================================
module example_keystone_panel()
{
    difference()
    {
        union()
        {
            // Base faceplate
            create_blank_faceplate(10, 1, "None", 0, 5, 0, false, false);

            // Keystone blocks
            keystone_3x1(0);
        }

        // Cut Keystone openings
        keystone_cutout(0, "3x1Keystone");
    }
}


// ============================================================
// EXAMPLE 14: Simple Rack Ears
// Basic L-bracket style mounting ears
// ============================================================
module example_simple_rack_ears()
{
    // Single simple rack ear
    translate([-50, 0, 0])
        simple_rack_ear(
            width = 40,
            height = 44.45,    // 1U
            depth = 20,
            thickness = 3,
            hole_diameter = 5
        );

    // Pair of simple rack ears (for 10" 2U)
    translate([50, 0, 0])
        simple_rack_ears_pair(
            faceplate_width = 254,  // 10"
            unit_height = 2,
            ear_width = 30,
            ear_depth = 20,
            thickness = 3,
            hole_diameter = 5
        );
}


// ============================================================
// EXAMPLE 15: Fusion Style Rack Ears
// Detailed rack ears based on Fusion 360 export
// ============================================================
module example_fusion_rack_ears()
{
    // Single Fusion-style rack ear (left)
    translate([-80, 0, 0])
        rack_ear_left(
            thickness = 2.9,
            side_width = 75,
            side_height = 25,
            bottom_depth = 22,
            hole_radius = 2.25,
            countersink = true
        );

    // Single Fusion-style rack ear (right)
    translate([80, 0, 0])
        rack_ear_right(
            thickness = 2.9,
            side_width = 75,
            side_height = 25,
            bottom_depth = 22,
            hole_radius = 2.25,
            countersink = true
        );
}


// ============================================================
// EXAMPLE 16: Faceplate with Rack Ears
// Complete faceplate with mounting ears attached
// ============================================================
module example_faceplate_with_rack_ears()
{
    _INCH_MM = 25.4;

    // 10" 2U faceplate with simple rack ears
    create_blank_faceplate(
        desired_width = 10,
        unit_height = 2,
        ear_type = "None",
        heavy_device = 0,
        faceplate_radius = 5,
        tap_hole_diameter = 0,
        add_alignment_pins = false,
        reinforce_faceplate = false
    );

    // Add simple rack ears
    simple_rack_ears_pair(
        faceplate_width = 10 * _INCH_MM,
        unit_height = 2,
        ear_width = 30,
        ear_depth = 25,
        thickness = 3,
        hole_diameter = 5
    );
}


// ============================================================
// EXAMPLE 17: Full Cage with Fusion Rack Ears
// Complete device cage with Fusion-style mounting ears
// ============================================================
module example_cage_with_fusion_ears()
{
    _INCH_MM = 25.4;
    _EIA_UNIT = 44.45;

    // Device dimensions
    dev_width = 120;
    dev_height = 50;
    dev_depth = 90;
    dev_clearance = 1;

    // Rack settings
    rack_width = 10;  // 10" rack
    unit_height = 2;  // 2U

    difference()
    {
        union()
        {
            // Faceplate
            create_blank_faceplate(
                desired_width = rack_width,
                unit_height = unit_height,
                ear_type = "None",
                heavy_device = 0,
                faceplate_radius = 5,
                tap_hole_diameter = 0,
                add_alignment_pins = false,
                reinforce_faceplate = false
            );

            // Cage structure with honeycomb ventilation
            cage_structure(
                offset_x = 0,
                offset_y = 0,
                device_width = dev_width,
                device_height = dev_height,
                device_depth = dev_depth,
                device_clearance = dev_clearance,
                heavy_device = 0,
                extra_support = false,
                cutout_edge = 5,
                cutout_radius = 5,
                is_split = false,
                use_honeycomb = true,
                hex_dia = 8,
                hex_wall = 2
            );

            // Fusion-style rack ears (toolless for Ubiquiti-style racks)
            rack_ears_for_rack(
                rack_width = rack_width,
                unit_height = unit_height,
                ear_depth = 22,
                ear_thickness = 2.9,
                hole_radius = 2.25,
                countersink = true,
                toolless = true
            );
        }

        // Cut device opening through faceplate
        translate([0, 0, 5])
            cube([dev_width + dev_clearance, dev_height + dev_clearance, 20], center=true);
    }
}


// ============================================================
// EXAMPLE 18: Faceplate with Bottom Hooks Only
// Toolless hooks attached directly to bottom of faceplate
// ============================================================
module example_faceplate_with_bottom_hooks()
{
    rack_width = 10;    // 10" rack
    unit_height = 2;    // 2U

    // Faceplate
    create_blank_faceplate(
        desired_width = rack_width,
        unit_height = unit_height,
        ear_type = "None",
        heavy_device = 0,
        faceplate_radius = 5,
        tap_hole_diameter = 0,
        add_alignment_pins = false,
        reinforce_faceplate = false
    );

    // Bottom hooks only (no L-bracket ears)
    bottom_rack_hooks(
        rack_width = rack_width,
        unit_height = unit_height,
        thickness = 2.9
    );
}


// ============================================================
// EXAMPLE 19: Joiner Bracket Parts (Left and Right)
// Individual joiner brackets for connecting faceplate sections
// Uses M5 screws and hex nuts for assembly
// ============================================================
module example_joiner_parts()
{
    // Display left and right joiner brackets side by side
    // 1U version with 3 screws
    translate([0, 50, 0])
    {
        color("SteelBlue")
            faceplate_joiner_left(
                unit_height = 1,
                faceplate_width = 60
            );

        translate([80, 0, 0])
            color("Coral")
                faceplate_joiner_right(
                    unit_height = 1,
                    faceplate_width = 60
                );
    }

    // 2U version with 6 screws
    translate([0, -60, 0])
    {
        color("SteelBlue")
            faceplate_joiner_left(
                unit_height = 2,
                faceplate_width = 60
            );

        translate([80, 0, 0])
            color("Coral")
                faceplate_joiner_right(
                    unit_height = 2,
                    faceplate_width = 60
                );
    }
}


// ============================================================
// EXAMPLE 20: Joiner Assembled View
// Shows how joiner brackets mate together
// ============================================================
module example_joiner_assembled()
{
    // Exploded view (parts separated)
    translate([0, 60, 0])
    {
        echo("Exploded view - 1U joiner with 3x M5 screws");
        faceplate_joiner_assembled(
            unit_height = 1,
            faceplate_width = 60,
            explode = 30
        );
    }

    // Assembled view (parts mated)
    translate([0, -40, 0])
    {
        echo("Assembled view - 2U joiner with 6x M5 screws");
        faceplate_joiner_assembled(
            unit_height = 2,
            faceplate_width = 60,
            explode = 0
        );
    }
}


// ============================================================
// EXAMPLE 21: Joiner Pair for Printing
// Both left and right parts laid out for 3D printing
// ============================================================
module example_modular_faceplate_sections()
{
    // Pair of 1U joiners ready for printing
    translate([0, 50, 0])
        faceplate_joiner_pair(
            unit_height = 1,
            faceplate_width = 80,
            spacing = 15
        );

    // Pair of 2U joiners ready for printing
    translate([0, -60, 0])
        faceplate_joiner_pair(
            unit_height = 2,
            faceplate_width = 80,
            spacing = 15
        );

    // Text annotation (visible in preview)
    %translate([0, -130, 0])
        linear_extrude(1)
            text("M5 screws: 10-16mm, M5 hex nuts", size=6, halign="center");

    %translate([0, -140, 0])
        linear_extrude(1)
            text("3 screws per 1U (6 per 2U)", size=5, halign="center");
}


// ============================================================
// Render selected example
// ============================================================
if (example == 1) example_basic_shapes();
else if (example == 2) example_standalone_faceplate();
else if (example == 3) example_faceplate_with_ears();
else if (example == 4) example_keystone_jacks();
else if (example == 5) example_fan_grills();
else if (example == 6) example_fan_cutout_complete();
else if (example == 7) example_cage_structure();
else if (example == 8) example_cage_honeycomb();
else if (example == 9) example_preview_guides();
else if (example == 10) example_stacked_cages();
else if (example == 11) example_side_by_side_cages();
else if (example == 12) example_dual_fan_faceplate();
else if (example == 13) example_keystone_panel();
else if (example == 14) example_simple_rack_ears();
else if (example == 15) example_fusion_rack_ears();
else if (example == 16) example_faceplate_with_rack_ears();
else if (example == 17) example_cage_with_fusion_ears();
else if (example == 18) example_faceplate_with_bottom_hooks();
else if (example == 19) example_joiner_parts();
else if (example == 20) example_joiner_assembled();
else if (example == 21) example_modular_faceplate_sections();
