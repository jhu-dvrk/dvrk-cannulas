// Cylinder parameters (central part)
include_bottom = true; // Set to false to remove the bottom tube (cannula)
cut_in_half = false; // Set to true to cut the model in half - creates two mating parts
peg_position_z = -100; // Z position of the mating peg when cut in half
inner_d = 8.7;  // 8.7 for 8mm instruments, 10.7, 14.35

// part held by cannula holder, assumes no sterile adapter
outer_d = 29;
height = 25;
bevel_r = 1.5; // rounded edges

// Top Cylinder parameters
top_d = 23;
top_h = 18;
top_r = top_d / 2;

// Cone parameters (top, to help insert instrument)
cone_d = top_h - 4;
cone_h = 40;
cone_r = cone_d / 2;

// Bottom Cylinder parameters, i.e cannula
// Wall thickness: 5.0 if cut_in_half, 2 otherwise
bottom_thick = cut_in_half ? 5.0 : 2.0;
bottom_r = (inner_d / 2) + bottom_thick;
bottom_d = bottom_r * 2;
bottom_len = 125;

inner_r = inner_d / 2;
outer_r = outer_d / 2;

// resolution
$fn=100;

module corner_mask(r) {
    difference() {
        square([r, r]);
        translate([r, r]) circle(r=r);
    }
}

module main_geometry() {
    difference() {
        rotate_extrude() {
            difference() {
            union() {
                // Main wall
                translate([inner_r, 0]) square([outer_r - inner_r, height]);
                // Bottom wall
                if (include_bottom) {
                    translate([inner_r, -bottom_len]) square([bottom_r - inner_r, bottom_len]);
                }
                // Top wall
                translate([inner_r, height]) square([top_r - inner_r, top_h]);
            }
            
            // Cone cut
            polygon([
                [0, height + top_h - cone_h],
                [cone_r, height + top_h],
                [0, height + top_h]
            ]);
            
            // Remove corners to create rounded edges
            
            // --- Top Cylinder ---
            // Top Left (Inner Top with Cone)
            translate([cone_r, height + top_h]) rotate([0, 0, -90]) corner_mask(r=bevel_r);
            
            // Top Right (Outer Top)
            translate([top_r, height + top_h]) rotate([0, 0, 180]) corner_mask(r=bevel_r);

            // --- Main Cylinder ---
            // Top Right (Outer Top) - Junction with Top Cylinder
            translate([outer_r, height]) rotate([0, 0, 180]) corner_mask(r=bevel_r);
            // Bottom Right (Outer Bottom) - Junction with Bottom Cylinder
            translate([outer_r, 0]) rotate([0, 0, 90]) corner_mask(r=bevel_r);

            // --- Bottom Cylinder ---
            if (include_bottom) {
                // Inner Bottom
                translate([inner_r, -bottom_len]) corner_mask(r=bevel_r);
                // Outer Bottom
                translate([bottom_r, -bottom_len]) rotate([0, 0, 90]) corner_mask(r=bevel_r);
            } else {
                // If no bottom cylinder, rounded bevel on the inner bottom of the main wall
                translate([inner_r, 0]) corner_mask(r=bevel_r);
            }
            }
        }
        // Engraved Text
        if (include_bottom) {
            translate([0, -(bottom_r - 0.25), -bottom_len/2]) 
                rotate([90, 0, 0]) 
                linear_extrude(2) 
                rotate([0, 0, 90])
                text(str("JHU dVRK ", inner_d), size=4, halign="center", valign="center");
        }
    }
}

difference() {
    union() {
        main_geometry();
        
        if (cut_in_half) {
             // Add Peg on the Right Side (X > 0)
             if (include_bottom) {
                 // Center R approx (inner_r + bottom_r)/2
                 peg_r = (inner_r + bottom_r) / 2;
                 translate([peg_r, 0, peg_position_z]) 
                     rotate([-90, 0, 0]) // Pointing in Y+
                     cylinder(h=3, d1=3, d2=2); 
             }
        }
    }
    
    if (cut_in_half) {
        // The Cut Mask
        peg_r = (inner_r + bottom_r) / 2;
        difference() {
            translate([-200, 0, -200]) cube([400, 200, 400]); // Remove Y>0
            
            // Protect the peg from being cut
            if (include_bottom) {
                translate([peg_r, 0, peg_position_z]) 
                    rotate([-90, 0, 0])
                    cylinder(h=3.1, d1=3, d2=2); 
            }
        }
        
        // The Matching Hole on the Left Side (X < 0)
        // Subtracting from the Main Body (Y <= 0)
        if (include_bottom) {
             translate([-peg_r, 0, peg_position_z]) 
                rotate([90, 0, 0]) // Pointing in Y-
                cylinder(h=3.2, d1=3.2, d2=2.2); // Slightly larger for tolerance
        }
    }

    // Perpendicular hole at 95mm from top of bottom tube, RCM point
    if (include_bottom) {
        translate([0, 0, -95]) rotate([90, 0, 0]) cylinder(h=200, d=4, center=true);
    }
}
