
module honeycomb;


import std.conv: roundTo;
import std.stdio: writeln, readf;
import core.stdc.stdlib: exit;
import std.range;

import std.math.rounding: floor;
import std.math.algebraic: abs;


/+
From:  https://wiki.dlang.org/Dense_multidimensional_arrays


Jagged arrays
The simplest way is to use an array of arrays:

int[][] matrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
];
assert(matrix[0][0] == 1);
assert(matrix[1][1] == 5);

However, this approach is not so memory-efficient, because the outer array is a separate block of memory 
containing references to the inner arrays. Array lookups require multiple indirections, so there is a s
light performance hit.

Note that with the "jagged" array scheme, the "2nd dimensions" arrays may either all be allocated individually, 
or simply be slices of a single very big 1D array. Both schemes are valid.

A dynamic rectangular jagged array may be dynamically allocated at once using the multi-dim allocation syntax:

//Allocates a dynamic array containing
//  2 dynamic arrays containing
//    5 ints
int[][] matrix = new int[][](5, 2);

Note that in this example, the dimensions don't need to be known at compile time. Also note that this works for 
any amount of dimensions.

Static arrays
D recognizes the inefficiency of jagged arrays, so when all the dimensions of the array are known at compile-time, 
the array is automatically implemented as a dense array: the elements are packed together into a single memory block, 
and array access requires only a single indexed lookup:

// This is a dense array
int[3][3] matrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
];

Dense arrays are fast and memory-efficient. But it requires that all array dimensions be known at compile-time, that is, 
it must be a static array.

Dense dynamic arrays

There is a way to make multidimensional dynamic arrays dense, if only the last dimension needs to be variable, or if the 
array is just too big to fit on stack:

enum columns = 100;
int rows = 100;
double[columns][] gridInfo = new double[columns][](rows);

This creates a multidimensional dynamic array with dense storage: all the array elements are contiguous in memory.

+/

/+
https://web.cse.ohio-state.edu/~shen.94/5542/4-coordinates.pdf

What are the visible coordinates range?

For 2D drawing, the visible range of the display window is from [-1,-1] to [1,1] (for 3D, the z is also
from -1 to 1, but we will talk about it later)

In other words, you need to transform your points to this range so that they will be visible. This is 
called “Normalized Device Coordinate (NDC) system 

But how to map the NDC to the display window?

A pixel in a window is referenced as two integers (i,j)
This is called the screen coordinate (SC) system.

GLFW and SDL starts numbering the pixels from the left top corner of the window.

From NDC to SC

Just do a linear mapping from [-1,-1] x [1,1] to [0,0] x [Imax, Jmax]
That is, assume (x,y) is in NDC, (i,j) is in SC, then
i = (x – (-1))/2.0 * Imax
j = (y – (-1))/2.0 * Jmax


https://www.gamedev.net/forums/topic/685104-ndc-to-pixel-space/

I used mathematics and my conclusion was:

float pixelX = (NDCx + 1.0f) * 0.5 * screenWidth;
float pixelY = (1.0f - NDCy) * 0.5 * screenHeight;


+/

bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);   
}


                             // x, y is the lower left corner of the rectangle touching all vertices
D3_point[6] defineHexVertices(float x, float y, float perpendicular, float diameter, float apothem, float halfRadius, float radius)
{
    D3_point[6] points;
	
    points[0].x = x + halfRadius;
    points[0].y = y;	
    points[0].z = 0.0;	

    points[1].x = x + halfRadius + radius;
    points[1].y = y;
    points[1].z = 0.0;		
		
    points[2].x = x + diameter;
    points[2].y = y + apothem;
    points[2].z = 0.0;		
	
    points[3].x = x + halfRadius + radius;
    points[3].y = y + perpendicular;
    points[3].z = 0.0;		
	
    points[4].x = x + halfRadius;
    points[4].y = y + perpendicular;
    points[4].z = 0.0;	
	
    points[5].x = x;
    points[5].y = y + apothem;
    points[5].z = 0.0;	
	
    // writeln("points = ", points);
	
    return points;
} 

D3_point defineHexCenter(float x, float y, float apothem, float radius)
{
    D3_point center;
	
    center.x = x + radius;
    center.y = y + apothem;
    center.z = 0.0;
	
    return center;
} 



struct D2_point
{
    int x;
    int y; 
}


struct D2_NDC
{
    float x;
    float y; 
}


struct D2_SC
{
    int x;
    int y; 
}


struct D3_point
{
    float x;
    float y; 
    float z;
}


struct Edges
{                // This is the hex board edges, not the window's and is in NDC units
    float top;   // The hex board can be smaller, larger or identical to the window size
    float bottom; 
    float left;
    float right;	
}

struct MouseClick
{   	
    D3_point ndc;  // normalized device coordinates 
    D2_SC  sc;   // screen coordinates
}		

struct SelectedHex
{
    int row;
    int col;
}


struct Hex
{
    D3_point[6] points;  // each hex is made up of 6 vertices
    D2_point[6] sc;      // screen coordinates
    D3_point center;     // each hex has a center
}


struct HexBoard
{
    @disable this();   // disables default constructor HexBoard h;
	
    this(float d, uint r, uint c) 
    {
        // These three parametes suffice to define the hexboard as well as each individual hex
        diameter = d;
        maxRows = r;
        maxCols = c;		
		
        radius        = diameter * 0.5;	
        halfRadius    = radius   * 0.5;						
        perpendicular = diameter * 0.866;	
        apothem       = perpendicular * 0.5; 
		
        edge.bottom = -1.0;
        edge.top    = edge.bottom + (maxRows * perpendicular); 
        edge.left   = -1.0;
        edge.right  = edge.left + (maxCols * (radius + halfRadius)); 			
		
        hexes = new Hex[][](maxRows, maxCols);

        initializeHexBoard();
		
        mouseClick.ndc.x = 0.0;
        mouseClick.ndc.y = 0.0;		
		
        // can't call from here because we need the apps windows screen size which is 
        // unknown to the hex board. 
        //convertNDCoordsToScreenCoords(???);  // convert Normalized Device Coordinates to Screen Coordinates		
    }
	
    enum invalid = -1;  // -1 means a row or column is invalid
	
    uint maxRows;  // number of rows on the board [0..rows-1]
    uint maxCols;  // number of columns on the bord [0..cols-1]
	
    Edges edge;

    // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
    // which because of the hex board stagger makes a row of 5 (not 4) hexes.
    // A diameter of 2.0, would display a single hex which would fill the full width 
    // of the window and 0.866 of the window's height.

    float diameter;  // diameter is used to define all the other hex parameters 
    float radius;	
    float halfRadius;	
    float perpendicular;	
    float apothem;

    Hex[][] hexes;  // = new int[][](5, 2);	

    SelectedHex selectedHex; 

    MouseClick mouseClick;
	
    //D3_point hexCenter;  // will just use the x,y coordinates (not z)
	

    uint numberOfRows(){ return maxRows; }

    uint numberOfColumns(){ return maxCols; }
	
    void displayHexBoard()
    {
        foreach(r; 0..maxRows)
        {
            foreach(c; 0..maxCols)
            {
                //writeln("hexes[", r, "][", c, "].center ", hexes[r][c].center );    	
                foreach(p; 0..6)
                {
                    //writeln("hexes(r,c) ) ", hexes[r][c].points[p] );                   
                }				 	
            }
        }			
    }
	
    // DEFINE HEX BOARD
	
    void initializeHexBoard()
    {	
        // start at the bottom left corner of NDC window, drawing from left to right, bottom to top.
		
        float x = edge.left;      // NDC Normalized Device Coordinates start at -1.0
        float y = edge.bottom; 

        writeln("inside initializeHexBoard");		
 
        foreach(row; 0..maxRows)
        {
            // writeln("inside foreach row, row = ", row);		
            foreach(col; 0..maxCols)
            {	
                hexes[row][col].points = defineHexVertices(x, y, perpendicular, diameter, 
														   apothem, halfRadius, radius);
			
                hexes[row][col].center = defineHexCenter(x, y, apothem, radius);
				
                // writeln("hexes[row][col].center = ", hexes[row][col].center);
				
                if (col.isEven)
                {
                    y += apothem;
                }
                else
                {			
                    y -= apothem;   
                }
                x += halfRadius + radius;  
            }
		
            x = edge.left;  // start a new row and column on the left
		
            if (maxCols.isOdd)
            {
                y -= apothem;
            }
			
            y += perpendicular;	
        }  
    }	
	
	
    void convertNDCoordsToScreenCoords(int screenWidth, int screenHeight)
    {
        foreach(r; 0..maxRows)
        {
            foreach(c; 0..maxCols)
            {	
                foreach(v; 0..6)
                {
                    float NDCx = hexes[r][c].points[v].x;
                    float NDCy = hexes[r][c].points[v].y;
					
                    hexes[r][c].sc[v].x = roundTo!int((NDCx + 1.0) * 0.5 * screenWidth); 
                    hexes[r][c].sc[v].y = roundTo!int((1.0 - NDCy) * 0.5 * screenHeight); 					
                }
            }				
        }  
    }		


    // Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)
	
    void convertScreenCoordinatesToNormalizedDeviceCoordinates(int screenWidth, int screenHeight)
    {
	
        mouseClick.ndc.x =   (mouseClick.sc.x / (screenWidth / 2.0)) - 1.0;   // xPos/(screenWidth/2.0) gives values from 0.0 to 2.0
                                                                              // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
																	
        mouseClick.ndc.y = -((mouseClick.sc.y / (screenHeight / 2.0)) - 1.0); // yPos/(winHeight/2.0) gives values from 0.0 to 2.0
                                                                              // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0
																			  
        // The minus sign at front of expression is needed because screen coordinates are flipped horizontally from NDC coordinates																	
 							
        // Take the bottom of the edge of the screen (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
	    // So that the mouse click and subtract the edge.  	
		
    }			
	
}
