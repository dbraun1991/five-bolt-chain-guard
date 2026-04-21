// 5-Bolt Universal Chain Guard for Trekking / City / Touring Bike
// Two concentric rings connected by 5 struts with bolt channels
// Plus additional structural reinforcements
// Target: 130mm BCD cranksets (Shimano FC-T521, FC-T431, FC-T4060)

// Main dimensions
outer_rim_diameter = 220;  // mm - outer edge (chainring teeth sit at ~105mm radius)
inner_rim_diameter = 120;  // mm - inner edge (crankset body extends ~60mm from axis)
ring_thickness = 5;        // mm - wall thickness of rings
thickness = 5;             // mm - vertical height/thickness

// Bolt specifications
bolt_diameter = 8;         // M8 bolt shaft diameter
connector_thickness = 5;   // mm - thickness of each strut wall
gap_between_connectors = bolt_diameter;  // gap for bolt shaft

// Strut dimensions
strut_width = connector_thickness + gap_between_connectors + connector_thickness;  // 18mm total
num_struts = 5;           // for pentagonal pattern

// Calculated radii
inner_radius = inner_rim_diameter/2;
outer_radius = outer_rim_diameter/2;
inner_ring_outer = inner_radius + ring_thickness;
outer_ring_inner = outer_radius - ring_thickness;

// Rendering quality
$fn = 100;

module chain_guard() {
    union() {
        // Outer ring (hollow circle)
        difference() {
            cylinder(h = thickness, d = outer_rim_diameter, center = false);
            translate([0, 0, -1])
                cylinder(h = thickness + 2, d = outer_rim_diameter - 2*ring_thickness, center = false);
        }

        // Inner ring (hollow circle)
        difference() {
            cylinder(h = thickness, d = inner_rim_diameter + 2*ring_thickness, center = false);
            translate([0, 0, -1])
                cylinder(h = thickness + 2, d = inner_rim_diameter, center = false);
        }

        // Five struts with bolt channels
        for (i = [0:num_struts-1]) {
            angle = i * 360/num_struts;
            rotate([0, 0, angle]) {
                // First connector wall (5mm thick) - slightly extended
                translate([inner_ring_outer - 3, -strut_width/2, 0])
                    cube([
                        outer_ring_inner - inner_ring_outer + 3,
                        connector_thickness,
                        thickness
                    ]);

                // Second connector wall (5mm thick, parallel)
                translate([inner_ring_outer - 3, strut_width/2 - connector_thickness, 0])
                    cube([
                        outer_ring_inner - inner_ring_outer + 3,
                        connector_thickness,
                        thickness
                    ]);
            }
        }

        // Additional structural reinforcements between channels
        for (i = [0:num_struts-1]) {
            angle1 = i * 360/num_struts;
            angle2 = ((i + 1) % num_struts) * 360/num_struts;
            mid_angle = angle1 + 360/(2*num_struts);

            // 1. Two diagonal struts forming X pattern
            // Calculate junction points
            // Channel 1 walls at angle1
            x1_inner_pos = (inner_ring_outer) * cos(angle1) + (strut_width/2 - connector_thickness/2) * sin(angle1);
            y1_inner_pos = (inner_ring_outer) * sin(angle1) - (strut_width/2 - connector_thickness/2) * cos(angle1);
            x1_outer_pos = (outer_ring_inner) * cos(angle1) + (strut_width/2 - connector_thickness/2) * sin(angle1);
            y1_outer_pos = (outer_ring_inner) * sin(angle1) - (strut_width/2 - connector_thickness/2) * cos(angle1);

            x1_inner_neg = (inner_ring_outer) * cos(angle1) - (strut_width/2 - connector_thickness/2) * sin(angle1);
            y1_inner_neg = (inner_ring_outer) * sin(angle1) + (strut_width/2 - connector_thickness/2) * cos(angle1);
            x1_outer_neg = (outer_ring_inner) * cos(angle1) - (strut_width/2 - connector_thickness/2) * sin(angle1);
            y1_outer_neg = (outer_ring_inner) * sin(angle1) + (strut_width/2 - connector_thickness/2) * cos(angle1);

            // Channel 2 walls at angle2
            x2_inner_pos = (inner_ring_outer) * cos(angle2) + (strut_width/2 - connector_thickness/2) * sin(angle2);
            y2_inner_pos = (inner_ring_outer) * sin(angle2) - (strut_width/2 - connector_thickness/2) * cos(angle2);
            x2_outer_pos = (outer_ring_inner) * cos(angle2) + (strut_width/2 - connector_thickness/2) * sin(angle2);
            y2_outer_pos = (outer_ring_inner) * sin(angle2) - (strut_width/2 - connector_thickness/2) * cos(angle2);

            x2_inner_neg = (inner_ring_outer) * cos(angle2) - (strut_width/2 - connector_thickness/2) * sin(angle2);
            y2_inner_neg = (inner_ring_outer) * sin(angle2) + (strut_width/2 - connector_thickness/2) * cos(angle2);
            x2_outer_neg = (outer_ring_inner) * cos(angle2) - (strut_width/2 - connector_thickness/2) * sin(angle2);
            y2_outer_neg = (outer_ring_inner) * sin(angle2) + (strut_width/2 - connector_thickness/2) * cos(angle2);

            // Diagonal 1: inner of channel1 to outer of channel2
            hull() {
                translate([x1_inner_neg, y1_inner_neg, 0])
                    cylinder(h = thickness, d = connector_thickness);
                translate([x2_outer_pos, y2_outer_pos, 0])
                    cylinder(h = thickness, d = connector_thickness);
            }

            // Diagonal 2: outer of channel1 to inner of channel2
            hull() {
                translate([x1_outer_neg, y1_outer_neg, 0])
                    cylinder(h = thickness, d = connector_thickness);
                translate([x2_inner_pos, y2_inner_pos, 0])
                    cylinder(h = thickness, d = connector_thickness);
            }

            // 2. Straight chord connector between outer junction points
            hull() {
                translate([x1_outer_neg, y1_outer_neg, 0])
                    cylinder(h = thickness, d = connector_thickness);
                translate([x2_outer_pos, y2_outer_pos, 0])
                    cylinder(h = thickness, d = connector_thickness);
            }

            // 3. Radial strut in the middle between two channels
            rotate([0, 0, mid_angle])
                translate([inner_ring_outer, -connector_thickness/2, 0])
                    cube([outer_ring_inner - inner_ring_outer, connector_thickness, thickness]);
        }
    }
}

// Render the chain guard
chain_guard();
