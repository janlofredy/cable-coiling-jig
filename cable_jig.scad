// =============================================================================
// PARAMETRIC HANDHELD CABLE COILING & STRAPPING JIG
// =============================================================================
// Compresses coiled cables into uniform, space-saving oblong or circular
// bundles, ready to be strapped with standard 1/2" (12-15mm) hook-and-loop
// (Velcro One-Wrap) cable ties.
//
// Optimized for handheld use, uniform storage in random boxes / tins / bins,
// and 100% support-free 3D printing.
// =============================================================================

/* [Preset & Mode Selection] */
// Active Preset: "S" (Small/USB), "M" (Medium/Laptop/HDMI), "L" (Large/Power), or "CUSTOM"
preset = "S"; // ["S": Small (USB & Mobile), "M": Medium (Laptop & HDMI), "L": Large (Power & Appliance), "CUSTOM": Custom Dimensions]

// Bundle Cross-Section Geometry
shape_type = "oblong"; // ["oblong": Space-Saving Stadium Shape, "circular": Classic Round Coil]

/* [Custom Dimensions (When preset == "CUSTOM")] */
custom_inner_length = 80;
custom_inner_width  = 30;
custom_inner_depth  = 30;

/* [Tolerances & Structural Parameters] */
strap_slot_width    = 16.0; // Width of strap pass-through slots (fits 1/2" / 12-15mm ties)
wall_thickness      = 3.2;  // Wall thickness (rigid, durable, 4 perimeters @ 0.4mm nozzle)
base_thickness      = 4.0;  // Solid bottom floor thickness
strap_recess_depth  = 1.2;  // Depth of strap seating bed on bottom floor
flare_height        = 6.0;  // Funnel lead-in height at top opening
flare_expansion     = 5.0;  // Lateral flare per side to easily funnel round coils
ejection_hole_dia   = 16.0; // Diameter of bottom finger push-out ports
grip_ribs_count     = 5;    // Number of tactile exterior ribs on ends

/* [Render Quality] */
$fn = 64;

// -----------------------------------------------------------------------------
// PRESET DIMENSION LOOKUPS
// -----------------------------------------------------------------------------
function get_length(p) = 
    (p == "S") ? 80 :
    (p == "M") ? 115 :
    (p == "L") ? 155 : custom_inner_length;

function get_width(p) = 
    (p == "S") ? 30 :
    (p == "M") ? 42 :
    (p == "L") ? 55 : custom_inner_width;

function get_depth(p) = 
    (p == "S") ? 30 :
    (p == "M") ? 45 :
    (p == "L") ? 55 : custom_inner_depth;

// Active nominal dimensions
nominal_len = (shape_type == "circular") ? get_width(preset) : get_length(preset);
nominal_wid = get_width(preset);
nominal_dep = get_depth(preset);

// -----------------------------------------------------------------------------
// 2D PROFILE GENERATOR
// -----------------------------------------------------------------------------
module 2d_stadium(length, width) {
    if (length <= width) {
        circle(d = width);
    } else {
        dx = (length - width) / 2;
        hull() {
            translate([-dx, 0]) circle(d = width);
            translate([ dx, 0]) circle(d = width);
        }
    }
}

// -----------------------------------------------------------------------------
// 3D MAIN JIG COMPONENT
// -----------------------------------------------------------------------------
module cable_jig(
    length = nominal_len,
    width  = nominal_wid,
    depth  = nominal_dep,
    label  = preset
) {
    total_inner_h = depth;
    total_h = base_thickness + total_inner_h + flare_height;

    outer_len = length + 2 * wall_thickness;
    outer_wid = width  + 2 * wall_thickness;

    flared_inner_len = length + 2 * flare_expansion;
    flared_inner_wid = width  + 2 * flare_expansion;
    flared_outer_len = outer_len + 2 * flare_expansion;
    flared_outer_wid = outer_wid + 2 * flare_expansion;

    dx = (length > width) ? (length - width) / 2 : 0;
    actual_hole_dia = min(ejection_hole_dia, width - 6);

    difference() {
        // --- 1. POSITIVE SOLID BODY ---
        union() {
            // Main lower column
            linear_extrude(height = base_thickness + total_inner_h) {
                2d_stadium(outer_len, outer_wid);
            }

            // Flared upper funnel lead-in
            translate([0, 0, base_thickness + total_inner_h]) {
                hull() {
                    linear_extrude(height = 0.01) {
                        2d_stadium(outer_len, outer_wid);
                    }
                    translate([0, 0, flare_height]) {
                        linear_extrude(height = 0.01) {
                            2d_stadium(flared_outer_len, flared_outer_wid);
                        }
                    }
                }
            }

            // Tactile grip ribs on curved exterior ends for ergonomic handheld grip
            if (grip_ribs_count > 0 && dx > 0) {
                outer_tip_x = dx + (outer_wid / 2);
                rib_spacing = (total_inner_h - 10) / (grip_ribs_count + 1);
                for (i = [1 : grip_ribs_count]) {
                    rz = base_thickness + 5 + i * rib_spacing;
                    translate([-outer_tip_x, 0, rz])
                        rotate([0, 90, 0])
                        cylinder(r = 1.0, h = 1.0, center = true);
                    translate([outer_tip_x, 0, rz])
                        rotate([0, 90, 0])
                        cylinder(r = 1.0, h = 1.0, center = true);
                }
            }
        }

        // --- 2. INNER CAVITY ---
        // Main uniform sizing cavity
        translate([0, 0, base_thickness]) {
            linear_extrude(height = total_inner_h + 0.05) {
                2d_stadium(length, width);
            }
        }

        // Flared funnel cavity
        translate([0, 0, base_thickness + total_inner_h]) {
            hull() {
                linear_extrude(height = 0.01) {
                    2d_stadium(length, width);
                }
                translate([0, 0, flare_height + 0.1]) {
                    linear_extrude(height = 0.01) {
                        2d_stadium(flared_inner_len, flared_inner_wid);
                    }
                }
            }
        }

        // --- 3. TRANSVERSE STRAP SLOTS (THROUGH SIDEWALLS) ---
        // Drops straight in from top down to floor
        translate([-strap_slot_width / 2, -(flared_outer_wid + 10) / 2, base_thickness]) {
            cube([
                strap_slot_width,
                flared_outer_wid + 10,
                total_h + 10
            ]);
        }

        // Recessed strap bed groove across bottom floor
        translate([-strap_slot_width / 2, -(outer_wid + 4) / 2, base_thickness - strap_recess_depth]) {
            cube([
                strap_slot_width,
                outer_wid + 4,
                strap_recess_depth + 0.05
            ]);
        }

        // --- 4. BOTTOM EJECTION PORTS (FINGER PUSH HOLES) ---
        // Dual ports located under the end lobes for even push-out
        if (dx > 0) {
            translate([-dx, 0, -1]) {
                cylinder(d = actual_hole_dia, h = base_thickness + 2);
            }
            translate([ dx, 0, -1]) {
                cylinder(d = actual_hole_dia, h = base_thickness + 2);
            }
        } else {
            // Circular mode: single central ejection port
            translate([0, 0, -1]) {
                cylinder(d = actual_hole_dia, h = base_thickness + 2);
            }
        }

        // --- 5. EMBOSSED/DEBOSSED SIZE LABEL ---
        if (label != "" && label != "CUSTOM") {
            translate([0, -(outer_wid / 2 - 0.4), base_thickness + total_inner_h / 2]) {
                rotate([90, 0, 0]) {
                    linear_extrude(height = 0.8) {
                        text(str("SIZE ", label), size = 6.0, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
                    }
                }
            }
        }
    }
}

// Render active selection
cable_jig(nominal_len, nominal_wid, nominal_dep, preset);
