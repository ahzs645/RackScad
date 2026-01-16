/**
 * Rack Shelf Library - Utilities
 *
 * Utility functions and standard rack dimensions
 *
 * Author: Generated with Claude
 * License: MIT
 */

/* [Rack Standards] */
// Standard rack dimensions

// Convert inches to mm
function in_to_mm(inches) = inches * 25.4;

// Convert mm to inches
function mm_to_in(mm) = mm / 25.4;

// 19" rack dimensions
RACK_19_OUTER_WIDTH = in_to_mm(19);           // 482.6mm
RACK_19_INNER_WIDTH = in_to_mm(17.75);        // 450.85mm
RACK_19_MOUNT_WIDTH = in_to_mm(0.625);        // 15.875mm
RACK_19_HOLE_SPACING = in_to_mm(18.3125);     // 465.1mm center-to-center

// 10" rack dimensions
RACK_10_OUTER_WIDTH = in_to_mm(10);           // 254mm
RACK_10_INNER_WIDTH = in_to_mm(8.75);         // 222.25mm
RACK_10_MOUNT_WIDTH = in_to_mm(0.625);        // 15.875mm
RACK_10_HOLE_SPACING = in_to_mm(9.5);         // 241.3mm center-to-center

// Common rack unit height
RACK_1U_HEIGHT = in_to_mm(1.75);              // 44.45mm
RACK_1U_PANEL_HEIGHT = in_to_mm(1.71875);     // 43.66mm

// Rack mounting hole positions (from bottom of 1U)
RACK_HOLE_BOTTOM = in_to_mm(0.25);            // 6.35mm
RACK_HOLE_MID = in_to_mm(0.875);              // 22.225mm
RACK_HOLE_TOP = in_to_mm(1.5);                // 38.1mm

// Standard mounting hole diameters
RACK_HOLE_DIA_M6 = 6.5;                       // M6 clearance
RACK_HOLE_DIA_10_32 = 5.1;                    // 10-32 clearance
RACK_CAGE_NUT_SQUARE = in_to_mm(0.375);       // 9.525mm square hole

/**
 * Get rack dimensions by type
 * @param rack_type "19inch" or "10inch"
 * @return [outer_width, inner_width, mount_width, hole_spacing]
 */
function get_rack_dims(rack_type) =
    rack_type == "19inch" ? [RACK_19_OUTER_WIDTH, RACK_19_INNER_WIDTH, RACK_19_MOUNT_WIDTH, RACK_19_HOLE_SPACING] :
    rack_type == "10inch" ? [RACK_10_OUTER_WIDTH, RACK_10_INNER_WIDTH, RACK_10_MOUNT_WIDTH, RACK_10_HOLE_SPACING] :
    [RACK_19_OUTER_WIDTH, RACK_19_INNER_WIDTH, RACK_19_MOUNT_WIDTH, RACK_19_HOLE_SPACING]; // default to 19"

/**
 * Calculate panel height for given rack units
 * @param units Number of rack units (1U, 2U, etc.)
 * @return Panel height in mm
 */
function rack_panel_height(units) = units * RACK_1U_HEIGHT - (RACK_1U_HEIGHT - RACK_1U_PANEL_HEIGHT);

/* [Geometry Helpers] */

/**
 * Create a rounded rectangle (2D)
 * @param size [width, height]
 * @param radius Corner radius
 */
module rounded_rect(size, radius) {
    offset(r=radius)
        offset(delta=-radius)
            square(size, center=true);
}

/**
 * Create a rounded cube
 * @param size [x, y, z] dimensions
 * @param radius Corner radius
 * @param center Center the object
 */
module rounded_cube(size, radius, center=false) {
    translate(center ? [0, 0, 0] : [size[0]/2, size[1]/2, size[2]/2])
        linear_extrude(size[2], center=true)
            rounded_rect([size[0], size[1]], radius);
}

/**
 * Create an elongated/slot hole (2D)
 * @param length Total length of slot
 * @param diameter Diameter of ends
 */
module slot_2d(length, diameter) {
    hull() {
        circle(d=diameter);
        translate([length - diameter, 0])
            circle(d=diameter);
    }
}

/**
 * Create a countersunk hole
 * @param depth Total hole depth
 * @param hole_dia Through hole diameter
 * @param head_dia Countersink diameter
 * @param head_depth Countersink depth
 */
module countersunk_hole(depth, hole_dia, head_dia, head_depth) {
    union() {
        cylinder(h=depth, d=hole_dia);
        translate([0, 0, depth - head_depth])
            cylinder(h=head_depth + 0.01, d1=hole_dia, d2=head_dia);
    }
}

/**
 * Mirror an object on both sides of an axis
 * @param axis [x, y, z] mirror axis
 */
module mirror_copy(axis) {
    children();
    mirror(axis) children();
}
