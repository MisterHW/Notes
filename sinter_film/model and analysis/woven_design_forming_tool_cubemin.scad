d = 0.4; // draft offset
g = 0.04; // gap/2

pitch = 4 + 4*d + 4*g;

pts = [
    // top
    [-0.5, 1.5, 1],[0.5, 1.5, 1], // 0 1 
    
    [-0.5,-1.5, 1],[0.5,-1.5, 1], // 2 3
    // bottom
    [-1.5+g,1.5+d, 0],           [1.5-g,1.5+d, 0], // 4     5
        [-0.5-d, 1.5, 0], [0.5+d, 1.5, 0],         //   6 7
        
        [-0.5-d,-1.5, 0], [0.5+d,-1.5, 0],         //   8 9
    [-1.5+g,-1.5-d, 0],          [1.5-g,-1.5-d, 0] // 10   11
];
    

faces = [ // orientation: CW when looking at a face from outside
    [0, 1, 3, 2],
    [4, 5, 1, 0],
    [1, 5, 7],
    [3, 1, 7, 9],
    [3, 9, 11],
    [2, 3, 11, 10], 
    [2, 10, 8],
    [6, 0, 2, 8],
    [0, 6, 4],
    [4, 6, 8, 10, 11, 9, 7, 5]
];


module tool_unit_cell(){
for ( i = [0:1:3] ) 
    rotate([0,0,90*i])
        translate([-1-d-g,-1-d-g,0])
             polyhedron(pts, faces, convexity=2);
}

module solid_tool(nx = 1, ny = 1, plate_thickness=[0,0,1]){
    union(){
        for (y = [0:1:(ny-1)])
            for (x = [0:1:(nx-1)])  
                translate([(x+0.5)*pitch+d+g, (y+0.5)*pitch+d+g, 0])
                        tool_unit_cell();

        translate([-plate_thickness[0], -plate_thickness[1], 1E-3-plate_thickness[2]])
            cube([
                nx*pitch+2*d+2*g+2*plate_thickness[0],
                ny*pitch+2*d+2*g+2*plate_thickness[1],
                plate_thickness[2]
            ]);
    }
}




module device(){
n_x = 2; 
n_y = 2;
difference(){
    minkowski(convexity=8){
        solid_tool(n_x, n_y, plate_thickness=[0.2,0.2,1]);
        // sphere(r=0.1, $fn=4);
        cube(0.1, center=true);
    };
    solid_tool(n_x, n_y, plate_thickness=[1,1,2]);   
}
}

difference(){
device();
// cube([10,10,10], center=true);
}


