/*
 * Rack Template - Easy Rack Mount Creator
 *
 * Use the Customizer panel (View > Customizer) to configure your rack mount.
 * Or copy this file and edit the values directly.
 *
 * For more advanced configurations with multiple devices,
 * see test_rack_generator.scad for examples.
 */

use <components/rack_generator.scad>
include <components/devices.scad>

// ============================================================================
// CUSTOMIZER - Use the panel on the right to configure
// ============================================================================

/* [Rack Settings] */
// Rack height in units (1U = 44.45mm)
rack_u = 2; // [1:1:6]

// Rack ear style
ear_style = "toolless"; // [toolless:Toolless Hooks, fusion:Fusion Style, simple:Simple L-Bracket, none:No Ears]

// Ear vertical position
ear_position = "bottom"; // [bottom:Bottom, top:Top, center:Center]

/* [Device 1] */
// Enable Device 1
device1_enabled = true;

// Select device (or use Custom for manual dimensions)
device1_type = "raspberry_pi_5"; // [raspberry_pi_5:Raspberry Pi 5, raspberry_pi_4:Raspberry Pi 4, intel_nuc_11:Intel NUC 11, intel_nuc_12:Intel NUC 12, minisforum_um890:Minisforum UM890, minisforum_ms01:Minisforum MS-01, beelink_ser5:Beelink SER5, ucg_fiber:Ubiquiti UCG-Fiber, ucg_ultra:Ubiquiti UCG-Ultra, usw_flex_mini:Ubiquiti USW-Flex-Mini, usw_lite_8_poe:Ubiquiti USW-Lite-8-PoE, mikrotik_hex:MikroTik hEX, jetkvm:JetKVM, pikvm_v4_plus:PiKVM V4 Plus, lutron_caseta:Lutron Caseta, hue_bridge:Philips Hue Bridge, hubitat_c8:Hubitat C-8, home_assistant_yellow:HA Yellow, slzb_06:SLZB-06 Zigbee, sonoff_zbdongle_p:Sonoff ZBDongle-P, orange_pi_5:Orange Pi 5, odroid_h3_plus:ODROID-H3+, custom:Custom Device]

// Mount type
device1_mount = "cage"; // [cage:Cage - Honeycomb Vents, cage_rect:Cage - Rectangular Vents, cage_open:Cage - No Front Block, enclosed:Enclosed Box with Rails, angle:Angle Brackets, simple:Simple Box, passthrough:Passthrough Frame, tray:Open Tray, shelf:Ventilated Shelf, storage:Storage Tray, none:Cutout Only]

// Horizontal position (negative=left, positive=right)
device1_x = 0; // [-200:5:200]

// Vertical position (negative=down, positive=up)
device1_y = 0; // [-40:5:40]

/* [Device 1 - Custom Dimensions] */
// Only used when device1_type = "custom"
device1_custom_width = 100; // [20:5:300]
device1_custom_height = 50; // [10:5:100]
device1_custom_depth = 100; // [20:5:200]
device1_custom_name = "My Device";

/* [Device 2 (Optional)] */
// Enable Device 2
device2_enabled = false;

// Select device
device2_type = "slzb_06"; // [raspberry_pi_5:Raspberry Pi 5, raspberry_pi_4:Raspberry Pi 4, intel_nuc_11:Intel NUC 11, intel_nuc_12:Intel NUC 12, minisforum_um890:Minisforum UM890, minisforum_ms01:Minisforum MS-01, beelink_ser5:Beelink SER5, ucg_fiber:Ubiquiti UCG-Fiber, ucg_ultra:Ubiquiti UCG-Ultra, usw_flex_mini:Ubiquiti USW-Flex-Mini, usw_lite_8_poe:Ubiquiti USW-Lite-8-PoE, mikrotik_hex:MikroTik hEX, jetkvm:JetKVM, pikvm_v4_plus:PiKVM V4 Plus, lutron_caseta:Lutron Caseta, hue_bridge:Philips Hue Bridge, hubitat_c8:Hubitat C-8, home_assistant_yellow:HA Yellow, slzb_06:SLZB-06 Zigbee, sonoff_zbdongle_p:Sonoff ZBDongle-P, orange_pi_5:Orange Pi 5, odroid_h3_plus:ODROID-H3+, custom:Custom Device]

// Mount type
device2_mount = "passthrough"; // [cage:Cage - Honeycomb Vents, cage_rect:Cage - Rectangular Vents, cage_open:Cage - No Front Block, enclosed:Enclosed Box with Rails, angle:Angle Brackets, simple:Simple Box, passthrough:Passthrough Frame, tray:Open Tray, shelf:Ventilated Shelf, storage:Storage Tray, none:Cutout Only]

// Horizontal position
device2_x = 100; // [-200:5:200]

// Vertical position
device2_y = 0; // [-40:5:40]

/* [Device 2 - Custom Dimensions] */
device2_custom_width = 50; // [20:5:300]
device2_custom_height = 30; // [10:5:100]
device2_custom_depth = 80; // [20:5:200]
device2_custom_name = "Device 2";

/* [Device 3 (Optional)] */
// Enable Device 3
device3_enabled = false;

// Select device
device3_type = "lutron_caseta"; // [raspberry_pi_5:Raspberry Pi 5, raspberry_pi_4:Raspberry Pi 4, intel_nuc_11:Intel NUC 11, intel_nuc_12:Intel NUC 12, minisforum_um890:Minisforum UM890, minisforum_ms01:Minisforum MS-01, beelink_ser5:Beelink SER5, ucg_fiber:Ubiquiti UCG-Fiber, ucg_ultra:Ubiquiti UCG-Ultra, usw_flex_mini:Ubiquiti USW-Flex-Mini, usw_lite_8_poe:Ubiquiti USW-Lite-8-PoE, mikrotik_hex:MikroTik hEX, jetkvm:JetKVM, pikvm_v4_plus:PiKVM V4 Plus, lutron_caseta:Lutron Caseta, hue_bridge:Philips Hue Bridge, hubitat_c8:Hubitat C-8, home_assistant_yellow:HA Yellow, slzb_06:SLZB-06 Zigbee, sonoff_zbdongle_p:Sonoff ZBDongle-P, orange_pi_5:Orange Pi 5, odroid_h3_plus:ODROID-H3+, custom:Custom Device]

// Mount type
device3_mount = "cage"; // [cage:Cage - Honeycomb Vents, cage_rect:Cage - Rectangular Vents, cage_open:Cage - No Front Block, enclosed:Enclosed Box with Rails, angle:Angle Brackets, simple:Simple Box, passthrough:Passthrough Frame, tray:Open Tray, shelf:Ventilated Shelf, storage:Storage Tray, none:Cutout Only]

// Horizontal position
device3_x = -100; // [-200:5:200]

// Vertical position
device3_y = 0; // [-40:5:40]

/* [Device 3 - Custom Dimensions] */
device3_custom_width = 70; // [20:5:300]
device3_custom_height = 40; // [10:5:100]
device3_custom_depth = 70; // [20:5:200]
device3_custom_name = "Device 3";

/* [Cage Options] */
// Back plate style
back_style = "vent"; // [solid:Solid Back, vent:Ventilated Back, none:No Back (Open)]

// Wall thickness (0=standard 4mm, 1=thick 5mm, 2=extra thick 6mm)
heavy_device = 0; // [0:Standard (4mm), 1:Thick (5mm), 2:Extra Thick (6mm)]

// Device clearance
clearance = 1.0; // [0.5:0.1:2.0]

/* [Ventilation - Honeycomb (for "cage" mount)] */
// Honeycomb hole diameter
hex_size = 8; // [4:1:12]

// Honeycomb wall thickness
hex_wall = 2; // [1:1:4]

/* [Ventilation - Rectangular (for "cage_rect" mount)] */
// Edge margin around cutouts (smaller = larger holes, like Example 7)
cutout_edge = 3; // [2:1:15]

// Corner radius of rectangular cutouts
cutout_radius = 3; // [2:1:15]

/* [Display Options] */
// Show device preview boxes
show_preview = true;

// Show device labels
show_labels = true;

/* [Hidden] */
$fn = 32;

// ============================================================================
// BUILD DEVICE LIST FROM CUSTOMIZER
// ============================================================================

// Helper to build device entry
function make_device(enabled, dtype, mount, x, y, cw, ch, cd, cname) =
    enabled ? (
        dtype == "custom"
            ? ["custom", x, y, mount, [cw, ch, cd], cname]
            : [dtype, x, y, mount]
    ) : [];

// Build the device list
_dev1 = make_device(device1_enabled, device1_type, device1_mount, device1_x, device1_y,
                    device1_custom_width, device1_custom_height, device1_custom_depth, device1_custom_name);
_dev2 = make_device(device2_enabled, device2_type, device2_mount, device2_x, device2_y,
                    device2_custom_width, device2_custom_height, device2_custom_depth, device2_custom_name);
_dev3 = make_device(device3_enabled, device3_type, device3_mount, device3_x, device3_y,
                    device3_custom_width, device3_custom_height, device3_custom_depth, device3_custom_name);

// Combine enabled devices into list
devices = [
    if (len(_dev1) > 0) _dev1,
    if (len(_dev2) > 0) _dev2,
    if (len(_dev3) > 0) _dev3,
];

// ============================================================================
// RENDER
// ============================================================================

rack_faceplate(
    rack_u = rack_u,
    devices = devices,
    ear_style = ear_style,
    ear_position = ear_position,
    back_style = back_style,
    heavy_device = heavy_device,
    clearance = clearance,
    hex_diameter = hex_size,
    hex_wall = hex_wall,
    cutout_edge = cutout_edge,
    cutout_radius = cutout_radius,
    show_preview = show_preview,
    show_labels = show_labels
);

// ============================================================================
// INFO
// ============================================================================

echo("=== Rack Template ===");
echo(str("Rack: ", rack_u, "U (", rack_u * 44.45, "mm)"));
echo(str("Devices: ", len(devices)));
echo(str("Back: ", back_style));
