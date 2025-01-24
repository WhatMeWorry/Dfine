
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
import hex;

import textures.texture;
import a_star.spot;
import hexmath;
import redblacktree : Location;

import windows.simple_directmedia_layer;

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

/+
     CARTESIAN COORDINATES
                                   
     + (0.0, maxY)            
     |
     |
     |
     |
     |
     |
     |
     |
     |              (maxX, 0.0)                  
     +-------------------+ 
 (0.0,0.0)


     NORMALIXED DEVICE COORDINATES (NDC)

Normalized device coordinates (-1, -1) is at the lower-left corner 
while (+1, +1) is at the top-right 

                     (1.0,1.0)
     +-------------------+
     |         |         |
     |                   |
     |         |         |
     |                   |
     | - - - (0.0) - - - |
     |                   |
     |         |         |
     |                   |
     |         |         |
     +-------------------+ 
(-1.0,-1.0)


     SCREEN COORDINATES (SC)

SDL coordinates, like most graphic engine coordinates, start at the top left corner of 
the screen/window. The more you go down the screen the more Y increases and as you go 
across to the right the X increases.

   (0,0)
     +-------------------+
     |                   |
     |                   |
     |                   |
     |                   |
     |                   |
     |                   |
     |                   |
     |                   |
     |                   | 
     |                   |
     +-------------------+ 
                (maxWidth, maxHeight)
+/


/+
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
+/

struct Edges
{                // This is the hex board edges, not the window's and is in NDC units
    float top;   // The hex board can be smaller, larger or identical to the window size
    float bottom; 
    float left;
    float right;
}

struct MouseClick
{
    Point2D!(float) ndc;  // normalized device coordinates 
    Point2D!(int)   sc;   // screen coordinates
}

struct SelectedHex
{
    int row;
    int col;
}


// x, y is the lower left corner of the rectangle touching all vertices

Point2D!(float)[6] defineHexVertices(float x, float y, float perpendicular, float diameter, 
                            float apothem, float halfRadius, float radius)
{
    Point2D!(float)[6] points;
    
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


Point2D!(float) defineHexCenter(float x, float y, float apothem, float radius)
{
    Point2D!(float) center;
    
    center.x = x + radius;
    center.y = y + apothem;
    
    return center;
} 


Point2D!(float) defineTextureStartingPoint(float x, float y, float perpendicular)
{
    Point2D!(float) anchor;
    
    anchor.x = x;
    anchor.y = y + perpendicular;
    
    return anchor;
} 


struct HexBoard
{
    @disable this();   // disables default constructor HexBoard h;
    
    this(float d, uint r, uint c) 
    {
        // These three parameters suffice to define the hexboard: the diameter size of each hex
        // (in ndc units) and the number of rows and columns making up the board
        diameter = d;
        rows = r;
        columns = c;
        
        /+    _________           _________
             /         \         /    |     \ 
            /           \       /     |      \
           /___diameter__\     /perpendicular \
           \             /     \      |       /
            \           /       \     |      /
             \_________/         \____|____ / 
        +/

        radius        = diameter * 0.5;
        halfRadius    = radius   * 0.5;
        perpendicular = diameter * 0.866; 
        apothem       = perpendicular * 0.5;
        
        /+ The bottom left corner (left edge and bottom edge) of the hexboard will always start at (-1.0,-1.0) 
           Ideally, the upper right corner (upper edge and right edge) of the hexboard would end at (1.0,1.0) thus
           perfectly fitting the NDC window. But since the hexboard is asymetric (1.0 in width to .866 in height) rarely 
           is this the case. If the top edge or bottom edge is less than 1.0, there will simply be a gap between The
           hexboard and the window. If the the top edge or bottom edge is greater than 1.0, then all geometry greater
           than one, will simply not be rendered.
           
           The function hexWidthToFitWindow() was written to allow either the horizontal or vertical direction to be
           fitted perfectly within the (-1.0, 1.0) window.  
        +/
        
        edge.bottom = -1.0;
        edge.top    = edge.bottom + (rows * perpendicular);
        edge.left   = -1.0;
        edge.right  = edge.left + (columns * (radius + halfRadius));
        
        hexes = new Hex!(float,int)[][](rows, columns);  // dynamically allocate all the hexes

        spots = new Spot[][](rows, columns);

        foreach(i; 0..rows)
        {
            foreach(j; 0..columns)
            {
                spots[i][j].location.r = i;
                spots[i][j].location.c = j;
            }
        }

        initializeHexBoard();
        
        addNeighbors();
        
        mouseClick.ndc.x = 0.0;
        mouseClick.ndc.y = 0.0;

        // can't call from here because we need the apps windows screen size which is 
        // unknown to the hex board. 
        //convertNDCoordsToScreenCoords(???);  // convert Normalized Device Coordinates to Screen Coordinates

        renderer = null;  // renderer for this hex board        
    }
    
    
    
    enum invalid = -1;  // -1 means a row or column is invalid

    uint rows;     // number of rows on the board [0..rows-1]
    uint columns;  // number of columns on the bord [0..cols-1]

    @property lastRow() { return rows-1; }
    @property lastColumn() { return columns-1; }

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
                    // each hex board has-a 2 dimensional array of hex structures
    Hex!(float,int)[][]  hexes;  // = new int[][](5, 2);    

    Spot[][] spots;  // each hex board has-a 2 dimensional array of path properties
                     // think of this a being superimposed over the hexes array.
    
    SDL_Renderer* renderer;

    SelectedHex selectedHex; 

    MouseClick mouseClick;

    void setRenderOfHexboard(SDL_Renderer *rend)
    {
        renderer = rend;
    }
    
    void displayHexBoardData()
    {
        writeln("===== Values are in Normalized Device Coordinates =====");
        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
            {
                writeln("hexes[", r, "][", c, "].center ", hexes[r][c].center );
                foreach(p; 0..6)
                {
                    writeln("hexes(r,c) ", hexes[r][c].points.ndc[p] );
                    writeln("hexes(r,c) ", hexes[r][c].points.sc[p] );
                }
            }
        }
    }

    void displayHexBoardScreenCoordinates()
    {
        //writeln("===== Values are in Screen Coordinates =====");
        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
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
 
        foreach(row; 0..rows)
        {
            // writeln("inside foreach row, row = ", row);
            foreach(col; 0..columns)
            {    
                hexes[row][col].points.ndc = defineHexVertices(x, y, perpendicular, diameter, 
                                                           apothem, halfRadius, radius);
            
                hexes[row][col].center.ndc = defineHexCenter(x, y, apothem, radius);
                
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
        
            if (columns.isOdd)
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
        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
            {    
                foreach(v; 0..6)
                {
                    float NDCx = hexes[r][c].points.ndc[v].x;  // makes following statements more legable
                    float NDCy = hexes[r][c].points.ndc[v].y;
                    
                    hexes[r][c].points.sc[v].x = roundTo!int((NDCx + 1.0) * 0.5 * screenWidth);
                    hexes[r][c].points.sc[v].y = roundTo!int((1.0 - NDCy) * 0.5 * screenHeight);
                }
                
                Point2D!(float) temp = hexes[r][c].texturePoint.ndc; // make func call easier to read
                
                hexes[r][c].texturePoint.sc = convertPointFromNDCtoSC(temp, screenWidth, screenHeight);
            }
        }
    }

    // screenWidth and screenHeight are not know by struct HexBoard
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


    Point2D!(int) convertPointFromNDCtoSC(Point2D!(float) ndc, int screenWidth, int screenHeight)
    {
        Point2D!(int) sc;
        
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


    void setHexboardTexturesAndTerrain(Globals g)
    {
        import std.random : uniform;
        auto rnd = Random(unpredictableSeed);    
 
        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
            {    
                // Generate an integer in 0,1,2,3,4,5
                auto a = uniform(0, 10, rnd);
                //hexes[r][c].texture.id = g.textures[a].id;
                //hexes[r][c].texture.fileName = g.textures[a].fileName;
                //hexes[r][c].texture.ptr = g.textures[a].ptr;

                switch(a) 
                {
                    case 0,1,2,3,4:
                        {
                            //writeln("solidGreen");
                            hexes[r][c].textures ~= g.textures[Ids.solidGreen];
                            spots[r][c].terrainCost = 1;
                        }
                        break;
                    case 5,6,7:
                        {
                            //writeln("solidBrown");
                            hexes[r][c].textures ~= g.textures[Ids.solidBrown];
                            spots[r][c].terrainCost = 9; // 9
                        }
                        break;
                    case 8,9:
                        {
                            //writeln("solidBlue");
                            hexes[r][c].textures ~= g.textures[Ids.solidBlue];
                            spots[r][c].terrainCost = 999; // 999
                        }
                        break;          
                    default: break;                                         
                }
                //hexes[r][c].texture = g.textures[a];
            }
        }
    }




    void clearHexBoard()
    {
        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
            {    
                //hexes[r][c].textures = Texture(Ids.none, "", null); // when textures was just a single Texture
                hexes[r][c].textures.length = 0;  // a=[]; a=null; change the pointer, so one cannot reuse the array
                // spots[r][c].location = Location(-1,-1); // DO NOT CHANGE!!!
                spots[r][c].neighbors = [Location(-1,-1), Location(-1,-1), Location(-1,-1), 
                                         Location(-1,-1), Location(-1,-1), Location(-1,-1)]; 
                spots[r][c].f = 0;
                spots[r][c].g = 0;
                spots[r][c].h = 0;
                spots[r][c].previous = Location(-1,-1);
                spots[r][c].terrainCost = 0;
            }
        }
    }



    void setHexTexture(Globals g, Location hex, Ids id)
    {
        hexes[hex.r][hex.c].textures ~= g.textures[id];
    }


    void setHexRowTexture(Globals g, int row, Ids id)  
    {
        foreach(c; 0..columns)
        {
            hexes[row][c].textures ~= g.textures[id]; 
        }
    }

    void setHexColTexture(Globals g, int col, Ids id)  
    {
        foreach(r; 0..rows)
        {
            hexes[r][col].textures ~= g.textures[id]; 
        }            
    }

    void displayHexTextures()
    {    
        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
            {
                foreach(tex; hexes[r][c].textures)
                {
                    if (tex.ptr != null)
                    {
                    SDL_Rect dst;
                
                    dst.x = hexes[r][c].texturePoint.sc.x;
                    dst.y = hexes[r][c].texturePoint.sc.y;

                    dst.w = sc.diameter;
                    dst.h = sc.perpendicular;

                    /+
                    SDL_RenderCopy(SDL_Renderer* renderer, DL_Texture* texture,
                    Is used for rendering a SDL_Texture and has the following parameters:

                    SDL_Renderer* renderer,   the renderer you want to use for rendering.
                    SDL_Texture*  texture,    the texture you want to render.
                    const SDL_Rect* srcrect,  part of the texture to render, null renders the entire texture.
                    const SDL_Rect* dstrect   where to render the texture in the window. If the width and height 
                                              of this SDL_Rect is smaller or larger than the dimensions of the texture 
                                              itself, the texture will be stretched according to this SDL_Rect.
                    +/
                    
                    SDL_RenderCopy( renderer, tex.ptr, null, &dst );
                                // Update window
                    // SDL_RenderPresent( renderer );  // DO OUTSIDE OF LOOP!!!
                    }
                }
            }
        }
        SDL_RenderPresent( renderer );
    }




    void drawHexBoard()
    {
        SDL_SetRenderDrawColor( g.sdl.renderer, 128, 128, 128, SDL_ALPHA_OPAQUE );
        //Clear screen
        SDL_RenderClear( g.sdl.renderer );

        SDL_SetRenderDrawColor( g.sdl.renderer, 0xFF, 0x00, 0x00, SDL_ALPHA_OPAQUE );        

        foreach(r; 0..rows)
        {
            foreach(c; 0..columns)
            {  
                // writeln("r = ", r, " c = ", c);
                SDL_RenderDrawLines(g.sdl.renderer, cast (SDL_Point *) &hexes[r][c].points.sc[0], 6);
                SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].points.sc[5].x,  // close off the hex  
                                                    hexes[r][c].points.sc[5].y, 
                                                    hexes[r][c].points.sc[0].x, 
                                                    hexes[r][c].points.sc[0].y);
                /+
                foreach(p; 0..6)
                {
                    SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].sc[0].x, 
                                                        hexes[r][c].sc[0].y, 
                                                        hexes[r][c].sc[1].x, 
                                                        hexes[r][c].sc[1].y);
                    SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].sc[1].x, 
                                                        hexes[r][c].sc[1].y, 
                                                        hexes[r][c].sc[2].x, 
                                                        hexes[r][c].sc[2].y);
                    SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].sc[2].x, 
                                                        hexes[r][c].sc[2].y, 
                                                        hexes[r][c].sc[3].x, 
                                                        hexes[r][c].sc[3].y);
                    SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].sc[3].x, 
                                                        hexes[r][c].sc[3].y, 
                                                        hexes[r][c].sc[4].x, 
                                                        hexes[r][c].sc[4].y);
                    SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].sc[4].x, 
                                                        hexes[r][c].sc[4].y, 
                                                        hexes[r][c].sc[5].x, 
                                                        hexes[r][c].sc[5].y);
                    SDL_RenderDrawLine( g.sdl.renderer, hexes[r][c].sc[5].x, 
                                                        hexes[r][c].sc[5].y, 
                                                        hexes[r][c].sc[0].x, 
                                                        hexes[r][c].sc[0].y);
                }
                +/
            }
        }

        // Update screen
        SDL_RenderPresent( g.sdl.renderer );
    }
 


void validateHexboard()
{
    foreach(i; 0..rows)
    {
        foreach(j; 0..columns)
        {
            if ((spots[i][j].location.r < 0) ||
                (spots[i][j].location.r > rows))
            {
                writeln("[i][j] = [", i, "][", j, "]");
                writeln("Index out of bounds");
                exit(0);
            }
                 
        }
    }

}



const uint N  = 0;  // North
const uint NE = 1;  // North-East
const uint SE = 2;  // South-East
const uint S  = 3;  // South
const uint SW = 4;  // South-West
const uint NW = 5;  // North-West


void addNeighbors()
{
    foreach(int r; 0..rows)          // Note: rows and columns are defined as uint 
    {                                    // this caused problems with < 0 boundary checking
        foreach(int c; 0..columns)   // causing -1 to be 4294967295
        {                                // had to declare the local r and c as ints
            foreach(int i; 0..6)
            {
                spots[r][c].neighbors[i].r = -1;
                spots[r][c].neighbors[i].c = -1;
            }
            if (c.isEven)
            {
                if (r+1 <= lastRow)                     // north
                {
                    spots[r][c].neighbors[N].r = r+1;
                    spots[r][c].neighbors[N].c = c;
                }
                if (c+1 <= lastColumn)                  // north-east
                {
                    spots[r][c].neighbors[NE].r = r;
                    spots[r][c].neighbors[NE].c = c+1;
                }
                if ((c+1 <= lastColumn) && (r-1 >= 0))  // south-east
                {
                    spots[r][c].neighbors[SE].r = r-1;
                    spots[r][c].neighbors[SE].c = c+1;
                }
                if (r-1 >= 0)                             // south
                {
                    spots[r][c].neighbors[S].r = r-1;
                    spots[r][c].neighbors[S].c = c;
                }
                if ((r-1 >= 0) && (c-1 >= 0))             // south-west
                {
                    spots[r][c].neighbors[SW].r = r-1;
                    spots[r][c].neighbors[SW].c = c-1;
                }
                if (c-1 >= 0)                             // north-west
                {
                    spots[r][c].neighbors[NW].r = r;
                    spots[r][c].neighbors[NW].c = c-1;
                }
            }
            else   // On Odd Column
            {
                
                if (r+1 <= lastRow)                     // north
                {
                    spots[r][c].neighbors[N].r = r+1;
                    spots[r][c].neighbors[N].c = c;
                }
                if ((r+1 <= lastRow) && (c+1 <= lastColumn)) // north-east
                {
                    spots[r][c].neighbors[NE].r = r+1;
                    spots[r][c].neighbors[NE].c = c+1;
                }
                if (c+1 <= lastColumn)                  // south-east
                {
                    spots[r][c].neighbors[SE].r = r;
                    spots[r][c].neighbors[SE].c = c+1;
                }
                if (r-1 >= 0)                             // south
                {
                    spots[r][c].neighbors[S].r = r-1;
                    spots[r][c].neighbors[S].c = c;
                }
                if (c-1 >= 0)                             // south-west
                {
                    spots[r][c].neighbors[SW].r = r;
                    spots[r][c].neighbors[SW].c = c-1;
                }
                if ((r+1 <= lastRow) && (c-1 >= 0))     // north-west
                {
                    spots[r][c].neighbors[NW].r = r+1;
                    spots[r][c].neighbors[NW].c = c-1;
                }
            }
            //writeln("(r,c) = ", "(", r, ",", c, ")"); 
            //writeln("spots[r][c].neighbors = ", spots[r][c].neighbors);
        }
    }
}


 
}
