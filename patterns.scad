/**
 * Rack Shelf Library - Ventilation Patterns
 *
 * Cutout patterns for airflow and weight reduction
 * All patterns are centered on origin for easy positioning
 *
 * Patterns auto-scale to prevent CSG complexity issues
 *
 * Author: Generated with Claude
 * License: MIT
 */

/* [Pattern Parameters] */
// Max elements to generate (prevents CSG overload)
MAX_PATTERN_ELEMENTS = 500;

// Minimum hole size
MIN_HOLE_SIZE = 6;

/**
 * Calculate adaptive hole size to limit element count
 */
function adaptive_size(width, height, base_size, spacing) =
    let(
        step = base_size + spacing,
        cols = floor(width / step),
        rows = floor(height / step),
        count = cols * rows
    )
    count > MAX_PATTERN_ELEMENTS ?
        let(scale = sqrt(count / MAX_PATTERN_ELEMENTS))
        max(base_size * scale, MIN_HOLE_SIZE) :
        max(base_size, MIN_HOLE_SIZE);

/**
 * Honeycomb pattern cutout (3D)
 * Creates a hex grid pattern for excellent airflow
 * Auto-scales to prevent complexity issues
 *
 * @param width Pattern width
 * @param height Pattern height
 * @param thickness Extrusion thickness
 * @param hex_dia Hexagon diameter (will be scaled up for large areas)
 * @param wall Wall thickness between hexagons
 */
module honeycomb_cutout(width, height, thickness, hex_dia=10, wall=2.5) {
    // Adaptive sizing
    adj_dia = adaptive_size(width, height, hex_dia, wall);
    adj_wall = wall * (adj_dia / hex_dia);

    small_dia = adj_dia * cos(30);
    proj_wall = adj_wall * cos(30);

    y_step = small_dia + adj_wall;
    x_step = adj_dia * 3/4 * 2 + proj_wall * 2;

    cols = ceil(width / x_step) + 1;
    rows = ceil(height / y_step) + 1;

    translate([-width/2, -height/2, 0])
    intersection() {
        cube([width, height, thickness]);
        translate([adj_dia/2, adj_dia/2, 0])
        for (i = [0 : rows - 1]) {
            for (j = [0 : cols - 1]) {
                translate([j * x_step, i * y_step, -0.1])
                    cylinder(h=thickness + 0.2, d=adj_dia, $fn=6);
                translate([j * x_step + adj_dia*3/4 + proj_wall, i * y_step + y_step/2, -0.1])
                    cylinder(h=thickness + 0.2, d=adj_dia, $fn=6);
            }
        }
    }
}

/**
 * Honeycomb solid with holes (inverse of cutout)
 * Use with difference() to create ventilation
 */
module honeycomb_solid(width, height, thickness, hex_dia=10, wall=2.5) {
    difference() {
        translate([-width/2, -height/2, 0])
            cube([width, height, thickness]);
        honeycomb_cutout(width, height, thickness + 0.2, hex_dia, wall);
    }
}

/**
 * Grid pattern cutout (3D)
 * Creates a square grid pattern
 */
module grid_cutout(width, height, thickness, hole_size=12, spacing=4) {
    adj_size = adaptive_size(width, height, hole_size, spacing);
    adj_spacing = spacing * (adj_size / hole_size);

    step = adj_size + adj_spacing;
    cols = max(1, floor(width / step));
    rows = max(1, floor(height / step));

    x_offset = (width - (cols * step - adj_spacing)) / 2;
    y_offset = (height - (rows * step - adj_spacing)) / 2;

    translate([-width/2, -height/2, 0])
    intersection() {
        cube([width, height, thickness]);
        translate([x_offset, y_offset, -0.1])
        for (i = [0 : rows - 1]) {
            for (j = [0 : cols - 1]) {
                translate([j * step, i * step, 0])
                    cube([adj_size, adj_size, thickness + 0.2]);
            }
        }
    }
}

/**
 * Slot pattern cutout (3D)
 * Creates horizontal or vertical slot vents
 * Slots are more efficient - fewer elements needed
 */
module slot_cutout(width, height, thickness, slot_length=40, slot_width=5, spacing=8, horizontal=true) {
    slot_spacing = slot_width + spacing;
    gap = 12;  // Gap between slot columns/rows

    if (horizontal) {
        rows = max(1, floor(height / slot_spacing));
        y_offset = (height - (rows * slot_spacing - spacing)) / 2;
        cols = max(1, floor((width - gap) / (slot_length + gap)));
        x_offset = (width - (cols * (slot_length + gap) - gap)) / 2;

        translate([-width/2, -height/2, 0])
        intersection() {
            cube([width, height, thickness]);
            translate([0, y_offset, -0.1])
            for (i = [0 : rows - 1]) {
                for (j = [0 : cols - 1]) {
                    translate([x_offset + j * (slot_length + gap), i * slot_spacing, 0])
                        hull() {
                            translate([slot_width/2, slot_width/2, 0])
                                cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                            translate([slot_length - slot_width/2, slot_width/2, 0])
                                cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                        }
                }
            }
        }
    } else {
        cols = max(1, floor(width / slot_spacing));
        x_offset = (width - (cols * slot_spacing - spacing)) / 2;
        rows = max(1, floor((height - gap) / (slot_length + gap)));
        y_offset = (height - (rows * (slot_length + gap) - gap)) / 2;

        translate([-width/2, -height/2, 0])
        intersection() {
            cube([width, height, thickness]);
            translate([x_offset, 0, -0.1])
            for (j = [0 : cols - 1]) {
                for (i = [0 : rows - 1]) {
                    translate([j * slot_spacing, y_offset + i * (slot_length + gap), 0])
                        hull() {
                            translate([slot_width/2, slot_width/2, 0])
                                cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                            translate([slot_width/2, slot_length - slot_width/2, 0])
                                cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                        }
                }
            }
        }
    }
}

/**
 * Circle pattern cutout (3D)
 * Creates a grid of circular holes
 */
module circle_cutout(width, height, thickness, hole_dia=10, spacing=6) {
    adj_dia = adaptive_size(width, height, hole_dia, spacing);
    adj_spacing = spacing * (adj_dia / hole_dia);

    step = adj_dia + adj_spacing;
    cols = max(1, floor(width / step));
    rows = max(1, floor(height / step));

    x_offset = (width - (cols * step - adj_spacing)) / 2 + adj_dia/2;
    y_offset = (height - (rows * step - adj_spacing)) / 2 + adj_dia/2;

    translate([-width/2, -height/2, 0])
    intersection() {
        cube([width, height, thickness]);
        translate([x_offset, y_offset, -0.1])
        for (i = [0 : rows - 1]) {
            for (j = [0 : cols - 1]) {
                translate([j * step, i * step, 0])
                    cylinder(h=thickness + 0.2, d=adj_dia, $fn=$preview ? 16 : 32);
            }
        }
    }
}

/**
 * Diamond pattern cutout (3D)
 * Creates a staggered diamond/rhombus pattern
 */
module diamond_cutout(width, height, thickness, diamond_size=14, spacing=5) {
    adj_size = adaptive_size(width, height, diamond_size, spacing);
    adj_spacing = spacing * (adj_size / diamond_size);

    step = adj_size + adj_spacing;
    cols = max(1, floor(width / step));
    rows = max(1, floor(height / (step * 0.866)));

    x_offset = (width - (cols * step - adj_spacing)) / 2 + adj_size/2;
    y_offset = (height - (rows * step * 0.866)) / 2 + adj_size/2;

    translate([-width/2, -height/2, 0])
    intersection() {
        cube([width, height, thickness]);
        translate([x_offset, y_offset, -0.1])
        for (i = [0 : rows - 1]) {
            for (j = [0 : cols - 1]) {
                translate([j * step + (i % 2) * step/2, i * step * 0.866, 0])
                    rotate([0, 0, 45])
                        cube([adj_size * 0.707, adj_size * 0.707, thickness + 0.2], center=true);
            }
        }
    }
}

/**
 * Simple large slot pattern - very low complexity
 * Good for previews or when you need guaranteed fast rendering
 */
module simple_slots(width, height, thickness, count=5, horizontal=true) {
    slot_width = 6;

    if (horizontal) {
        spacing = height / (count + 1);
        slot_len = width * 0.85;

        translate([0, 0, -0.1])
        for (i = [1 : count]) {
            translate([-slot_len/2, -height/2 + i * spacing - slot_width/2, 0])
                hull() {
                    translate([slot_width/2, slot_width/2, 0])
                        cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                    translate([slot_len - slot_width/2, slot_width/2, 0])
                        cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                }
        }
    } else {
        spacing = width / (count + 1);
        slot_len = height * 0.85;

        translate([0, 0, -0.1])
        for (i = [1 : count]) {
            translate([-width/2 + i * spacing - slot_width/2, -slot_len/2, 0])
                hull() {
                    translate([slot_width/2, slot_width/2, 0])
                        cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                    translate([slot_width/2, slot_len - slot_width/2, 0])
                        cylinder(h=thickness + 0.2, d=slot_width, $fn=16);
                }
        }
    }
}

/**
 * Pattern selector - use string to select pattern type
 *
 * @param pattern Pattern name: "honeycomb", "grid", "slots", "circles", "diamond", "simple", "none"
 * @param width Pattern width
 * @param height Pattern height
 * @param thickness Extrusion thickness
 */
module ventilation_pattern(pattern, width, height, thickness) {
    if (pattern == "honeycomb") {
        honeycomb_cutout(width, height, thickness);
    } else if (pattern == "grid") {
        grid_cutout(width, height, thickness);
    } else if (pattern == "slots") {
        slot_cutout(width, height, thickness);
    } else if (pattern == "slots_v") {
        slot_cutout(width, height, thickness, horizontal=false);
    } else if (pattern == "circles") {
        circle_cutout(width, height, thickness);
    } else if (pattern == "diamond") {
        diamond_cutout(width, height, thickness);
    } else if (pattern == "simple") {
        simple_slots(width, height, thickness);
    } else if (pattern == "simple_v") {
        simple_slots(width, height, thickness, horizontal=false);
    }
    // "none" or unknown = no pattern
}
