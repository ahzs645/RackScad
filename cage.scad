/**
 * Rack Shelf Library - Cage Generator
 *
 * Parametric rack cage generator for mounting devices in standard racks.
 * Inspired by CageMaker PRCG, adapted for this library.
 *
 * Author: Generated with Claude
 * License: MIT
 *
 * Usage:
 *   use <cage.scad>
 *   rack_cage(device_width=100, device_height=40, device_depth=80);
 */

use <utils.scad>
use <patterns.scad>
use <mounting.scad>

/* [Device Dimensions] */
// Device width (left to right) in mm
device_width = 100; // [15:300]

// Device height (top to bottom) in mm
device_height = 40; // [15:150]

// Device depth (front to back) in mm
device_depth = 80; // [15:250]

// Clearance around device in mm
device_clearance = 1; // [0:0.5:5]

/* [Rack Configuration] */
// Rack type
cage_rack_type = "19inch"; // [19inch:19" Standard, 10inch:10" Mini, 10inch_half:10" Half-Width, 19inch_half:19" Half-Width, 19inch_third:19" Third-Width]

// Allow half-unit heights (non-standard)
allow_half_units = false;

// Horizontal offset from center (mm)
horizontal_offset = 0; // [-200:200]

// Vertical offset from center (mm)
vertical_offset = 0; // [-100:100]

/* [Structure] */
// Wall thickness level (0=standard, 1=thick, 2=extra thick)
wall_level = 0; // [0:2]

// Add center support divider
center_support = false;

// Corner radius for cutouts
cutout_radius = 3; // [0:10]

// Reinforce faceplate edges
reinforce_faceplate = false;

/* [Ventilation] */
// Ventilation pattern for sides
side_vent_pattern = "slots_v"; // [none, honeycomb, grid, slots, slots_v, circles]

// Ventilation pattern for top/bottom
top_vent_pattern = "slots"; // [none, honeycomb, grid, slots, slots_v, circles]

// Ventilation pattern for back
back_vent_pattern = "honeycomb"; // [none, honeycomb, grid, slots, slots_v, circles]

/* [Faceplate Modifications] */
// Modification type 1
mod1_type = "none"; // [none, keystone_1x1, keystone_2x1, keystone_3x1, keystone_1x2, fan_30, fan_40, fan_60, fan_80, cable_slot]

// Modification 1 horizontal offset
mod1_offset = 0; // [-150:150]

// Modification type 2
mod2_type = "none"; // [none, keystone_1x1, keystone_2x1, keystone_3x1, keystone_1x2, fan_30, fan_40, fan_60, fan_80, cable_slot]

// Modification 2 horizontal offset
mod2_offset = 0; // [-150:150]

/* [Split Cage] */
// Split cage into two halves for printing
split_cage = false;

// Show only specific half (0=both, 1=left, 2=right)
show_half = 0; // [0:2]

// Add alignment pin holes
alignment_pins = true;

/* [Hidden] */
$fn = $preview ? 32 : 64;

// Wall thickness based on level
function wall_thickness(level) = 4 + level;

// EIA-310 standard rack unit height
RACK_UNIT = 44.45;

// Faceplate screw hole positions (from bottom of 1U)
FACEPLATE_HOLES = [6.35, 22.225, 38.1];

/**
 * Get cage width for rack type
 */
function cage_rack_width(rack_type) =
    rack_type == "19inch" ? in_to_mm(17.75) :
    rack_type == "10inch" ? in_to_mm(8.75) :
    rack_type == "10inch_half" ? in_to_mm(4.375) :
    rack_type == "19inch_half" ? in_to_mm(8.875) :
    rack_type == "19inch_third" ? in_to_mm(5.917) :
    in_to_mm(17.75);

/**
 * Calculate required rack units for device height
 */
function calc_units(dev_height, wall_level, half_units) =
    let(total = dev_height + 16 + wall_level * 2)
    half_units ?
        ceil(total / (RACK_UNIT / 2)) * 0.5 :
        ceil(total / RACK_UNIT);

/**
 * Rounded corner plate (4 corners)
 */
module rounded_plate(width, height, thickness, radius) {
    if (radius > 0) {
        linear_extrude(thickness)
            offset(r=radius)
                offset(delta=-radius)
                    square([width, height], center=true);
    } else {
        cube([width, height, thickness], center=true);
    }
}

/**
 * Fan grill pattern
 */
module fan_grill(size) {
    ring_width = 2;
    bar_width = 3;

    difference() {
        circle(d=size - 4);

        // Concentric rings
        for (r = [17 : 10 : size]) {
            if (r < size - 4) {
                difference() {
                    circle(d=r);
                    circle(d=r - ring_width);
                }
            }
        }

        // Cross bars
        for (angle = [0, 60, 120]) {
            rotate([0, 0, angle])
                square([size, bar_width], center=true);
        }
    }
}

/**
 * Fan mounting holes
 */
module fan_mount_holes(size, thickness) {
    // Hole centers and diameters by fan size
    centers = size == 30 ? 24 :
              size == 40 ? 32 :
              size == 60 ? 50 :
              size == 80 ? 71.5 : 32;

    hole_dia = size <= 40 ? 3.2 : 4.2;

    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * centers/2, y * centers/2, 0])
                cylinder(h=thickness + 0.2, d=hole_dia, center=true);
        }
    }
}

/**
 * Faceplate modification cutout
 */
module faceplate_mod(mod_type, thickness) {
    if (mod_type == "keystone_1x1") {
        keystone_cutout(thickness);
    } else if (mod_type == "keystone_2x1") {
        for (i = [-0.5, 0.5]) translate([i * 19, 0, 0]) keystone_cutout(thickness);
    } else if (mod_type == "keystone_3x1") {
        for (i = [-1, 0, 1]) translate([i * 19, 0, 0]) keystone_cutout(thickness);
    } else if (mod_type == "keystone_1x2") {
        for (j = [-0.5, 0.5]) translate([0, j * 20, 0]) keystone_cutout(thickness);
    } else if (mod_type == "fan_30") {
        translate([0, 0, -thickness/2 - 0.1])
            linear_extrude(thickness + 0.2) fan_grill(30);
        fan_mount_holes(30, thickness);
    } else if (mod_type == "fan_40") {
        translate([0, 0, -thickness/2 - 0.1])
            linear_extrude(thickness + 0.2) fan_grill(40);
        fan_mount_holes(40, thickness);
    } else if (mod_type == "fan_60") {
        translate([0, 0, -thickness/2 - 0.1])
            linear_extrude(thickness + 0.2) fan_grill(60);
        fan_mount_holes(60, thickness);
    } else if (mod_type == "fan_80") {
        translate([0, 0, -thickness/2 - 0.1])
            linear_extrude(thickness + 0.2) fan_grill(80);
        fan_mount_holes(80, thickness);
    } else if (mod_type == "cable_slot") {
        cable_slot(30, 12, thickness);
    }
}

/**
 * Main rack cage module
 */
module rack_cage(
    dev_width = 100,
    dev_height = 40,
    dev_depth = 80,
    clearance = 1,
    rack_type = "19inch",
    wall_level = 0,
    half_units = false,
    h_offset = 0,
    v_offset = 0,
    add_center_support = false,
    corner_r = 3,
    reinforce = false,
    side_vent = "slots_v",
    top_vent = "slots",
    back_vent = "honeycomb",
    mod1 = "none",
    mod1_off = 0,
    mod2 = "none",
    mod2_off = 0
) {
    // Calculate dimensions
    wall = wall_thickness(wall_level);
    rack_width = cage_rack_width(rack_type);
    units = calc_units(dev_height, wall_level, half_units);
    faceplate_height = units * RACK_UNIT - 1.6;  // Standard gap

    // Cavity dimensions (device + clearance)
    cavity_w = dev_width + clearance * 2;
    cavity_h = dev_height + clearance * 2;
    cavity_d = dev_depth + clearance * 2;

    // Cage outer dimensions
    cage_w = cavity_w + wall * 2;
    cage_h = cavity_h + wall * 2;
    cage_d = cavity_d + wall;

    // Ear width
    ear_width = in_to_mm(0.625);

    // Vent cutout margins
    vent_margin = 8;

    difference() {
        union() {
            // Faceplate
            translate([h_offset, v_offset, 0])
            difference() {
                // Main faceplate
                translate([0, 0, wall/2])
                    rounded_plate(rack_width, faceplate_height, wall, corner_r);

                // Faceplate cutout for device access
                translate([0, 0, wall/2])
                    cube([cavity_w - 10, cavity_h - 10, wall + 0.2], center=true);
            }

            // Cage body (behind faceplate)
            translate([h_offset, v_offset, wall + cage_d/2])
            difference() {
                // Outer shell
                cube([cage_w, cage_h, cage_d], center=true);

                // Device cavity
                translate([0, 0, wall/2])
                    cube([cavity_w, cavity_h, cavity_d + 0.1], center=true);

                // Side ventilation cutouts
                if (side_vent != "none" && cavity_d > 40) {
                    vent_h = cavity_h - vent_margin * 2;
                    vent_d = cavity_d - vent_margin * 2 - wall;

                    // Left side
                    translate([-cage_w/2, 0, 0])
                        rotate([90, 0, 90])
                            ventilation_pattern(side_vent, vent_d, vent_h, wall + 0.2);

                    // Right side
                    translate([cage_w/2, 0, 0])
                        rotate([90, 0, 90])
                            ventilation_pattern(side_vent, vent_d, vent_h, wall + 0.2);
                }

                // Top/bottom ventilation cutouts
                if (top_vent != "none" && cavity_d > 40) {
                    vent_w = cavity_w - vent_margin * 2;
                    vent_d = cavity_d - vent_margin * 2 - wall;

                    // Top
                    translate([0, cage_h/2, 0])
                        rotate([90, 0, 0])
                            ventilation_pattern(top_vent, vent_w, vent_d, wall + 0.2);

                    // Bottom
                    translate([0, -cage_h/2, 0])
                        rotate([90, 0, 0])
                            ventilation_pattern(top_vent, vent_w, vent_d, wall + 0.2);
                }

                // Back ventilation
                if (back_vent != "none") {
                    vent_w = cavity_w - vent_margin * 2;
                    vent_h = cavity_h - vent_margin * 2;

                    translate([0, 0, cage_d/2])
                        ventilation_pattern(back_vent, vent_w, vent_h, wall + 0.2);
                }
            }

            // Center support divider
            if (add_center_support && cavity_d > 60) {
                translate([h_offset, v_offset, wall + cage_d/2])
                    cube([wall, cage_h, cage_d], center=true);
            }

            // Mounting ears
            // Left ear
            translate([-rack_width/2 - ear_width/2, v_offset, wall/2])
                _cage_ear(ear_width, faceplate_height, wall, cage_d, false);

            // Right ear
            translate([rack_width/2 + ear_width/2, v_offset, wall/2])
                _cage_ear(ear_width, faceplate_height, wall, cage_d, true);

            // Faceplate reinforcement
            if (reinforce) {
                // Top edge brace
                translate([h_offset, v_offset + cage_h/2 - wall/2, wall])
                    cube([cage_w, wall, 10], center=true);
                // Bottom edge brace
                translate([h_offset, v_offset - cage_h/2 + wall/2, wall])
                    cube([cage_w, wall, 10], center=true);
            }
        }

        // Faceplate modifications
        if (mod1 != "none") {
            translate([h_offset + mod1_off, v_offset, wall/2])
                faceplate_mod(mod1, wall + 0.2);
        }
        if (mod2 != "none") {
            translate([h_offset + mod2_off, v_offset, wall/2])
                faceplate_mod(mod2, wall + 0.2);
        }
    }
}

/**
 * Cage mounting ear (internal)
 */
module _cage_ear(width, height, thickness, depth, is_right) {
    hole_dia = 6.4;  // M6/10-32 slot

    difference() {
        union() {
            // Ear plate
            cube([width, height, thickness], center=true);

            // Connection flange
            translate([is_right ? -width/2 + thickness/2 : width/2 - thickness/2, 0, depth/2])
                cube([thickness, height, depth], center=true);
        }

        // Mounting holes (slotted)
        for (h = FACEPLATE_HOLES) {
            if (h < height/2) {
                translate([0, -height/2 + h, 0])
                    hull() {
                        cylinder(h=thickness + 0.2, d=hole_dia, center=true);
                        translate([0, 3, 0])
                            cylinder(h=thickness + 0.2, d=hole_dia, center=true);
                    }
            }
        }
    }
}

/**
 * Split cage - left half
 */
module rack_cage_left_half(
    dev_width = 100,
    dev_height = 40,
    dev_depth = 80,
    clearance = 1,
    rack_type = "19inch",
    wall_level = 0,
    add_pins = true
) {
    wall = wall_thickness(wall_level);
    cage_d = dev_depth + clearance * 2 + wall;

    difference() {
        rack_cage(
            dev_width = dev_width,
            dev_height = dev_height,
            dev_depth = dev_depth,
            clearance = clearance,
            rack_type = rack_type,
            wall_level = wall_level
        );

        // Cut right half
        translate([500, 0, cage_d/2 + wall])
            cube([1000, 1000, 1000], center=true);
    }

    // Add mating tabs
    cage_h = dev_height + clearance * 2 + wall * 2;
    translate([0, cage_h/4, wall + cage_d - wall/2])
        cube([8, 8, wall], center=true);
    translate([0, -cage_h/4, wall + cage_d - wall/2])
        cube([8, 8, wall], center=true);

    // Alignment pin holes
    if (add_pins) {
        translate([0, cage_h/4, wall + cage_d/2])
            cylinder(h=5, d=1.75, center=true);
        translate([0, -cage_h/4, wall + cage_d/2])
            cylinder(h=5, d=1.75, center=true);
    }
}

/**
 * Split cage - right half
 */
module rack_cage_right_half(
    dev_width = 100,
    dev_height = 40,
    dev_depth = 80,
    clearance = 1,
    rack_type = "19inch",
    wall_level = 0,
    add_pins = true
) {
    wall = wall_thickness(wall_level);
    cage_d = dev_depth + clearance * 2 + wall;
    cage_h = dev_height + clearance * 2 + wall * 2;

    difference() {
        union() {
            difference() {
                rack_cage(
                    dev_width = dev_width,
                    dev_height = dev_height,
                    dev_depth = dev_depth,
                    clearance = clearance,
                    rack_type = rack_type,
                    wall_level = wall_level
                );

                // Cut left half
                translate([-500, 0, cage_d/2 + wall])
                    cube([1000, 1000, 1000], center=true);
            }
        }

        // Tab slots
        translate([0, cage_h/4, wall + cage_d - wall/2])
            cube([8.4, 8.4, wall + 0.2], center=true);
        translate([0, -cage_h/4, wall + cage_d - wall/2])
            cube([8.4, 8.4, wall + 0.2], center=true);

        // Alignment pin holes
        if (add_pins) {
            translate([0, cage_h/4, wall + cage_d/2])
                cylinder(h=6, d=1.85, center=true);
            translate([0, -cage_h/4, wall + cage_d/2])
                cylinder(h=6, d=1.85, center=true);
        }
    }
}

/**
 * Multi-device cage - stack multiple devices vertically
 */
module rack_cage_multi(
    devices,  // Array of [width, height, depth] for each device
    rack_type = "19inch",
    wall_level = 0,
    spacing = 5
) {
    wall = wall_thickness(wall_level);

    // Calculate total height
    total_h = len(devices) > 0 ?
        [for (i = [0 : len(devices) - 1])
            devices[i][1] + (i < len(devices) - 1 ? spacing : 0)
        ] : [0];

    // Generate stacked cages
    y_offset = 0;
    for (i = [0 : len(devices) - 1]) {
        dev = devices[i];
        translate([0, y_offset, 0])
            rack_cage(
                dev_width = dev[0],
                dev_height = dev[1],
                dev_depth = dev[2],
                rack_type = rack_type,
                wall_level = wall_level
            );
    }
}

// Preview with Customizer settings
if ($preview) {
    if (split_cage) {
        if (show_half == 0 || show_half == 1) {
            translate([-device_width/2 - 20, 0, 0])
                rack_cage_left_half(
                    dev_width = device_width,
                    dev_height = device_height,
                    dev_depth = device_depth,
                    clearance = device_clearance,
                    rack_type = cage_rack_type,
                    wall_level = wall_level,
                    add_pins = alignment_pins
                );
        }
        if (show_half == 0 || show_half == 2) {
            translate([device_width/2 + 20, 0, 0])
                rack_cage_right_half(
                    dev_width = device_width,
                    dev_height = device_height,
                    dev_depth = device_depth,
                    clearance = device_clearance,
                    rack_type = cage_rack_type,
                    wall_level = wall_level,
                    add_pins = alignment_pins
                );
        }
    } else {
        rack_cage(
            dev_width = device_width,
            dev_height = device_height,
            dev_depth = device_depth,
            clearance = device_clearance,
            rack_type = cage_rack_type,
            wall_level = wall_level,
            half_units = allow_half_units,
            h_offset = horizontal_offset,
            v_offset = vertical_offset,
            add_center_support = center_support,
            corner_r = cutout_radius,
            reinforce = reinforce_faceplate,
            side_vent = side_vent_pattern,
            top_vent = top_vent_pattern,
            back_vent = back_vent_pattern,
            mod1 = mod1_type,
            mod1_off = mod1_offset,
            mod2 = mod2_type,
            mod2_off = mod2_offset
        );
    }
}
