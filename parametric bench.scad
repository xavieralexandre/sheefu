mode = "bench"; // "joinery" "bench"

// Bench dimensions
// (mm)
bench_length=430; // [0:1000]
// (mm)
seating_height=430; // [10:80]
// (mm)
seating_depth=430; // [10:80]

// Boards properties
// Jumbo: http://www.jumbo.ch/fileadmin/user_upload/bilder/services/jumbo_service_total/0714_Decoupe_planches_f.pdf
// (mm)
board_thickness=6.5; // [1:20]
// (Boards surfacic price (CHF per square meter). Total price echoed when script is ran through OpenScad)
board_surfacic_price=29.50; // [0:100]
// (kg.m^.3) Total boards weight echoed when script is ran through OpenScad)
volumetric_mass_density=450; // kg.m^.3


/* [Hidden] */

// 3D printing properties
// (mm)
min_unsupported_wall_thickness=1;

// Feet dimensions


// Feet spacing

// Top
// Top-spacing of feet relative to seating_depth
outside_feet_top_spacing_ratio=1;  // [0:1] 
outside_feet_top_spacing=min(seating_depth*outside_feet_top_spacing_ratio,seating_depth-board_thickness);
inside_feet_top_spacing=board_thickness; // Depending of way feet are joined to the seating board it might be better to space feet in order to better distribute the weight. Here they are kept together to avoid them sliding toward each other. Spacing is a bit overestimated since it doesn't take angle into account.

// Bottom
outside_feet_bottom_spacing_ratio=.8; 
outside_feet_bottom_spacing=outside_feet_top_spacing*outside_feet_bottom_spacing_ratio;
inside_feet_bottom_spacing=outside_feet_bottom_spacing-2*(board_thickness+min_unsupported_wall_thickness);
average_bottom_spacing=(outside_feet_bottom_spacing+inside_feet_bottom_spacing)/2;

// Lenghts
underseat_height=seating_height-board_thickness;
feet_height=underseat_height-2*min_unsupported_wall_thickness;

outside_feet_length_x=(outside_feet_bottom_spacing-outside_feet_top_spacing)/2;
inside_feet_length_x=(inside_feet_bottom_spacing-inside_feet_top_spacing)/2;

outside_feet_angle=atan(feet_height/outside_feet_length_x);
inside_feet_angle=atan(feet_height/inside_feet_length_x);

outside_offset=cos(outside_feet_angle)*board_thickness/2;
inside_offset=cos(inside_feet_angle)*board_thickness/2;

outside_feet_length=sqrt(pow(outside_feet_length_x,2)+pow(feet_height,2))-2*outside_offset;
inside_feet_length=sqrt(pow(inside_feet_length_x,2)+pow(feet_height,2))-2*inside_offset;


module boards(){

	//Seating board
	color("yellow")
	translate([0,0,(seating_height-board_thickness/2)])
	cube([seating_depth,bench_length,board_thickness],center=true);


	//Feet

	// Right outside foot
	color("green")
	translate([(outside_feet_length_x+outside_feet_top_spacing)/2,0,underseat_height/2])
	rotate([0,outside_feet_angle,0])
	cube([outside_feet_length,bench_length,board_thickness],center=true);

	// Left outside foot
	color("red")
	translate([-(outside_feet_length_x+outside_feet_top_spacing)/2,0,underseat_height/2])
	rotate([0,-outside_feet_angle,0])
	cube([outside_feet_length,bench_length,board_thickness],center=true);

	// Right inside foot
	color("purple")
	translate([(inside_feet_length_x+inside_feet_top_spacing)/2,0,underseat_height/2])
	rotate([0,inside_feet_angle,0])
	cube([inside_feet_length,bench_length,board_thickness],center=true);

	// Left inside foot
	color("blue")
	translate([-(inside_feet_length_x+inside_feet_top_spacing)/2,0,underseat_height/2])
	rotate([0,-inside_feet_angle,0])
	cube([inside_feet_length,bench_length,board_thickness],center=true);
}

board_width = seating_depth + 2*(outside_feet_length+inside_feet_length);

module board(){
	translate([feet_bottom_spacing+board_width/2,0,0])
	square([board_width,bench_length],center=true);
}

//Joinery
joint_length=20; //mm
joinery_offset_lengthwise=min_unsupported_wall_thickness; //mm
joinery_thickness=min_unsupported_wall_thickness; //mm
feet_joint_height=.025*outside_feet_length+min_unsupported_wall_thickness;



module foot_bottom_joinery(){
	a=[-board_thickness-joinery_thickness,0];
	b=[-board_thickness-joinery_thickness-feet_joint_height/tan(inside_feet_angle),feet_joint_height];
	c=[board_thickness+joinery_thickness-feet_joint_height/tan(outside_feet_angle),feet_joint_height];
	d=[board_thickness+joinery_thickness,0];
	
	translate([average_bottom_spacing/2,-bench_length/2+joint_length,0])
	rotate([90,0,0])
	
	linear_extrude(joint_length+joinery_offset_lengthwise)
	polygon([a,b,c,d]);
}

module foot_top_outside_joinery(){
	a=[-joinery_thickness,joinery_thickness];
	b=[board_thickness+joinery_thickness,joinery_thickness];
	c=[board_thickness+joinery_thickness,-board_thickness-min_unsupported_wall_thickness];
	d=[board_thickness+joinery_thickness-feet_joint_height/tan(outside_feet_angle),-feet_joint_height-board_thickness];
	e=[-joinery_thickness-feet_joint_height/tan(outside_feet_angle),-feet_joint_height-board_thickness];
	f=[-joinery_thickness,-board_thickness-min_unsupported_wall_thickness];
	translate([-seating_depth/2,-bench_length/2+joint_length,seating_height])
	rotate([90,0,0])
	
	linear_extrude(joint_length+joinery_offset_lengthwise)
	polygon([a,b,c,d,e,f]);

}

module foot_top_inside_joinery(){
	a=[-board_thickness-joinery_thickness,joinery_thickness];
	b=[board_thickness+joinery_thickness,joinery_thickness];
	c=[board_thickness+joinery_thickness,-board_thickness];
	d=[board_thickness+joinery_thickness+feet_joint_height/tan(inside_feet_angle),-feet_joint_height-board_thickness];
	e=[-board_thickness-joinery_thickness-feet_joint_height/tan(inside_feet_angle),-feet_joint_height-board_thickness];
	f=[-board_thickness-joinery_thickness,-board_thickness];
	translate([0,-bench_length/2+joint_length,seating_height])
	rotate([90,0,0])
	
	linear_extrude(joint_length+joinery_offset_lengthwise)
	polygon([a,b,c,d,e,f]);

}

module feet_top_inside_joinery(){
	foot_top_inside_joinery();
	mirror([0,1,0]) foot_top_inside_joinery();
}

module foot_top_inside_joinery_only(){
	difference(){
		foot_top_inside_joinery();
		boards();
	}
}

// foot_top_inside_joinery_only();

module feet_bottom_joinery(){
	foot_bottom_joinery();
	mirror([0,1,0]) foot_bottom_joinery();
	mirror([1,0,0]) foot_bottom_joinery();
	mirror([0,1,0]) mirror([1,0,0]) foot_bottom_joinery();
}

module foot_bottom_joinery_only(){
	difference(){
		foot_bottom_joinery();
		boards();
	}
}
// foot_bottom_joinery_only();

module feet_top_joinery(){
	foot_top_outside_joinery();
	mirror([0,1,0]) foot_top_outside_joinery();
	mirror([1,0,0]) foot_top_outside_joinery();
	mirror([0,1,0]) mirror([1,0,0]) foot_top_outside_joinery();
}

module foot_top_outside_joinery_only(){
	difference(){
		foot_top_outside_joinery();
		boards();
	}
}
// foot_top_outside_joinery_only();

module bench(){
	% feet_bottom_joinery();
	% feet_top_joinery();
	% feet_top_inside_joinery();
	boards();
}

module left_joinery(){
	
	module outside_joinery(){
		translate([-30-average_bottom_spacing/2,bench_length/2-min_unsupported_wall_thickness-joint_length,0])
		foot_bottom_joinery_only();
	
		translate([-30+outside_feet_top_spacing/2,bench_length/2-min_unsupported_wall_thickness-joint_length,-seating_height+board_thickness+feet_joint_height+2*feet_joint_height])
		foot_top_outside_joinery_only();
	}
	outside_joinery();
	
	mirror([1,0,0]) outside_joinery();
	
	module inside_joinery(){
		translate([0,bench_length/2-min_unsupported_wall_thickness-joint_length,-seating_height+board_thickness+feet_joint_height+2*feet_joint_height])
		foot_top_inside_joinery_only();
	}
	inside_joinery();
}

module joinery(){
	left_joinery();
	mirror([0,1,0]) left_joinery();
}

if (mode == "joinery") {
	joinery(); 
} else if (mode == "bench") { 
	bench(); 
} else {
	bench(); 
	joinery();
}


//Surface, weight & price
surface = bench_length * board_width / 1000000;
price = surface * board_surfacic_price;
volume = surface * board_thickness / 1000;
weight = volume * volumetric_mass_density;

echo(Section_m=board_width/1000);
echo(Surface_m2=surface);
echo(Price_fr=price);
echo(Weight_kg=weight);
