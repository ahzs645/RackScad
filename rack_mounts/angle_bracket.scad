/*
 * Rack Scad - Angle Bracket Rack Mount Type
 * Simple L-shaped brackets for mounting equipment
 *
 * Use this for equipment that has its own mounting holes
 * but needs adapters for rack mounting.
 */

include <common.scad>

// ============================================================================
// ANGLE BRACKET CONFIGURATION
// ============================================================================

DEFAULT_BRACKET_THICKNESS = 3;
DEFAULT_BRACKET_DEPTH = 80;
DEFAULT_BRACKET_WIDTH = 150;

// ============================================================================
// MAIN ANGLE BRACKET SYSTEM
// ============================================================================

/*
 * Create a pair of angle brackets for rack mounting
 *
 * Parameters:
 *   boxWidth - Width of the equipment (space between brackets)
 *   boxDepth - Depth/length of the equipment
 *   u - Rack units
 *   thickness - Bracket material thickness
 *   sideVent - Add ventilation slots
 *   visualize - Show equipment outline
 *   splitForPrint - Separate parts for printing
 */
module angle_brackets(
    boxWidth = DEFAULT_BRACKET_WIDTH,
    boxDepth = DEFAULT_BRACKET_DEPTH,
    u = 2,
    thickness = DEFAULT_BRACKET_THICKNESS,
    sideVent = false,
    visualize = false,
    splitForPrint = false
) {
    bracketHeight = u * EIA_UNIT_HEIGHT - 2 * thickness;
    bracketBaseWidth = 15;

    if (visualize) {
        // Show equipment outline
        %translate([thickness, 0, thickness])
        cube([boxWidth, boxDepth, bracketHeight]);
    }

    if (splitForPrint) {
        // Left bracket
        color("SteelBlue")
        angle_bracket_single(
            depth = boxDepth,
            height = bracketHeight,
            thickness = thickness,
            baseWidth = bracketBaseWidth,
            u = u,
            sideVent = sideVent
        );

        // Right bracket (mirrored and offset)
        color("SteelBlue")
        translate([bracketBaseWidth * 2 + 20, 0, 0])
        mirror([1, 0, 0])
        translate([-bracketBaseWidth, 0, 0])
        angle_bracket_single(
            depth = boxDepth,
            height = bracketHeight,
            thickness = thickness,
            baseWidth = bracketBaseWidth,
            u = u,
            sideVent = sideVent
        );
    } else {
        // Assembled position
        // Left bracket
        color("SteelBlue")
        angle_bracket_single(
            depth = boxDepth,
            height = bracketHeight,
            thickness = thickness,
            baseWidth = bracketBaseWidth,
            u = u,
            sideVent = sideVent
        );

        // Right bracket
        color("SteelBlue")
        translate([boxWidth + 2 * thickness, 0, 0])
        mirror([1, 0, 0])
        angle_bracket_single(
            depth = boxDepth,
            height = bracketHeight,
            thickness = thickness,
            baseWidth = bracketBaseWidth,
            u = u,
            sideVent = sideVent
        );
    }
}

// ============================================================================
// SINGLE ANGLE BRACKET
// ============================================================================

/*
 * Create a single angle bracket
 *
 * Parameters:
 *   depth - Length of the bracket
 *   height - Vertical height of the side wall
 *   thickness - Material thickness
 *   baseWidth - Width of bottom flange
 *   u - Rack units
 *   sideVent - Add ventilation slots
 *   mountingHoles - Add holes for mounting equipment
 *   mountingHoleSpacing - Spacing of mounting holes
 *   mountingHoleType - Screw type for mounting holes
 */
module angle_bracket_single(
    depth = DEFAULT_BRACKET_DEPTH,
    height = 40,
    thickness = DEFAULT_BRACKET_THICKNESS,
    baseWidth = 15,
    u = 2,
    sideVent = false,
    mountingHoles = false,
    mountingHoleSpacing = 30,
    mountingHoleType = "M3"
) {
    totalHeight = height + 2 * thickness;

    difference() {
        union() {
            // Bottom flange
            cube([baseWidth, depth, thickness]);

            // Side wall
            cube([thickness, depth, totalHeight]);

            // Top flange
            translate([0, 0, totalHeight - thickness])
            cube([baseWidth, depth, thickness]);

            // Rack mounting ear
            translate([0, 0, rackMountScrewZDist])
            rack_ear(
                u = u,
                frontThickness = thickness,
                sideThickness = thickness,
                frontWidth = baseWidth + rackMountScrewXDist,
                sideDepth = depth,
                backPlaneHeight = totalHeight - rackMountScrewZDist,
                support = true
            );
        }

        // Ventilation slots
        if (sideVent) {
            _bracket_vent_slots(thickness, depth, totalHeight);
        }

        // Equipment mounting holes
        if (mountingHoles) {
            _bracket_mount_holes(baseWidth, depth, thickness, mountingHoleSpacing, mountingHoleType);
        }
    }
}

/*
 * Internal: Add ventilation slots
 */
module _bracket_vent_slots(sideThickness, depth, height) {
    slotWidth = 3;
    slotSpacing = 10;
    margin = 15;

    for (y = [margin:slotSpacing:depth - margin]) {
        translate([-eps, y, height * 0.2])
        cube([sideThickness + 2 * eps, slotWidth, height * 0.6]);
    }
}

/*
 * Internal: Add mounting holes
 */
module _bracket_mount_holes(baseWidth, depth, thickness, spacing, screwType) {
    holeRadius = screw_radius_slacked(screwType);
    margin = 10;
    holeY = margin;

    // Holes along the depth
    while (holeY < depth - margin) {
        // Bottom flange holes
        translate([baseWidth / 2, holeY, -eps])
        cylinder(r = holeRadius, h = thickness + 2 * eps, $fn = 32);

        holeY = holeY + spacing;
    }
}

// ============================================================================
// ADJUSTABLE ANGLE BRACKET
// With slotted holes for positioning
// ============================================================================

/*
 * Create an angle bracket with slotted mounting holes
 * Allows adjustment of equipment position
 */
module adjustable_angle_bracket(
    depth = 100,
    height = 40,
    thickness = 3,
    baseWidth = 20,
    u = 2,
    slotLength = 15,
    slotWidth = 4
) {
    totalHeight = height + 2 * thickness;

    difference() {
        // Basic bracket shape
        angle_bracket_single(
            depth = depth,
            height = height,
            thickness = thickness,
            baseWidth = baseWidth,
            u = u,
            sideVent = false,
            mountingHoles = false
        );

        // Slotted holes in bottom flange
        slotSpacing = 30;
        margin = 15;

        for (y = [margin:slotSpacing:depth - margin]) {
            translate([baseWidth / 2, y, -eps])
            hull() {
                translate([-slotLength / 2, 0, 0])
                cylinder(r = slotWidth / 2, h = thickness + 2 * eps, $fn = 32);
                translate([slotLength / 2, 0, 0])
                cylinder(r = slotWidth / 2, h = thickness + 2 * eps, $fn = 32);
            }
        }

        // Slotted holes in top flange
        for (y = [margin:slotSpacing:depth - margin]) {
            translate([baseWidth / 2, y, totalHeight - thickness - eps])
            hull() {
                translate([-slotLength / 2, 0, 0])
                cylinder(r = slotWidth / 2, h = thickness + 2 * eps, $fn = 32);
                translate([slotLength / 2, 0, 0])
                cylinder(r = slotWidth / 2, h = thickness + 2 * eps, $fn = 32);
            }
        }
    }
}

// ============================================================================
// UNIVERSAL MOUNTING PLATE
// Flat plate with grid of mounting holes
// ============================================================================

/*
 * Create a universal mounting plate with hole grid
 * Attaches to angle brackets for flexible equipment mounting
 */
module universal_mount_plate(
    width = 100,
    depth = 80,
    thickness = 3,
    holeSpacing = 20,
    holeType = "M3",
    margin = 10
) {
    holeRadius = screw_radius_slacked(holeType);

    difference() {
        // Base plate
        cube([width, depth, thickness]);

        // Grid of holes
        for (x = [margin:holeSpacing:width - margin]) {
            for (y = [margin:holeSpacing:depth - margin]) {
                translate([x, y, -eps])
                cylinder(r = holeRadius, h = thickness + 2 * eps, $fn = 32);
            }
        }
    }
}

// ============================================================================
// EXAMPLE
// ============================================================================

module angle_bracket_example() {
    // Basic bracket pair
    color("SteelBlue")
    angle_brackets(
        boxWidth = 140,
        boxDepth = 100,
        u = 2,
        visualize = true
    );

    // Split for printing
    translate([0, 150, 0])
    angle_brackets(
        boxWidth = 140,
        boxDepth = 100,
        u = 2,
        splitForPrint = true
    );

    // Adjustable bracket
    color("Coral")
    translate([200, 0, 0])
    adjustable_angle_bracket(
        depth = 100,
        height = 35,
        u = 2
    );

    // Universal mount plate
    color("LightGreen")
    translate([200, 150, 0])
    universal_mount_plate(
        width = 100,
        depth = 80
    );
}

// Uncomment to preview:
// angle_bracket_example();
