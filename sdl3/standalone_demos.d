
module standalone_demos;


import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import breakup;
import magnify;
import sdl_funcs_with_error_handling;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations



void ThreeSurfacesAndOneStreamingTexure()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Demo", 2000, 2000, cast(SDL_WindowFlags) 0, &window, &renderer);

    // Texture max dimensions are limited to 16384 x 16384

    SDL_Texture *texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 16384, 16384);
    
    SDL_Surface *bigSurface = createSurface(16384, 16384, SDL_PIXELFORMAT_RGBA8888);

    displayTextureProperties(texture);
    
    SDL_Surface *one = loadImageToSurface("./images/1.png");
    displaySurfaceProperties(one);
    
    SDL_Surface *two = loadImageToSurface("./images/2.png");
    displaySurfaceProperties(two);
    
    SDL_Surface *three = loadImageToSurface("./images/3.png");
    displaySurfaceProperties(three);
    
    SDL_Surface *four = loadImageToSurface("./images/4.png");
    displaySurfaceProperties(four);

    copySurfaceToTexture(one, null, texture, null);
    
    copySurfaceToSurface(one, null, bigSurface, null);
    
    SDL_Rect dst;     // an SDL_Rect has x, y, w, and h
    
    dst.x = one.w;
    dst.y = 0;      // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = two.w;
    dst.h = two.h;
       
    copySurfaceToTexture(two, null, texture, &dst);
    
    copySurfaceToSurface(two, null, bigSurface, &dst);


    dst.x = 1000;
    dst.y = 1000;     // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = three.w;
    dst.h = three.h;

    copySurfaceToTexture(three, null, texture, &dst);
    
    copySurfaceToSurface(three, null, bigSurface, &dst);
    
    dst.x = 4000;
    dst.y = 4000;     // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = four.w;
    dst.h = four.h;

    copySurfaceToTexture(four, null, texture, &dst);
    
    copySurfaceToSurface(four, null, bigSurface, &dst);

    SDL_RenderClear(renderer);
        SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer);
    
    
    // SDL_Surface *saveSurface = null;  // invalid value for SDL_BlitSurface

    SDL_Surface *saveSurface = createSurface(16384, 16384, SDL_PIXELFORMAT_RGBA8888);
    
    writeln("b4 copyTextureToSurface");
    
    int w; int h;
    getWindowMaximumSize(window, &w, &h);
    
    copyTextureToSurface(texture, null, saveSurface, null);
    writeln("after copyTextureToSurface");
    
    //saveSurfaceToPNGfile(saveSurface, "./images/saved_from_surface.png");
    
    saveSurfaceToPNGfile(bigSurface, "./images/bigSurface.png");

    // Keep the window open until the user closes it
    SDL_Event event;
    while (SDL_WaitEvent(&event)) 
    {
        if (event.type == SDL_EVENT_KEY_DOWN)
        {
            if (event.key.key == SDLK_ESCAPE)
            {
                break;
            }
        }
        if (event.type == SDL_EVENT_QUIT) 
        {
            break;
        }
    }
}






struct Pane
{
    this(int len)
    {
        writeln("is this called by new in World");
        //length = len;   // length of all sides (square) 
    }
    int         paneLength; // length of all sides (square) 
    // SDL_Rect panePts { 0, 0, sides, sides };
    SDL_Rect    worldPts;
    SDL_Texture texture;
}


struct World
{
    this(int rows, int cols, int sideLength)
    {
        paneLength = sideLength;
        rows = rows;
        cols = cols;
        panes = new Pane[][](rows,cols);
        worldLength.w = cols * sideLength;    // set the width and height of the World
        worldLength.h = rows * sideLength;
        
        /+ int[][] matrix = [ [1, 2, 3], [7, 8, 9] ];

        // Iterate through the 2D array using nested foreach loops
        
        foreach (int[] row; matrix) { // Outer loop iterates through each row (1D array)
            foreach (int element; row) { // Inner loop iterates through each element in the current row
                write(element, " "); // Print each element followed by a space
            }
            writeln(); // Move to the next line after printing a row
        }
        +/
        foreach (int i, Pane[] row; panes) 
        {
            foreach (int j, Pane pane; row) 
            {
                panes[i][j].paneLength = sideLength;
                write("i,j= ", i, ",", j, "   ");
                panes[i][j].worldPts.x = (j * panes[i][j].paneLength);
                panes[i][j].worldPts.y = (i * panes[i][j].paneLength);
                panes[i][j].worldPts.w = panes[i][j].paneLength;
                panes[i][j].worldPts.h = panes[i][j].paneLength;
                writeln("panes[i][j].worldPts = ", panes[i][j].worldPts);
            }
            writeln();
        }
    }
    
    int rows;
    int cols;
    Pane[][] panes;
    SDL_Rect worldLength; // rectangular so need rect
    int      paneLength;  // always square so just need one side
}


struct Segment  // pane, offset pait
{
    int pane;
    int offset;
}


struct MicroPt
{
    Segment x;
    Segment y;
}

struct DualPt
{
    Point   high;
    MicroPt low;
}

void convertHighPtToLowPt(DualPt *dualPt, World *world)
{
    dualPt.low.x.pane   = dualPt.high.x / world.paneLength;
    dualPt.low.x.offset = dualPt.high.x - (dualPt.low.x.pane * world.paneLength);

    dualPt.low.y.pane   = dualPt.high.y / world.paneLength;
    dualPt.low.y.offset = dualPt.high.y - (dualPt.low.y.pane * world.paneLength);
}

struct Piece
{
    SDL_Surface  *surface;  // sub-surface of within pane 
    SDL_Rect     rect;      // rect of the sub-surface (in pane coordinates)
    Segment      segment;   // Pane - offset pair
}

struct BigRect
{
    DualPt upLeftPt;
    DualPt upRightPt;
    DualPt botRightPt;
    DualPt botLeftPt;
}

void allocatePiecesAndSetUpperLeftPoints(BigRect *bigRect, Object *obj)
{
    int min_r = bigRect.upLeftPt.low.y.pane; 
    int max_r = bigRect.botLeftPt.low.y.pane;
    int min_c = bigRect.upLeftPt.low.x.pane;
    int max_c = bigRect.upRightPt.low.x.pane;

    obj.pieces = new Piece[][]((max_r-min_r+1),(max_r-min_r+1));

    for (int r = min_r; (r <= max_r); r++) 
    {
        for (int c = min_c; (c <= max_c); c++) 
        {
            obj.pieces[r][c].segment.pane = 777;
        }
        writeln();
    }

}



struct Object
{
    this(SDL_Surface *s, int x, int y, World *world)
    {
        this.surface = s;

        Piece[] pieces;

        BigRect bigRect;

        bigRect.upLeftPt.high.x = x;
        bigRect.upLeftPt.high.y = y;

        convertHighPtToLowPt(&bigRect.upLeftPt, world);

        int w; int h;
        getSurfaceWidthAndHeight(s, &w, &h);
        writeln("w x h ", w, " x ", h);

        bigRect.upRightPt.high.x = bigRect.upLeftPt.high.x + w;
        bigRect.upRightPt.high.y = bigRect.upLeftPt.high.y;
        
        convertHighPtToLowPt(&bigRect.upRightPt, world);
        
        // columns upLeftPt.low.x.pane ... upRightPt.low.x.pane
        writeln("Columns from ",bigRect.upLeftPt.low.x.pane, " to ", bigRect.upRightPt.low.x.pane);
        
        bigRect.botLeftPt.high.x = bigRect.upLeftPt.high.x;
        bigRect.botLeftPt.high.y = bigRect.upLeftPt.high.y + h;
        
        convertHighPtToLowPt(&bigRect.botLeftPt, world);
        
        // rows upLeftPt.low.y.pane ... botLeftPt.low.y.Pane
        writeln("rows from ", bigRect.upLeftPt.low.y.pane, " to ", bigRect.botLeftPt.low.y.pane);

        allocatePiecesAndSetUpperLeftPoints(&bigRect, &this);

        int min_r = bigRect.upLeftPt.low.y.pane; 
        int max_r = bigRect.botLeftPt.low.y.pane;
        int min_c = bigRect.upLeftPt.low.x.pane;
        int max_c = bigRect.upRightPt.low.x.pane;

        for (int r = min_r; (r <= max_r); r++) 
        {
            for (int c = min_c; (c <= max_c); c++) 
            {
                write("r,c= ", r, ",", c, "   ");
            }
            writeln();
        }





    }
    SDL_Surface *surface;  // each object has an image stored in a surface

    Piece[][] pieces;  // The object will be placed on a texture or broken up
                       // into multiple textures if larger than one pane

}

/+  In SDL3, textures can only be 16K x 16K. Some images can be larger
    than this limit. Below is a method for exceeding this limitation.
    Note: 

    world
       +-------------+-------------+-------------+
       |(0,0)        |(1024,0)     |(2048,0)     |
       |             |             |             |
       |             |             |             |
       |    pane     |    pane     |    pane     |
       |          +--|-------------|--+          |  world - is one big surface made up of panes
       |          |  |             |  |          |  panes - are fixed size square surfces 
       +-------------+-------------+-------------+  objects - are variable surfaces created by sized images 
       |(0,1024)  |  |(1024,1024)  |(2048,1024)  |  (loaded from files) loaded into surfaces loaded 
       |          |  |             |  |          |
       |          |  |             |  |          |
       |    pane  |  |    pane     |  | pane     |
       |          +--|-------------|--+          |
       |             |             |  object     |
       +-------------+-------------+-------------+
       |(0,2048)     |(1024,2048)  |(2048,2048)  |
       |             |             |             |
       |             |             |             |
       |    pane     |    pane     |    pane     |
       |             |             |             |
       |             |             |             |
       +-------------+-------------+-------------+
+/

void mosaic()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Demo", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    // Texture max dimensions are limited to 16384 x 16384

    SDL_Texture *texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 16384, 16384);

    SDL_Surface *bigSurface = createSurface(4096, 4096, SDL_PIXELFORMAT_RGBA8888);

    displayTextureProperties(texture);
/+
    SDL_Surface *one   = loadImageToSurface("./images/wach1.png");
    displaySurfaceProperties(one);

    SDL_Surface *two   = loadImageToSurface("./images/wach2.png");
    displaySurfaceProperties(two);

    SDL_Surface *three = loadImageToSurface("./images/wach3.png");
    displaySurfaceProperties(three);

    SDL_Surface *four  = loadImageToSurface("./images/wach4.png");
    displaySurfaceProperties(four);
+/


    SDL_Surface *one   = loadImageToSurface("./images/earth1024x1024.png");
    displaySurfaceProperties(one);

                    // rows, cols, pane size
    auto world = World(4,    4,    512);

    Object obj1 = Object(one, 256, 256, &world);  // world placement

/+ finding 2 dimensional lengths in dynamic array
arr.length - returns the number of elements in the first dimension of the array. 
arr[0].length - accesses the first row (at index 0) and then retrieves its length. 
Since each element in a 2D array is itself an array, this gives the number of (columns)
+/



    writeln("obj1.pieces.length = ", obj1.pieces.length);
    writeln("obj1.pieces[0].length = ", obj1.pieces[0].length);

    writeln("obj1 = ", obj1);

    writeln("world = ", world);

    

/+
    copySurfaceToTexture(one, null, texture, null);
    
    copySurfaceToSurface(one, null, bigSurface, null);
    
    SDL_Rect dst;     // an SDL_Rect has x, y, w, and h
    
    dst.x = one.w;
    dst.y = 0;      // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = two.w;
    dst.h = two.h;
       
    copySurfaceToTexture(two, null, texture, &dst);
    
    copySurfaceToSurface(two, null, bigSurface, &dst);


    dst.x = 1000;
    dst.y = 1000;     // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = three.w;
    dst.h = three.h;

    copySurfaceToTexture(three, null, texture, &dst);
    
    copySurfaceToSurface(three, null, bigSurface, &dst);
    
    dst.x = 4000;
    dst.y = 4000;     // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = four.w;
    dst.h = four.h;

    copySurfaceToTexture(four, null, texture, &dst);
    
    copySurfaceToSurface(four, null, bigSurface, &dst);

    SDL_RenderClear(renderer);
        SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer);
    
    
    // SDL_Surface *saveSurface = null;  // invalid value for SDL_BlitSurface

    SDL_Surface *saveSurface = createSurface(16384, 16384, SDL_PIXELFORMAT_RGBA8888);
    
    writeln("b4 copyTextureToSurface");
    
    int w; int h;
    getWindowMaximumSize(window, &w, &h);
    
    copyTextureToSurface(texture, null, saveSurface, null);
    writeln("after copyTextureToSurface");
    
    //saveSurfaceToPNGfile(saveSurface, "./images/saved_from_surface.png");
    
    saveSurfaceToPNGfile(bigSurface, "./images/bigSurface.png");
    
    +/

    // Keep the window open until the user closes it
    SDL_Event event;
    while (SDL_WaitEvent(&event)) 
    {
        if (event.type == SDL_EVENT_KEY_DOWN)
        {
            if (event.key.key == SDLK_ESCAPE)
            {
                break;
            }
        }
        if (event.type == SDL_EVENT_QUIT) 
        {
            break;
        }
    }
}



