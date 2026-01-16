/**
 * Rack Shelf Library - Mounting Components
 *
 * Standoffs, screw holes, cable management, and mounting hardware
 *
 * Author: Generated with Claude
 * License: MIT
 */

use <utils.scad>

/* [Mounting Parameters] */
$fn = $preview ? 32 : 64;

/* [Common Screw Sizes] */
// M3 screw dimensions
M3_HOLE = 3.2;
M3_HEAD = 5.5;
M3_HEAD_DEPTH = 2;

// M4 screw dimensions
M4_HOLE = 4.2;
M4_HEAD = 7;
M4_HEAD_DEPTH = 2.5;

// M5 screw dimensions
M5_HOLE = 5.2;
M5_HEAD = 8.5;
M5_HEAD_DEPTH = 3;

// #6-32 screw (common for SBC)
N6_32_HOLE = 3.5;
N6_32_HEAD = 6.35;
N6_32_HEAD_DEPTH = 2;

/**
 * Simple standoff
 *
 * @param height Standoff height
 * @param outer_dia Outer diameter
 * @param hole_dia Screw hole diameter
 * @param shape "round", "hex", or "square"
 */
module standoff(height, outer_dia=6, hole_dia=3.2, shape="round") {
    difference() {
        if (shape == "round") {
            cylinder(h=height, d=outer_dia);
        } else if (shape == "hex") {
            cylinder(h=height, d=outer_dia, $fn=6);
        } else if (shape == "square") {
            translate([-outer_dia/2, -outer_dia/2, 0])
                cube([outer_dia, outer_dia, height]);
        }
        translate([0, 0, -0.1])
            cylinder(h=height + 0.2, d=hole_dia);
    }
}

/**
 * Standoff with base flange for better adhesion
 *
 * @param height Standoff height (not including base)
 * @param outer_dia Outer diameter
 * @param hole_dia Screw hole diameter
 * @param base_dia Base flange diameter
 * @param base_height Base flange height
 */
module standoff_flanged(height, outer_dia=6, hole_dia=3.2, base_dia=10, base_height=1.5) {
    difference() {
        union() {
            cylinder(h=base_height, d=base_dia);
            translate([0, 0, base_height])
                cylinder(h=height, d=outer_dia);
        }
        translate([0, 0, -0.1])
            cylinder(h=height + base_height + 0.2, d=hole_dia);
    }
}

/**
 * Array of standoffs for common SBC mounting patterns
 *
 * @param pattern Board pattern name or custom array of [x, y] positions
 * @param height Standoff height
 * @param hole_dia Screw hole diameter
 */
module standoff_array(pattern, height=5, hole_dia=2.75) {
    // Common SBC mounting hole patterns (mm)
    positions =
        pattern == "rpi" ? [[3.5, 3.5], [3.5, 52.5], [61.5, 3.5], [61.5, 52.5]] :           // Raspberry Pi
        pattern == "rpi_zero" ? [[3.5, 3.5], [3.5, 26.5], [61.5, 3.5], [61.5, 26.5]] :      // Pi Zero
        pattern == "jetson_nano" ? [[3, 3], [3, 55], [83, 3], [83, 55]] :                    // Jetson Nano
        pattern == "orange_pi" ? [[3, 3], [3, 49], [53, 3], [53, 49]] :                      // Orange Pi
        pattern == "nuc" ? [[3, 3], [3, 108], [108, 3], [108, 108]] :                        // Intel NUC
        pattern == "mini_itx" ? [[6.35, 6.35], [6.35, 163.35], [163.35, 6.35], [163.35, 163.35]] : // Mini-ITX
        is_list(pattern) ? pattern : [[0, 0]];                                               // Custom or default

    for (pos = positions) {
        translate([pos[0], pos[1], 0])
            standoff(height, hole_dia=hole_dia);
    }
}

/**
 * Screw hole (through hole)
 *
 * @param depth Hole depth
 * @param diameter Hole diameter
 */
module screw_hole(depth, diameter=M3_HOLE) {
    cylinder(h=depth, d=diameter);
}

/**
 * Countersunk screw hole
 *
 * @param depth Hole depth
 * @param hole_dia Through hole diameter
 * @param head_dia Countersink head diameter
 * @param head_angle Countersink angle (90 for flat head)
 */
module countersunk_screw_hole(depth, hole_dia=M3_HOLE, head_dia=M3_HEAD, head_angle=90) {
    head_depth = (head_dia - hole_dia) / 2 / tan(head_angle/2);
    union() {
        cylinder(h=depth, d=hole_dia);
        translate([0, 0, depth - head_depth])
            cylinder(h=head_depth + 0.01, d1=hole_dia, d2=head_dia);
    }
}

/**
 * Captive nut pocket (for hex nuts)
 *
 * @param nut_width Nut width across flats
 * @param nut_height Nut thickness
 * @param hole_dia Screw hole diameter
 */
module nut_pocket(nut_width, nut_height, hole_dia) {
    union() {
        // Hex pocket
        cylinder(h=nut_height, d=nut_width * 2 / sqrt(3), $fn=6);
        // Through hole
        translate([0, 0, -0.1])
            cylinder(h=nut_height + 0.2, d=hole_dia);
    }
}

/**
 * Keystone jack cutout (standard networking keystone)
 *
 * @param thickness Wall thickness to cut through
 */
module keystone_cutout(thickness) {
    // Standard keystone: 14.5mm x 16mm
    translate([-7.25, -8, -0.1])
        cube([14.5, 16, thickness + 0.2]);
}

/**
 * Row of keystone cutouts
 *
 * @param count Number of keystone cutouts
 * @param thickness Wall thickness
 * @param spacing Spacing between keystones
 */
module keystone_row(count, thickness, spacing=19) {
    for (i = [0 : count - 1]) {
        translate([i * spacing, 0, 0])
            keystone_cutout(thickness);
    }
}

/**
 * Cable routing slot
 *
 * @param length Slot length
 * @param width Slot width
 * @param thickness Material thickness
 */
module cable_slot(length, width, thickness) {
    translate([-length/2, -width/2, -0.1])
    hull() {
        translate([width/2, width/2, 0])
            cylinder(h=thickness + 0.2, d=width);
        translate([length - width/2, width/2, 0])
            cylinder(h=thickness + 0.2, d=width);
    }
}

/**
 * Cable tie mount point
 *
 * @param width Tie width
 * @param thickness Material thickness for slot
 * @param height Mount height
 */
module cable_tie_mount(width=5, thickness=2, height=8) {
    slot_width = 1.5;
    difference() {
        // Main body
        hull() {
            cylinder(h=height, d=width + 4);
            translate([0, width/2 + 2, 0])
                cylinder(h=height, d=width + 4);
        }
        // Tie slot
        translate([-width/2 - 0.5, -0.5, height/2 - slot_width/2])
            cube([width + 1, width + 5, slot_width]);
    }
}

/**
 * Rack ear mounting bracket (for attaching to rack rails)
 *
 * @param height Bracket height (1U = 44.45mm panel)
 * @param depth Bracket depth (how far it extends)
 * @param thickness Material thickness
 * @param hole_dia Mounting hole diameter
 * @param ear_width Width of the ear portion
 */
module rack_ear(height, depth, thickness=3, hole_dia=6.4, ear_width=15.875) {
    // Ear portion with mounting holes
    difference() {
        cube([ear_width, height, thickness]);

        // Standard 3-hole pattern for 1U
        for (z = [6.35, 22.225, 38.1]) {
            if (z < height) {
                translate([ear_width/2, z, -0.1])
                    cylinder(h=thickness + 0.2, d=hole_dia);
            }
        }
    }

    // Shelf attachment flange
    translate([ear_width - thickness, 0, 0])
        cube([thickness, height, depth]);
}

/**
 * L-bracket for shelf support
 *
 * @param width Bracket width
 * @param height Vertical height
 * @param depth Horizontal depth
 * @param thickness Material thickness
 * @param hole_dia Mounting hole diameter
 */
module l_bracket(width, height, depth, thickness=3, hole_dia=4) {
    difference() {
        union() {
            // Vertical part
            cube([width, thickness, height]);
            // Horizontal part
            cube([width, depth, thickness]);
        }
        // Mounting holes on vertical
        translate([width/2, -0.1, height/2])
            rotate([-90, 0, 0])
                cylinder(h=thickness + 0.2, d=hole_dia);
        // Mounting holes on horizontal
        translate([width/2, depth/2, -0.1])
            cylinder(h=thickness + 0.2, d=hole_dia);
    }
}

/**
 * DIN rail clip mount
 *
 * @param width Clip width
 * @param height Clip height
 */
module din_rail_clip(width=35, height=15) {
    // Standard DIN rail is 35mm wide, 7.5mm tall
    rail_width = 35;
    rail_height = 7.5;
    lip = 1.5;

    difference() {
        cube([width, rail_height + 4, height]);
        // Rail channel
        translate([-0.1, 2, -0.1])
            cube([width + 0.2, rail_height, height - lip + 0.1]);
        // Entry slot
        translate([-0.1, 2 + lip, height - lip - 0.1])
            cube([width + 0.2, rail_height - lip*2, lip + 0.2]);
    }
}
