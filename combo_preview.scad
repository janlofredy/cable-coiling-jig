// =============================================================================
// 2-IN-1 MATING CAPSULE SIDE-BY-SIDE PREVIEW (SIZE S)
// =============================================================================
// Left  (x = -62): Closed Storage Capsule (inverted sleeve seated in pocket)
// Right (x = +62): Exploded Mating View (showing nested posts & aligned slots)
// =============================================================================

use <cable_jig.scad>;
use <cable_mandrel_jig.scad>;

$fn = 64;

module size_s_mandrel() {
    color([0.92, 0.52, 0.16]) {
        oblong_mandrel_jig(64, 18, 34, "S", 96.4, 46.4);
    }
}

module size_s_inverted_sleeve(z_lift = 0) {
    // cable_jig total height for S = 4.0 + 30.0 + 6.0 = 40.0 mm
    // Mandrel flange floor = 3.6 mm
    color([0.15, 0.55, 0.85, 0.58]) {
        translate([0, 0, 3.6 + 40.0 + z_lift]) {
            rotate([180, 0, 0]) {
                cable_jig(80, 30, 30, "S");
            }
        }
    }
}

// Left: Closed Storage Capsule
translate([-62, 0, 0]) {
    size_s_mandrel();
    size_s_inverted_sleeve(z_lift = 0);
}

// Right: Exploded / Open Mating View
translate([62, 0, 0]) {
    size_s_mandrel();
    size_s_inverted_sleeve(z_lift = 25);
}
