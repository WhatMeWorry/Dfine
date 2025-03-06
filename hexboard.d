
module hexboard;


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
import std.algorithm : min;

/+
import std.stdio;

void main()
{
    struct HexBoard(F, I)
    {
        this(F d, I r, I c) {}
        F f;
        I i;
    }

    void displayHexBoard(HB)(HB h) {}  // This is so elegant!
    
    auto h = HexBoard!(float,uint)(.25, 3, 7);
    auto h2 = HexBoard!(double,int)(.43, 6, 6);
    
    displayHexBoard(h);
    displayHexBoard(h2);   
    writeln(typeof(h).stringof);  
    writeln(typeof(h.f).stringof);
    writeln(typeof(h.i).stringof); 
    
    writeln(typeof(h2).stringof);  
    writeln(typeof(h2.f).stringof);
    writeln(typeof(h2.i).stringof);  
}

HexBoard!(float, uint)
float
uint
HexBoard!(double, int)
double
int

+/






struct Edges(F)
{                // This is the hex board edges, not the window's and is in NDC units
    F top;   // The hex board can be smaller, larger or identical to the window size
    F bottom; 
    F left;
    F right;
}


struct MouseClick(F,I)
{
    Point2D!(F) ndc;  // normalized device coordinates 
    Point2D!(I) sc;   // screen coordinates
}


struct SelectedHex(I)
{
    I row;
    I col;
}


void defineHexVertices(HB, F, I)(HB h, F x, F y, I r, I c)
{   
    h.hexes[r][c].points.ndc[0].x = x + h.ndc.halfRadius;
    h.hexes[r][c].points.ndc[0].y = y;    

    h.hexes[r][c].points.ndc[1].x = x + h.ndc.halfRadius + h.ndc.radius;
    h.hexes[r][c].points.ndc[1].y = y;    
        
    h.hexes[r][c].points.ndc[2].x = x + h.ndc.diameter;
    h.hexes[r][c].points.ndc[2].y = y + h.ndc.apothem;    
    
    h.hexes[r][c].points.ndc[3].x = x + h.ndc.halfRadius + h.ndc.radius;
    h.hexes[r][c].points.ndc[3].y = y + h.ndc.perpendicular;    
    
    h.hexes[r][c].points.ndc[4].x = x + h.ndc.halfRadius;
    h.hexes[r][c].points.ndc[4].y = y + h.ndc.perpendicular;
    
    h.hexes[r][c].points.ndc[5].x = x;
    h.hexes[r][c].points.ndc[5].y = y + h.ndc.apothem;
}



void defineHexCenters(HB, F, I)(HB h, F x, F y, I r, I c)
{
    h.hexes[r][c].center.ndc.x = x + h.ndc.radius;
    h.hexes[r][c].center.ndc.y = y + h.ndc.apothem;
}



void defineTextureStartingPoints(HB, F, I)(HB h, F x, F y, I r, I c)
{
    h.hexes[r][c].texturePoint.ndc.x = x;
    h.hexes[r][c].texturePoint.ndc.y = y + h.ndc.perpendicular;
}



struct HexProperties(T)
{
    T diameter;
    T radius;
    T halfRadius;
    T perpendicular;
    T apothem;
}


struct HexBoard(F,I)
{
    @disable this();   // disables default constructor HexBoard h;
    
    this(F d, I r, I c) 
    {
        ndc.diameter = d;
        rows = r;
        columns = c;

        ndc.radius        = ndc.diameter * 0.5;
        ndc.halfRadius    = ndc.radius   * 0.5;
        ndc.perpendicular = ndc.diameter * 0.866; 
        ndc.apothem       = ndc.perpendicular * 0.5;
        
        edge.bottom = -1.0;
        edge.top    = edge.bottom + (rows * ndc.perpendicular);
        edge.left   = -1.0;
        edge.right  = edge.left + (columns * (ndc.radius + ndc.halfRadius));
        
        hexes = new Hex!(F,I)[][](rows, columns);  // dynamically allocate all the hexes

        spots = new Spot[][](rows, columns);

        foreach(i; 0..rows)
        {
            foreach(j; 0..columns)
            {
                spots[i][j].location.r = i;
                spots[i][j].location.c = j;
            }
        }

        //this.initializeHexBoard();  // either one works
        initializeHexBoard(this);
        
        this.addNeighbors();
        
        mouseClick.ndc.x = 0.0;
        mouseClick.ndc.y = 0.0;

        renderer = null;  // renderer for this hex board        
    }

    enum invalid = -1;  // -1 means a row or column is invalid

    I rows;     // number of rows on the board [0..rows-1]
    I columns;  // number of columns on the bord [0..cols-1]

    @property lastRow() { return rows-1; }
    @property lastColumn() { return columns-1; }

    Edges!(F) edge;

    HexProperties!(F) ndc;
    HexProperties!(I) sc;
    
                           // each hex board has-a 2 dimensional array of hex structures
    Hex!(F,I)[][]  hexes;  // = new int[][](5, 2);    

    Spot[][] spots;  // each hex board has-a 2 dimensional array of path properties
                     // think of this a being superimposed over the hexes array.
    
    F floatType;
    I integerType;
    
    SDL_Renderer* renderer;

    SelectedHex!(I) selectedHex; 

    MouseClick!(F,I) mouseClick;

    void setRenderOfHexboard(SDL_Renderer *rend)
    {
        renderer = rend;
    }

}






/+   
    2. You can use UFCS (Universal Function Call Syntax). Ali's book talks about
it here:

http://ddili.org/ders/d.en/ufcs.html

but basically what it comes down to is that you call call a free function as if it were a member function of its first argument. e.g.

auto foo(MyClass m, int i) {..}
auto result = myClass.foo(42);

This allows you to essentially add member functions without them having to be member functions. You don't 
end up with prototypes or with them being listed as member functions in your struct or class, but the 
functions are then separate from the struct or class, and you don't need their implementation inside the 
struct or class. Where UFCS is truly useful though is it allows generic code to call functions without caring 
whether they're member functions or free functions.
+/    
    

void displayHexBoardDataSC(HB)(HB h)
{
    writeln("===== Values are in Screen Coordinates =====");
    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {
            writeln("hexes[", r, "][", c, "].center.sc ", h.hexes[r][c].center.sc );
            foreach(p; 0..6)
            {
                writeln("hexes(", r, ",", c, ") = ", h.hexes[r][c].points.sc[p] ); 
            }
            writeln("hexes texture Point = ", h.hexes[r][c].texturePoint.sc);
        }
    }
}



void displayHexBoardDataNDC(HB)(HB h)
{
    writeln("===== Values are in Normalized Screen Coordinates =====");
    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {
            writeln("hexes[", r, "][", c, "].center.ndc ", h.hexes[r][c].center.ndc );
            foreach(p; 0..6)
            {
                writeln("hexes(", r, ",", c, ") = ", h.hexes[r][c].points.ndc[p] ); 
            }
            writeln("hexes texture Point = ", h.hexes[r][c].texturePoint.ndc);
        }
    }
}



void displayHexBoardDataNDCandSC(HB)(HB h)
{
    writeln("===== Values are in NDC and SC coordinates =====");
    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {
            writeln("hexes[", r, "][", c, "].center ", h.hexes[r][c].center );
            foreach(p; 0..6)
            {
                writeln("hexes(", r, ",", c, ") = ", h.hexes[r][c].points.ndc[p],
                                              "   ", h.hexes[r][c].points.sc[p]); 
            }
            writeln("hexes texture Point = ", h.hexes[r][c].texturePoint);
        }
    }
}



// DEFINE HEX BOARD

void initializeHexBoard(HB)(HB h)
{
    // start at the bottom left corner of NDC window, drawing from left to right, bottom to top.

    auto x = h.edge.left;      // NDC (Normalized Device Coordinates) start at -1.0
    auto y = h.edge.bottom;
 
    foreach(row; 0..(h.rows))
    {
        foreach(col; 0..(h.columns))
        {
            h.defineHexVertices(x, y, row, col);

            h.defineHexCenters(x, y, row, col);

            h.defineTextureStartingPoints(x, y, row, col);

            if (col.isEven)
            {
                y += h.ndc.apothem;
            }
            else
            {            
                y -= h.ndc.apothem;   
            }
            x += h.ndc.halfRadius + h.ndc.radius;
        }
        
        x = h.edge.left;  // start a new row and column on the left
        
        if (h.columns.isOdd)
        {
            y -= h.ndc.apothem;
        }

        y += h.ndc.perpendicular;
    }
}



void convertNDCoordsToScreenCoords(HB, I)(HB h, I screenWidth, I screenHeight)
{
    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {
            auto centerNDC = h.hexes[r][c].center.ndc;  // make func call easier to read

            h.hexes[r][c].center.sc = convertPointFromNDCtoSC(centerNDC, screenWidth, screenHeight);
            
            foreach(v; 0..6)
            {
                auto NDCx = h.hexes[r][c].points.ndc[v].x;  // makes following statements more legable
                auto NDCy = h.hexes[r][c].points.ndc[v].y;

                h.hexes[r][c].points.sc[v].x = roundTo!(I)((NDCx + 1.0) * 0.5 * screenWidth);
                h.hexes[r][c].points.sc[v].y = roundTo!(I)((1.0 - NDCy) * 0.5 * screenHeight);
            }

            auto texturePointNDC = h.hexes[r][c].texturePoint.ndc;  // make func call easier to read

            h.hexes[r][c].texturePoint.sc = convertPointFromNDCtoSC(texturePointNDC, screenWidth, screenHeight);
        }
    }
}




void convertLengthsFromNDCtoSC(HB, I)(ref HB h, I screenWidth, I screenHeight)
{
    auto NDCfullWidth = 2.0;  // from -1.0 to 1.0

    auto perCentOfEntireLength = h.ndc.diameter / NDCfullWidth;
        
    h.sc.diameter      = roundTo!(I)(perCentOfEntireLength * screenWidth);
        
    h.sc.radius        = roundTo!(I)(h.sc.diameter * 0.5);
    h.sc.halfRadius    = roundTo!(I)(h.sc.radius   * 0.5);

    h.sc.perpendicular = roundTo!(I)(h.sc.diameter * 0.866 );
    h.sc.apothem       = roundTo!(I)(h.sc.perpendicular * 0.5);
}



Point2D!(I) convertPointFromNDCtoSC(F, I)(F ndc, I screenWidth, I screenHeight)
{
    Point2D!(I) sc;

    sc.x = roundTo!(I)((ndc.x + 1.0) * 0.5 * screenWidth);
    sc.y = roundTo!(I)((1.0 - ndc.y) * 0.5 * screenHeight);

    return sc;
}



// Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)

// screenWidth and screeHeight are not know by struct HexBoard
// this function can only be called from outside of this module

void convertScreenCoordinatesToNormalizedDeviceCoordinates(HB, I)(ref HB h, I screenWidth, I screenHeight)
{
    h.mouseClick.ndc.x =   (h.mouseClick.sc.x / (screenWidth  / 2.0)) - 1.0;  // xPos/(screenWidth/2.0) gives values from 0.0 to 2.0
                                                                              // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0     

    h.mouseClick.ndc.y = -((h.mouseClick.sc.y / (screenHeight / 2.0)) - 1.0); // yPos/(winHeight/2.0) gives values from 0.0 to 2.0
                                                                          // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0
                                                                              
    // The minus sign at front of expression is needed because screen coordinates are flipped horizontally from NDC coordinates

    // Take the bottom of the edge of the screen (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
    // So that the mouse click and subtract the edge.
}



void setHexboardTexturesAndTerrain(HB)(HB h, Globals g)
{
    import std.random : uniform;
    auto rnd = Random(unpredictableSeed);    

    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
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
                        h.hexes[r][c].textures ~= g.textures[Ids.solidGreen];
                        h.spots[r][c].terrainCost = 1;
                    }
                    break;
                    case 5,6,7:
                    {
                        //writeln("solidBrown");
                        h.hexes[r][c].textures ~= g.textures[Ids.solidBrown];
                        h.spots[r][c].terrainCost = 9; // 9
                    }
                    break;
                case 8,9:
                    {
                        //writeln("solidBlue");
                        h.hexes[r][c].textures ~= g.textures[Ids.solidBlue];
                        h.spots[r][c].terrainCost = 999; // 999
                    }
                    break;
                default: break;
            }
            //hexes[r][c].texture = g.textures[a];
        }
    }
}




void clearHexBoard(HB)(HB h)
{
    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {
            //hexes[r][c].textures = Texture(Ids.none, "", null); // when textures was just a single Texture
            h.hexes[r][c].textures.length = 0;  // a=[]; a=null; change the pointer, so one cannot reuse the array
            // spots[r][c].location = Location(-1,-1); // DO NOT CHANGE!!!
            h.spots[r][c].neighbors = [Location(-1,-1), Location(-1,-1), Location(-1,-1), 
                                       Location(-1,-1), Location(-1,-1), Location(-1,-1)]; 
            h.spots[r][c].f = 0;
            h.spots[r][c].g = 0;
            h.spots[r][c].h = 0;
            h.spots[r][c].previous = Location(-1,-1);
            h.spots[r][c].terrainCost = 0;
        }
    }
}





void setHexTexture(HB,T)(ref HB h, Globals g, T hex, Ids id)
{
    h.hexes[hex.r][hex.c].textures ~= g.textures[id];
}



void setHexsNorth(HB,S,I)(ref HB h, Globals g, S clickedOn, I count, Ids id)  
{
    I endRow;
    endRow = clickedOn.r + count;
    if (endRow > h.rows)
    {
        endRow = h.rows;
    }

    //writeln("clickedOn = ", clickedOn);
    //writeln("count = ", count);
    //writeln("endRow = ", endRow);
    
    foreach(row; (clickedOn.r)..endRow)
    {
        //writeln("row = ", row);
        h.hexes[row][clickedOn.c].textures ~= g.textures[id]; 
    }
}


void setHexsNorthEast(HB,S,I)(ref HB h, Globals g, S clickedOn, I count, Ids id)  
{
    I endRow;
    I endCol;

    writeln("clickedOn = ", clickedOn);

    endCol = clickedOn.c + count;
    if (endCol >= h.columns)
    {
        endCol = h.columns;
    }

    
    writeln("count = ", count);
    writeln("endCol = ", endCol);

    I r = clickedOn.r;
    foreach(c; (clickedOn.c)..endCol)
    {
        writeln("r,c = ", r, " ", c);
        
        h.hexes[r][c].textures ~= g.textures[id]; 
        if (isOdd(c)) { r++; }
    }
}




void setHexsSouth(HB,S,I)(ref HB h, Globals g, S clickedOn, I count, Ids id)  
{
    I endRow;
    endRow = clickedOn.r - count;
    if (endRow < 0)
    {
        endRow = 0;
    }

    foreach(row; endRow..(clickedOn.r))
    {
        h.hexes[row][clickedOn.c].textures ~= g.textures[id]; 
    }
}

void setHexColTexture(HB,I)(ref HB h, Globals g, I col, Ids id)  
{
    foreach(r; 0..(h.rows))
    {
        h.hexes[r][col].textures ~= g.textures[id]; 
    }
}


void displayHexTextures(HB)(HB h)
{
    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {
            foreach(texture; h.hexes[r][c].textures)
            {
                if (texture.ptr != null)
                {
                    SDL_Rect dst;
                
                    dst.x = h.hexes[r][c].texturePoint.sc.x;
                    dst.y = h.hexes[r][c].texturePoint.sc.y;

                    dst.w = h.sc.diameter;
                    dst.h = h.sc.perpendicular;
                    
                    //writeln("dst = ", dst);

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

                    SDL_RenderCopy(h.renderer, texture.ptr, null, &dst);
                }
            }
        }
    }
}



void drawHexBoard(HB)(HB h)
{
    SDL_SetRenderDrawColor( g.sdl.renderer, 128, 128, 128, SDL_ALPHA_OPAQUE );
    //Clear screen
    SDL_RenderClear( g.sdl.renderer );

    SDL_SetRenderDrawColor( g.sdl.renderer, 0xFF, 0x00, 0x00, SDL_ALPHA_OPAQUE );        

    foreach(r; 0..(h.rows))
    {
        foreach(c; 0..(h.columns))
        {  
            // writeln("r = ", r, " c = ", c);
            //SDL_RenderDrawLines(g.sdl.renderer, cast (SDL_Point *) &hexes[r][c].points.sc[0], 6);
            SDL_RenderDrawLines(g.sdl.renderer, cast (SDL_Point *) &h.hexes[r][c].points.sc[0], 6);
            
            SDL_RenderDrawLine( g.sdl.renderer, h.hexes[r][c].points.sc[5].x,  // close off the hex  
                                                h.hexes[r][c].points.sc[5].y, 
                                                h.hexes[r][c].points.sc[0].x, 
                                                h.hexes[r][c].points.sc[0].y);
        }
    }
}


/+
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
    }
+/



/+     DELETE IF STARTS WORKING IN SPOT.D
const uint N  = 0;  // North
const uint NE = 1;  // North-East
const uint SE = 2;  // South-East
const uint S  = 3;  // South
const uint SW = 4;  // South-West
const uint NW = 5;  // North-West


void addNeighbors(HB)(HB h)
{
    foreach(int r; 0..(h.rows))          // Note: rows and columns are defined as uint 
    {                                    // this caused problems with < 0 boundary checking
        foreach(int c; 0..(h.columns))   // causing -1 to be 4294967295
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
+/

 
//}
