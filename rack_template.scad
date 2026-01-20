/*
 * Rack Template - Copy this file to create a new rack mount
 *
 * Instructions:
 * 1. Copy this file and rename it (e.g., "my_network_rack.scad")
 * 2. Edit the devices list below with your devices
 * 3. Adjust rack_u for your desired height
 * 4. Render and print!
 *
 * Device Format:
 *   [device_id, offset_x, offset_y, mount_type]
 *
 * Available device_ids: (see components/devices.scad for full list)
 *   Mini PCs: "minisforum_um890", "intel_nuc_11", "beelink_ser5", etc.
 *   Network:  "ucg_fiber", "usw_flex_mini", "mikrotik_hex", etc.
 *   KVM:      "jetkvm", "pikvm_v4_plus", etc.
 *   Smart:    "lutron_caseta", "hue_bridge", "hubitat_c8", etc.
 *   Zigbee:   "slzb_06", "sonoff_zbdongle_p", "conbee_ii", etc.
 *   SBCs:     "raspberry_pi_5", "orange_pi_5", etc.
 *
 * Custom devices:
 *   ["custom", offset_x, offset_y, mount_type, [width, height, depth], "Name"]
 *
 * Mount types:
 *   "cage"       - Full cage with honeycomb vents (best for most devices)
 *   "cage_rect"  - Full cage with rectangular vents
 *   "enclosed"   - Enclosed box with side rails
 *   "angle"      - L-bracket style (good for access)
 *   "simple"     - Basic box (no vents)
 *   "passthrough"- Thin frame (for dongles/keystones)
 *   "tray"       - Open tray
 *   "none"       - Cutout only
 *
 * Positioning:
 *   offset_x: negative = left, positive = right (from center)
 *   offset_y: negative = down, positive = up (from center)
 */

use <components/rack_generator.scad>
include <components/devices.scad>

// ============================================================================
// CONFIGURATION - Edit these values
// ============================================================================

// Rack height in units (1U = 44.45mm)
rack_u = 2;

// Your devices - EDIT THIS LIST
devices = [
    // Example: Raspberry Pi centered
    ["raspberry_pi_5", 0, 0, "cage"],

    // Add more devices here...
    // ["device_id", x_offset, y_offset, "mount_type"],
];

// ============================================================================
// RENDER - Usually don't need to change below this line
// ============================================================================

/* [Options] */
show_preview = true;
show_labels = true;
ear_style = "toolless"; // [toolless, fusion, simple, none]

rack_faceplate(
    rack_u = rack_u,
    devices = devices,
    ear_style = ear_style,
    show_preview = show_preview,
    show_labels = show_labels
);
