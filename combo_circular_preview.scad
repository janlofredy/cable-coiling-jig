// =============================================================================
// CIRCULAR 2-IN-1 MATING CAPSULE SIDE-BY-SIDE PREVIEW (SIZE S)
// =============================================================================
// Left  (x = -55): Closed Storage Capsule (inverted circular sleeve in pocket)
// Right (x = +55): Exploded Mating View (showing nested tube & aligned slots)
// =============================================================================

use <cable_jig.scad>;
use <cable_mandrel_jig.scad>;

$fn = 64;

module size_s_tube() {
    color([0.92, 0.52, 0.16]) {
        circular_tube_jig(50, 34, "S", 82.4);
    }
}

module size_s_inverted_circular_sleeve(z_lift = 0) {
    // cable_jig total height for S = 4.0 + 30.0 + 6.0 = 40.0 mm
    // Tube flange floor = 3.6 mm
    color([0.15, 0.55, 0.85, 0.58]) {
        translate([0, 0, 3.6 + 40.0 + z_lift]) {
            rotate([180, 0, 0]) {
                cable_jig(66, 66, 30, "S");
            }
        }
    }
}

// Left: Closed Circular Storage Capsule
translate([-55, 0, 0]) {
    size_s_tube();
    size_s_inverted_circular_sleeve(z_lift = 0);
}

// Right: Exploded / Open Circular Mating View
translate([55, 0, 0]) {
    size_s_tube();
    size_s_inverted_circular_sleeve(z_lift = 25);
}
