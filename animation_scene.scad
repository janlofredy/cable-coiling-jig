// =============================================================================
// ANIMATION SCENE FOR CABLE JIG USAGE DEMO
// =============================================================================
// Rendered at specific progress values 't_val' from 0.0 to 5.0

t_val = 0.0; // [0.0 : 0.1 : 5.0]

$fn = 40;

// Dimensions for Size S Jig
jig_len = 80;
jig_wid = 30;
jig_dep = 30;
wall    = 3.2;
base_h  = 4.0;
recess  = 1.2;
slot_w  = 16.0;
flare_h = 6.0;
flare_e = 5.0;

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
// JIG BODY (Semi-transparent cyan for clear internal visibility)
// -----------------------------------------------------------------------------
module jig() {
    outer_l = jig_len + 2 * wall;
    outer_w = jig_wid + 2 * wall;
    flared_outer_l = outer_l + 2 * flare_e;
    flared_outer_w = outer_w + 2 * flare_e;
    flared_inner_l = jig_len + 2 * flare_e;
    flared_inner_w = jig_wid + 2 * flare_e;
    total_h = base_h + jig_dep + flare_h;
    dx = (jig_len - jig_wid) / 2;

    color([0.15, 0.55, 0.85, 0.50]) {
        difference() {
            union() {
                linear_extrude(base_h + jig_dep) 2d_stadium(outer_l, outer_w);
                translate([0, 0, base_h + jig_dep]) hull() {
                    linear_extrude(0.01) 2d_stadium(outer_l, outer_w);
                    translate([0, 0, flare_h]) linear_extrude(0.01) 2d_stadium(flared_outer_l, flared_outer_w);
                }
            }
            // Inner cavity
            translate([0, 0, base_h]) linear_extrude(jig_dep + 0.05) 2d_stadium(jig_len, jig_wid);
            translate([0, 0, base_h + jig_dep]) hull() {
                linear_extrude(0.01) 2d_stadium(jig_len, jig_wid);
                translate([0, 0, flare_h + 0.1]) linear_extrude(0.01) 2d_stadium(flared_inner_l, flared_inner_w);
            }
            // Side slots
            translate([-slot_w / 2, -(flared_outer_w + 10) / 2, base_h])
                cube([slot_w, flared_outer_w + 10, total_h + 10]);
            // Floor recess
            translate([-slot_w / 2, -(outer_w + 4) / 2, base_h - recess])
                cube([slot_w, outer_w + 4, recess + 0.05]);
            // Ejection holes
            translate([-dx, 0, -1]) cylinder(d = 16, h = base_h + 2);
            translate([ dx, 0, -1]) cylinder(d = 16, h = base_h + 2);
        }
    }
}

// -----------------------------------------------------------------------------
// CABLE COIL / BUNDLE
// -----------------------------------------------------------------------------
module wire_stadium(l, w, wire_r=1.8) {
    if (l <= w) {
        rotate_extrude() translate([w / 2 - wire_r, 0, 0]) circle(r = wire_r);
    } else {
        dx = (l - w) / 2;
        dy = w / 2 - wire_r;
        translate([-dx,  dy, 0]) rotate([0, 90, 0]) cylinder(r = wire_r, h = 2 * dx);
        translate([-dx, -dy, 0]) rotate([0, 90, 0]) cylinder(r = wire_r, h = 2 * dx);
        translate([ dx, 0, 0]) rotate([0, 0, -90]) rotate_extrude(angle = 180) translate([dy, 0, 0]) circle(r = wire_r);
        translate([-dx, 0, 0]) rotate([0, 0,  90]) rotate_extrude(angle = 180) translate([dy, 0, 0]) circle(r = wire_r);
    }
}

module cable_bundle(l, w) {
    color([0.18, 0.20, 0.24]) {
        for (dz = [-5, 0, 5]) {
            for (dw = [-2.5, 2.5]) {
                translate([0, 0, dz]) wire_stadium(max(w + dw, l + dw), w + dw, wire_r = 1.6);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// VELCRO STRAP
// -----------------------------------------------------------------------------
module strap_open(z_pos) {
    // Open strap resting or descending into slot
    color([0.95, 0.25, 0.22]) {
        // Floor section
        translate([-6, -17, z_pos]) cube([12, 34, 1.2]);
        // Left wing angled out
        translate([-6, 17, z_pos]) rotate([-25, 0, 0]) cube([12, 18, 1.2]);
        // Right wing angled out
        translate([-6, -17, z_pos]) rotate([205, 0, 0]) cube([12, 18, 1.2]);
    }
}

module strap_cinched(z_pos, wrap_phase=1.0) {
    color([0.95, 0.25, 0.22]) {
        // Floor section
        translate([-6, -15, z_pos]) cube([12, 30, 1.2]);
        // Sidewall verticals
        translate([-6, 14, z_pos]) cube([12, 1.2, 18]);
        translate([-6, -15.2, z_pos]) cube([12, 1.2, 18]);
        // Top flaps folding over
        top_fold = min(1.0, wrap_phase);
        translate([-6, 15, z_pos + 18]) rotate([0, 0, 0]) cube([12, 1.2, 0.1]);
        // Left top flap
        translate([-6, 15 - 15 * top_fold, z_pos + 17.5]) cube([12, 15 * top_fold, 1.2]);
        // Right top flap overlapping
        translate([-6, -15, z_pos + 18.2]) cube([12, 16 * top_fold, 1.2]);
    }
}

// -----------------------------------------------------------------------------
// UPWARD EJECTION ARROWS
// -----------------------------------------------------------------------------
module ejection_arrows(alpha=1.0) {
    dx = (jig_len - jig_wid) / 2;
    color([0.2, 0.85, 0.3, alpha]) {
        for (side = [-dx, dx]) {
            translate([side, 0, -18]) {
                cylinder(r = 2.5, h = 12);
                translate([0, 0, 12]) cylinder(r1 = 5.0, r2 = 0.5, h = 6);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// ANIMATION TIMELINE LOGIC
// -----------------------------------------------------------------------------
jig();

// STAGE 1: Strap drops into jig (t_val: 0.0 -> 1.0)
if (t_val <= 1.0) {
    s_t = t_val; // 0 -> 1
    strap_z = 50 - 46.5 * s_t;
    strap_open(strap_z);
}

// STAGE 2: Strap rests at bottom, round cable coil approaches (t_val: 1.0 -> 2.0)
else if (t_val <= 2.0) {
    s_t = t_val - 1.0; // 0 -> 1
    strap_open(3.5);
    cable_z = 65 - 28 * s_t;
    translate([0, 0, cable_z]) cable_bundle(58, 58);
}

// STAGE 3: Cable enters funnel, squashes into oblong against stopper (t_val: 2.0 -> 3.0)
else if (t_val <= 3.0) {
    s_t = t_val - 2.0; // 0 -> 1
    strap_open(3.5);
    cable_z = 37 - 24 * s_t;
    // Morph from circular (58x58) to oblong (74x24)
    cur_len = 58 + (74 - 58) * s_t;
    cur_wid = 58 + (24 - 58) * s_t;
    translate([0, 0, cable_z]) cable_bundle(cur_len, cur_wid);
}

// STAGE 4: Cable at bottom, strap folds and cinches around waist (t_val: 3.0 -> 4.0)
else if (t_val <= 4.0) {
    s_t = t_val - 3.0; // 0 -> 1
    translate([0, 0, 13]) cable_bundle(74, 24);
    strap_cinched(3.5, wrap_phase = s_t);
}

// STAGE 5: Ejection! Upward arrows push strapped bundle out (t_val: 4.0 -> 5.0)
else {
    s_t = min(1.0, t_val - 4.0); // 0 -> 1
    eject_z = 13 + 52 * s_t;
    translate([0, 0, eject_z]) {
        cable_bundle(74, 24);
        strap_cinched(-9.0, wrap_phase = 1.0);
    }
    ejection_arrows(alpha = 0.9);
}
