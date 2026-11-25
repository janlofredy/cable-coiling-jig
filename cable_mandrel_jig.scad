// =============================================================================
// PARAMETRIC EXTERNAL WRAP-AROUND CABLE COILING JIG (2-IN-1 MATING CAPABLE)
// =============================================================================
// Wrap cables around the OUTSIDE of a tapered mandrel against a bottom stopper
// flange, cinch with a 1/2" (12-15mm) hook-and-loop strap, and slide off.
//
// Two modes:
//   - "oblong":   Twin-Post Stadium Mandrel with an open center window and a
//                 mating registration pocket that nests with the inverted
//                 Internal Compression Sleeve (cable_jig.scad) as a 2-in-1
//                 capsule.
//   - "circular": Classic Flanged Hollow Tube with opposite strap-relief slots.
//
// 100% support-free 3D printing (upright orientation on z = 0).
// =============================================================================

/* [Preset & Mode Selection] */
// Active Preset: "S" (Small/USB), "M" (Medium/Laptop/HDMI), "L" (Large/Power), or "CUSTOM"
preset = "S"; // ["S": Small (USB & Mobile), "M": Medium (Laptop & HDMI), "L": Large (Power & Appliance), "CUSTOM": Custom Dimensions]

// Mandrel Cross-Section Geometry
shape_type = "oblong"; // ["oblong": Twin-Post Stadium Mandrel, "circular": Flanged Hollow Tube]

// Enable mating registration pocket on Oblong Mandrel to nest with cable_jig.scad
mating_rim = true;

/* [Custom Dimensions (When preset == "CUSTOM")] */
custom_length = 64;
custom_width  = 18;
custom_height = 34;

/* [Tolerances & Structural Parameters] */
flange_thickness  = 3.6;  // Bottom stopper flange thickness
flange_overhang   = 8.0;  // Fallback flange lip when mating_rim == false or circular
wall_thickness    = 3.2;  // Tube wall thickness (circular mode)
taper_inset       = 1.5;  // Draft taper per side toward top for easy slide-off
center_gap_width  = 24.0; // Open center window width between posts (oblong mode)
strap_slot_width  = 16.0; // Strap pass-through slot width (matches cable_jig.scad)
strap_recess_depth= 1.0;  // Recessed floor strap groove depth (oblong mating mode)
start_notch_width = 5.0;  // Cable-end tuck notch width on flange edge

/* [Mating Capsule Parameters (Oblong Mode)] */
fit_clearance     = 0.35; // Slip-fit clearance per side around inverted sleeve rim
rim_wall          = 2.4;  // Outer perimeter lip wall thickness
rim_height        = 2.8;  // Raised registration lip height above flange floor

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

// Post heights give 2.0 mm vertical clearance inside inverted cable_jig.scad
function get_oblong_height(p) =
    (p == "S") ? 34 :
    (p == "M") ? 49 :
    (p == "L") ? 59 : custom_height;

// Matching outer flared rim dimensions from cable_jig.scad
// (sleeve_inner + 2*3.2 wall + 2*5.0 flare = sleeve_inner + 16.4)
function get_sleeve_rim_length(p) =
    (p == "S") ? 96.4 :
    (p == "M") ? 131.4 :
    (p == "L") ? 171.4 : (custom_length + 32.4);

function get_sleeve_rim_width(p) =
    (p == "S") ? 46.4 :
    (p == "M") ? 58.4 :
    (p == "L") ? 71.4 : (custom_width + 28.4);

function get_tube_diameter(p) =
    (p == "S") ? 50 :
    (p == "M") ? 72 :
    (p == "L") ? 98 : custom_length;

// Tube heights give 2.0 mm vertical clearance inside inverted circular cable_jig.scad
function get_tube_height(p) =
    (p == "S") ? 34 :
    (p == "M") ? 49 :
    (p == "L") ? 59 : custom_height;

// Matching outer flared rim diameter from circular cable_jig.scad
function get_circular_sleeve_rim_dia(p) =
    (p == "S") ? 82.4 :
    (p == "M") ? 108.4 :
    (p == "L") ? 138.4 : (custom_length + 32.4);

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
// 3D OBLONG TWIN-POST MANDREL (WITH OPTIONAL MATING REGISTRATION POCKET)
// -----------------------------------------------------------------------------
module oblong_mandrel_jig(length, width, height, label, sleeve_rim_l, sleeve_rim_w) {
    pocket_l = sleeve_rim_l + 2 * fit_clearance;
    pocket_w = sleeve_rim_w + 2 * fit_clearance;

    flange_l = mating_rim ? (pocket_l + 2 * rim_wall) : (length + 2 * flange_overhang);
    flange_w = mating_rim ? (pocket_w + 2 * rim_wall) : (width  + 2 * flange_overhang);
    base_total_h = mating_rim ? (flange_thickness + rim_height) : flange_thickness;

    top_l = max(width, length - 2 * taper_inset);
    top_w = max(8, width - 2 * taper_inset);
    bevel_h = 1.5;
    lead_chamfer = 0.8;

    difference() {
        union() {
            // 1. Base plate + optional raised mating registration lip
            if (mating_rim) {
                difference() {
                    chamfered_stadium_plate(flange_l, flange_w, base_total_h, chamfer = 1.0);
                    // Inner registration pocket
                    translate([0, 0, flange_thickness]) {
                        linear_extrude(height = rim_height + 0.1) {
                            2d_stadium(pocket_l, pocket_w);
                        }
                    }
                    // 45-degree inner lead-in chamfer at top of lip
                    translate([0, 0, base_total_h - lead_chamfer]) {
                        hull() {
                            linear_extrude(height = 0.01) {
                                2d_stadium(pocket_l, pocket_w);
                            }
                            translate([0, 0, lead_chamfer + 0.05]) {
                                linear_extrude(height = 0.01) {
                                    2d_stadium(pocket_l + 2 * lead_chamfer, pocket_w + 2 * lead_chamfer);
                                }
                            }
                        }
                    }
                }
            } else {
                chamfered_stadium_plate(flange_l, flange_w, flange_thickness, chamfer = 1.0);
            }

            // 2. Tapered stadium mandrel posts with top bevel
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

        // Open central transverse gap forming the two D-posts (bounded to post width)
        translate([-center_gap_width / 2, -(width + 4) / 2, flange_thickness]) {
            cube([center_gap_width, width + 4, height + 5]);
        }

        // 16mm strap pass-through slot across the raised lip (aligns with cable_jig.scad)
        if (mating_rim) {
            translate([-strap_slot_width / 2, -(flange_w + 10) / 2, flange_thickness]) {
                cube([strap_slot_width, flange_w + 10, rim_height + 2]);
            }
        }

        // Recessed strap bed groove across flange floor
        translate([-strap_slot_width / 2, -(flange_w + 4) / 2, flange_thickness - strap_recess_depth]) {
            cube([strap_slot_width, flange_w + 4, strap_recess_depth + 0.05]);
        }

        // Cable-end tuck notch on outer +X edge of flange
        translate([flange_l / 2 - 5.5, -start_notch_width / 2, -1]) {
            cube([7, start_notch_width, base_total_h + 2]);
        }

        // Debossed size label on floor inside center gap
        if (label != "" && label != "CUSTOM") {
            label_z = flange_thickness - strap_recess_depth - 0.5;
            translate([0, 0, label_z]) {
                linear_extrude(height = 0.6) {
                    text(str("EXT ", label), size = 4.2, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
                }
            }
        }
    }
}

// -----------------------------------------------------------------------------
// 3D CIRCULAR FLANGED HOLLOW TUBE (WITH OPTIONAL MATING REGISTRATION POCKET)
// -----------------------------------------------------------------------------
module circular_tube_jig(diameter, height, label, sleeve_rim_d) {
    pocket_d = sleeve_rim_d + 2 * fit_clearance;
    flange_d = mating_rim ? (pocket_d + 2 * rim_wall) : (diameter + 2 * flange_overhang);
    base_total_h = mating_rim ? (flange_thickness + rim_height) : flange_thickness;

    top_outer_d = max(16, diameter - 2 * taper_inset);
    base_inner_d = max(12, diameter - 2 * wall_thickness);
    top_inner_d = max(10, top_outer_d - 2 * wall_thickness);
    grip_hole_d = max(18, base_inner_d - 8);
    bevel_h = 1.2;
    lead_chamfer = 0.8;

    difference() {
        union() {
            // 1. Base plate + optional raised mating registration lip
            if (mating_rim) {
                difference() {
                    chamfered_stadium_plate(flange_d, flange_d, base_total_h, chamfer = 1.0);
                    // Inner circular registration pocket
                    translate([0, 0, flange_thickness]) {
                        cylinder(d = pocket_d, h = rim_height + 0.1);
                    }
                    // 45-degree inner lead-in chamfer at top of lip
                    translate([0, 0, base_total_h - lead_chamfer]) {
                        cylinder(d1 = pocket_d, d2 = pocket_d + 2 * lead_chamfer, h = lead_chamfer + 0.05);
                    }
                }
            } else {
                chamfered_stadium_plate(flange_d, flange_d, flange_thickness, chamfer = 1.0);
            }

            // 2. Tapered outer cylinder with top bevel
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

        // Two opposite vertical strap-relief slots on ±Y walls (and across raised lip)
        translate([-strap_slot_width / 2, -(flange_d + 10) / 2, flange_thickness]) {
            cube([strap_slot_width, flange_d + 10, height + 5]);
        }

        // Recessed strap bed groove across flange floor
        if (mating_rim) {
            translate([-strap_slot_width / 2, -(flange_d + 4) / 2, flange_thickness - strap_recess_depth]) {
                cube([strap_slot_width, flange_d + 4, strap_recess_depth + 0.05]);
            }
        }

        // Cable-end tuck notch on outer +X edge of flange
        translate([flange_d / 2 - 5.5, -start_notch_width / 2, -1]) {
            cube([7, start_notch_width, base_total_h + 2]);
        }

        // Debossed size label on flat floor ring between tube and raised lip
        if (label != "" && label != "CUSTOM") {
            translate([-(diameter / 2 + 4.5), 0, flange_thickness - 0.5]) {
                rotate([0, 0, 90]) {
                    linear_extrude(height = 0.6) {
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
    circular_tube_jig(
        get_tube_diameter(preset),
        get_tube_height(preset),
        preset,
        get_circular_sleeve_rim_dia(preset)
    );
} else {
    oblong_mandrel_jig(
        get_oblong_length(preset),
        get_oblong_width(preset),
        get_oblong_height(preset),
        preset,
        get_sleeve_rim_length(preset),
        get_sleeve_rim_width(preset)
    );
}
