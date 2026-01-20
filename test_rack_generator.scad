/*
 * Test Rack - Rack Generator Demo
 * Demonstrates the new rack_generator module for easy rack creation
 *
 * This file shows how to create a 2U rack mount using the declarative
 * device list approach instead of manually positioning everything.
 *
 * Compare this to homelab_2u_rack.scad to see how much simpler it is!
 */

use <components/rack_generator.scad>
include <components/devices.scad>
include <components/constants.scad>

// ============================================================================
// CUSTOMIZER CONFIGURATION
// ============================================================================

/* [Render Options] */
render_mode = "both"; // [single:Single Piece, both:Split - Both Halves, left:Split - Left Only, right:Split - Right Only, left_print:Split - Left (Print), right_print:Split - Right (Print)]

// Show device preview boxes
show_previews = true;

// Show device labels
show_labels = true;

/* [Rack Settings] */
// Rack units
rack_units = 2; // [1:6]

// Faceplate thickness
plate_thickness = 4; // [3:6]

// Corner radius (0 for square)
corners = 0; // [0:10]

// Rack ear style
ear_style = "toolless"; // [toolless:Toolless Hooks, fusion:Fusion Style, simple:Simple L-Bracket, none:No Ears]

// Ear position
ear_position = "bottom"; // [bottom:Bottom, top:Top, center:Center]

/* [Cage Settings] */
// Device clearance
clearance = 1.0; // [0.5:0.1:2.0]

// Honeycomb hole size
hex_size = 8; // [4:12]

// Honeycomb wall thickness
hex_wall = 2; // [1:4]

// Back plate style
back_style = "vent"; // [solid:Solid Back, vent:Ventilated Back, none:No Back (Open)]

/* [Split Settings] */
// Split position (0 = auto center)
split_position = 180;

/* [Hidden] */
$fn = 32;

// ============================================================================
// DEVICE CONFIGURATION
// This is the key part - just define your devices as a list!
//
// Format: [device_id, offset_x, offset_y, mount_type]
//    or   ["custom", offset_x, offset_y, mount_type, [width, height, depth], "Name"]
//
// Mount types: "cage", "cage_rect", "enclosed", "angle", "simple",
//              "passthrough", "tray", "shelf", "storage", "none"
// ============================================================================

// Example 1: Single piece rack with multiple devices
single_piece_devices = [
    // Center a Raspberry Pi 5
    ["raspberry_pi_5", -150, 10, "cage"],

    // Intel NUC to the right
    ["intel_nuc_11", 0, 0, "cage"],

    // Small USB dongle using passthrough mount
    ["slzb_06", 130, 15, "passthrough"],

    // Custom device with manual dimensions
    ["custom", 130, -15, "simple", [30, 25, 50], "Custom Box"],
];

// Example with shelf and storage tray (uncomment to try)
// shelf_example_devices = [
//     // Ventilated shelf for a switch (uses width x depth)
//     ["custom", 0, 0, "shelf", [200, 120, 30], "Switch Shelf"],
//
//     // Storage tray for cables/tools (height becomes wall height)
//     ["custom", -150, 0, "storage", [80, 100, 25], "Cable Tray"],
// ];

// Example 2: Split rack - Left half devices
left_half_devices = [
    // Minisforum centered in left half
    ["minisforum_um890", 0, 0, "cage"],
];

// Example 3: Split rack - Right half devices
right_half_devices = [
    // UCG-Fiber at bottom of right half
    ["ucg_fiber", 0, -15, "cage"],

    // JetKVM upper left
    ["jetkvm", -80, 20, "cage"],

    // Lutron upper center
    ["lutron_caseta", -10, 20, "cage"],

    // SLZB as passthrough upper right
    ["slzb_06", 60, 20, "passthrough"],
];

// ============================================================================
// RENDER
// ============================================================================

if (render_mode == "single") {
    // Single piece faceplate
    rack_faceplate(
        rack_u = rack_units,
        devices = single_piece_devices,
        plate_thick = plate_thickness,
        corner_radius = corners,
        ear_style = ear_style,
        ear_thickness = 2.9,
        ear_position = ear_position,
        clearance = clearance,
        hex_diameter = hex_size,
        hex_wall = hex_wall,
        back_style = back_style,
        show_preview = show_previews,
        show_labels = show_labels
    );
}
else {
    // Split faceplate (two halves that join together)
    rack_faceplate_split(
        rack_u = rack_units,
        left_devices = left_half_devices,
        right_devices = right_half_devices,
        split_x = split_position,
        plate_thick = plate_thickness,
        corner_radius = corners,
        ear_style = ear_style,
        ear_thickness = 2.9,
        ear_position = ear_position,
        clearance = clearance,
        hex_diameter = hex_size,
        hex_wall = hex_wall,
        back_style = back_style,
        show_preview = show_previews,
        show_labels = show_labels,
        render_part = render_mode
    );
}

// ============================================================================
// INFO OUTPUT
// ============================================================================

echo("=== Rack Generator Test ===");
echo(str("Mode: ", render_mode));
echo(str("Rack Units: ", rack_units, "U (", rack_height(rack_units), "mm)"));
echo(str("Ear Style: ", ear_style));

if (render_mode == "single") {
    echo(str("Devices: ", len(single_piece_devices)));
} else {
    echo(str("Left devices: ", len(left_half_devices)));
    echo(str("Right devices: ", len(right_half_devices)));
    echo(str("Split at: ", split_position, "mm"));
}
