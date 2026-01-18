/**
 * Rack Scad - Joiner Examples
 *
 * Dedicated examples file for faceplate joiner walls.
 * These thin vertical walls allow separately printed rack panels
 * to be screwed together face-to-face using M5 hardware.
 *
 * Design: Thin wall (4mm) with rounded top at joint edge
 * Screw Pattern: Triangle layout (2 at top, 1 at bottom)
 * Hardware: M5 screws (12-16mm) + M5 hex nuts
 *
 * Use the Customizer to select which example to view.
 */

use <components/joiners.scad>

/* [Example Selection] */

// Select which joiner example to display
joiner_example = 1; // [1:Single Left Wall (1U), 2:Single Right Wall (1U), 3:Wall Pair (1U), 4:Assembled View (1U), 5:Exploded View (1U), 6:2U Wall Pair, 7:2U Assembled, 8:3U Wall Pair, 9:Wall Only (no faceplate), 10:All Sizes Comparison, 11:Print Layout - 1U Pair, 12:Print Layout - 2U Pair]

/* [Joiner Parameters] */

// Faceplate section width (mm)
faceplate_width = 60; // [40:10:120]

// Detail level for curves
detail_fn = 32; // [16:Low, 32:Medium, 64:High]


/* [Hide] */
_dummy = 0;


// ============================================================
// EXAMPLE 1: Single Left Wall (1U)
// The side with screw clearance holes
// ============================================================
module example_single_left_1u()
{
    color("SteelBlue")
        faceplate_joiner_left(
            unit_height = 1,
            faceplate_width = faceplate_width,
            include_faceplate = true,
            fn = detail_fn
        );

    // Label
    %translate([0, -35, 0])
        linear_extrude(1)
            text("LEFT (screw side)", size = 4, halign = "center");
}


// ============================================================
// EXAMPLE 2: Single Right Wall (1U)
// The side with hex nut pockets
// ============================================================
module example_single_right_1u()
{
    color("Coral")
        faceplate_joiner_right(
            unit_height = 1,
            faceplate_width = faceplate_width,
            include_faceplate = true,
            fn = detail_fn
        );

    // Label
    %translate([30, -35, 0])
        linear_extrude(1)
            text("RIGHT (nut side)", size = 4, halign = "center");
}


// ============================================================
// EXAMPLE 3: Wall Pair (1U)
// Both left and right walls side by side
// ============================================================
module example_pair_1u()
{
    faceplate_joiner_pair(
        unit_height = 1,
        faceplate_width = faceplate_width,
        spacing = 15,
        fn = detail_fn
    );

    // Labels
    %translate([-faceplate_width/2 - 5, -35, 0])
        linear_extrude(1)
            text("LEFT", size = 4, halign = "center");

    %translate([faceplate_width/2 + 5, -35, 0])
        linear_extrude(1)
            text("RIGHT", size = 4, halign = "center");

    // Hardware note
    %translate([0, -45, 0])
        linear_extrude(1)
            text("Hardware: 3x M5 screws + 3x M5 hex nuts", size = 3, halign = "center");
}


// ============================================================
// EXAMPLE 4: Assembled View (1U)
// Shows how the walls mate face-to-face
// ============================================================
module example_assembled_1u()
{
    faceplate_joiner_assembled(
        unit_height = 1,
        faceplate_width = faceplate_width,
        explode = 0,
        fn = detail_fn
    );

    // Label
    %translate([0, -35, 0])
        linear_extrude(1)
            text("ASSEMBLED - 1U Joint", size = 4, halign = "center");
}


// ============================================================
// EXAMPLE 5: Exploded View (1U)
// Shows assembly with parts separated
// ============================================================
module example_exploded_1u()
{
    faceplate_joiner_assembled(
        unit_height = 1,
        faceplate_width = faceplate_width,
        explode = 30,
        fn = detail_fn
    );

    // Assembly arrow
    %translate([0, 0, 25])
        rotate([0, 90, 0])
            cylinder(h = 20, d1 = 8, d2 = 0, center = true, $fn = 16);

    // Label
    %translate([0, -35, 0])
        linear_extrude(1)
            text("EXPLODED VIEW", size = 4, halign = "center");
}


// ============================================================
// EXAMPLE 6: 2U Wall Pair
// Larger walls with 6 screws (2 triangles)
// ============================================================
module example_pair_2u()
{
    faceplate_joiner_pair(
        unit_height = 2,
        faceplate_width = faceplate_width,
        spacing = 15,
        fn = detail_fn
    );

    // Hardware note
    %translate([0, -60, 0])
        linear_extrude(1)
            text("2U: 6x M5 screws + 6x M5 hex nuts", size = 3, halign = "center");
}


// ============================================================
// EXAMPLE 7: 2U Assembled
// Shows assembled 2U joint
// ============================================================
module example_assembled_2u()
{
    faceplate_joiner_assembled(
        unit_height = 2,
        faceplate_width = faceplate_width,
        explode = 0,
        fn = detail_fn
    );

    // Label
    %translate([0, -60, 0])
        linear_extrude(1)
            text("ASSEMBLED - 2U Joint", size = 4, halign = "center");
}


// ============================================================
// EXAMPLE 8: 3U Wall Pair
// Even larger walls with 9 screws (3 triangles)
// ============================================================
module example_pair_3u()
{
    faceplate_joiner_pair(
        unit_height = 3,
        faceplate_width = faceplate_width,
        spacing = 15,
        fn = detail_fn
    );

    // Hardware note
    %translate([0, -80, 0])
        linear_extrude(1)
            text("3U: 9x M5 screws + 9x M5 hex nuts", size = 3, halign = "center");
}


// ============================================================
// EXAMPLE 9: Wall Only (no faceplate)
// Just the joiner wall for adding to existing designs
// ============================================================
module example_bracket_only()
{
    // Left wall only
    color("SteelBlue")
        translate([-25, 0, 0])
            joiner_wall_addon(unit_height = 1, side = "left", fn = detail_fn);

    // Right wall only
    color("Coral")
        translate([25, 0, 0])
            joiner_wall_addon(unit_height = 1, side = "right", fn = detail_fn);

    // Labels
    %translate([-25, -35, 0])
        linear_extrude(1)
            text("LEFT wall", size = 3, halign = "center");

    %translate([25, -35, 0])
        linear_extrude(1)
            text("RIGHT wall", size = 3, halign = "center");

    %translate([0, -45, 0])
        linear_extrude(1)
            text("Use with union() on existing faceplates", size = 3, halign = "center");
}


// ============================================================
// EXAMPLE 10: All Sizes Comparison
// 1U, 2U, and 3U walls side by side
// ============================================================
module example_size_comparison()
{
    // 1U
    translate([0, 80, 0]) {
        faceplate_joiner_pair(unit_height = 1, faceplate_width = 50, spacing = 10, fn = detail_fn);
        %translate([0, -30, 0])
            linear_extrude(1)
                text("1U (3 screws)", size = 3, halign = "center");
    }

    // 2U
    translate([0, 0, 0]) {
        faceplate_joiner_pair(unit_height = 2, faceplate_width = 50, spacing = 10, fn = detail_fn);
        %translate([0, -55, 0])
            linear_extrude(1)
                text("2U (6 screws)", size = 3, halign = "center");
    }

    // 3U
    translate([0, -100, 0]) {
        faceplate_joiner_pair(unit_height = 3, faceplate_width = 50, spacing = 10, fn = detail_fn);
        %translate([0, -80, 0])
            linear_extrude(1)
                text("3U (9 screws)", size = 3, halign = "center");
    }
}


// ============================================================
// EXAMPLE 11: Print Layout - 1U Pair
// Optimized layout for 3D printing
// ============================================================
module example_print_layout_1u()
{
    // Parts laid flat for printing
    color("SteelBlue")
        translate([-40, 0, 0])
            faceplate_joiner_left(
                unit_height = 1,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = detail_fn
            );

    color("Coral")
        translate([40, 0, 0])
            faceplate_joiner_right(
                unit_height = 1,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = detail_fn
            );

    // Print settings note
    %translate([0, -40, 0])
        linear_extrude(1)
            text("Print Settings: 0.2mm layer, 4+ walls, 20% infill", size = 3, halign = "center");

    %translate([0, -48, 0])
        linear_extrude(1)
            text("No supports needed", size = 3, halign = "center");
}


// ============================================================
// EXAMPLE 12: Print Layout - 2U Pair
// Optimized layout for 3D printing larger walls
// ============================================================
module example_print_layout_2u()
{
    // Parts laid flat for printing
    color("SteelBlue")
        translate([-45, 0, 0])
            faceplate_joiner_left(
                unit_height = 2,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = detail_fn
            );

    color("Coral")
        translate([45, 0, 0])
            faceplate_joiner_right(
                unit_height = 2,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = detail_fn
            );

    // Print settings note
    %translate([0, -60, 0])
        linear_extrude(1)
            text("2U Print Layout", size = 4, halign = "center");

    %translate([0, -70, 0])
        linear_extrude(1)
            text("Hardware: 6x M5x12mm screws + 6x M5 hex nuts", size = 3, halign = "center");
}


// ============================================================
// Render selected example
// ============================================================
if (joiner_example == 1) example_single_left_1u();
else if (joiner_example == 2) example_single_right_1u();
else if (joiner_example == 3) example_pair_1u();
else if (joiner_example == 4) example_assembled_1u();
else if (joiner_example == 5) example_exploded_1u();
else if (joiner_example == 6) example_pair_2u();
else if (joiner_example == 7) example_assembled_2u();
else if (joiner_example == 8) example_pair_3u();
else if (joiner_example == 9) example_bracket_only();
else if (joiner_example == 10) example_size_comparison();
else if (joiner_example == 11) example_print_layout_1u();
else if (joiner_example == 12) example_print_layout_2u();
