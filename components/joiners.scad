/**
 * Rack Scad - Joiners Module
 *
 * Modules for joining separately printed rack faceplate parts using
 * M5 screws and hex nuts. Creates a raised bracket on the faceplate edge
 * that allows two sections to be screwed together.
 *
 * Hardware Requirements:
 * - 3x or 6x M5 screws (recommended length: 10-16mm)
 * - 3x or 6x M5 hex nuts (8mm across flats)
 *
 * Usage:
 *   use <components/joiners.scad>
 *
 *   // Create left side (with bracket and screw holes)
 *   faceplate_joiner_left(unit_height=1);
 *
 *   // Create right side (with bracket and hex nut pockets)
 *   faceplate_joiner_right(unit_height=1);
 */

// ============================================================================
// Constants
// ============================================================================

// M5 Hardware dimensions
M5_CLEARANCE_HOLE = 5.5;       // M5 screw clearance hole diameter
M5_HEX_NUT_AF = 8.0;           // M5 hex nut across flats
M5_HEX_NUT_THICKNESS = 4.0;    // M5 hex nut thickness
M5_HEX_NUT_POCKET_AF = 8.4;    // Hex nut pocket with clearance
M5_HEX_NUT_POCKET_DEPTH = 4.5; // Hex nut pocket depth with clearance

// EIA-310 standard
_EIA_UNIT_HEIGHT = 44.45;      // 1U = 44.45mm
_EIA_PANEL_HEIGHT = 43.66;     // Panel height (1U minus clearance)

// Bracket dimensions (defaults)
_BRACKET_WIDTH = 20;           // Width of the bracket (along faceplate edge)
_BRACKET_DEPTH = 20;           // How far bracket extends inward from faceplate
_BRACKET_THICKNESS = 8;        // Thickness of bracket wall
_BRACKET_ROUNDING = 2;         // Edge rounding radius
_FACEPLATE_THICKNESS = 4;      // Default faceplate thickness

// Screw spacing
_SCREW_VERTICAL_SPACING = 12;  // Vertical spacing between screws


// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Calculate screw Y positions based on unit height
 * Returns positions for 3 screws per U, centered vertically
 */
function get_bracket_screw_positions(unit_height) =
    let(
        screw_count = unit_height * 3,
        total_spacing = (screw_count - 1) * _SCREW_VERTICAL_SPACING,
        start_y = -total_spacing / 2
    )
    [for (i = [0 : screw_count - 1]) start_y + (i * _SCREW_VERTICAL_SPACING)];


// ============================================================================
// 2D Helper Shapes
// ============================================================================

/**
 * 2D hexagon for hex nut pocket
 */
module hexagon_2d(af) {
    // af = across flats dimension
    circle(d = af / cos(30), $fn = 6);
}


/**
 * 2D rounded rectangle
 */
module rounded_rect_2d(width, height, radius) {
    offset(r = radius)
        offset(delta = -radius)
            square([width, height], center = true);
}


// ============================================================================
// 3D Helper Shapes
// ============================================================================

/**
 * Rounded box using hull of spheres at corners
 */
module rounded_box(size, radius, fn = 32) {
    x = size[0];
    y = size[1];
    z = size[2];
    r = min(radius, min(x, min(y, z)) / 2);

    hull() {
        for (xi = [-1, 1])
            for (yi = [-1, 1])
                for (zi = [-1, 1])
                    translate([xi * (x/2 - r), yi * (y/2 - r), zi * (z/2 - r)])
                        sphere(r = r, $fn = fn);
    }
}


/**
 * Box with only top edges rounded
 */
module top_rounded_box(size, radius, fn = 32) {
    x = size[0];
    y = size[1];
    z = size[2];
    r = min(radius, min(x, y) / 2, z / 2);

    hull() {
        // Bottom corners (sharp)
        translate([0, 0, -z/2 + 0.5])
            cube([x, y, 1], center = true);

        // Top corners (rounded)
        for (xi = [-1, 1])
            for (yi = [-1, 1])
                translate([xi * (x/2 - r), yi * (y/2 - r), z/2 - r])
                    sphere(r = r, $fn = fn);
    }
}


// ============================================================================
// Main Bracket Modules
// ============================================================================

/**
 * Creates the joiner bracket block with rounded top edges
 */
module joiner_bracket(
    unit_height = 1,
    bracket_width = _BRACKET_WIDTH,
    bracket_depth = _BRACKET_DEPTH,
    bracket_thickness = _BRACKET_THICKNESS,
    faceplate_thickness = _FACEPLATE_THICKNESS,
    rounding = _BRACKET_ROUNDING,
    fn = 32
) {
    panel_height = unit_height * _EIA_PANEL_HEIGHT;
    total_height = faceplate_thickness + bracket_depth + bracket_thickness;

    // Create L-shaped bracket with rounded top
    difference() {
        // Main bracket body with rounded top edges
        translate([bracket_width/2, 0, total_height/2])
            top_rounded_box(
                [bracket_width, panel_height, total_height],
                rounding,
                fn
            );

        // Cut away the lower back to create L-shape
        translate([bracket_width/2, 0, faceplate_thickness/2 - 0.05])
            cube([bracket_width + 1, panel_height + 1, faceplate_thickness + 0.1], center = true);
    }
}


/**
 * Creates the LEFT side joiner (with screw clearance holes)
 */
module faceplate_joiner_left(
    unit_height = 1,
    faceplate_width = 60,
    faceplate_thickness = _FACEPLATE_THICKNESS,
    bracket_width = _BRACKET_WIDTH,
    bracket_depth = _BRACKET_DEPTH,
    bracket_thickness = _BRACKET_THICKNESS,
    rounding = _BRACKET_ROUNDING,
    include_faceplate = true,
    fn = 32
) {
    panel_height = unit_height * _EIA_PANEL_HEIGHT;
    screw_positions = get_bracket_screw_positions(unit_height);
    screw_z = faceplate_thickness + bracket_depth + bracket_thickness / 2;

    difference() {
        union() {
            // Faceplate section (optional)
            if (include_faceplate) {
                translate([-faceplate_width/2 + bracket_width/2, 0, faceplate_thickness/2])
                    cube([faceplate_width, panel_height, faceplate_thickness], center = true);
            }

            // Bracket
            joiner_bracket(
                unit_height = unit_height,
                bracket_width = bracket_width,
                bracket_depth = bracket_depth,
                bracket_thickness = bracket_thickness,
                faceplate_thickness = faceplate_thickness,
                rounding = rounding,
                fn = fn
            );
        }

        // Screw clearance holes
        for (y_pos = screw_positions) {
            translate([bracket_width/2, y_pos, screw_z])
                rotate([0, 90, 0])
                    cylinder(h = bracket_width + 2, d = M5_CLEARANCE_HOLE, center = true, $fn = fn);
        }
    }
}


/**
 * Creates the RIGHT side joiner (with hex nut pockets)
 */
module faceplate_joiner_right(
    unit_height = 1,
    faceplate_width = 60,
    faceplate_thickness = _FACEPLATE_THICKNESS,
    bracket_width = _BRACKET_WIDTH,
    bracket_depth = _BRACKET_DEPTH,
    bracket_thickness = _BRACKET_THICKNESS,
    rounding = _BRACKET_ROUNDING,
    include_faceplate = true,
    fn = 32
) {
    panel_height = unit_height * _EIA_PANEL_HEIGHT;
    screw_positions = get_bracket_screw_positions(unit_height);
    screw_z = faceplate_thickness + bracket_depth + bracket_thickness / 2;

    difference() {
        union() {
            // Faceplate section (optional)
            if (include_faceplate) {
                translate([faceplate_width/2 + bracket_width/2, 0, faceplate_thickness/2])
                    cube([faceplate_width, panel_height, faceplate_thickness], center = true);
            }

            // Bracket
            joiner_bracket(
                unit_height = unit_height,
                bracket_width = bracket_width,
                bracket_depth = bracket_depth,
                bracket_thickness = bracket_thickness,
                faceplate_thickness = faceplate_thickness,
                rounding = rounding,
                fn = fn
            );
        }

        // Screw holes and hex nut pockets
        for (y_pos = screw_positions) {
            // Through hole
            translate([bracket_width/2, y_pos, screw_z])
                rotate([0, 90, 0])
                    cylinder(h = bracket_width + 2, d = M5_CLEARANCE_HOLE, center = true, $fn = fn);

            // Hex nut pocket
            translate([bracket_width - M5_HEX_NUT_POCKET_DEPTH + 0.1, y_pos, screw_z])
                rotate([0, 90, 0])
                    rotate([0, 0, 30])  // Flat side for printing
                        linear_extrude(height = M5_HEX_NUT_POCKET_DEPTH + 1)
                            hexagon_2d(M5_HEX_NUT_POCKET_AF);
        }
    }
}


/**
 * Creates both joiners side by side for printing
 */
module faceplate_joiner_pair(
    unit_height = 1,
    faceplate_width = 60,
    spacing = 10,
    fn = 32
) {
    // Left side
    color("SteelBlue")
        translate([-faceplate_width/2 - spacing/2, 0, 0])
            faceplate_joiner_left(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );

    // Right side
    color("Coral")
        translate([faceplate_width/2 + spacing/2, 0, 0])
            faceplate_joiner_right(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );
}


/**
 * Creates an assembled view showing how parts mate
 */
module faceplate_joiner_assembled(
    unit_height = 1,
    faceplate_width = 60,
    explode = 0,
    fn = 32
) {
    bracket_width = _BRACKET_WIDTH;

    // Left side
    color("SteelBlue", 0.8)
        translate([-faceplate_width + bracket_width - explode/2, 0, 0])
            faceplate_joiner_left(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );

    // Right side
    color("Coral", 0.8)
        translate([explode/2, 0, 0])
            faceplate_joiner_right(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );
}


/**
 * Creates just the bracket for adding to existing faceplates
 */
module joiner_bracket_addon(
    unit_height = 1,
    side = "left",
    fn = 32
) {
    if (side == "left") {
        faceplate_joiner_left(unit_height = unit_height, include_faceplate = false, fn = fn);
    } else {
        faceplate_joiner_right(unit_height = unit_height, include_faceplate = false, fn = fn);
    }
}


// ============================================================================
// Preview
// ============================================================================

// Uncomment to preview:
// faceplate_joiner_pair(unit_height=1);
// faceplate_joiner_assembled(unit_height=1, explode=20);
