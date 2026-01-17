/*
 * Rack Scad - Enclosed Box Rack Mount Type
 * Mounting system for boxes/devices without existing mounting holes
 *
 * This system uses side rails and a front plate to hold a box.
 * The device simply slides in and is held by the rails and front.
 */

include <common.scad>

// ============================================================================
// ENCLOSED BOX CONFIGURATION
// ============================================================================

DEFAULT_BOX_WIDTH = 160;
DEFAULT_BOX_HEIGHT = 30;
DEFAULT_BOX_DEPTH = 120;

DEFAULT_RAIL_THICKNESS = 2;
DEFAULT_RAIL_SIDE_THICKNESS = 3;
DEFAULT_FRONT_PLATE_THICKNESS = 3;

// ============================================================================
// MAIN ENCLOSED BOX SYSTEM
// ============================================================================

/*
 * Create a complete enclosed box mounting system
 * Generates side rails and front plate
 *
 * Parameters:
 *   boxWidth - Width of the box to mount
 *   boxHeight - Height of the box
 *   boxDepth - Depth of the box
 *   railThickness - Thickness of rail bottom/top
 *   railSideThickness - Thickness of rail sides
 *   frontPlateThickness - Thickness of front plate
 *   frontCutoutXSpace - X margin for front cutout
 *   frontCutoutYSpace - Y margin for front cutout
 *   zOrientation - "middle" or "bottom" placement
 *   visualize - Show box preview
 *   splitForPrint - Separate parts for printing
 */
module enclosed_box_system(
    boxWidth = DEFAULT_BOX_WIDTH,
    boxHeight = DEFAULT_BOX_HEIGHT,
    boxDepth = DEFAULT_BOX_DEPTH,
    railThickness = DEFAULT_RAIL_THICKNESS,
    railSideThickness = DEFAULT_RAIL_SIDE_THICKNESS,
    frontPlateThickness = DEFAULT_FRONT_PLATE_THICKNESS,
    frontCutoutXSpace = 5,
    frontCutoutYSpace = 3,
    zOrientation = "middle",
    visualize = false,
    splitForPrint = false
) {
    // Calculate required rack units
    u = _find_u(boxHeight, railThickness, zOrientation);
    totalRackHeight = u * EIA_UNIT_HEIGHT;

    // Rail bottom thickness based on orientation
    railBottomThickness = _rail_bottom_thickness(u, boxHeight, railThickness, zOrientation);

    // Positions
    sideRailBaseWidth = 15;  // Width of each side rail

    if (visualize) {
        // Show the box being mounted
        %translate([railSideThickness, 0, railBottomThickness])
        cube([boxWidth, boxDepth, boxHeight]);
    }

    if (splitForPrint) {
        // Spread parts out for printing
        // Left rail
        color("SteelBlue")
        side_support_rail(
            boxHeight = boxHeight,
            boxDepth = boxDepth,
            boxWidth = boxWidth,
            railThickness = railThickness,
            railSideThickness = railSideThickness,
            hasTop = true,
            zOrientation = zOrientation
        );

        // Right rail
        color("SteelBlue")
        translate([sideRailBaseWidth * 2 + 10, 0, 0])
        mirror([1, 0, 0])
        translate([-sideRailBaseWidth, 0, 0])
        side_support_rail(
            boxHeight = boxHeight,
            boxDepth = boxDepth,
            boxWidth = boxWidth,
            railThickness = railThickness,
            railSideThickness = railSideThickness,
            hasTop = true,
            zOrientation = zOrientation
        );

        // Front plate
        color("Coral")
        translate([0, -50, 0])
        front_box_holder(
            boxWidth = boxWidth,
            boxHeight = boxHeight,
            plateThickness = frontPlateThickness,
            cutoutXSpace = frontCutoutXSpace,
            cutoutYSpace = frontCutoutYSpace,
            u = u,
            railBottomThickness = railBottomThickness,
            zOrientation = zOrientation
        );
    } else {
        // Assembled view
        // Left rail
        color("SteelBlue")
        side_support_rail(
            boxHeight = boxHeight,
            boxDepth = boxDepth,
            boxWidth = boxWidth,
            railThickness = railThickness,
            railSideThickness = railSideThickness,
            hasTop = true,
            zOrientation = zOrientation
        );

        // Right rail
        color("SteelBlue")
        translate([boxWidth + 2 * railSideThickness, 0, 0])
        mirror([1, 0, 0])
        side_support_rail(
            boxHeight = boxHeight,
            boxDepth = boxDepth,
            boxWidth = boxWidth,
            railThickness = railThickness,
            railSideThickness = railSideThickness,
            hasTop = true,
            zOrientation = zOrientation
        );

        // Front plate
        color("Coral")
        translate([railSideThickness - (rackMountScrewWidth - boxWidth) / 2, 0, railBottomThickness])
        mirror([0, 1, 0])
        rotate([90, 0, 0])
        front_box_holder(
            boxWidth = boxWidth,
            boxHeight = boxHeight,
            plateThickness = frontPlateThickness,
            cutoutXSpace = frontCutoutXSpace,
            cutoutYSpace = frontCutoutYSpace,
            u = u,
            railBottomThickness = railBottomThickness,
            zOrientation = zOrientation
        );
    }
}

// ============================================================================
// SIDE SUPPORT RAIL MODULE
// ============================================================================

/*
 * Create a side support rail
 *
 * Parameters:
 *   boxHeight - Height of box to support
 *   boxDepth - Depth of box
 *   boxWidth - Width of box (for ear calculation)
 *   railThickness - Bottom/top thickness
 *   railSideThickness - Side wall thickness
 *   hasTop - Include top rail
 *   zOrientation - "middle" or "bottom"
 *   ventilation - Add vent holes to side
 */
module side_support_rail(
    boxHeight = DEFAULT_BOX_HEIGHT,
    boxDepth = DEFAULT_BOX_DEPTH,
    boxWidth = DEFAULT_BOX_WIDTH,
    railThickness = DEFAULT_RAIL_THICKNESS,
    railSideThickness = DEFAULT_RAIL_SIDE_THICKNESS,
    hasTop = true,
    zOrientation = "middle",
    ventilation = false
) {
    u = _find_u(boxHeight, railThickness, zOrientation);
    bottomThickness = _rail_bottom_thickness(u, boxHeight, railThickness, zOrientation);
    topThickness = hasTop ? railThickness : 0;

    totalHeight = bottomThickness + boxHeight + topThickness;
    sideRailWidth = 15;

    difference() {
        union() {
            // Bottom plate
            cube([sideRailWidth, boxDepth, bottomThickness]);

            // Side wall
            cube([railSideThickness, boxDepth, totalHeight]);

            // Top plate (optional)
            if (hasTop) {
                translate([0, 0, bottomThickness + boxHeight])
                cube([sideRailWidth, boxDepth, topThickness]);
            }

            // Front ear attachment
            translate([0, 0, rackMountScrewZDist])
            rack_ear(
                u = u,
                frontThickness = railSideThickness,
                sideThickness = railSideThickness,
                frontWidth = sideRailWidth + rackMountScrewXDist,
                sideDepth = boxDepth,
                backPlaneHeight = totalHeight - rackMountScrewZDist,
                support = true
            );
        }

        // Ventilation (optional)
        if (ventilation) {
            _side_rail_vents(sideRailWidth, boxDepth, totalHeight, railSideThickness);
        }
    }
}

/*
 * Internal: Add ventilation slots to side rail
 */
module _side_rail_vents(width, depth, height, sideThick) {
    slotWidth = 3;
    slotSpacing = 8;
    margin = 10;

    for (y = [margin:slotSpacing:depth - margin]) {
        translate([-eps, y, height * 0.2])
        cube([sideThick + 2 * eps, slotWidth, height * 0.6]);
    }
}

// ============================================================================
// FRONT BOX HOLDER (FACEPLATE WITH CUTOUT)
// ============================================================================

/*
 * Create front plate with cutout for box face
 *
 * Parameters:
 *   boxWidth - Width of box
 *   boxHeight - Height of box
 *   plateThickness - Plate thickness
 *   cutoutXSpace - X margin around cutout
 *   cutoutYSpace - Y margin around cutout
 *   u - Rack units
 *   railBottomThickness - Height of bottom rail
 *   zOrientation - Vertical position
 */
module front_box_holder(
    boxWidth = DEFAULT_BOX_WIDTH,
    boxHeight = DEFAULT_BOX_HEIGHT,
    plateThickness = DEFAULT_FRONT_PLATE_THICKNESS,
    cutoutXSpace = 5,
    cutoutYSpace = 3,
    u = 1,
    railBottomThickness = 5,
    zOrientation = "middle"
) {
    plateLength = rackMountScrewWidth + 2 * rackMountScrewXDist;
    plateHeight = u * screwDiff + 2 * rackMountScrewZDist;

    cutoutWidth = boxWidth - 2 * cutoutXSpace;
    cutoutHeight = boxHeight - 2 * cutoutYSpace;
    cutoutX = (plateLength - cutoutWidth) / 2;
    cutoutY = railBottomThickness + cutoutYSpace;

    difference() {
        // Base plate
        plate_base(
            U = u,
            plateThickness = plateThickness,
            screwType = mainRailScrewType
        );

        // Cutout for box face
        translate([cutoutX, cutoutY, -eps])
        cube([cutoutWidth, cutoutHeight, plateThickness + 2 * eps]);
    }

    // Support lip below cutout
    if (zOrientation == "bottom" && cutoutY > 3) {
        translate([cutoutX - 2, cutoutY - 2, plateThickness])
        cube([cutoutWidth + 4, 2, 3]);
    }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/*
 * Calculate required rack units for a box height
 */
function _find_u(boxHeight, railThickness, zOrientation) =
    let(
        minHeight = (zOrientation == "bottom")
            ? boxHeight + railThickness
            : boxHeight + 2 * railThickness
    )
    ceil(minHeight / EIA_UNIT_HEIGHT);

/*
 * Calculate bottom rail thickness based on orientation
 */
function _rail_bottom_thickness(u, boxHeight, railThickness, zOrientation) =
    (zOrientation == "bottom")
        ? railThickness
        : (u * EIA_UNIT_HEIGHT - boxHeight - railThickness) / 2;

// ============================================================================
// EXAMPLE
// ============================================================================

module enclosed_box_example() {
    // Assembled view with visualization
    enclosed_box_system(
        boxWidth = 140,
        boxHeight = 28,
        boxDepth = 100,
        visualize = true,
        splitForPrint = false
    );

    // Parts spread for printing
    translate([0, 150, 0])
    enclosed_box_system(
        boxWidth = 140,
        boxHeight = 28,
        boxDepth = 100,
        visualize = false,
        splitForPrint = true
    );
}

// Uncomment to preview:
// enclosed_box_example();
