/*
 * Homelab 2U Rack Mount - Modular Faceplate Design
 * Split into Left and Right halves for 3D printing
 *
 * Uses actual library components:
 *   - cage_structure() from components/cage.scad
 *   - angle_brackets() from rack_mounts/angle_bracket.scad
 *   - keystone modules from components/keystone.scad
 *
 * Devices:
 *   Left Half:  Minisforum UM890 Pro
 *   Right Half: UCG-Fiber + JetKVM + Lutron Caseta + SLZB-06
 *
 * For 19" EIA-310 rack (2U = 88.9mm)
 */

use <components/utilities.scad>
use <components/faceplate.scad>
use <components/cage.scad>
use <components/keystone.scad>
use <components/joiners.scad>
use <rack_mounts/angle_bracket.scad>
include <rack_mounts/common.scad>
use <rack_mounts/enclosed_box.scad>

// ============================================================================
// CUSTOMIZER CONFIGURATION
// ============================================================================

/* [Render Options] */
render_part = "both"; // [left:Left Half, right:Right Half, both:Both Halves (Assembly View), left_print:Left Half (Print), right_print:Right Half (Print)]

// Show device preview boxes
show_previews = true;

// Show device labels on faceplate
show_labels = true;

/* [Device 1: Minisforum UM890 Pro] */
minisforum_enabled = true;
minisforum_mount_type = "cage"; // [cage:Cage with Honeycomb, cage_rect:Cage with Slots, enclosed:Enclosed Box (Side Rails), angle:Angle Brackets, simple:Simple Box, none:Cutout Only]
minisforum_face_w = 128;  // Width (side to side)
minisforum_face_h = 52;   // Height
minisforum_depth = 126;   // Depth to back

/* [Device 2: UCG-Fiber] */
ucg_enabled = true;
ucg_mount_type = "cage"; // [cage:Cage with Honeycomb, cage_rect:Cage with Slots, enclosed:Enclosed Box (Side Rails), angle:Angle Brackets, simple:Simple Box, none:Cutout Only]
ucg_face_w = 213;
ucg_face_h = 30;
ucg_depth = 128;

/* [Device 3: JetKVM] */
jetkvm_enabled = true;
jetkvm_mount_type = "cage"; // [cage:Cage with Honeycomb, cage_rect:Cage with Slots, enclosed:Enclosed Box (Side Rails), angle:Angle Brackets, simple:Simple Box, none:Cutout Only]
jetkvm_face_w = 43;
jetkvm_face_h = 31;
jetkvm_depth = 60;

/* [Device 4: Lutron Caseta] */
lutron_enabled = true;
lutron_mount_type = "cage"; // [cage:Cage with Honeycomb, cage_rect:Cage with Slots, enclosed:Enclosed Box (Side Rails), angle:Angle Brackets, simple:Simple Box, none:Cutout Only]
lutron_face_w = 70;
lutron_face_h = 31;
lutron_depth = 70;

/* [Device 5: SLZB-06 Zigbee] */
slzb_enabled = true;
slzb_mount_type = "keystone"; // [keystone:Keystone Pass-through, simple:Simple Box, none:Cutout Only]
slzb_slot_w = 23.4;
slzb_slot_h = 20.0;
slzb_holder_depth = 8.2;  // Thin keystone frame

/* [Cage Settings] */
// Device clearance inside cage (mm)
device_clearance = 1.0;

// Wall thickness level (0=standard 4mm, 1=thick 5mm, 2=extra 6mm)
heavy_device = 0; // [0:Standard, 1:Thick, 2:Extra Thick]

// Honeycomb hole diameter (for Cage with Honeycomb)
hex_diameter = 8; // [4:12]

// Honeycomb wall thickness (for Cage with Honeycomb)
hex_wall = 2; // [1:4]

// Add extra center support for wide devices
extra_support = false;

/* [Panel Settings] */
// Faceplate thickness (mm)
plate_thick = 4;

// Corner radius for faceplate
corner_radius = 5;

/* [Hidden] */
$fn = 32;
eps = 0.01;

// ============================================================================
// 19" RACK CONSTANTS (EIA-310)
// ============================================================================

EIA_U = 44.45;
rack_u = 2;
rack_height = rack_u * EIA_U;  // 88.9mm

// Rack mounting
rack_mount_hole_spacing = 450.85;  // 17.75"
faceplate_width = 482.6;           // 19"
ear_width = (faceplate_width - rack_mount_hole_spacing) / 2 + 8;

// Internal panel width (between ears)
panel_width = rack_mount_hole_spacing;

// Split point - asymmetric for UCG-Fiber
left_width = 180;
right_width = panel_width - left_width;

// ============================================================================
// DEVICE POSITIONING (center-based for cage_structure compatibility)
// ============================================================================

// Left half - Minisforum centered
minisforum_offset_x = 0;  // Centered in left half
minisforum_offset_y = 0;  // Vertically centered

// Right half positions
// UCG at bottom
ucg_offset_x = 0;
ucg_offset_y = -15;  // Lower portion

// Upper row (JetKVM, Lutron, SLZB above UCG)
upper_row_y = 20;  // Upper portion

jetkvm_offset_x = -80;
lutron_offset_x = -10;
slzb_offset_x = 60;

// ============================================================================
// MAIN MODULES
// ============================================================================

module left_half(for_print = false) {
    if (for_print) {
        rotate([90, 0, 0])
        _left_geometry();
    } else {
        _left_geometry();
    }
}

module right_half(for_print = false) {
    pos = for_print ? [left_width + 20, 0, 0] : [left_width, 0, 0];

    translate(pos)
    if (for_print) {
        rotate([90, 0, 0])
        _right_geometry();
    } else {
        _right_geometry();
    }
}

// ============================================================================
// LEFT HALF GEOMETRY - Minisforum
// ============================================================================

module _left_geometry() {
    center_x = left_width / 2;
    center_z = rack_height / 2;

    difference() {
        union() {
            // Faceplate base - rounded on ear side, flat on joint side
            _faceplate_left(left_width, rack_height, plate_thick);

            // Left rack ear
            _rack_ear_left();

            // Joining wall (uses library joiner component)
            // Left half gets joiner with screw holes - wall ends at joint edge (X=left_width)
            // rotate([-90,0,0]) flips wall to extend behind faceplate (+Y)
            translate([left_width, 0, rack_height/2])
            rotate([-90, 0, 0])
            joiner_wall_addon(unit_height = rack_u, side = "left");

            // Device mount (extends behind faceplate in +Y direction)
            // Cage reinforcing block starts at Z=2.5 in cage coords, which overlaps into faceplate
            if (minisforum_enabled && minisforum_mount_type != "none") {
                translate([center_x, 0, center_z])
                rotate([-90, 0, 0])
                _device_mount_structure(
                    minisforum_face_w, minisforum_face_h, minisforum_depth,
                    minisforum_offset_x, -minisforum_offset_y,
                    minisforum_mount_type
                );
            }
        }

        // Device cutout in faceplate
        if (minisforum_enabled) {
            translate([center_x + minisforum_offset_x, -eps, center_z + minisforum_offset_y])
            _device_cutout(minisforum_face_w, minisforum_face_h);
        }

        // Joining bolt holes
        _left_join_holes();
    }
}

// ============================================================================
// RIGHT HALF GEOMETRY - UCG + JetKVM + Lutron + SLZB
// ============================================================================

module _right_geometry() {
    center_x = right_width / 2;
    center_z = rack_height / 2;

    difference() {
        union() {
            // Faceplate base - flat on joint side, rounded on ear side
            _faceplate_right(right_width, rack_height, plate_thick);

            // Right rack ear
            _rack_ear_right();

            // Joining wall (uses library joiner component)
            // Right half gets joiner with nut pockets - wall starts at joint edge (X=0)
            // rotate([-90,0,0]) flips wall to extend behind faceplate (+Y)
            translate([0, 0, rack_height/2])
            rotate([-90, 0, 0])
            joiner_wall_addon(unit_height = rack_u, side = "right");

            // UCG-Fiber mount (bottom)
            // Cage reinforcing block starts at Z=2.5 in cage coords, which overlaps into faceplate
            if (ucg_enabled && ucg_mount_type != "none") {
                translate([center_x, 0, center_z])
                rotate([-90, 0, 0])
                _device_mount_structure(
                    ucg_face_w, ucg_face_h, ucg_depth,
                    ucg_offset_x, -ucg_offset_y,
                    ucg_mount_type
                );
            }

            // JetKVM mount (upper left)
            if (jetkvm_enabled && jetkvm_mount_type != "none") {
                translate([center_x, 0, center_z])
                rotate([-90, 0, 0])
                _device_mount_structure(
                    jetkvm_face_w, jetkvm_face_h, jetkvm_depth,
                    jetkvm_offset_x, -upper_row_y,
                    jetkvm_mount_type
                );
            }

            // Lutron mount (upper center)
            if (lutron_enabled && lutron_mount_type != "none") {
                translate([center_x, 0, center_z])
                rotate([-90, 0, 0])
                _device_mount_structure(
                    lutron_face_w, lutron_face_h, lutron_depth,
                    lutron_offset_x, -upper_row_y,
                    lutron_mount_type
                );
            }

            // SLZB keystone mount (upper right)
            if (slzb_enabled && slzb_mount_type != "none") {
                translate([center_x, 0, center_z])
                rotate([-90, 0, 0])
                _slzb_mount_structure(slzb_offset_x, -upper_row_y);
            }
        }

        // Device cutouts in faceplate
        if (ucg_enabled) {
            translate([center_x + ucg_offset_x, -eps, center_z + ucg_offset_y])
            _device_cutout(ucg_face_w, ucg_face_h);
        }
        if (jetkvm_enabled) {
            translate([center_x + jetkvm_offset_x, -eps, center_z + upper_row_y])
            _device_cutout(jetkvm_face_w, jetkvm_face_h);
        }
        if (lutron_enabled) {
            translate([center_x + lutron_offset_x, -eps, center_z + upper_row_y])
            _device_cutout(lutron_face_w, lutron_face_h);
        }
        if (slzb_enabled) {
            translate([center_x + slzb_offset_x, -eps, center_z + upper_row_y])
            _device_cutout(slzb_slot_w, slzb_slot_h);
        }

        // Joining bolt holes
        _right_join_holes();
    }
}

// ============================================================================
// DEVICE MOUNT STRUCTURE - Uses library cage_structure()
// ============================================================================

module _device_mount_structure(dev_w, dev_h, dev_d, offset_x, offset_y, mount_type) {
    if (mount_type == "cage") {
        // Cage with honeycomb ventilation (Example 8 style)
        cage_structure(
            offset_x = offset_x,
            offset_y = offset_y,
            device_width = dev_w,
            device_height = dev_h,
            device_depth = dev_d,
            device_clearance = device_clearance,
            heavy_device = heavy_device,
            extra_support = extra_support,
            cutout_edge = 5,
            cutout_radius = 5,
            is_split = false,
            use_honeycomb = true,
            hex_dia = hex_diameter,
            hex_wall = hex_wall
        );
    } else if (mount_type == "cage_rect") {
        // Cage with rectangular slot ventilation (Example 7 style)
        cage_structure(
            offset_x = offset_x,
            offset_y = offset_y,
            device_width = dev_w,
            device_height = dev_h,
            device_depth = dev_d,
            device_clearance = device_clearance,
            heavy_device = heavy_device,
            extra_support = extra_support,
            cutout_edge = 5,
            cutout_radius = 5,
            is_split = false,
            use_honeycomb = false
        );
    } else if (mount_type == "enclosed") {
        // Enclosed box with side rails (Example 27 style)
        // Uses library side_support_rail_base from rack_mounts/enclosed_box.scad
        translate([offset_x, offset_y, plate_thick])
        _enclosed_box_rails_library(dev_w, dev_h, dev_d);
    } else if (mount_type == "angle") {
        // Use angle bracket style from rack_mounts/angle_bracket.scad
        translate([offset_x - dev_w/2, offset_y - dev_h/2, plate_thick])
        _angle_bracket_cage(dev_w, dev_h, dev_d);
    } else if (mount_type == "simple") {
        // Simple box cage
        translate([offset_x, offset_y, plate_thick])
        _simple_box_cage(dev_w, dev_h, dev_d);
    }
}

// Enclosed box style - uses library side_support_rail_base from enclosed_box.scad
// Matches Example 4 "Enclosed Box - Assembled" from rack_mount_examples.scad
module _enclosed_box_rails_library(dev_w, dev_h, dev_d) {
    rail_thickness = 1.5;
    rail_side_thick = 3;

    // Calculate rail dimensions using library functions
    u = findU(dev_h, rail_thickness);
    rail_bottom = railBottomThickness(u, dev_h, rail_thickness, "middle");

    // The side_support_rail_base creates rails in library coords:
    //   - X: rail side thickness direction
    //   - Y: depth (extends backward)
    //   - Z: height (extends upward)
    //
    // Our cage coords after main rotate([-90,0,0]):
    //   - X: horizontal (unchanged)
    //   - Y: becomes -Z (vertical down in rack)
    //   - Z: becomes Y (depth behind faceplate in rack)
    //
    // We need rail's Y (depth) → our Z, rail's Z (height) → our -Y
    // This is achieved with rotate([90, 0, 0])

    // Left rail
    translate([-dev_w/2 - rail_side_thick, dev_h/2 + rail_bottom, 0])
    rotate([90, 0, 0])
    side_support_rail_base(
        top = true,
        recess = false,
        defaultThickness = rail_thickness,
        supportedZ = dev_h,
        supportedY = dev_d,
        supportedX = dev_w,
        zOrientation = "middle",
        railSideThickness = rail_side_thick,
        sideVent = true
    );

    // Right rail (mirrored)
    translate([dev_w/2, dev_h/2 + rail_bottom, 0])
    rotate([90, 0, 0])
    mirror([1, 0, 0])
    side_support_rail_base(
        top = true,
        recess = false,
        defaultThickness = rail_thickness,
        supportedZ = dev_h,
        supportedY = dev_d,
        supportedX = dev_w,
        zOrientation = "middle",
        railSideThickness = rail_side_thick,
        sideVent = true
    );
}

// Angle bracket style cage (L-shaped sides)
module _angle_bracket_cage(dev_w, dev_h, dev_d) {
    wall = 3;
    actual_depth = min(140, dev_d + 20);

    // Left L-bracket
    difference() {
        union() {
            // Bottom plate
            cube([wall + 10, actual_depth, wall]);
            // Side wall
            cube([wall, actual_depth, dev_h + 2 * wall]);
        }
        // Ventilation slots
        for (dy = [15 : 20 : actual_depth - 15]) {
            translate([-eps, dy, dev_h/4])
            cube([wall + 2*eps, 10, dev_h/2]);
        }
    }

    // Right L-bracket
    translate([dev_w + wall, 0, 0])
    mirror([1, 0, 0])
    difference() {
        union() {
            cube([wall + 10, actual_depth, wall]);
            cube([wall, actual_depth, dev_h + 2 * wall]);
        }
        for (dy = [15 : 20 : actual_depth - 15]) {
            translate([-eps, dy, dev_h/4])
            cube([wall + 2*eps, 10, dev_h/2]);
        }
    }
}

// Simple box cage (no ventilation)
module _simple_box_cage(dev_w, dev_h, dev_d) {
    wall = 3;
    actual_depth = min(140, dev_d + 15);

    difference() {
        // Outer shell
        translate([-(dev_w/2 + wall), -(dev_h/2 + wall), 0])
        cube([dev_w + 2*wall, dev_h + 2*wall, actual_depth]);

        // Inner cavity
        translate([-dev_w/2, -dev_h/2, -eps])
        cube([dev_w, dev_h, actual_depth + 2*eps]);
    }
}

// SLZB keystone mount
module _slzb_mount_structure(offset_x, offset_y) {
    if (slzb_mount_type == "keystone") {
        slot_w = slzb_slot_w + device_clearance;
        slot_h = slzb_slot_h + device_clearance;
        wall = 3;

        // Simple thin frame - 8.2mm deep
        holder_w = slot_w + 2 * wall;
        holder_h = slot_h + 2 * wall;

        translate([offset_x - holder_w/2, offset_y - holder_h/2, plate_thick])
        difference() {
            cube([holder_w, holder_h, slzb_holder_depth]);
            translate([wall, wall, -eps])
            cube([slot_w, slot_h, slzb_holder_depth + 2*eps]);
        }
    } else if (slzb_mount_type == "simple") {
        translate([offset_x, offset_y, plate_thick])
        _simple_box_cage(slzb_slot_w, slzb_slot_h, 20);
    }
}

// ============================================================================
// FACEPLATE AND CUTOUTS
// ============================================================================

// Left faceplate - rounded on left (ear side), flat on right (joint side)
module _faceplate_left(width, height, thickness) {
    hull() {
        // Left side - rounded corners
        translate([corner_radius, 0, corner_radius])
        rotate([-90, 0, 0])
        cylinder(r = corner_radius, h = thickness, $fn = 32);

        translate([corner_radius, 0, height - corner_radius])
        rotate([-90, 0, 0])
        cylinder(r = corner_radius, h = thickness, $fn = 32);

        // Right side - flat edge (joint side)
        translate([width - eps, 0, 0])
        cube([eps, thickness, height]);
    }
}

// Right faceplate - flat on left (joint side), rounded on right (ear side)
module _faceplate_right(width, height, thickness) {
    hull() {
        // Left side - flat edge (joint side)
        cube([eps, thickness, height]);

        // Right side - rounded corners
        translate([width - corner_radius, 0, corner_radius])
        rotate([-90, 0, 0])
        cylinder(r = corner_radius, h = thickness, $fn = 32);

        translate([width - corner_radius, 0, height - corner_radius])
        rotate([-90, 0, 0])
        cylinder(r = corner_radius, h = thickness, $fn = 32);
    }
}

module _device_cutout(w, h) {
    // Center-based cutout
    translate([-w/2 - device_clearance/2, 0, -h/2 - device_clearance/2])
    cube([w + device_clearance, plate_thick + 2*eps, h + device_clearance]);
}

// ============================================================================
// RACK EARS
// ============================================================================

module _rack_ear_left() {
    translate([-ear_width, 0, 0])
    difference() {
        cube([ear_width + 5, plate_thick + 3, rack_height]);
        _ear_holes(ear_width / 2);
    }
}

module _rack_ear_right() {
    translate([right_width - 5, 0, 0])
    difference() {
        cube([ear_width + 5, plate_thick + 3, rack_height]);
        _ear_holes(ear_width / 2 + 5);
    }
}

module _ear_holes(x_pos) {
    for (u = [0 : rack_u - 1]) {
        for (offset = [6.35, 22.225, 38.1]) {
            translate([x_pos, -eps, u * EIA_U + offset])
            rotate([-90, 0, 0])
            cylinder(d = 7.5, h = plate_thick + 6, $fn = 32);
        }
    }
}

// ============================================================================
// JOINING HARDWARE
// ============================================================================

// Join holes are now built into the joiner_bracket_addon components
// Left side has M5 clearance holes, right side has hex nut pockets
module _left_join_holes() {
    // No longer needed - joiner bracket has built-in holes
}

module _right_join_holes() {
    // No longer needed - joiner bracket has built-in hex nut pockets
}

// ============================================================================
// DEVICE PREVIEW BOXES
// ============================================================================

module _preview_devices() {
    if ($preview && show_previews) {
        left_cx = left_width / 2;
        left_cz = rack_height / 2;
        right_cx = left_width + right_width / 2;
        right_cz = rack_height / 2;

        // Minisforum - left side (Blue)
        if (minisforum_enabled) {
            color("SteelBlue", 0.7)
            translate([left_cx + minisforum_offset_x - minisforum_face_w/2,
                       plate_thick + 5,
                       left_cz + minisforum_offset_y - minisforum_face_h/2])
            cube([minisforum_face_w, minisforum_depth - 10, minisforum_face_h]);
        }

        // UCG-Fiber - right side, bottom (Dark Gray)
        if (ucg_enabled) {
            color("DarkSlateGray", 0.7)
            translate([right_cx + ucg_offset_x - ucg_face_w/2,
                       plate_thick + 5,
                       right_cz + ucg_offset_y - ucg_face_h/2])
            cube([ucg_face_w, ucg_depth - 5, ucg_face_h]);
        }

        // JetKVM - right side, upper (Coral)
        if (jetkvm_enabled) {
            color("Coral", 0.7)
            translate([right_cx + jetkvm_offset_x - jetkvm_face_w/2,
                       plate_thick + 5,
                       right_cz + upper_row_y - jetkvm_face_h/2])
            cube([jetkvm_face_w, jetkvm_depth - 5, jetkvm_face_h]);
        }

        // Lutron - right side, upper (Gold)
        if (lutron_enabled) {
            color("Gold", 0.7)
            translate([right_cx + lutron_offset_x - lutron_face_w/2,
                       plate_thick + 5,
                       right_cz + upper_row_y - lutron_face_h/2])
            cube([lutron_face_w, lutron_depth - 5, lutron_face_h]);
        }

        // SLZB-06 - right side, upper (Green)
        if (slzb_enabled) {
            color("LimeGreen", 0.7)
            translate([right_cx + slzb_offset_x - slzb_slot_w/2,
                       plate_thick + 10,
                       right_cz + upper_row_y - slzb_slot_h/2])
            cube([slzb_slot_w, 80, slzb_slot_h]);
        }
    }
}

// ============================================================================
// DEVICE LABELS
// ============================================================================

module _preview_labels() {
    if ($preview && show_labels) {
        left_cx = left_width / 2;
        left_cz = rack_height / 2;
        right_cx = left_width + right_width / 2;
        right_cz = rack_height / 2;

        // Minisforum
        if (minisforum_enabled) {
            color("White")
            translate([left_cx + minisforum_offset_x, -0.5, left_cz + minisforum_offset_y])
            rotate([90, 0, 0])
            linear_extrude(0.5)
            text("Minisforum", size = 6, halign = "center", valign = "center");
        }

        // UCG-Fiber
        if (ucg_enabled) {
            color("White")
            translate([right_cx + ucg_offset_x, -0.5, right_cz + ucg_offset_y])
            rotate([90, 0, 0])
            linear_extrude(0.5)
            text("UCG-Fiber", size = 5, halign = "center", valign = "center");
        }

        // JetKVM
        if (jetkvm_enabled) {
            color("White")
            translate([right_cx + jetkvm_offset_x, -0.5, right_cz + upper_row_y])
            rotate([90, 0, 0])
            linear_extrude(0.5)
            text("JetKVM", size = 4, halign = "center", valign = "center");
        }

        // Lutron
        if (lutron_enabled) {
            color("White")
            translate([right_cx + lutron_offset_x, -0.5, right_cz + upper_row_y])
            rotate([90, 0, 0])
            linear_extrude(0.5)
            text("Lutron", size = 4, halign = "center", valign = "center");
        }

        // SLZB
        if (slzb_enabled) {
            color("White")
            translate([right_cx + slzb_offset_x, -0.5, right_cz + upper_row_y])
            rotate([90, 0, 0])
            linear_extrude(0.5)
            text("SLZB", size = 4, halign = "center", valign = "center");
        }
    }
}

// ============================================================================
// RENDER
// ============================================================================

if (render_part == "left") {
    color("SteelBlue") left_half(false);
    _preview_devices();
    _preview_labels();
}
else if (render_part == "right") {
    color("Coral") right_half(false);
    _preview_devices();
    _preview_labels();
}
else if (render_part == "both") {
    color("SteelBlue") left_half(false);
    color("Coral") right_half(false);
    _preview_devices();
    _preview_labels();
}
else if (render_part == "left_print") {
    left_half(true);
}
else if (render_part == "right_print") {
    right_half(true);
}

// Info output
echo(str("=== Homelab 2U Rack Mount ==="));
echo(str("Left half: ", left_width, "mm"));
echo(str("Right half: ", right_width, "mm"));
echo(str("Total height: ", rack_height, "mm (", rack_u, "U)"));
echo(str("Mount types: Minisforum=", minisforum_mount_type,
         ", UCG=", ucg_mount_type,
         ", JetKVM=", jetkvm_mount_type,
         ", Lutron=", lutron_mount_type,
         ", SLZB=", slzb_mount_type));
