/*
 * Rack Scad - Rack Mount Common Definitions
 * Shared variables and modules for rack mount types
 */

include <../components/print_config.scad>
include <../components/constants.scad>
use <../components/screws.scad>

// ============================================================================
// RACK FRAME CONFIGURATION
// Based on EIA-310 standard
// ============================================================================

// Standard 19" rack internal width (between mounting rails)
RACK_19_INTERNAL_WIDTH = 450;  // ~17.75"

// Standard 10" rack internal width
RACK_10_INTERNAL_WIDTH = 222.25;  // ~8.75"

// EIA unit height
EIA_UNIT_HEIGHT = 44.45;

// Screw spacing between rack mount holes (center to center)
RACK_SCREW_SPACING = EIA_UNIT_HEIGHT;  // Same as 1U

// Distance from screw center to inner edge of rail
RAIL_SCREW_TO_INNER_EDGE = 5;

// ============================================================================
// RACK SIZE PROFILES
// Pre-configured sizes for common rack setups
// ============================================================================

// Profile: [maxUnitWidth, maxUnitDepth, screwSpacing, screwType]
PROFILE_NANO = [105, 105, EIA_UNIT_HEIGHT, "M3"];
PROFILE_MICRO = [135, 135, EIA_UNIT_HEIGHT, "M3"];
PROFILE_MINI = [165, 165, EIA_UNIT_HEIGHT, "M4"];
PROFILE_DEFAULT = [205, 205, EIA_UNIT_HEIGHT, "M4"];
PROFILE_FULL_10 = [222.25, 300, EIA_UNIT_HEIGHT, "M5"];
PROFILE_FULL_19 = [450, 600, EIA_UNIT_HEIGHT, "M5"];

// Current active profile - change this to switch sizes
ACTIVE_PROFILE = PROFILE_MINI;

// Extract profile values
maxUnitWidth = ACTIVE_PROFILE[0];
maxUnitDepth = ACTIVE_PROFILE[1];
screwDiff = ACTIVE_PROFILE[2];    // Spacing between rack screws
mainRailScrewType = ACTIVE_PROFILE[3];

// ============================================================================
// RACK MOUNT DIMENSIONS
// ============================================================================

// Distance from edge of faceplate to screw center
rackMountScrewXDist = 4.5;
rackMountScrewZDist = 4.5;

// Calculate the width between rack mount screws
rackMountScrewWidth = maxUnitWidth - 2 * RAIL_SCREW_TO_INNER_EDGE;

// Distance from rail screw hole to inner edge of equipment space
railScrewHoleToInnerEdge = RAIL_SCREW_TO_INNER_EDGE;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Calculate number of rack units needed for a given height
function calculate_units(height) = ceil(height / EIA_UNIT_HEIGHT);

// Calculate actual height for a given number of units
function unit_height(units) = units * EIA_UNIT_HEIGHT;

// Calculate plate dimensions for given units
function plate_length(units) = rackMountScrewWidth + 2 * rackMountScrewXDist;
function plate_height(units) = units * screwDiff + 2 * rackMountScrewZDist;

// ============================================================================
// RACK EAR MODULE
// Common L-bracket ear for all mount types
// ============================================================================

/*
 * Create a rack mounting ear
 *
 * Parameters:
 *   u - Number of rack units
 *   frontThickness - Thickness of front face
 *   sideThickness - Thickness of side face
 *   frontWidth - Width of front face
 *   sideDepth - Depth of side face
 *   backPlaneHeight - Height of back connection plane
 *   support - Add diagonal support
 */
module rack_ear(
    u = 1,
    frontThickness = 3,
    sideThickness = 3,
    frontWidth = 20,
    sideDepth = 50,
    backPlaneHeight = 10,
    support = true
) {
    earHeight = u * screwDiff + 2 * rackMountScrewZDist;

    difference() {
        translate([-rackMountScrewXDist, 0, -rackMountScrewZDist]) {
            // Front plate
            cube([frontWidth, frontThickness, earHeight]);

            // Side plate
            hull() {
                translate([frontWidth - sideThickness, 0, 0])
                cube([sideThickness, frontThickness, earHeight]);

                translate([frontWidth - sideThickness, sideDepth, 0])
                cube([sideThickness, eps, backPlaneHeight]);
            }

            // Diagonal support
            if (support) {
                supportStart = rackMountScrewXDist + railScrewHoleToInnerEdge + 1;
                if (frontWidth - supportStart > sideThickness) {
                    hull() {
                        translate([supportStart, frontThickness, 0])
                        cube([sideThickness, eps, earHeight]);

                        translate([frontWidth - sideThickness, sideDepth, 0])
                        cube([sideThickness, eps, backPlaneHeight]);
                    }
                }
            }
        }

        // Screw holes
        _rack_mount_holes(u);
    }
}

/*
 * Create rack mount screw holes
 */
module _rack_mount_holes(u) {
    for (i = [0:u]) {
        translate([0, 0, i * screwDiff])
        rotate([90, 0, 0])
        cylinder(r = screw_radius_slacked(mainRailScrewType), h = inf, center = true, $fn = 32);
    }
}

// ============================================================================
// BASE PLATE MODULE
// Common plate for faceplates and panels
// ============================================================================

/*
 * Create a base plate with rack mount holes
 *
 * Parameters:
 *   U - Number of rack units
 *   plateThickness - Thickness of the plate
 *   screwType - Screw type for mounting holes
 *   screwToXEdge - Distance from screw to X edge
 *   screwToYEdge - Distance from screw to Y edge
 *   filletR - Corner fillet radius
 */
module plate_base(
    U = 1,
    plateThickness = 3,
    screwType = "M4",
    screwToXEdge = 4.5,
    screwToYEdge = 4.5,
    filletR = 2
) {
    plateLength = rackMountScrewWidth + 2 * screwToXEdge;
    plateHeight = U * screwDiff + 2 * screwToYEdge;

    difference() {
        // Main plate with rounded corners
        linear_extrude(plateThickness)
        offset(r = filletR, $fn = 32)
        offset(delta = -filletR)
        square([plateLength, plateHeight], center = false);

        // Mounting holes
        for (x = [screwToXEdge, plateLength - screwToXEdge]) {
            for (y = [screwToYEdge, plateHeight - screwToYEdge]) {
                translate([x, y, -eps])
                cylinder(r = screw_radius_slacked(screwType), h = plateThickness + 2 * eps, $fn = 32);
            }
        }
    }
}

// ============================================================================
// POSITIVE/NEGATIVE OPERATION HELPER
// ============================================================================

/*
 * Helper module to apply positive and negative operations
 * Used for adding mount points with countersunk holes
 */
module apply_pn() {
    difference() {
        union() {
            children(0);  // Positive volumes
            children(2);  // Base object
        }
        children(1);      // Negative volumes
    }
}
