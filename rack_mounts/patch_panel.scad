/*
 * Rack Scad - Patch Panel Rack Mount Type
 * Linear array of keystone module slots
 *
 * Use this for network patch panels, audio/video panels,
 * or any modular connector system.
 */

include <common.scad>
use <../components/keystone.scad>

// ============================================================================
// KEYSTONE MODULE DIMENSIONS
// Standard keystone jack dimensions
// ============================================================================

KEYSTONE_WIDTH = 14.5;          // Standard keystone width
KEYSTONE_HEIGHT = 16;           // Standard keystone height (opening)
KEYSTONE_SPACING = 19;          // Center-to-center spacing
KEYSTONE_DEPTH = 18;            // Depth of keystone module

// Slot types:
// 1 = Type 1 keystone (snap-in from front)
// 2 = Type 2 keystone (snap-in from rear)
// 3 = Blank plate
// 4 = Thick blank (5.9mm)
// 5 = Extra thick blank (9.9mm)

// ============================================================================
// MAIN PATCH PANEL MODULE
// ============================================================================

/*
 * Create a keystone patch panel
 *
 * Parameters:
 *   slots - Array of slot types [1, 1, 2, 3, 1, ...] or count
 *   u - Rack units (default 2U for standard panels)
 *   plateThickness - Panel thickness
 *   screwToXEdge - Distance from screw to edge
 *   screwToYEdge - Distance from screw to edge
 *   keystoneSpacing - Spacing between keystones
 *   centered - Center the keystone array
 */
module patch_panel(
    slots = [1, 1, 1, 1, 1, 1],
    u = 2,
    plateThickness = 3,
    screwToXEdge = 4.5,
    screwToYEdge = 4.5,
    keystoneSpacing = KEYSTONE_SPACING,
    centered = true
) {
    // Handle both array and count inputs
    slotArray = is_list(slots) ? slots : [for (i = [0:slots-1]) 1];
    slotCount = len(slotArray);

    slotsWidth = slotCount * keystoneSpacing;
    slotsMinPadding = railScrewHoleToInnerEdge + 4;

    plateLength = rackMountScrewWidth + 2 * screwToXEdge;
    plateHeight = u * screwDiff + 2 * screwToYEdge;

    leftRailScrewToSlots = centered
        ? (plateLength - slotsWidth - slotsMinPadding) / 2
        : slotsMinPadding;

    difference() {
        // Base plate with mounting holes
        plate_base(
            U = u,
            plateThickness = plateThickness,
            screwType = mainRailScrewType,
            screwToXEdge = screwToXEdge,
            screwToYEdge = screwToYEdge,
            filletR = 2
        );

        // Cutout for keystone area
        translate([leftRailScrewToSlots, screwToYEdge, -eps])
        cube([slotsWidth, plateHeight - 2 * screwToYEdge, plateThickness + 2 * eps]);
    }

    // Add keystone holders
    for (i = [0:slotCount - 1]) {
        slotType = slotArray[i];
        slotX = leftRailScrewToSlots + keystoneSpacing / 2 + i * keystoneSpacing;
        slotY = plateHeight / 2;

        translate([slotX, slotY, 0])
        _keystone_slot(slotType, keystoneSpacing, plateHeight - 2 * screwToYEdge, plateThickness);
    }
}

/*
 * Internal: Create individual keystone slot
 */
module _keystone_slot(slotType, outerWidth, outerHeight, plateThickness) {
    if (slotType == 1) {
        // Type 1: Standard snap-in keystone holder
        keystone_holder_type1(outerWidth, outerHeight, plateThickness);
    } else if (slotType == 2) {
        // Type 2: Rear-insert keystone holder
        keystone_holder_type2(outerWidth, outerHeight, plateThickness);
    } else if (slotType == 3) {
        // Blank plate
        _blank_plate(outerWidth, outerHeight, plateThickness);
    } else if (slotType == 4) {
        // Thick blank
        _blank_plate(outerWidth, outerHeight, 5.9);
    } else if (slotType == 5) {
        // Extra thick blank
        _blank_plate(outerWidth, outerHeight, 9.9);
    }
}

// ============================================================================
// KEYSTONE HOLDER TYPE 1 (FRONT SNAP-IN)
// ============================================================================

/*
 * Create a Type 1 keystone holder
 * Keystone snaps in from the front
 */
module keystone_holder_type1(outerWidth, outerHeight, thickness) {
    wallThickness = (outerWidth - KEYSTONE_WIDTH) / 2 - xySlack;
    slotHeight = KEYSTONE_HEIGHT + 2 * xySlack;

    // Side walls with snap hooks
    difference() {
        union() {
            // Left wall
            translate([-outerWidth/2, -outerHeight/2, 0])
            cube([wallThickness, outerHeight, thickness]);

            // Right wall
            translate([outerWidth/2 - wallThickness, -outerHeight/2, 0])
            cube([wallThickness, outerHeight, thickness]);

            // Top bar
            translate([-outerWidth/2, outerHeight/2 - 3, 0])
            cube([outerWidth, 3, thickness]);

            // Bottom bar with relief for keystone latch
            translate([-outerWidth/2, -outerHeight/2, 0])
            cube([outerWidth, 3, thickness]);

            // Snap hooks
            _keystone_snap_hooks(outerWidth, thickness);
        }

        // Keystone opening
        translate([-KEYSTONE_WIDTH/2 - xySlack, -slotHeight/2, -eps])
        cube([KEYSTONE_WIDTH + 2*xySlack, slotHeight, thickness + 2*eps]);
    }
}

/*
 * Internal: Create snap hooks for keystone
 */
module _keystone_snap_hooks(width, thickness) {
    hookWidth = 1.5;
    hookDepth = 2;
    hookHeight = 4;

    // Left hook
    translate([-width/2 + hookWidth, 0, thickness])
    rotate([0, -45, 0])
    cube([hookWidth, hookHeight, hookDepth], center = true);

    // Right hook
    translate([width/2 - hookWidth, 0, thickness])
    rotate([0, 45, 0])
    cube([hookWidth, hookHeight, hookDepth], center = true);
}

// ============================================================================
// KEYSTONE HOLDER TYPE 2 (REAR INSERT)
// ============================================================================

/*
 * Create a Type 2 keystone holder
 * Keystone inserts from the rear
 */
module keystone_holder_type2(outerWidth, outerHeight, thickness) {
    wallThickness = (outerWidth - KEYSTONE_WIDTH) / 2 - xySlack;
    frontOpening = KEYSTONE_WIDTH - 3;  // Slightly smaller front opening
    slotHeight = KEYSTONE_HEIGHT + 2 * xySlack;

    difference() {
        union() {
            // Left wall
            translate([-outerWidth/2, -outerHeight/2, 0])
            cube([wallThickness + 1.5, outerHeight, thickness]);

            // Right wall
            translate([outerWidth/2 - wallThickness - 1.5, -outerHeight/2, 0])
            cube([wallThickness + 1.5, outerHeight, thickness]);

            // Top retention bar
            translate([-outerWidth/2, outerHeight/2 - 3, 0])
            cube([outerWidth, 3, thickness + 2]);

            // Bottom retention bar
            translate([-outerWidth/2, -outerHeight/2, 0])
            cube([outerWidth, 3, thickness + 2]);
        }

        // Front opening (smaller, keystone face shows through)
        translate([-frontOpening/2, -slotHeight/2, -eps])
        cube([frontOpening, slotHeight, thickness + 3]);

        // Rear opening (full keystone size for insertion)
        translate([-KEYSTONE_WIDTH/2 - xySlack, -slotHeight/2, thickness - 1])
        cube([KEYSTONE_WIDTH + 2*xySlack, slotHeight, 4]);
    }
}

// ============================================================================
// BLANK PLATE
// ============================================================================

/*
 * Create a blank plate for unused slots
 */
module _blank_plate(outerWidth, outerHeight, thickness) {
    translate([-outerWidth/2, -outerHeight/2, 0])
    cube([outerWidth, outerHeight, thickness]);
}

// ============================================================================
// LABELED PATCH PANEL
// ============================================================================

/*
 * Create a patch panel with labels
 *
 * Parameters:
 *   slots - Array of slot types
 *   labels - Array of label strings
 *   labelHeight - Height of label area
 *   ... (other parameters same as patch_panel)
 */
module labeled_patch_panel(
    slots = [1, 1, 1, 1],
    labels = [],
    labelHeight = 8,
    u = 2,
    plateThickness = 3,
    keystoneSpacing = KEYSTONE_SPACING
) {
    // Main panel (shifted down to make room for labels)
    translate([0, labelHeight/2, 0])
    patch_panel(
        slots = slots,
        u = u,
        plateThickness = plateThickness,
        keystoneSpacing = keystoneSpacing
    );

    // Label area at top
    slotCount = is_list(slots) ? len(slots) : slots;
    slotsWidth = slotCount * keystoneSpacing;
    plateLength = rackMountScrewWidth + 2 * 4.5;
    leftOffset = (plateLength - slotsWidth) / 2;

    // Label strip (raised area for writing/labeling)
    color("White")
    translate([leftOffset, u * screwDiff + 4.5, plateThickness])
    cube([slotsWidth, labelHeight, 0.5]);
}

// ============================================================================
// EXAMPLE
// ============================================================================

module patch_panel_example() {
    // Basic 6-port patch panel
    color("SteelBlue")
    patch_panel(
        slots = [1, 1, 1, 1, 1, 1],
        u = 2,
        centered = true
    );

    // Mixed slot types (offset for visibility)
    color("Coral")
    translate([0, 100, 0])
    patch_panel(
        slots = [1, 1, 2, 3, 1, 1],  // Type1, Type1, Type2, Blank, Type1, Type1
        u = 2
    );

    // 12-port panel
    color("LightGreen")
    translate([0, 200, 0])
    patch_panel(
        slots = [for (i = [0:11]) 1],  // 12 Type 1 slots
        u = 2
    );
}

// Uncomment to preview:
// patch_panel_example();
