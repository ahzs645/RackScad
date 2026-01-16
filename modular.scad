/**
 * Rack Shelf Library - Modular/Multi-Piece System
 *
 * Connectors and splitting for 3D printing large rack equipment.
 * Inspired by Libre19 project's modular approach.
 *
 * 19" racks are ~483mm wide - too large for most printers.
 * This module provides ways to split designs into printable sections.
 *
 * Author: Generated with Claude
 * License: MIT
 */

use <utils.scad>

/* [Print Bed Configuration] */
// Maximum print bed size (mm)
MAX_PRINT_WIDTH = 220;   // Common for Ender 3, Prusa, etc.
MAX_PRINT_DEPTH = 220;

/* [Connector Settings] */
// Screw hole diameter for M3
M3_HOLE = 3.2;
M3_HEAD = 5.5;

// Tolerance for mating parts
FIT_TOLERANCE = 0.3;

// Overlap for screw joints
JOINT_OVERLAP = 15;

/* [Hidden] */
$fn = $preview ? 24 : 48;

/**
 * Calculate number of sections needed to fit print bed
 * @param total_width Total width to split
 * @param max_width Maximum printable width
 * @return Number of sections needed
 */
function sections_needed(total_width, max_width=MAX_PRINT_WIDTH) =
    ceil(total_width / max_width);

/**
 * Calculate section width for even splits
 * @param total_width Total width to split
 * @param num_sections Number of sections
 * @return Width of each section
 */
function section_width(total_width, num_sections) =
    total_width / num_sections;

/**
 * M3 Corner bracket connector
 * L-shaped bracket for joining sections at corners
 * Based on Libre19's corner() design
 *
 * @param height Bracket height
 * @param arm_length Length of each arm
 * @param thickness Material thickness
 */
module corner_bracket(height=10, arm_length=15, thickness=3) {
    screw_inset = arm_length / 2;

    difference() {
        union() {
            // Horizontal arm
            cube([arm_length, thickness, height]);
            // Vertical arm
            cube([thickness, arm_length, height]);
        }
        // Screw holes - horizontal arm
        translate([screw_inset, -0.1, height/2])
            rotate([-90, 0, 0])
                cylinder(h=thickness + 0.2, d=M3_HOLE);
        // Screw holes - vertical arm
        translate([-0.1, screw_inset, height/2])
            rotate([0, 90, 0])
                cylinder(h=thickness + 0.2, d=M3_HOLE);
    }
}

/**
 * Corner bracket holes (for subtraction)
 * Place where corner brackets will attach
 */
module corner_bracket_holes(height=10, arm_length=15, thickness=3) {
    screw_inset = arm_length / 2;

    // Hole for horizontal arm attachment
    translate([screw_inset, 0, height/2])
        rotate([-90, 0, 0])
            cylinder(h=thickness * 2, d=M3_HOLE, center=true);
    // Hole for vertical arm attachment
    translate([0, screw_inset, height/2])
        rotate([0, 90, 0])
            cylinder(h=thickness * 2, d=M3_HOLE, center=true);
}

/**
 * Tab connector (male)
 * Protruding tab for joining sections
 *
 * @param width Tab width
 * @param length Tab length (how far it protrudes)
 * @param height Tab height
 */
module connector_tab(width=10, length=8, height=6) {
    // Tapered tab for easier insertion
    hull() {
        cube([width, 0.1, height]);
        translate([(width - width*0.9)/2, length, 0])
            cube([width * 0.9, 0.1, height]);
    }
}

/**
 * Tab connector slot (female)
 * Slot to receive a tab connector
 * Includes tolerance for fit
 */
module connector_slot(width=10, length=8, height=6, tolerance=FIT_TOLERANCE) {
    w = width + tolerance * 2;
    l = length + tolerance;
    h = height + tolerance * 2;

    translate([-(w - width)/2, -0.1, -(h - height)/2])
        hull() {
            cube([w, 0.1, h]);
            translate([(w - w*0.9)/2, l + 0.1, 0])
                cube([w * 0.9, 0.1, h]);
        }
}

/**
 * Dovetail connector (male)
 * Strong interlocking joint
 *
 * @param width Base width
 * @param length Dovetail length
 * @param height Connector height
 * @param angle Dovetail angle (default 15°)
 */
module dovetail_tab(width=12, length=10, height=8, angle=15) {
    top_width = width + 2 * length * tan(angle);

    linear_extrude(height)
        polygon([
            [0, 0],
            [width, 0],
            [width + length * tan(angle), length],
            [-length * tan(angle), length]
        ]);
}

/**
 * Dovetail connector slot (female)
 */
module dovetail_slot(width=12, length=10, height=8, angle=15, tolerance=FIT_TOLERANCE) {
    w = width + tolerance * 2;
    l = length + tolerance;
    h = height + tolerance * 2;

    translate([-tolerance, -0.1, -tolerance])
        linear_extrude(h)
            polygon([
                [0, 0],
                [w, 0],
                [w + l * tan(angle), l + 0.1],
                [-l * tan(angle), l + 0.1]
            ]);
}

/**
 * Alignment pin hole
 * For precise alignment when gluing sections
 *
 * @param depth Hole depth
 * @param diameter Pin diameter (1.75mm for filament)
 */
module alignment_pin_hole(depth=5, diameter=1.75) {
    cylinder(h=depth, d=diameter + 0.1);
}

/**
 * Alignment pin
 * Use with alignment_pin_hole for precise joining
 */
module alignment_pin(length=10, diameter=1.75) {
    cylinder(h=length, d=diameter - 0.1);
}

/**
 * Screw joint flange
 * Overlapping flange with screw holes for bolted joints
 *
 * @param width Flange width
 * @param height Flange height (along edge)
 * @param thickness Flange thickness
 * @param holes Number of screw holes
 */
module screw_flange(width=JOINT_OVERLAP, height=40, thickness=3, holes=2) {
    hole_spacing = height / (holes + 1);

    difference() {
        cube([width, height, thickness]);

        // Screw holes
        for (i = [1 : holes]) {
            translate([width/2, i * hole_spacing, -0.1])
                cylinder(h=thickness + 0.2, d=M3_HOLE);
        }
    }
}

/**
 * Screw joint holes (for mating flange)
 * Countersunk holes for flush screws
 */
module screw_flange_holes(width=JOINT_OVERLAP, height=40, thickness=3, holes=2) {
    hole_spacing = height / (holes + 1);

    for (i = [1 : holes]) {
        translate([width/2, i * hole_spacing, 0]) {
            // Through hole
            translate([0, 0, -0.1])
                cylinder(h=thickness + 0.2, d=M3_HOLE);
            // Countersink
            translate([0, 0, thickness - 1.5])
                cylinder(h=2, d1=M3_HOLE, d2=M3_HEAD);
        }
    }
}

/**
 * Split a shelf into printable sections
 * Returns one section at a time
 *
 * @param section Which section (0-indexed)
 * @param total_sections Total number of sections
 * @param total_width Total shelf width
 * @param depth Shelf depth
 * @param thickness Material thickness
 * @param joint_type "tab", "dovetail", "screw", or "none"
 */
module shelf_section(section, total_sections, total_width, depth, thickness, joint_type="tab") {
    sec_width = total_width / total_sections;
    x_offset = section * sec_width - total_width/2;

    is_first = section == 0;
    is_last = section == total_sections - 1;

    difference() {
        union() {
            // Main section
            translate([x_offset, -depth/2, 0])
                cube([sec_width, depth, thickness]);

            // Right-side connector tabs (not on last section)
            if (!is_last && joint_type == "tab") {
                translate([x_offset + sec_width, -depth/4, thickness/2 - 3])
                    connector_tab();
                translate([x_offset + sec_width, depth/4 - 10, thickness/2 - 3])
                    connector_tab();
            }

            // Right-side screw flange (not on last section)
            if (!is_last && joint_type == "screw") {
                translate([x_offset + sec_width - JOINT_OVERLAP/2, -depth/2, 0])
                    screw_flange(JOINT_OVERLAP, depth, thickness, 3);
            }
        }

        // Left-side connector slots (not on first section)
        if (!is_first && joint_type == "tab") {
            translate([x_offset, -depth/4, thickness/2 - 3])
                rotate([0, 0, 180])
                    connector_slot();
            translate([x_offset, depth/4 - 10, thickness/2 - 3])
                rotate([0, 0, 180])
                    connector_slot();
        }

        // Left-side screw holes (not on first section)
        if (!is_first && joint_type == "screw") {
            translate([x_offset + JOINT_OVERLAP/2, -depth/2, 0])
                screw_flange_holes(JOINT_OVERLAP, depth, thickness, 3);
        }
    }
}

/**
 * Libre19-style brick unit dimensions
 * Standard modular sizing for consistent stacking
 */
L19_BRICK_X = 73;    // Width per unit
L19_BRICK_Y = 215;   // Depth per unit
L19_BRICK_Z = 42.5;  // Height per unit

function l19_width(units) = units * L19_BRICK_X;
function l19_depth(units) = units * L19_BRICK_Y;
function l19_height(units) = units * L19_BRICK_Z;

/**
 * Modular rack section frame
 * Creates a printable section that tiles to form full rack width
 *
 * @param width_units Number of L19 width units
 * @param depth Actual depth in mm
 * @param height Actual height in mm
 * @param thickness Wall thickness
 * @param left_joint Include left joint features
 * @param right_joint Include right joint features
 */
module modular_section(width_units=2, depth=200, height=44.45, thickness=3, left_joint=true, right_joint=true) {
    width = l19_width(width_units);
    tab_positions = [height * 0.25, height * 0.75];

    difference() {
        union() {
            // Base frame - U channel
            // Bottom
            cube([width, depth, thickness]);
            // Left wall
            cube([thickness, depth, height]);
            // Right wall
            translate([width - thickness, 0, 0])
                cube([thickness, depth, height]);

            // Right connector tabs
            if (right_joint) {
                for (z = tab_positions) {
                    translate([width, depth/3, z - 3])
                        connector_tab();
                    translate([width, depth*2/3 - 10, z - 3])
                        connector_tab();
                }
            }
        }

        // Left connector slots
        if (left_joint) {
            for (z = tab_positions) {
                translate([0, depth/3, z - 3])
                    rotate([0, 0, 180])
                        connector_slot();
                translate([0, depth*2/3 - 10, z - 3])
                    rotate([0, 0, 180])
                        connector_slot();
            }
        }

        // Alignment pin holes on mating faces
        if (right_joint) {
            translate([width - 0.1, depth/2, height/2])
                rotate([0, 90, 0])
                    alignment_pin_hole(depth=6);
        }
        if (left_joint) {
            translate([0.1, depth/2, height/2])
                rotate([0, -90, 0])
                    alignment_pin_hole(depth=6);
        }
    }
}

/**
 * Full 19" rack as 3 printable sections
 * Demonstrates splitting a full-width design
 */
module rack_19_split_demo() {
    inner_width = in_to_mm(17.75);  // ~450mm
    sections = 3;
    sec_width = inner_width / sections;  // ~150mm each

    for (i = [0 : sections - 1]) {
        translate([i * (sec_width + 20), 0, 0])  // Spread for visibility
            color(i == 0 ? "red" : i == 1 ? "green" : "blue")
                shelf_section(i, sections, inner_width, 200, 3, "tab");
    }
}

/**
 * Print layout helper
 * Arranges sections flat for printing
 *
 * @param sections Number of sections
 * @param sec_width Width of each section
 * @param depth Depth of sections
 */
module print_layout(sections, sec_width, depth, spacing=10) {
    for (i = [0 : sections - 1]) {
        translate([0, i * (depth + spacing), 0])
            children(i);
    }
}
