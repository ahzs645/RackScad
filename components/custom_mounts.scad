/*
 * Rack Scad - Custom Mount Components
 * Modular Component: Custom device mounting structures
 *
 * This module contains specialized mount types that don't fit into
 * the standard cage_structure or enclosed_box categories.
 *
 * Mount Types:
 *   - passthrough_frame: Thin frame for pass-through devices (keystones, dongles)
 *   - angle_bracket_cage: L-shaped side brackets with ventilation
 *   - simple_box_cage: Basic box enclosure without ventilation
 *   - usb_dongle_holder: Holder for USB stick-style devices
 *
 * License: CC BY-NC-SA 4.0
 */

// ============================================================================
// CONSTANTS
// ============================================================================

_CM_EPS = 0.01;
_CM_DEFAULT_WALL = 3;
_CM_DEFAULT_CLEARANCE = 1.0;

// ============================================================================
// PASSTHROUGH FRAME
// Creates a thin frame for pass-through style mounts (keystones, dongles, etc.)
// The device sticks through and is held by a thin frame
//
// Parameters:
//   device_w - Device face width
//   device_h - Device face height
//   frame_depth - How deep the frame extends (default 8mm for keystone-style)
//   wall - Frame wall thickness
//   clearance - Extra clearance around device opening
// ============================================================================

module passthrough_frame(
    device_w,
    device_h,
    frame_depth = 8,
    wall = _CM_DEFAULT_WALL,
    clearance = _CM_DEFAULT_CLEARANCE
) {
    slot_w = device_w + clearance;
    slot_h = device_h + clearance;
    holder_w = slot_w + 2 * wall;
    holder_h = slot_h + 2 * wall;

    difference() {
        // Outer frame
        cube([holder_w, holder_h, frame_depth]);

        // Inner opening
        translate([wall, wall, -_CM_EPS])
        cube([slot_w, slot_h, frame_depth + 2 * _CM_EPS]);
    }
}

// Positioned version - places frame at offset from center
module passthrough_frame_positioned(
    offset_x,
    offset_y,
    device_w,
    device_h,
    frame_depth = 8,
    wall = _CM_DEFAULT_WALL,
    clearance = _CM_DEFAULT_CLEARANCE,
    plate_thick = 4
) {
    slot_w = device_w + clearance;
    slot_h = device_h + clearance;
    holder_w = slot_w + 2 * wall;
    holder_h = slot_h + 2 * wall;

    translate([offset_x - holder_w/2, offset_y - holder_h/2, plate_thick])
    passthrough_frame(device_w, device_h, frame_depth, wall, clearance);
}

// ============================================================================
// ANGLE BRACKET CAGE
// L-shaped side brackets that cradle the device from below and sides
// Good for devices that need side ventilation or easy top access
//
// Parameters:
//   device_w - Device width
//   device_h - Device height
//   device_d - Device depth
//   wall - Wall thickness
//   max_depth - Maximum cage depth (will be clamped)
//   vent_slot_width - Width of ventilation slots
//   vent_slot_spacing - Spacing between ventilation slots
// ============================================================================

module angle_bracket_cage(
    device_w,
    device_h,
    device_d,
    wall = _CM_DEFAULT_WALL,
    max_depth = 140,
    vent_slot_width = 10,
    vent_slot_spacing = 20
) {
    actual_depth = min(max_depth, device_d + 20);

    // Left L-bracket
    difference() {
        union() {
            // Bottom plate
            cube([wall + 10, actual_depth, wall]);
            // Side wall
            cube([wall, actual_depth, device_h + 2 * wall]);
        }
        // Ventilation slots
        for (dy = [15 : vent_slot_spacing : actual_depth - 15]) {
            translate([-_CM_EPS, dy, device_h/4])
            cube([wall + 2*_CM_EPS, vent_slot_width, device_h/2]);
        }
    }

    // Right L-bracket
    translate([device_w + wall, 0, 0])
    mirror([1, 0, 0])
    difference() {
        union() {
            cube([wall + 10, actual_depth, wall]);
            cube([wall, actual_depth, device_h + 2 * wall]);
        }
        for (dy = [15 : vent_slot_spacing : actual_depth - 15]) {
            translate([-_CM_EPS, dy, device_h/4])
            cube([wall + 2*_CM_EPS, vent_slot_width, device_h/2]);
        }
    }
}

// Positioned version - places cage at offset from center (corner-based)
module angle_bracket_cage_positioned(
    offset_x,
    offset_y,
    device_w,
    device_h,
    device_d,
    wall = _CM_DEFAULT_WALL,
    max_depth = 140,
    plate_thick = 4
) {
    translate([offset_x - device_w/2, offset_y - device_h/2, plate_thick])
    angle_bracket_cage(device_w, device_h, device_d, wall, max_depth);
}

// ============================================================================
// SIMPLE BOX CAGE
// Basic rectangular enclosure without ventilation
// Good for devices that need full enclosure or dust protection
//
// Parameters:
//   device_w - Device width
//   device_h - Device height
//   device_d - Device depth
//   wall - Wall thickness
//   max_depth - Maximum cage depth (will be clamped)
// ============================================================================

module simple_box_cage(
    device_w,
    device_h,
    device_d,
    wall = _CM_DEFAULT_WALL,
    max_depth = 140
) {
    actual_depth = min(max_depth, device_d + 15);

    difference() {
        // Outer shell
        translate([-(device_w/2 + wall), -(device_h/2 + wall), 0])
        cube([device_w + 2*wall, device_h + 2*wall, actual_depth]);

        // Inner cavity
        translate([-device_w/2, -device_h/2, -_CM_EPS])
        cube([device_w, device_h, actual_depth + 2*_CM_EPS]);
    }
}

// Positioned version - places cage at offset from center
module simple_box_cage_positioned(
    offset_x,
    offset_y,
    device_w,
    device_h,
    device_d,
    wall = _CM_DEFAULT_WALL,
    max_depth = 140,
    plate_thick = 4
) {
    translate([offset_x, offset_y, plate_thick])
    simple_box_cage(device_w, device_h, device_d, wall, max_depth);
}

// ============================================================================
// USB DONGLE HOLDER
// Specialized holder for USB stick-style devices (Zigbee coordinators, etc.)
// Creates a channel with retention clips
//
// Parameters:
//   device_w - Device width
//   device_h - Device height (thickness)
//   device_d - Device length/depth
//   wall - Wall thickness
//   clip_height - Height of retention clips
//   clip_inset - How far clips extend inward
// ============================================================================

module usb_dongle_holder(
    device_w,
    device_h,
    device_d,
    wall = 2,
    clip_height = 3,
    clip_inset = 1.5
) {
    channel_w = device_w + 1;  // 1mm clearance
    channel_h = device_h + 0.5;  // 0.5mm clearance

    difference() {
        // Main body
        cube([channel_w + 2*wall, device_d + wall, channel_h + wall]);

        // Channel for device
        translate([wall, -_CM_EPS, wall])
        cube([channel_w, device_d + _CM_EPS, channel_h + _CM_EPS]);
    }

    // Retention clips (flexible tabs)
    for (x = [wall + 2, wall + channel_w - 2 - clip_inset]) {
        translate([x, device_d * 0.3, wall + channel_h - 0.5])
        cube([clip_inset, 3, 0.5 + clip_height]);

        translate([x, device_d * 0.7, wall + channel_h - 0.5])
        cube([clip_inset, 3, 0.5 + clip_height]);
    }
}

// Positioned version
module usb_dongle_holder_positioned(
    offset_x,
    offset_y,
    device_w,
    device_h,
    device_d,
    wall = 2,
    plate_thick = 4
) {
    holder_w = device_w + 1 + 2*wall;
    holder_h = device_h + 0.5 + wall;

    translate([offset_x - holder_w/2, offset_y - holder_h/2, plate_thick])
    usb_dongle_holder(device_w, device_h, device_d, wall);
}

// ============================================================================
// TRAY MOUNT
// Open tray for devices that sit on top rather than being enclosed
// Good for devices with irregular shapes or that need easy access
//
// Parameters:
//   device_w - Device width
//   device_h - Device height (used for lip height)
//   device_d - Device depth
//   wall - Wall/floor thickness
//   lip_height - Height of retaining lip (default: device_h * 0.3)
//   lip_style - "full" = all sides, "sides" = left/right only, "back" = back only
// ============================================================================

module tray_mount(
    device_w,
    device_h,
    device_d,
    wall = _CM_DEFAULT_WALL,
    lip_height = 0,  // 0 = auto-calculate
    lip_style = "sides"
) {
    actual_lip = lip_height > 0 ? lip_height : device_h * 0.3;
    tray_w = device_w + 2;
    tray_d = device_d + 5;

    // Base tray floor
    cube([tray_w + 2*wall, tray_d + wall, wall]);

    // Side lips
    if (lip_style == "full" || lip_style == "sides") {
        // Left lip
        cube([wall, tray_d + wall, wall + actual_lip]);
        // Right lip
        translate([tray_w + wall, 0, 0])
        cube([wall, tray_d + wall, wall + actual_lip]);
    }

    // Back lip
    if (lip_style == "full" || lip_style == "back") {
        translate([0, tray_d, 0])
        cube([tray_w + 2*wall, wall, wall + actual_lip]);
    }

    // Front lip (only for full)
    if (lip_style == "full") {
        cube([tray_w + 2*wall, wall, wall + actual_lip * 0.5]);
    }
}

// Positioned version
module tray_mount_positioned(
    offset_x,
    offset_y,
    device_w,
    device_h,
    device_d,
    wall = _CM_DEFAULT_WALL,
    lip_height = 0,
    lip_style = "sides",
    plate_thick = 4
) {
    tray_w = device_w + 2 + 2*wall;
    tray_d = device_d + 5 + wall;

    translate([offset_x - tray_w/2, offset_y - (device_h/2), plate_thick])
    tray_mount(device_w, device_h, device_d, wall, lip_height, lip_style);
}

// ============================================================================
// CLIP MOUNT
// Spring clip style mount for thin/flat devices
// Creates opposing clips that flex to hold the device
//
// Parameters:
//   device_w - Device width
//   device_h - Device height/thickness
//   clip_depth - How deep the clips extend
//   wall - Base wall thickness
//   clip_gap - Gap between clips (should be slightly less than device_h)
// ============================================================================

module clip_mount(
    device_w,
    device_h,
    clip_depth = 15,
    wall = 2,
    clip_gap = 0  // 0 = auto-calculate
) {
    actual_gap = clip_gap > 0 ? clip_gap : device_h - 0.5;
    base_w = device_w + 10;
    clip_thickness = 1.5;

    // Base
    cube([base_w, clip_depth, wall]);

    // Bottom clips
    for (x = [3, base_w - 3 - clip_thickness]) {
        translate([x, 0, wall])
        cube([clip_thickness, clip_depth, 2]);

        // Angled entry
        translate([x, 0, wall + 2])
        rotate([-15, 0, 0])
        cube([clip_thickness, clip_depth * 0.6, 1]);
    }

    // Top clips
    for (x = [3, base_w - 3 - clip_thickness]) {
        translate([x, 0, wall + actual_gap + 2])
        cube([clip_thickness, clip_depth, 2]);

        // Angled entry
        translate([x, 0, wall + actual_gap + 4])
        rotate([15, 0, 0])
        cube([clip_thickness, clip_depth * 0.6, 1]);
    }
}

// ============================================================================
// GENERIC CUSTOM MOUNT DISPATCHER
// Use this to call any custom mount by type string
//
// Parameters:
//   mount_type - String identifier for mount type
//   offset_x, offset_y - Position offsets
//   device_w, device_h, device_d - Device dimensions
//   plate_thick - Faceplate thickness
//   params - Optional parameters array [wall, clearance, ...]
// ============================================================================

module custom_mount(
    mount_type,
    offset_x,
    offset_y,
    device_w,
    device_h,
    device_d,
    plate_thick = 4,
    wall = _CM_DEFAULT_WALL,
    clearance = _CM_DEFAULT_CLEARANCE,
    frame_depth = 8
) {
    if (mount_type == "passthrough" || mount_type == "keystone") {
        passthrough_frame_positioned(
            offset_x, offset_y,
            device_w, device_h,
            frame_depth, wall, clearance, plate_thick
        );
    }
    else if (mount_type == "angle" || mount_type == "angle_bracket") {
        angle_bracket_cage_positioned(
            offset_x, offset_y,
            device_w, device_h, device_d,
            wall, 140, plate_thick
        );
    }
    else if (mount_type == "simple" || mount_type == "box") {
        simple_box_cage_positioned(
            offset_x, offset_y,
            device_w, device_h, device_d,
            wall, 140, plate_thick
        );
    }
    else if (mount_type == "dongle" || mount_type == "usb") {
        usb_dongle_holder_positioned(
            offset_x, offset_y,
            device_w, device_h, device_d,
            wall, plate_thick
        );
    }
    else if (mount_type == "tray") {
        tray_mount_positioned(
            offset_x, offset_y,
            device_w, device_h, device_d,
            wall, 0, "sides", plate_thick
        );
    }
    // Add more mount types here as needed
}
