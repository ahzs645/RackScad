/**
 * Rack Scad - Joiners Module
 *
 * Modules for joining separately printed rack faceplate parts using
 * M5 screws and hex nuts. Creates a raised bracket on the faceplate edge
 * that allows two sections to be screwed together.
 *
 * Based on modular rack panel joint design.
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
EIA_UNIT_HEIGHT = 44.45;       // 1U = 44.45mm
EIA_PANEL_HEIGHT = 43.66;      // Panel height (1U minus clearance)

// Bracket dimensions
BRACKET_WIDTH = 20;            // Width of the bracket (along faceplate edge)
BRACKET_DEPTH = 20;            // How far bracket extends inward from faceplate
BRACKET_THICKNESS = 8;         // Thickness of bracket wall
BRACKET_CORNER_RADIUS = 3;     // Rounded corner radius on top
FACEPLATE_THICKNESS = 4;       // Default faceplate thickness

// Screw spacing
SCREW_VERTICAL_SPACING = 12;   // Vertical spacing between screws
SCREW_EDGE_MARGIN = 8;         // Distance from bracket edge to screw center


// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Calculate screw Y positions based on unit height
 * Returns positions for 3 screws per U, centered vertically
 *
 * @param unit_height - Height in rack units (1, 2, etc.)
 * @return Array of Y positions for screws
 */
function get_bracket_screw_positions(unit_height) =
    let(
        panel_height = unit_height * EIA_PANEL_HEIGHT,
        screw_count = unit_height * 3,
        total_spacing = (screw_count - 1) * SCREW_VERTICAL_SPACING,
        start_y = -total_spacing / 2
    )
    [for (i = [0 : screw_count - 1]) start_y + (i * SCREW_VERTICAL_SPACING)];


// ============================================================================
// 2D Helper Shapes
// ============================================================================

/**
 * 2D hexagon for hex nut pocket
 *
 * @param size - Across-flats dimension
 */
module hexagon_2d(size) {
    circle(d = size / cos(30), $fn = 6);
}


/**
 * 2D bracket profile with rounded top corners
 * Creates the side profile of the bracket
 *
 * @param depth - How far the bracket extends
 * @param thickness - Thickness of the bracket
 * @param radius - Corner radius
 */
module bracket_profile_2d(depth, thickness, radius) {
    hull() {
        // Bottom left corner (sharp)
        square([0.1, 0.1]);

        // Bottom right corner (sharp)
        translate([depth - 0.1, 0])
            square([0.1, 0.1]);

        // Top right corner (rounded)
        translate([depth - radius, thickness - radius])
            circle(r = radius, $fn = 32);

        // Top left corner (rounded)
        translate([radius, thickness - radius])
            circle(r = radius, $fn = 32);
    }
}


// ============================================================================
// Main Bracket Modules
// ============================================================================

/**
 * Creates a single bracket block with rounded top
 * This is the raised portion that extends from the faceplate
 *
 * @param unit_height - Height in rack units
 * @param bracket_width - Width of bracket
 * @param bracket_depth - How far bracket extends inward
 * @param bracket_thickness - Wall thickness of bracket
 * @param corner_radius - Rounding on top corners
 * @param fn - Curve resolution
 */
module joiner_bracket(
    unit_height = 1,
    bracket_width = BRACKET_WIDTH,
    bracket_depth = BRACKET_DEPTH,
    bracket_thickness = BRACKET_THICKNESS,
    corner_radius = BRACKET_CORNER_RADIUS,
    fn = 32
) {
    panel_height = unit_height * EIA_PANEL_HEIGHT;

    // Bracket body with rounded top edges
    translate([0, -panel_height/2, 0])
        rotate([90, 0, 90])
            linear_extrude(height = bracket_width, center = false)
                hull() {
                    // Bottom corners (sharp at faceplate level)
                    square([panel_height, 0.1]);

                    // Top corners (rounded)
                    translate([corner_radius, bracket_depth + bracket_thickness - corner_radius])
                        circle(r = corner_radius, $fn = fn);
                    translate([panel_height - corner_radius, bracket_depth + bracket_thickness - corner_radius])
                        circle(r = corner_radius, $fn = fn);

                    // Bottom of rounded section
                    translate([0, bracket_depth])
                        square([panel_height, 0.1]);
                }
}


/**
 * Creates the LEFT side joiner (with screw clearance holes)
 * Screws insert from this side into hex nuts on the right side
 *
 * @param unit_height - Height in rack units
 * @param faceplate_width - Width of the faceplate section
 * @param faceplate_thickness - Thickness of faceplate
 * @param bracket_width - Width of the bracket
 * @param bracket_depth - How far bracket extends inward
 * @param bracket_thickness - Thickness of bracket top
 * @param include_faceplate - Include a sample faceplate section
 * @param fn - Curve resolution
 */
module faceplate_joiner_left(
    unit_height = 1,
    faceplate_width = 60,
    faceplate_thickness = FACEPLATE_THICKNESS,
    bracket_width = BRACKET_WIDTH,
    bracket_depth = BRACKET_DEPTH,
    bracket_thickness = BRACKET_THICKNESS,
    include_faceplate = true,
    fn = 32
) {
    panel_height = unit_height * EIA_PANEL_HEIGHT;
    screw_positions = get_bracket_screw_positions(unit_height);

    // Screw hole X position (center of bracket wall)
    screw_x = bracket_width / 2;
    // Screw hole Z position (center of bracket top section)
    screw_z = faceplate_thickness + bracket_depth + bracket_thickness / 2;

    difference() {
        union() {
            // Faceplate section (optional)
            if (include_faceplate) {
                translate([-faceplate_width + bracket_width, -panel_height/2, 0])
                    cube([faceplate_width, panel_height, faceplate_thickness]);
            }

            // Bracket extending inward from faceplate
            joiner_bracket(
                unit_height = unit_height,
                bracket_width = bracket_width,
                bracket_depth = bracket_depth,
                bracket_thickness = bracket_thickness,
                fn = fn
            );
        }

        // Screw clearance holes (horizontal, going through bracket)
        for (y_pos = screw_positions) {
            translate([screw_x, y_pos, screw_z])
                rotate([0, 90, 0])
                    cylinder(h = bracket_width + 2, d = M5_CLEARANCE_HOLE, center = true, $fn = fn);
        }
    }
}


/**
 * Creates the RIGHT side joiner (with hex nut pockets)
 * Hex nuts sit in pockets, screws come from the left side
 *
 * @param unit_height - Height in rack units
 * @param faceplate_width - Width of the faceplate section
 * @param faceplate_thickness - Thickness of faceplate
 * @param bracket_width - Width of the bracket
 * @param bracket_depth - How far bracket extends inward
 * @param bracket_thickness - Thickness of bracket top
 * @param include_faceplate - Include a sample faceplate section
 * @param fn - Curve resolution
 */
module faceplate_joiner_right(
    unit_height = 1,
    faceplate_width = 60,
    faceplate_thickness = FACEPLATE_THICKNESS,
    bracket_width = BRACKET_WIDTH,
    bracket_depth = BRACKET_DEPTH,
    bracket_thickness = BRACKET_THICKNESS,
    include_faceplate = true,
    fn = 32
) {
    panel_height = unit_height * EIA_PANEL_HEIGHT;
    screw_positions = get_bracket_screw_positions(unit_height);

    // Screw hole X position (center of bracket wall)
    screw_x = bracket_width / 2;
    // Screw hole Z position (center of bracket top section)
    screw_z = faceplate_thickness + bracket_depth + bracket_thickness / 2;

    difference() {
        union() {
            // Faceplate section (optional)
            if (include_faceplate) {
                translate([0, -panel_height/2, 0])
                    cube([faceplate_width, panel_height, faceplate_thickness]);
            }

            // Bracket extending inward from faceplate
            translate([0, 0, 0])
                joiner_bracket(
                    unit_height = unit_height,
                    bracket_width = bracket_width,
                    bracket_depth = bracket_depth,
                    bracket_thickness = bracket_thickness,
                    fn = fn
                );
        }

        // Screw clearance holes (horizontal, going through bracket)
        for (y_pos = screw_positions) {
            // Through hole
            translate([screw_x, y_pos, screw_z])
                rotate([0, 90, 0])
                    cylinder(h = bracket_width + 2, d = M5_CLEARANCE_HOLE, center = true, $fn = fn);

            // Hex nut pocket (on the outer face of bracket)
            translate([bracket_width - M5_HEX_NUT_POCKET_DEPTH + 0.1, y_pos, screw_z])
                rotate([0, 90, 0])
                    linear_extrude(height = M5_HEX_NUT_POCKET_DEPTH + 0.1)
                        hexagon_2d(M5_HEX_NUT_POCKET_AF);
        }
    }
}


/**
 * Creates both left and right joiners side by side for printing
 *
 * @param unit_height - Height in rack units
 * @param faceplate_width - Width of each faceplate section
 * @param spacing - Gap between parts
 * @param fn - Curve resolution
 */
module faceplate_joiner_pair(
    unit_height = 1,
    faceplate_width = 60,
    spacing = 10,
    fn = 32
) {
    // Left side (blue)
    color("SteelBlue")
        translate([-faceplate_width - spacing/2, 0, 0])
            faceplate_joiner_left(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );

    // Right side (coral)
    color("Coral")
        translate([spacing/2, 0, 0])
            faceplate_joiner_right(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );
}


/**
 * Creates an assembled view showing how the parts mate
 *
 * @param unit_height - Height in rack units
 * @param faceplate_width - Width of each faceplate section
 * @param explode - Separation distance for exploded view
 * @param fn - Curve resolution
 */
module faceplate_joiner_assembled(
    unit_height = 1,
    faceplate_width = 60,
    explode = 0,
    fn = 32
) {
    bracket_width = BRACKET_WIDTH;

    // Left side
    color("SteelBlue", 0.8)
        translate([-faceplate_width - explode/2, 0, 0])
            faceplate_joiner_left(
                unit_height = unit_height,
                faceplate_width = faceplate_width,
                include_faceplate = true,
                fn = fn
            );

    // Right side (flipped to mate)
    color("Coral", 0.8)
        translate([explode/2, 0, 0])
            mirror([1, 0, 0])
                faceplate_joiner_right(
                    unit_height = unit_height,
                    faceplate_width = faceplate_width,
                    include_faceplate = true,
                    fn = fn
                );
}


/**
 * Creates just the bracket portion for adding to existing faceplates
 * Use this with union() to add a joiner bracket to your faceplate
 *
 * @param unit_height - Height in rack units
 * @param side - "left" for screw holes, "right" for hex nut pockets
 * @param fn - Curve resolution
 */
module joiner_bracket_addon(
    unit_height = 1,
    side = "left",
    fn = 32
) {
    if (side == "left") {
        faceplate_joiner_left(
            unit_height = unit_height,
            include_faceplate = false,
            fn = fn
        );
    } else {
        faceplate_joiner_right(
            unit_height = unit_height,
            include_faceplate = false,
            fn = fn
        );
    }
}


// ============================================================================
// Preview / Testing
// ============================================================================

// Uncomment one of these to preview:

// Single left joiner (1U, 3 screws)
// faceplate_joiner_left(unit_height=1);

// Single right joiner (1U, 3 screws)
// faceplate_joiner_right(unit_height=1);

// Pair side by side (1U)
// faceplate_joiner_pair(unit_height=1);

// Assembled view (1U)
// faceplate_joiner_assembled(unit_height=1, explode=0);

// Exploded view (1U)
// faceplate_joiner_assembled(unit_height=1, explode=20);

// 2U version with 6 screws
// faceplate_joiner_pair(unit_height=2);
