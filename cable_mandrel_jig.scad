// =============================================================================
// PARAMETRIC EXTERNAL WRAP-AROUND CABLE COILING JIG
// =============================================================================
// Wrap cables around the OUTSIDE of a tapered mandrel against a bottom stopper
// flange, cinch with a 1/2" (12-15mm) hook-and-loop strap, and slide off.
//
// Two modes:
//   - "oblong":   Twin-Post Stadium Mandrel with an open center window for
//                 wrapping and cinching the strap directly around the bundle.
//   - "circular": Classic Flanged Hollow Tube with opposite strap-relief slots.
//
// 100% support-free 3D printing (upright orientation on z = 0).
// =============================================================================

/* [Preset & Mode Selection] */
// Active Preset: "S" (Small/USB), "M" (Medium/Laptop/HDMI), "L" (Large/Power), or "CUSTOM"
preset = "S"; // ["S": Small (USB & Mobile), "M": Medium (Laptop & HDMI), "L": Large (Power & Appliance), "CUSTOM": Custom Dimensions]

// Mandrel Cross-Section Geometry
shape_type = "oblong"; // ["oblong": Twin-Post Stadium Mandrel, "circular": Flanged Hollow Tube]

/* [Custom Dimensions (When preset == "CUSTOM")] */
custom_length = 64;
custom_width  = 18;
custom_height = 35;

/* [Tolerances & Structural Parameters] */
flange_thickness  = 3.6;  // Bottom stopper flange thickness
flange_overhang   = 8.0;  // Flange lip extending past mandrel walls
wall_thickness    = 3.2;  // Tube wall thickness (circular mode)
taper_inset       = 1.5;  // Draft taper per side toward top for easy slide-off
center_gap_width  = 24.0; // Open center window width (oblong mode)
strap_slot_width  = 16.0; // Strap-relief slot width (circular mode)
start_notch_width = 5.0;  // Cable-end tuck notch width on flange edge

/* [Render Quality] */
$fn = 64;

// -----------------------------------------------------------------------------
// PRESET DIMENSION LOOKUPS
// -----------------------------------------------------------------------------
function get_oblong_length(p) =
    (p == "S") ? 64 :
    (p == "M") ? 95 :
    (p == "L") ? 130 : custom_length;

function get_oblong_width(p) =
    (p == "S") ? 18 :
    (p == "M") ? 24 :
    (p == "L") ? 32 : custom_width;

function get_tube_diameter(p) =
    (p == "S") ? 50 :
    (p == "M") ? 72 :
    (p == "L") ? 98 : custom_length;

function get_height(p) =
    (p == "S") ? 35 :
    (p == "M") ? 48 :
    (p == "L") ? 58 : custom_height;

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

module chamfered_stadium_plate(length, width, thickness, chamfer = 1.0) {
    hull() {
        linear_extrude(height = max(0.2, thickness - chamfer)) {
            2d_stadium(length, width);
        }
        translate([0, 0, thickness - 0.01]) {
            linear_extrude(height = 0.01) {
                2d_stadium(length - 2 * chamfer, width - 2 * chamfer);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// 3D OBLONG TWIN-POST MANDREL
// -----------------------------------------------------------------------------
module oblong_mandrel_jig(length, width, height, label) {
    flange_l = length + 2 * flange_overhang;
    flange_w = width  + 2 * flange_overhang;

    top_l = max(width, length - 2 * taper_inset);
    top_w = max(8, width - 2 * taper_inset);
    bevel_h = 1.5;

    difference() {
        union() {
            // Bottom stopper flange
            chamfered_stadium_plate(flange_l, flange_w, flange_thickness, chamfer = 1.0);

            // Tapered stadium mandrel body with top bevel
            translate([0, 0, flange_thickness - 0.01]) {
                hull() {
                    linear_extrude(height = 0.01) {
                        2d_stadium(length, width);
                    }
                    translate([0, 0, height - bevel_h]) {
                        linear_extrude(height = 0.01) {
                            2d_stadium(top_l, top_w);
                        }
                    }
                }
                translate([0, 0, height - bevel_h - 0.01]) {
                    hull() {
                        linear_extrude(height = 0.01) {
                            2d_stadium(top_l, top_w);
                        }
                        translate([0, 0, bevel_h]) {
                            linear_extrude(height = 0.01) {
                                2d_stadium(max(4, top_l - 3.0), max(4, top_w - 3.0));
                            }
                        }
                    }
                }
            }
        }

        // Open central transverse gap forming the two D-posts
        translate([-center_gap_width / 2, -(flange_w + 10) / 2, flange_thickness]) {
            cube([center_gap_width, flange_w + 10, height + 5]);
        }

        // Cable-end tuck notch on outer +X edge of flange
        translate([flange_l / 2 - 4.5, -start_notch_width / 2, -1]) {
            cube([6, start_notch_width, flange_thickness + 2]);
        }

        // Debossed size label on top surface of bottom flange inside center gap
        if (label != "" && label != "CUSTOM") {
            translate([0, 0, flange_thickness - 0.6]) {
                linear_extrude(height = 0.7) {
                    text(str("EXT ", label), size = 4.2, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// 3D CIRCULAR FLANGED HOLLOW TUBE
// -----------------------------------------------------------------------------
module circular_tube_jig(diameter, height, label) {
    flange_d = diameter + 2 * flange_overhang;
    top_outer_d = max(16, diameter - 2 * taper_inset);
    base_inner_d = max(12, diameter - 2 * wall_thickness);
    top_inner_d = max(10, top_outer_d - 2 * wall_thickness);
    grip_hole_d = max(18, base_inner_d - 8);
    bevel_h = 1.2;

    difference() {
        union() {
            // Bottom stopper flange
            chamfered_stadium_plate(flange_d, flange_d, flange_thickness, chamfer = 1.0);

            // Tapered outer cylinder with top bevel
            translate([0, 0, flange_thickness - 0.01]) {
                cylinder(d1 = diameter, d2 = top_outer_d, h = height - bevel_h);
                translate([0, 0, height - bevel_h - 0.01]) {
                    cylinder(d1 = top_outer_d, d2 = max(12, top_outer_d - 2.4), h = bevel_h);
                }
            }
        }

        // Hollow tapered core
        translate([0, 0, flange_thickness - 0.05]) {
            cylinder(d1 = base_inner_d, d2 = top_inner_d, h = height + 0.2);
        }

        // Central finger-grip / lightening hole in bottom flange
        translate([0, 0, -1]) {
            cylinder(d = grip_hole_d, h = flange_thickness + 2);
        }

        // Two opposite vertical strap-relief slots on ±Y walls
        translate([-strap_slot_width / 2, -(flange_d + 10) / 2, flange_thickness]) {
            cube([strap_slot_width, flange_d + 10, height + 5]);
        }

        // Cable-end tuck notch on outer +X edge of flange
        translate([flange_d / 2 - 4.5, -start_notch_width / 2, -1]) {
            cube([6, start_notch_width, flange_thickness + 2]);
        }

        // Debossed size label on top surface of bottom flange lip
        if (label != "" && label != "CUSTOM") {
            translate([-(diameter / 2 + flange_overhang / 2 - 0.5), 0, flange_thickness - 0.6]) {
                rotate([0, 0, 90]) {
                    linear_extrude(height = 0.7) {
                        text(str("TUBE ", label), size = 3.5, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
                    }
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// RENDER ACTIVE SELECTION
// -----------------------------------------------------------------------------
if (shape_type == "circular") {
    circular_tube_jig(get_tube_diameter(preset), get_height(preset), preset);
} else {
    oblong_mandrel_jig(get_oblong_length(preset), get_oblong_width(preset), get_height(preset), preset);
}
