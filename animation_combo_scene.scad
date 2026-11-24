// =============================================================================
// ANIMATION SCENE FOR 2-IN-1 MATING CAPSULE USAGE DEMO (SIZE S)
// =============================================================================
// t_val: 0.0 -> 4.0
//   0.0 -> 1.0: Step 1 - Pre-lay strap in mandrel floor groove & wind cable
//   1.0 -> 2.0: Step 2 - Press inverted outer sleeve down over mandrel
//   2.0 -> 3.0: Step 3 - Wrap & cinch Velcro strap through aligned center slots
//   3.0 -> 4.0: Step 4 - Pull halves apart to release uniform bundle
// =============================================================================

use <cable_jig.scad>;
use <cable_mandrel_jig.scad>;

t_val = 0.0; // [0.0 : 0.1 : 4.0]
$fn = 40;

// -----------------------------------------------------------------------------
// CABLE LOOP PRIMITIVE
// -----------------------------------------------------------------------------
module wire_stadium(l, w, wire_r=1.8) {
    dx = (l - w) / 2;
    dy = w / 2 - wire_r;
    translate([-dx,  dy, 0]) rotate([0, 90, 0]) cylinder(r = wire_r, h = 2 * dx);
    translate([-dx, -dy, 0]) rotate([0, 90, 0]) cylinder(r = wire_r, h = 2 * dx);
    translate([ dx, 0, 0]) rotate([0, 0, -90]) rotate_extrude(angle = 180) translate([dy, 0, 0]) circle(r = wire_r);
    translate([-dx, 0, 0]) rotate([0, 0,  90]) rotate_extrude(angle = 180) translate([dy, 0, 0]) circle(r = wire_r);
}

module wound_cable_loops(count=4, z_offset=0, squeeze=0) {
    w_in  = 24.5 - 1.5 * squeeze;
    w_out = 29.0 - 2.0 * squeeze;
    l_in  = 70.5;
    l_out = 76.0;

    color([0.18, 0.20, 0.24]) {
        if (count >= 1) translate([0, 0, 6.2  + z_offset]) wire_stadium(l_in,  w_in,  1.8);
        if (count >= 2) translate([0, 0, 10.6 + z_offset]) wire_stadium(l_in,  w_in,  1.8);
        if (count >= 3) translate([0, 0, 6.2  + z_offset]) wire_stadium(l_out, w_out, 1.8);
        if (count >= 4) translate([0, 0, 10.6 + z_offset]) wire_stadium(l_out, w_out, 1.8);
    }
}

// -----------------------------------------------------------------------------
// VELCRO STRAP
// -----------------------------------------------------------------------------
module strap_open(z_pos=2.8) {
    color([0.95, 0.25, 0.22]) {
        translate([0, 0, z_pos]) {
            translate([-6, -24, 0]) cube([12, 48, 1.0]);
            translate([-6,  24, 0]) rotate([-30, 0, 0]) cube([12, 16, 1.0]);
            translate([-6, -24, 0]) rotate([210, 0, 0]) cube([12, 16, 1.0]);
        }
    }
}

module strap_cinched(z_pos=2.8, wrap_phase=1.0) {
    color([0.95, 0.25, 0.22]) {
        translate([0, 0, z_pos]) {
            translate([-6, -15.5, 0]) cube([12, 31, 1.0]);
            translate([-6,  14.5, 0]) cube([12, 1.0, 11.5]);
            translate([-6, -15.5, 0]) cube([12, 1.0, 11.5]);
            fold = min(1.0, wrap_phase);
            translate([-6, 15.5 - 15.5 * fold, 10.8]) cube([12, 15.5 * fold, 1.0]);
            translate([-6, -15.5, 11.5]) cube([12, 16.5 * fold, 1.0]);
        }
    }
}

// -----------------------------------------------------------------------------
// MANDREL & INVERTED SLEEVE
// -----------------------------------------------------------------------------
color([0.92, 0.52, 0.16]) {
    oblong_mandrel_jig(64, 18, 34, "S", 96.4, 46.4);
}

// STAGE 1: Pre-lay strap & wind cable around posts (t_val: 0.0 -> 1.0)
if (t_val <= 1.0) {
    s_t = t_val;
    strap_open(z_pos = 2.8);
    loop_count = (s_t < 0.25) ? 1 : (s_t < 0.5) ? 2 : (s_t < 0.75) ? 3 : 4;
    wound_cable_loops(count = loop_count, z_offset = 0, squeeze = 0);
}

// STAGE 2: Press inverted outer sleeve down over mandrel (t_val: 1.0 -> 2.0)
else if (t_val <= 2.0) {
    s_t = t_val - 1.0;
    strap_open(z_pos = 2.8);
    wound_cable_loops(count = 4, z_offset = 0, squeeze = 0.4 * s_t);
    sleeve_lift = 46 * (1.0 - s_t);
    color([0.15, 0.55, 0.85, 0.52]) {
        translate([0, 0, 3.6 + 40.0 + sleeve_lift]) {
            rotate([180, 0, 0]) {
                cable_jig(80, 30, 30, "S");
            }
        }
    }
}

// STAGE 3: Wrap & cinch Velcro strap through aligned center slots (t_val: 2.0 -> 3.0)
else if (t_val <= 3.0) {
    s_t = t_val - 2.0;
    wound_cable_loops(count = 4, z_offset = 0, squeeze = 0.4 + 0.6 * s_t);
    strap_cinched(z_pos = 2.8, wrap_phase = s_t);
    color([0.15, 0.55, 0.85, 0.52]) {
        translate([0, 0, 3.6 + 40.0]) {
            rotate([180, 0, 0]) {
                cable_jig(80, 30, 30, "S");
            }
        }
    }
}

// STAGE 4: Pull halves apart to release uniform bundle (t_val: 3.0 -> 4.0)
else {
    s_t = min(1.0, t_val - 3.0);
    sleeve_lift = 48 * s_t;
    bundle_lift = 22 * s_t;
    wound_cable_loops(count = 4, z_offset = bundle_lift, squeeze = 1.0);
    strap_cinched(z_pos = 2.8 + bundle_lift, wrap_phase = 1.0);
    color([0.15, 0.55, 0.85, 0.52]) {
        translate([0, 0, 3.6 + 40.0 + sleeve_lift]) {
            rotate([180, 0, 0]) {
                cable_jig(80, 30, 30, "S");
            }
        }
    }
}
