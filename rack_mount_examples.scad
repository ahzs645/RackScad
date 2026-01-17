/*
 * Rack Scad - Rack Mount Type Examples
 * Based on rackstack-main implementation
 *
 * This file demonstrates all four rack mount types.
 * Use the Customizer to select examples and adjust parameters.
 */

use <rack_mounts/tray.scad>
use <rack_mounts/enclosed_box.scad>
use <rack_mounts/patch_panel.scad>
use <rack_mounts/angle_bracket.scad>

/* [Example Selection] */

// Select example to display
mount_example = 4; // [1:Tray - Basic, 2:Tray - With Mount Points, 3:Tray - Ventilated, 4:Enclosed Box - Assembled, 5:Enclosed Box - Split, 6:Patch Panel - Type 2, 7:Patch Panel - Type 1, 8:Patch Panel - Mixed, 9:Angle Brackets - Assembled, 10:Angle Brackets - Split, 11:All Types Overview]

/* [Box Dimensions] */
box_width = 159;   // [80:220]
box_height = 27;   // [15:80]
box_depth = 101;   // [60:200]

/* [Tray Settings] */
tray_width = 140;  // [80:200]
tray_depth = 100;  // [60:200]
tray_u = 2;        // [1:6]

/* [Patch Panel] */
patch_ports = 6;   // [4:12]

/* [Bracket Settings] */
bracket_u = 3;     // [2:6]

/* [Hide] */
_dummy = 0;


// ============================================================
// EXAMPLE 1: Basic Tray
// ============================================================
module example_tray_basic() {
    color("SteelBlue")
    rack_tray(
        u = tray_u,
        trayWidth = tray_width,
        trayDepth = tray_depth,
        frontLipHeight = 12,
        backLipHeight = 8
    );
}

// ============================================================
// EXAMPLE 2: Tray with Mount Points
// ============================================================
module example_tray_mount_points() {
    mp_x = 15;
    mp_y = 20;

    color("SteelBlue")
    rack_tray(
        u = tray_u,
        trayWidth = tray_width,
        trayDepth = tray_depth,
        mountPoints = [
            [mp_x, mp_y],
            [tray_width - mp_x, mp_y],
            [mp_x, tray_depth - mp_y],
            [tray_width - mp_x, tray_depth - mp_y]
        ],
        mountPointType = "M3",
        mountPointElevation = 5
    );
}

// ============================================================
// EXAMPLE 3: Ventilated Tray
// ============================================================
module example_tray_ventilated() {
    color("SteelBlue")
    rack_tray(
        u = tray_u,
        trayWidth = tray_width,
        trayDepth = tray_depth,
        frontLipHeight = 15,
        backLipHeight = 10,
        sideLipHeight = 8,
        ventilation = true,
        ventHoleSize = 5
    );
}

// ============================================================
// EXAMPLE 4: Enclosed Box - Assembled
// Based on rackstack enclosed-box system
// ============================================================
module example_enclosed_box_assembled() {
    enclosed_box_system(
        boxWidth = box_width,
        boxHeight = box_height,
        boxDepth = box_depth,
        railDefaultThickness = 1.5,
        railSideThickness = 3,
        frontPlateThickness = 3,
        zOrientation = "middle",
        visualize = true,
        splitForPrint = false
    );
}

// ============================================================
// EXAMPLE 5: Enclosed Box - Split for Printing
// ============================================================
module example_enclosed_box_split() {
    enclosed_box_system(
        boxWidth = box_width,
        boxHeight = box_height,
        boxDepth = box_depth,
        railDefaultThickness = 1.5,
        railSideThickness = 3,
        frontPlateThickness = 3,
        zOrientation = "middle",
        visualize = false,
        splitForPrint = true
    );

    // Labels
    if ($preview) {
        %translate([7, -20, 0])
        linear_extrude(0.5) text("Left Rail", size = 4, halign = "center");

        %translate([50, -20, 0])
        linear_extrude(0.5) text("Right Rail", size = 4, halign = "center");

        %translate([90, -70, 0])
        linear_extrude(0.5) text("Front Plate", size = 4, halign = "center");
    }
}

// ============================================================
// EXAMPLE 6: Patch Panel - Type 2 (Cleaner)
// ============================================================
module example_patch_panel_type2() {
    slots = [for (i = [0:patch_ports-1]) 2];

    color("SteelBlue")
    patch_panel(
        slots = slots,
        u = 2,
        plateThickness = 3,
        centered = true
    );

    if ($preview) {
        %translate([95, -15, 0])
        linear_extrude(0.5)
        text(str(patch_ports, " x Type 2 Keystones"), size = 4, halign = "center");
    }
}

// ============================================================
// EXAMPLE 7: Patch Panel - Type 1 (Original)
// ============================================================
module example_patch_panel_type1() {
    slots = [for (i = [0:patch_ports-1]) 1];

    color("Coral")
    patch_panel(
        slots = slots,
        u = 2,
        plateThickness = 3,
        centered = true
    );

    if ($preview) {
        %translate([95, -15, 0])
        linear_extrude(0.5)
        text(str(patch_ports, " x Type 1 Keystones"), size = 4, halign = "center");
    }
}

// ============================================================
// EXAMPLE 8: Patch Panel - Mixed Slots
// ============================================================
module example_patch_panel_mixed() {
    // Type1, Type2, Type2, Thick Blank, Type2, Type2, Type1
    slots = [1, 2, 2, 5, 2, 2, 1];

    color("LightGreen")
    patch_panel(
        slots = slots,
        u = 2,
        plateThickness = 3,
        centered = true
    );

    if ($preview) {
        %translate([95, -15, 0])
        linear_extrude(0.5)
        text("T1, T2, T2, Blank, T2, T2, T1", size = 3.5, halign = "center");
    }
}

// ============================================================
// EXAMPLE 9: Angle Brackets - Assembled
// ============================================================
module example_angle_brackets_assembled() {
    angle_brackets(
        boxWidth = box_width,
        boxDepth = box_depth,
        u = bracket_u,
        thickness = 3,
        sideVent = false,
        visualize = true,
        splitForPrint = false
    );
}

// ============================================================
// EXAMPLE 10: Angle Brackets - Split for Printing
// ============================================================
module example_angle_brackets_split() {
    angle_brackets(
        boxWidth = box_width,
        boxDepth = box_depth,
        u = bracket_u,
        thickness = 3,
        sideVent = false,
        visualize = false,
        splitForPrint = true
    );

    // Universal mount plate
    color("Gold")
    translate([0, box_depth + 20, 0])
    universal_mount_plate(
        width = box_width,
        depth = 60,
        holeSpacing = 20,
        holeType = "M3"
    );
}

// ============================================================
// EXAMPLE 11: All Types Overview
// ============================================================
module example_all_types() {
    spacing_y = 150;

    // Tray
    color("SteelBlue")
    translate([0, 0, 0])
    rack_tray(u = 2, trayWidth = 120, trayDepth = 80, ventilation = true);

    if ($preview) {
        %translate([60, -20, 0])
        linear_extrude(0.5) text("1. Tray", size = 6, halign = "center");
    }

    // Enclosed Box
    translate([0, spacing_y, 0])
    enclosed_box_system(
        boxWidth = 120,
        boxHeight = 25,
        boxDepth = 80,
        visualize = true,
        splitForPrint = false
    );

    if ($preview) {
        %translate([60, spacing_y - 20, 0])
        linear_extrude(0.5) text("2. Enclosed Box", size = 6, halign = "center");
    }

    // Patch Panel
    color("Coral")
    translate([0, spacing_y * 2, 0])
    patch_panel(slots = [2, 2, 2, 2, 2], u = 2);

    if ($preview) {
        %translate([95, spacing_y * 2 - 20, 0])
        linear_extrude(0.5) text("3. Patch Panel", size = 6, halign = "center");
    }

    // Angle Brackets
    translate([0, spacing_y * 3, 0])
    angle_brackets(
        boxWidth = 120,
        boxDepth = 80,
        u = 3,
        visualize = true
    );

    if ($preview) {
        %translate([60, spacing_y * 3 - 20, 0])
        linear_extrude(0.5) text("4. Angle Brackets", size = 6, halign = "center");
    }
}


// ============================================================
// Render selected example
// ============================================================
if (mount_example == 1) example_tray_basic();
else if (mount_example == 2) example_tray_mount_points();
else if (mount_example == 3) example_tray_ventilated();
else if (mount_example == 4) example_enclosed_box_assembled();
else if (mount_example == 5) example_enclosed_box_split();
else if (mount_example == 6) example_patch_panel_type2();
else if (mount_example == 7) example_patch_panel_type1();
else if (mount_example == 8) example_patch_panel_mixed();
else if (mount_example == 9) example_angle_brackets_assembled();
else if (mount_example == 10) example_angle_brackets_split();
else if (mount_example == 11) example_all_types();
