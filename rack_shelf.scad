/**
 * Rack Shelf Library - Main Module
 *
 * Parametric rack shelf generator with full customization
 * Supports 19" and 10" racks, various ventilation patterns,
 * cable management, and mounting options.
 *
 * Author: Generated with Claude
 * License: MIT
 *
 * Usage:
 *   use <rack_shelf.scad>
 *   rack_shelf(rack_type="19inch", units=1, depth=250);
 */

use <utils.scad>
use <patterns.scad>
use <mounting.scad>
use <modular.scad>

/* [Rack Configuration] */
// Rack type
rack_type = "19inch"; // [19inch:19" Standard, 10inch:10" Mini]

// Number of rack units (1U, 2U, etc.)
rack_units = 1; // [1:5]

// Shelf depth in mm
shelf_depth = 250; // [100:400]

// Shelf thickness in mm
shelf_thickness = 3; // [2:0.5:6]

/* [Shelf Options] */
// Front lip height (0 to disable)
front_lip_height = 10; // [0:30]

// Rear lip height (0 to disable)
rear_lip_height = 0; // [0:30]

// Side wall height (0 to disable)
side_wall_height = 0; // [0:50]

// Corner radius
corner_radius = 3; // [0:10]

/* [Ventilation] */
// Ventilation pattern
vent_pattern = "honeycomb"; // [none:None, honeycomb:Honeycomb, grid:Grid, slots:Horizontal Slots, slots_v:Vertical Slots, circles:Circles, diamond:Diamond]

// Ventilation area margin from edges
vent_margin = 25; // [10:50]

/* [Rack Ears] */
// Include rack mounting ears
include_ears = true;

// Ear thickness
ear_thickness = 3; // [2:5]

// Use elongated/slot mounting holes
slot_holes = false;

/* [Cable Management] */
// Keystone cutouts on left side
keystones_left = 0; // [0:6]

// Keystone cutouts on right side
keystones_right = 0; // [0:6]

// Rear cable slots
rear_cable_slots = 0; // [0:5]

// Cable slot width
cable_slot_width = 15; // [10:30]

/* [Equipment Mounting] */
// Add equipment mounting holes
mounting_holes = false;

// Mounting hole pattern (grid spacing in mm)
mounting_hole_spacing = 25; // [15:50]

// Mounting hole diameter
mounting_hole_dia = 4; // [3:6]

/* [Hidden] */
$fn = $preview ? 32 : 64;

// Get rack dimensions
rack_dims = get_rack_dims(rack_type);
rack_outer_width = rack_dims[0];
rack_inner_width = rack_dims[1];
rack_mount_width = rack_dims[2];
rack_hole_spacing = rack_dims[3];

// Calculate panel height
panel_height = rack_panel_height(rack_units);

/**
 * Main rack shelf module
 *
 * @param rack_type "19inch" or "10inch"
 * @param units Number of rack units
 * @param depth Shelf depth in mm
 * @param thickness Material thickness
 * @param pattern Ventilation pattern name
 * @param ears Include rack ears
 * @param front_lip Front lip height
 * @param rear_lip Rear lip height
 * @param side_walls Side wall height
 */
module rack_shelf(
    rack_type = "19inch",
    units = 1,
    depth = 250,
    thickness = 3,
    pattern = "honeycomb",
    ears = true,
    front_lip = 10,
    rear_lip = 0,
    side_walls = 0,
    left_keystones = 0,
    right_keystones = 0,
    cable_slots = 0,
    slot_width = 15,
    equip_holes = false,
    hole_spacing = 25,
    hole_dia = 4,
    radius = 3
) {
    // Get rack dimensions
    dims = get_rack_dims(rack_type);
    outer_width = dims[0];
    inner_width = dims[1];
    mount_width = dims[2];
    hole_spacing_rack = dims[3];

    height = rack_panel_height(units);
    vent_margin = 25;

    // Main shelf body
    difference() {
        union() {
            // Base shelf plate
            _shelf_base(inner_width, depth, thickness, radius);

            // Front lip
            if (front_lip > 0) {
                translate([0, depth/2 - thickness/2, thickness])
                    _shelf_lip(inner_width, front_lip, thickness, radius);
            }

            // Rear lip
            if (rear_lip > 0) {
                translate([0, -depth/2 + thickness/2, thickness])
                    _shelf_lip(inner_width, rear_lip, thickness, radius);
            }

            // Side walls
            if (side_walls > 0) {
                // Left wall
                translate([-inner_width/2 + thickness/2, 0, thickness])
                    rotate([0, 0, 90])
                        _shelf_lip(depth - thickness*2, side_walls, thickness, 0);
                // Right wall
                translate([inner_width/2 - thickness/2, 0, thickness])
                    rotate([0, 0, 90])
                        _shelf_lip(depth - thickness*2, side_walls, thickness, 0);
            }

            // Rack ears
            if (ears) {
                // Left ear
                translate([-inner_width/2 - mount_width, -height/2, 0])
                    _rack_ear(mount_width, height, thickness, depth, false);
                // Right ear
                translate([inner_width/2, -height/2, 0])
                    _rack_ear(mount_width, height, thickness, depth, true);
            }
        }

        // Ventilation pattern cutout
        if (pattern != "none") {
            vent_width = inner_width - vent_margin * 2;
            vent_depth = depth - vent_margin * 2;
            if (vent_width > 20 && vent_depth > 20) {
                translate([0, 0, -0.1])
                    ventilation_pattern(pattern, vent_width, vent_depth, thickness + 0.2);
            }
        }

        // Keystone cutouts - left side
        if (left_keystones > 0 && side_walls > 0) {
            ks_start = -((left_keystones - 1) * 19) / 2;
            for (i = [0 : left_keystones - 1]) {
                translate([-inner_width/2 + thickness/2, ks_start + i * 19, thickness + side_walls/2])
                    rotate([0, 90, 0])
                        keystone_cutout(thickness);
            }
        }

        // Keystone cutouts - right side
        if (right_keystones > 0 && side_walls > 0) {
            ks_start = -((right_keystones - 1) * 19) / 2;
            for (i = [0 : right_keystones - 1]) {
                translate([inner_width/2 - thickness/2, ks_start + i * 19, thickness + side_walls/2])
                    rotate([0, 90, 0])
                        keystone_cutout(thickness);
            }
        }

        // Rear cable slots
        if (cable_slots > 0 && rear_lip > 0) {
            slot_start = -((cable_slots - 1) * (slot_width + 10)) / 2;
            for (i = [0 : cable_slots - 1]) {
                translate([slot_start + i * (slot_width + 10), -depth/2 + thickness, thickness + rear_lip/2])
                    rotate([90, 0, 0])
                        cable_slot(slot_width, rear_lip * 0.6, thickness);
            }
        }

        // Equipment mounting holes
        if (equip_holes) {
            hole_cols = floor((inner_width - vent_margin * 2) / hole_spacing);
            hole_rows = floor((depth - vent_margin * 2) / hole_spacing);
            x_start = -((hole_cols - 1) * hole_spacing) / 2;
            y_start = -((hole_rows - 1) * hole_spacing) / 2;

            for (r = [0 : hole_rows - 1]) {
                for (c = [0 : hole_cols - 1]) {
                    translate([x_start + c * hole_spacing, y_start + r * hole_spacing, -0.1])
                        cylinder(h=thickness + 0.2, d=hole_dia);
                }
            }
        }
    }
}

/**
 * Shelf base plate (internal)
 */
module _shelf_base(width, depth, thickness, radius) {
    if (radius > 0) {
        linear_extrude(thickness)
            offset(r=radius)
                offset(delta=-radius)
                    square([width, depth], center=true);
    } else {
        translate([-width/2, -depth/2, 0])
            cube([width, depth, thickness]);
    }
}

/**
 * Shelf lip/wall (internal)
 */
module _shelf_lip(width, height, thickness, radius) {
    translate([-width/2, -thickness/2, 0])
        cube([width, thickness, height]);
}

/**
 * Rack mounting ear (internal)
 */
module _rack_ear(ear_width, height, thickness, shelf_depth, is_right) {
    // Ear dimensions
    hole_dia = 6.4;  // M6 clearance
    hole_positions = [6.35, 22.225, 38.1];  // Standard 3-hole pattern

    difference() {
        union() {
            // Vertical ear plate
            cube([ear_width, height, thickness]);

            // Angled support bracket
            bracket_depth = min(30, shelf_depth * 0.15);
            translate([is_right ? 0 : ear_width - thickness, 0, 0])
                cube([thickness, height, bracket_depth]);

            // Gusset triangles for strength
            gusset_size = min(15, ear_width * 0.8);
            translate([is_right ? thickness : ear_width - thickness, height * 0.25, thickness])
                rotate([90, 0, is_right ? 0 : 180])
                    linear_extrude(2)
                        polygon([[0, 0], [gusset_size, 0], [0, gusset_size]]);
            translate([is_right ? thickness : ear_width - thickness, height * 0.75, thickness])
                rotate([90, 0, is_right ? 0 : 180])
                    linear_extrude(2)
                        polygon([[0, 0], [gusset_size, 0], [0, gusset_size]]);
        }

        // Mounting holes
        for (h = hole_positions) {
            if (h < height) {
                translate([ear_width/2, h, -0.1])
                    cylinder(h=thickness + 0.2, d=hole_dia);
            }
        }
    }
}

/**
 * Shelf with standoffs for mounting SBC or equipment
 */
module rack_shelf_with_standoffs(
    rack_type = "19inch",
    units = 1,
    depth = 250,
    standoff_pattern = "rpi",
    standoff_height = 5,
    standoff_x_offset = 0,
    standoff_y_offset = 0
) {
    rack_shelf(rack_type=rack_type, units=units, depth=depth);

    // Add standoffs
    translate([standoff_x_offset, standoff_y_offset, shelf_thickness])
        standoff_array(standoff_pattern, standoff_height);
}

/**
 * Blank panel (no shelf, just front plate)
 */
module rack_blank_panel(
    rack_type = "19inch",
    units = 1,
    thickness = 3,
    pattern = "none",
    ears = true
) {
    dims = get_rack_dims(rack_type);
    outer_width = dims[0];
    inner_width = dims[1];
    mount_width = dims[2];
    height = rack_panel_height(units);

    difference() {
        union() {
            // Main panel
            translate([-inner_width/2, -height/2, 0])
                cube([inner_width, height, thickness]);

            // Ears
            if (ears) {
                translate([-inner_width/2 - mount_width, -height/2, 0])
                    _rack_ear(mount_width, height, thickness, 30, false);
                translate([inner_width/2, -height/2, 0])
                    _rack_ear(mount_width, height, thickness, 30, true);
            }
        }

        // Ventilation pattern
        if (pattern != "none") {
            vent_width = inner_width - 40;
            vent_height = height - 10;
            translate([0, 0, -0.1])
                ventilation_pattern(pattern, vent_width, vent_height, thickness + 0.2);
        }
    }
}

/**
 * Split shelf into printable sections
 * Divides a 19" shelf into 3 sections (~150mm each)
 *
 * @param section Which section to generate (0, 1, or 2)
 * @param total_sections Number of sections (default 3 for 19")
 * @param joint_type "tab", "screw", or "none"
 * @param ... other rack_shelf parameters
 */
module rack_shelf_section(
    section = 0,
    total_sections = 3,
    joint_type = "tab",
    rack_type = "19inch",
    units = 1,
    depth = 250,
    thickness = 3,
    pattern = "slots",
    front_lip = 10,
    rear_lip = 0
) {
    dims = get_rack_dims(rack_type);
    inner_width = dims[1];
    mount_width = dims[2];
    sec_width = inner_width / total_sections;
    height = rack_panel_height(units);

    is_first = section == 0;
    is_last = section == total_sections - 1;

    // Connector dimensions
    tab_width = 10;
    tab_length = 8;
    tab_height = min(6, thickness);

    difference() {
        union() {
            // Section base plate
            translate([-sec_width/2, -depth/2, 0])
                cube([sec_width, depth, thickness]);

            // Front lip
            if (front_lip > 0) {
                translate([-sec_width/2, depth/2 - thickness, 0])
                    cube([sec_width, thickness, front_lip + thickness]);
            }

            // Rear lip
            if (rear_lip > 0) {
                translate([-sec_width/2, -depth/2, 0])
                    cube([sec_width, thickness, rear_lip + thickness]);
            }

            // Left ear (only on first section)
            if (is_first) {
                translate([-sec_width/2 - mount_width, -height/2, 0])
                    _rack_ear(mount_width, height, thickness, depth, false);
            }

            // Right ear (only on last section)
            if (is_last) {
                translate([sec_width/2, -height/2, 0])
                    _rack_ear(mount_width, height, thickness, depth, true);
            }

            // Right-side connector tabs (not on last section)
            if (!is_last && joint_type == "tab") {
                // Front tab
                translate([sec_width/2, depth/4, 0])
                    connector_tab(tab_width, tab_length, tab_height);
                // Rear tab
                translate([sec_width/2, -depth/4 - tab_width, 0])
                    connector_tab(tab_width, tab_length, tab_height);
            }

            // Screw flange (not on last section)
            if (!is_last && joint_type == "screw") {
                translate([sec_width/2 - JOINT_OVERLAP, -depth/2, 0])
                    screw_flange(JOINT_OVERLAP, depth, thickness, 4);
            }
        }

        // Ventilation pattern
        if (pattern != "none") {
            vent_width = sec_width - 20;
            vent_depth = depth - 40;
            translate([0, 0, -0.1])
                ventilation_pattern(pattern, vent_width, vent_depth, thickness + 0.2);
        }

        // Left-side connector slots (not on first section)
        if (!is_first && joint_type == "tab") {
            // Front slot
            translate([-sec_width/2, depth/4, 0])
                rotate([0, 0, 180])
                    connector_slot(tab_width, tab_length, tab_height);
            // Rear slot
            translate([-sec_width/2, -depth/4 - tab_width, 0])
                rotate([0, 0, 180])
                    connector_slot(tab_width, tab_length, tab_height);
        }

        // Screw holes (not on first section)
        if (!is_first && joint_type == "screw") {
            translate([-sec_width/2, -depth/2, 0])
                screw_flange_holes(JOINT_OVERLAP, depth, thickness, 4);
        }
    }
}

/**
 * Generate all shelf sections for printing
 * Lays out sections side by side for visualization
 *
 * @param spacing Gap between sections for display
 */
module rack_shelf_all_sections(
    total_sections = 3,
    joint_type = "tab",
    rack_type = "19inch",
    units = 1,
    depth = 250,
    thickness = 3,
    pattern = "slots",
    front_lip = 10,
    rear_lip = 0,
    spacing = 20
) {
    dims = get_rack_dims(rack_type);
    sec_width = dims[1] / total_sections;

    for (i = [0 : total_sections - 1]) {
        translate([i * (sec_width + spacing), 0, 0])
            color(i == 0 ? "tomato" : i == 1 ? "lightgreen" : "lightblue")
                rack_shelf_section(
                    section = i,
                    total_sections = total_sections,
                    joint_type = joint_type,
                    rack_type = rack_type,
                    units = units,
                    depth = depth,
                    thickness = thickness,
                    pattern = pattern,
                    front_lip = front_lip,
                    rear_lip = rear_lip
                );
    }
}

/**
 * Print layout - sections arranged for 3D printing
 * Rotates and positions sections optimally for print bed
 */
module rack_shelf_print_layout(
    total_sections = 3,
    joint_type = "tab",
    rack_type = "19inch",
    depth = 250,
    thickness = 3,
    pattern = "slots",
    front_lip = 10,
    spacing = 10
) {
    dims = get_rack_dims(rack_type);
    sec_width = dims[1] / total_sections;

    for (i = [0 : total_sections - 1]) {
        translate([0, i * (depth + spacing), 0])
            rack_shelf_section(
                section = i,
                total_sections = total_sections,
                joint_type = joint_type,
                rack_type = rack_type,
                depth = depth,
                thickness = thickness,
                pattern = pattern,
                front_lip = front_lip
            );
    }
}

// Preview with current settings
if ($preview) {
    rack_shelf(
        rack_type = rack_type,
        units = rack_units,
        depth = shelf_depth,
        thickness = shelf_thickness,
        pattern = vent_pattern,
        ears = include_ears,
        front_lip = front_lip_height,
        rear_lip = rear_lip_height,
        side_walls = side_wall_height,
        left_keystones = keystones_left,
        right_keystones = keystones_right,
        cable_slots = rear_cable_slots,
        slot_width = cable_slot_width,
        equip_holes = mounting_holes,
        hole_spacing = mounting_hole_spacing,
        hole_dia = mounting_hole_dia,
        radius = corner_radius
    );
}
