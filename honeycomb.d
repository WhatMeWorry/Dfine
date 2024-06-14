
module honeycomb;


import std.conv: roundTo, to;
import std.stdio: writeln, readf;
import core.stdc.stdlib: exit;
import std.range;
import std.random;

import bindbc.sdl;

import std.math.rounding: floor;
import std.math.algebraic: abs;

import app;
import std.string;

import textures.load_textures;
import a_star.spot;

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
containing references to the inner arrays. Array lookups require multiple indirections, so there is a 
slight performance hit.

Note that with the "jagged" array scheme, the "2nd dimensions" arrays may either all be allocated individually, 
or simply be slices of a single very big 1D array. Both schemes are valid.

A dynamic rectangular jagged array may be dynamically allocated at once using the multi-dim allocation syntax:

Allocate a dynamic array containing 2 dynamic arrays containing 5 ints

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

From SC to NDC

float pixelX = (NDCx + 1.0f) * 0.5 * screenWidth;
float pixelY = (1.0f - NDCy) * 0.5 * screenHeight;

when NDCx is -1 we get 0 and when NDCx is  1 we get screenWidth

when NDCy is  1 we get 0 and when NDCy is -1 we get screenHeight
+/




struct D2_NDC  // normalized device coordinates 2d point
{
    float x;
    float y; 
}

struct D2_SC   // screen cordinates 2d point
{
    int x;
    int y;
}


struct D2_DUAL  // same point but in different units
{
    D2_NDC ndc; // normalized device coordinates
    D2_SC  sc;  // screen coordinates
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
    D2_NDC  ndc;  // normalized device coordinates 
    D2_SC   sc;   // screen coordinates
}		

struct SelectedHex
{
    int row;
    int col;
}

struct HexPosition
{
    int row;
    int column;
}

enum Direction 
{ 
    vertically,
    horizontally
} 



float calculateHexDiameter(int rows, int cols, Direction fill )
{
    float totalSegments;
    float diameter;
    float widthPerSegment;	
	float heightPerHex;

     /+   note: all vertical segments are same size. The 
     | \         | /         | \         | /         | \         | /
     |  \________|/          |  \________|/          |  \________|/__|
     |  /        |\          |  /        |\          |  /        |\  |
     | /         | \         | /         | \         | /         | \ |
     |/          |  \____|___|/          |  \________|/  |       |  \|    
     |\ |    |   |  /|   |   |\  |   |   |  /|       |\  |   |   |  /|
     | \|    |   | / |   |   | \ |   |   | / |   |   | \ |   |   | / |
     |  \____|___|/__|___|___|  \|___|___|/__|___|___|  \|___|___|/__|
     | 1|  2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |10|| 11|12 |13 |14 |15 | 16|
     +/

    // The width of any given NDC system is always 2.0 units.  (-1.0 to 1.0)

    if (fill == Direction.horizontally)
    {	
        totalSegments = (cols * 3) + 1;
			
        widthPerSegment = 2.0 / totalSegments;

        diameter = 4.0 * widthPerSegment;  // 4 segments equal a hex diameter 	
    } 	
    if (fill == Direction.vertically)
    {
        heightPerHex = 2.0 / rows;
		
		writeln("heightPerHex = ", heightPerHex);
		
        // perpendicular = diameter * 0.866; or
        // diameter = perpendicular / 0.866;
		
        diameter = heightPerHex / 0.866;
    }	
	
    return diameter;
}	



bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);   
}

// x, y is the lower left corner of the rectangle touching all vertices

D2_NDC[6] defineHexVertices(float x, float y, float perpendicular, float diameter, 
                            float apothem, float halfRadius, float radius)
{
    D2_NDC[6] points;
	
    points[0].x = x + halfRadius;
    points[0].y = y;	

    points[1].x = x + halfRadius + radius;
    points[1].y = y;	
		
    points[2].x = x + diameter;
    points[2].y = y + apothem;	
	
    points[3].x = x + halfRadius + radius;
    points[3].y = y + perpendicular;	
	
    points[4].x = x + halfRadius;
    points[4].y = y + perpendicular;
	
    points[5].x = x;
    points[5].y = y + apothem;
	
    return points;
} 


D2_NDC defineHexCenter(float x, float y, float apothem, float radius)
{
    D2_NDC center;
	
    center.x = x + radius;
    center.y = y + apothem;
	
    return center;
} 


D2_NDC defineTextureStartingPoint(float x, float y, float perpendicular)
{
    D2_NDC anchor;
	
    anchor.x = x;
    anchor.y = y + perpendicular;
	
    return anchor;
} 


struct Hex
{
    D2_NDC[6] points;       // each hex is made up of 6 vertices
    D2_SC[6]  sc;           // screen coordinates
    D2_NDC    center;       // each hex has a center
	D2_DUAL   texturePoint; // each hex has conceptual rectange. Use its upper left
                            // corner as target rectangle for texture application   
    Texture   texture;	
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

        renderer = null;  // renderer for this hex board		
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
	
    struct SC
    {	
        int diameter;  // Same as above block but in Screen Coordinates (integers) 
        int radius;	
        int halfRadius;	
        int perpendicular;	
        int apothem;
    }		

    SC sc;
	                // each hex board has-a structure of hexes
    Hex[][] hexes;  // = new int[][](5, 2);	

    Spot[][] spots;  // each hex board has-a structure of path properties
                     // think of this a being superimposed over the hexes array.
	
	SDL_Renderer* renderer;

    SelectedHex selectedHex; 

    MouseClick mouseClick;
	
    uint numberOfRows(){ return maxRows; }

    uint numberOfColumns(){ return maxCols; }
	
	void setRenderOfHexboard(SDL_Renderer *rend)
	{
        renderer = rend;
    }
	
    void displayHexBoard()
    {
        //writeln("===== Values are in Normalized Device Coordinates =====");
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

    void displayHexBoardScreenCoordinates()
    {
	    //writeln("===== Values are in Screen Coordinates =====");
        foreach(r; 0..maxRows)
        {
            foreach(c; 0..maxCols)
            {
                //writeln("hexes[", r, "][", c, "].center ", hexes[r][c].center );    	
                foreach(p; 0..6)
                {
				    if (p == 5)
                    {
                         //writeln("hexes(", r, ",", c, ") = ", hexes[r][c].sc[p] ); 
                    }						 
                }
                //writeln("hexes texture Point = ", hexes[r][c].texturePoint);				
            }
        }			
    }

	
    // DEFINE HEX BOARD
	
    void initializeHexBoard()
    {	
        // start at the bottom left corner of NDC window, drawing from left to right, bottom to top.
		
        float x = edge.left;      // NDC (Normalized Device Coordinates) start at -1.0
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
				
				hexes[row][col].texturePoint.ndc = defineTextureStartingPoint(x, y, perpendicular);
				
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
	
    // screenWidth and screeHeight are not know by struct HexBoard
    // this function can only be called from outside of this module
	
    void convertNDCoordsToScreenCoords(int screenWidth, int screenHeight)
    {
        foreach(r; 0..maxRows)
        {
            foreach(c; 0..maxCols)
            {	
                foreach(v; 0..6)
                {
                    float NDCx = hexes[r][c].points[v].x;  // makes following statements more legable
                    float NDCy = hexes[r][c].points[v].y;
					
                    hexes[r][c].sc[v].x = roundTo!int((NDCx + 1.0) * 0.5 * screenWidth); 
                    hexes[r][c].sc[v].y = roundTo!int((1.0 - NDCy) * 0.5 * screenHeight); 					
                }
				
                D2_NDC temp = hexes[r][c].texturePoint.ndc; // make func call easier to read
				
				hexes[r][c].texturePoint.sc = convertPointFromNDCtoSC(temp, screenWidth, screenHeight);			
            }				
        }  
    }

    // screenWidth and screeHeight are not know by struct HexBoard
    // this function can only be called from outside of this module
	
    void convertNDClengthsToSClengths(int screenWidth, int screenHeight)
    {
	    float screenCoordinatesLength = 2.0;  // from -1.0 to 1.0
		
		float perCentOfEntireLength = diameter / screenCoordinatesLength;
		
        sc.diameter = roundTo!int(perCentOfEntireLength * screenWidth);	
		
        //radius        = diameter * 0.5;	
        //halfRadius    = radius   * 0.5;						
        //perpendicular = diameter * 0.866;	
		
        sc.perpendicular = roundTo!int( to!float(sc.diameter) * 0.866 );
    }
	
	
    D2_SC convertPointFromNDCtoSC(D2_NDC ndc, int screenWidth, int screenHeight)
    {	
        D2_SC sc;
		
        sc.x = roundTo!int((ndc.x + 1.0) * 0.5 * screenWidth);    
        sc.y = roundTo!int((1.0 - ndc.y) * 0.5 * screenHeight);

        return sc;		
    }	
	


    // Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)
	
	// screenWidth and screeHeight are not know by struct HexBoard
    // this function can only be called from outside of this module
	
    void convertScreenCoordinatesToNormalizedDeviceCoordinates(int screenWidth, int screenHeight)
    {
	
        mouseClick.ndc.x =   (mouseClick.sc.x / (screenWidth  / 2.0)) - 1.0;  // xPos/(screenWidth/2.0) gives values from 0.0 to 2.0
                                                                              // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
																
        mouseClick.ndc.y = -((mouseClick.sc.y / (screenHeight / 2.0)) - 1.0); // yPos/(winHeight/2.0) gives values from 0.0 to 2.0
                                                                              // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0
																			  
        // The minus sign at front of expression is needed because screen coordinates are flipped horizontally from NDC coordinates																	
 							
        // Take the bottom of the edge of the screen (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
	    // So that the mouse click and subtract the edge.  	
		
    }			


    void initializeHexTextures(Globals g)
    {
	    import std.random : uniform;
		auto rnd = Random(unpredictableSeed);	
 
        foreach(r; 0..maxRows)
        {
            foreach(c; 0..maxCols)
            {	
                // Generate an integer in 0,1,2,3,4
                auto a = uniform(0, 6, rnd);
                //hexes[r][c].texture.id = g.textures[a].id;				
                //hexes[r][c].texture.fileName = g.textures[a].fileName;
                //hexes[r][c].texture.ptr = g.textures[a].ptr;
				hexes[r][c].texture = g.textures[a];
            }
        }
    }

    void setHexTexture(Globals g, HexPosition hex, Ids id)
    {
        hexes[hex.row][hex.column].texture = g.textures[id];
    }


    void setHexRowTexture(Globals g, int row, Ids id)  
	{
        foreach(c; 0..maxCols)
        {
            hexes[row][c].texture = g.textures[id]; 
        }			
    }

    void setHexColTexture(Globals g, int col, Ids id)  
	{
        foreach(r; 0..maxRows)
        {
            hexes[r][col].texture = g.textures[id]; 
        }			
    }

    void displayHexTextures()
    {	
        foreach(r; 0..maxRows)
        {
            foreach(c; 0..maxCols)
            {
                SDL_Rect dst;
								
			    dst.x = hexes[r][c].texturePoint.sc.x;
                dst.y = hexes[r][c].texturePoint.sc.y;

                dst.w = sc.diameter;
                dst.h = sc.perpendicular;

                SDL_RenderCopy( renderer, hexes[r][c].texture.ptr, null, &dst );									
	                            // Update window
                // SDL_RenderPresent( renderer );  // DO OUTSIDE OF LOOP!!!		
            }
        }
        SDL_RenderPresent( renderer );			
    }	
	
}
