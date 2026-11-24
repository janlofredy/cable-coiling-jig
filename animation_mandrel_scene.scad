// =============================================================================
// ANIMATION SCENE FOR EXTERNAL WRAP-AROUND MANDREL JIG USAGE DEMO
// =============================================================================
// Rendered at specific progress values 't_val' from 0.0 to 4.0

t_val = 0.0; // [0.0 : 0.1 : 4.0]

$fn = 40;

// Dimensions for Size S Oblong Mandrel
m_len    = 64;
m_wid    = 18;
m_h      = 35;
flange_t = 3.6;
flange_o = 8.0;
taper    = 1.5;
gap_w    = 24.0;

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
// MANDREL JIG BODY (Semi-transparent cyan for clear visibility)
// -----------------------------------------------------------------------------
module mandrel_jig() {
    flange_l = m_len + 2 * flange_o;
    flange_w = m_wid + 2 * flange_o;
    top_l = m_len - 2 * taper;
    top_w = m_wid - 2 * taper;

    color([0.15, 0.55, 0.85, 0.65]) {
        difference() {
            union() {
                // Bottom stopper flange
                hull() {
                    linear_extrude(flange_t - 1.0) 2d_stadium(flange_l, flange_w);
                    translate([0, 0, flange_t - 0.01])
                        linear_extrude(0.01) 2d_stadium(flange_l - 2.0, flange_w - 2.0);
                }
                // Tapered mandrel posts
                translate([0, 0, flange_t - 0.01]) {
                    hull() {
                        linear_extrude(0.01) 2d_stadium(m_len, m_wid);
                        translate([0, 0, m_h - 1.5])
                            linear_extrude(0.01) 2d_stadium(top_l, top_w);
                    }
                    translate([0, 0, m_h - 1.51]) hull() {
                        linear_extrude(0.01) 2d_stadium(top_l, top_w);
                        translate([0, 0, 1.5])
                            linear_extrude(0.01) 2d_stadium(top_l - 3.0, top_w - 3.0);
                    }
                }
            }
            // Open central gap
            translate([-gap_w / 2, -(flange_w + 10) / 2, flange_t]) {
                cube([gap_w, flange_w + 10, m_h + 5]);
            }
        }
    }
}

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
    // 4 neat loops wrapped around the outside of the 64x18 posts
    // squeeze=0: wrapped around posts; squeeze=1: slightly cinched inward at waist
    w_in  = 24.5 - 2.0 * squeeze;
    w_out = 30.5 - 2.5 * squeeze;
    l_in  = 70.5;
    l_out = 76.5;

    color([0.18, 0.20, 0.24]) {
        if (count >= 1) translate([0, 0, 6.0  + z_offset]) wire_stadium(l_in,  w_in,  1.8);
        if (count >= 2) translate([0, 0, 10.5 + z_offset]) wire_stadium(l_in,  w_in,  1.8);
        if (count >= 3) translate([0, 0, 6.0  + z_offset]) wire_stadium(l_out, w_out, 1.8);
        if (count >= 4) translate([0, 0, 10.5 + z_offset]) wire_stadium(l_out, w_out, 1.8);
    }
}

// -----------------------------------------------------------------------------
// VELCRO STRAP
// -----------------------------------------------------------------------------
module strap_open(x_slide=0, z_pos=3.8) {
    color([0.95, 0.25, 0.22]) {
        translate([x_slide, 0, z_pos]) {
            // Bottom band passing through center gap
            translate([-6, -18, 0]) cube([12, 36, 1.2]);
            // Open wings
            translate([-6,  18, 0]) rotate([-35, 0, 0]) cube([12, 16, 1.2]);
            translate([-6, -18, 0]) rotate([215, 0, 0]) cube([12, 16, 1.2]);
        }
    }
}

module strap_cinched(z_pos=3.8, wrap_phase=1.0) {
    color([0.95, 0.25, 0.22]) {
        translate([0, 0, z_pos]) {
            // Bottom band
            translate([-6, -16, 0]) cube([12, 32, 1.2]);
            // Vertical sides
            translate([-6,  15, 0]) cube([12, 1.2, 11.5]);
            translate([-6, -16.2, 0]) cube([12, 1.2, 11.5]);
            // Top flaps folding over
            fold = min(1.0, wrap_phase);
            translate([-6, 16 - 16 * fold, 10.5]) cube([12, 16 * fold, 1.2]);
            translate([-6, -16, 11.2]) cube([12, 17 * fold, 1.2]);
        }
    }
}

// -----------------------------------------------------------------------------
// UPWARD LIFT ARROWS
// -----------------------------------------------------------------------------
module lift_arrows() {
    color([0.2, 0.85, 0.3, 0.9]) {
        for (side = [-46, 46]) {
            translate([side, 0, 10]) {
                cylinder(r = 2.2, h = 14);
                translate([0, 0, 14]) cylinder(r1 = 4.6, r2 = 0.5, h = 6);
            }
        }
    }
}

// -----------------------------------------------------------------------------
// ANIMATION TIMELINE LOGIC
// -----------------------------------------------------------------------------
mandrel_jig();

// STAGE 1: Wind cable around outside of tapered posts (t_val: 0.0 -> 1.0)
if (t_val <= 1.0) {
    s_t = t_val;
    loop_count = (s_t < 0.25) ? 1 : (s_t < 0.5) ? 2 : (s_t < 0.75) ? 3 : 4;
    wound_cable_loops(count = loop_count, z_offset = 0, squeeze = 0);
}

// STAGE 2: Pass Velcro strap through open center gap (t_val: 1.0 -> 2.0)
else if (t_val <= 2.0) {
    s_t = t_val - 1.0;
    wound_cable_loops(count = 4, z_offset = 0, squeeze = 0);
    // Strap slides in from above into the center gap
    strap_z = 38 - 34.2 * s_t;
    strap_open(x_slide = 0, z_pos = strap_z);
}

// STAGE 3: Wrap & cinch Velcro strap around bundle waist (t_val: 2.0 -> 3.0)
else if (t_val <= 3.0) {
    s_t = t_val - 2.0;
    wound_cable_loops(count = 4, z_offset = 0, squeeze = s_t);
    strap_cinched(z_pos = 3.8, wrap_phase = s_t);
}

// STAGE 4: Slide uniform bundle straight up off tapered posts (t_val: 3.0 -> 4.0)
else {
    s_t = min(1.0, t_val - 3.0);
    lift_z = 46 * s_t;
    wound_cable_loops(count = 4, z_offset = lift_z, squeeze = 1.0);
    strap_cinched(z_pos = 3.8 + lift_z, wrap_phase = 1.0);
    lift_arrows();
}
