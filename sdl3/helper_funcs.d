
// void splitTooLargeFile(string filename, int widthPieces, int heightPieces)
// SDL_Surface* assembleTilesIntoOneFile(string baseFileName, int widthPieces, int heightPieces )
// void createRealBigSurface()
// void assembleQuadFilesItoOnePNGfile()
// void trimFileIfPixelsAreNotEven()
// void hugePNGfileIntoQuadPNGfiles()
// SDL_Surface* assembleHugeSurface()

module helper_funcs;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import sdl_funcs_with_error_handling;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations


// width and height pieces are number of pieces to break up the image.
// so 2, 3 would break up the iamge into two equal horizonal breaks and three
// equal vertical breaks.  1 would mean to keep the existing dimension

void splitTooLargeFile(string filename, int widthPieces, int heightPieces )
{
    SDL_Surface *image;

    image = loadImageToSurface("./images/" ~ filename ~ ".png");
    
    int width = image.w;
    int height = image.h;

    writeln(width, " ", height);
    
    int dw = image.w / widthPieces;
    int dh = image.h / heightPieces;
    
    writeln("dw = ", dw);
    writeln("dh = ", dh);
    
    SDL_Surface *tile = createSurface(dw, dh, image.format);

    foreach(i; 0..widthPieces)
    {
        foreach(j; 0..heightPieces)
        {
            write("   i,j = ", i, ",", j);
        }
    }
    
    auto panes = new SDL_Rect[][](widthPieces, heightPieces);
    
    writeln("panes = ", panes);
    
    foreach(i; 0..widthPieces)
    {
        foreach(j; 0..heightPieces)
        {
            panes[i][j].x = i * dw;
            panes[i][j].y = j * dh;
            panes[i][j].w = dw;
            panes[i][j].h = dh;
        }
        writeln;
    }
    
    string path;
    foreach(i; 0..widthPieces)
    {
        foreach(j; 0..heightPieces)
        {
            writeln("panes[", i, "][", j, "] = ", panes[i][j]);
            
            copySurfaceToSurface(image, &panes[i][j], tile, null);
            
            path = "./images/" ~ filename ~ "_" ~ to!string(i) ~ to!string(j) ~ ".png";
            writeln("path = ", path);
            if (IMG_SavePNG(tile, toStringz(path)) < 0) {
                writefln("IMG_SavePNG failed: %s", SDL_GetError());
            }
        }
        writeln;
    }
    
    
    /+ copySurfaceToSurface(image0, null, huge, &quads[0]);
    copySurfaceToSurface(image1, null, huge, &quads[1]);
    copySurfaceToSurface(image2, null, huge, &quads[2]);
    copySurfaceToSurface(image3, null, huge, &quads[3]);
    copySurfaceToSurface(image4, null, huge, &quads[4]);
    
    string fileName = "./images/" ~ "1_" ~ ".png";
    if (IMG_SavePNG(huge, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    } +/
    
    
    
    
    
}


SDL_Surface* assembleTilesIntoOneFile(string baseFileName, int widthPieces, int heightPieces )
{
    SDL_Surface *tile;

    tile = loadImageToSurface("./images/" ~ baseFileName ~ "00.png");
    
    int width = tile.w;
    int height = tile.h;

    writeln(width, " ", height);
    
    SDL_Surface *image = createSurface(width * widthPieces, height * heightPieces, tile.format);
    
    
    auto panes = new SDL_Rect[][](widthPieces, heightPieces);
    
    writeln("panes = ", panes);
    
    foreach(i; 0..widthPieces)
    {
        foreach(j; 0..heightPieces)
        {
            panes[i][j].x = i * width;
            panes[i][j].y = j * height;
            panes[i][j].w = width;
            panes[i][j].h = height;
        }
        writeln;
    }
    
    
    
    string path;
    foreach(i; 0..widthPieces)
    {
        foreach(j; 0..heightPieces)
        {
            writeln("panes[", i, "][", j, "] = ", panes[i][j]);
            writeln("./images/" ~ baseFileName ~ to!string(i) ~ to!string(j) ~ ".png");
            
            tile = loadImageToSurface("./images/" ~ baseFileName ~ to!string(i) ~ to!string(j) ~ ".png");
            
            copySurfaceToSurface(tile, null, image, &panes[i][j]);
            
            //path = "./images/" ~ "1_" ~ to!string(i) ~ to!string(j) ~ ".png";
        }
        writeln;
    }
    
    //IMG_SavePNG(huge, toStringz(fileName)) < 0
    string fileN = "./images/TEST.png";
    if (IMG_SavePNG(image, toStringz(fileN)) < 0) 
    {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    
    return image;
}


void createRealBigSurface()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    int winWidth = 1000;
    int winHeight = 1000;

    createWindowAndRenderer("Real Big Texture", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_PropertiesID props = SDL_GetRendererProperties(renderer);
    int max_texture_size = cast(int) SDL_GetNumberProperty(props, SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER, 0);
    
    writeln("max_texture_size = ", max_texture_size);

    SDL_Surface *image0;
    SDL_Surface *image1;
    SDL_Surface *image2;
    SDL_Surface *image3;
    SDL_Surface *image4;

    image0 = loadImageToSurface("./images/1.png");
    image1 = loadImageToSurface("./images/2.png");
    image2 = loadImageToSurface("./images/3.png");
    image3 = loadImageToSurface("./images/4.png");
    image4 = loadImageToSurface("./images/5.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image0.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image0.w, " x ", image0.h);

    int width = image0.w;
    int height = image0.h;


    SDL_Surface *surface0 = createSurface(width, height, image0.format);
    SDL_Surface *surface1 = createSurface(width, height, image1.format);
    SDL_Surface *surface2 = createSurface(width, height, image2.format);
    SDL_Surface *surface3 = createSurface(width, height, image3.format);
    SDL_Surface *surface4 = createSurface(width, height, image4.format);


    SDL_Surface *huge = createSurface(5*6692, 1*10594, image0.format);


    SDL_Rect[5] quads =
    [
        SDL_Rect(0,     0,  6680, 10594),
        SDL_Rect(6681,  0,  6686, 10594),
        SDL_Rect(13368, 0,  6688, 10594),
        SDL_Rect(20057, 0,  6692, 10594),
        SDL_Rect(26749, 0,  6690, 10594)
    ];

    copySurfaceToSurface(image0, null, huge, &quads[0]);
    copySurfaceToSurface(image1, null, huge, &quads[1]);
    copySurfaceToSurface(image2, null, huge, &quads[2]);
    copySurfaceToSurface(image3, null, huge, &quads[3]);
    copySurfaceToSurface(image4, null, huge, &quads[4]);
    
    string fileName = "./images/" ~ "huge" ~ ".png";
    if (IMG_SavePNG(huge, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    else
    {
        writeln("IMG_SavePNG succeeded");
    }
}


void assembleQuadFilesItoOnePNGfile()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Assemble", 1500, 1500, cast(SDL_WindowFlags) 0, &window, &renderer);

    writeln("window = ", window);
    writeln("renderer = ", renderer);

    SDL_Surface *image;

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA0.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB0.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC0.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD0.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image.w, " x ", image.h);

    int width = image.w;
    int height = image.h;

    if (isOdd(width*2) || isOdd(height*2)) 
    {
        writeln("Image dimensions must be divisible by 2");
    }

    SDL_Surface *combined = createSurface(width*2, height*2, image.format);

    SDL_Rect[4] quads =
    [
        SDL_Rect(0,     0,      width, height),  // top left
        SDL_Rect(width, 0,      width, height),  // top right
        SDL_Rect(0,     height, width, height),  // bottom left
        SDL_Rect(width, height, width, height)   // bottom right
    ];

    copySurfaceToSurface(image, null, combined, &quads[0]);

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA1.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB1.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC1.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD1.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE1.png");

    copySurfaceToSurface(image, null, combined, &quads[1]);

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA2.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB2.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC2.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD2.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE2.png");

    copySurfaceToSurface(image, null, combined, &quads[2]);

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA3.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB3.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC3.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD3.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE3.png");

    copySurfaceToSurface(image, null, combined, &quads[3]);

    // /+ ============================================================
    string fileName = "./images/" ~ "COMBINE" ~ "_E" ~ ".png";
    if (IMG_SavePNG(combined, toStringz(fileName)) < 0) {
    writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    exit(-1);
    //  ============================================================ +/

    SDL_Surface *dstSurface = SDL_CreateSurface(1500, 1500, image.format);

    // copySurfaceToSurface(combined, null, dstSurface, null);

    SDL_Surface *windowSurface = SDL_GetWindowSurface(window);

    // Blit the image onto the window surface
    // copySurfaceToSurface(dstSurface, null, windowSurface, null);

    copySurfaceToSurface(combined, &quads[1], windowSurface, null);

    SDL_UpdateWindowSurface(window);

    writeln("after SDL_UpdateWindowSurface");

    //SDL_Delay(3000);


    auto sRect = SDL_Rect(2000, 2000, width, height);

    copySurfaceToSurface(combined, &sRect, windowSurface, null);

    SDL_UpdateWindowSurface(window);

    SDL_Delay(3000);
    
    foreach (int i; 0 .. 100) 
    {
        sRect = SDL_Rect(i*50, i*50, width, height);

        copySurfaceToSurface(combined, &sRect, windowSurface, null);

        SDL_UpdateWindowSurface(window);

        SDL_Delay(50);
    }


    /+
    sRect = SDL_Rect(2200, 2200, width, height);

    copySurfaceToSurface(combined, &sRect, windowSurface, null);

    SDL_UpdateWindowSurface(window);

    SDL_Delay(3000);
    +/
    
    exit(-1);
    
}


void trimFileIfPixelsAreNotEven()
{
    SDL_Surface *image = loadImageToSurface("./images/quadA0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image.w, " x ", image.h);

    SDL_Rect evenRect;
    evenRect.x = 0;
    evenRect.y = 0;
    evenRect.w = image.w;
    evenRect.h = image.h;

    if (image.w.isOdd)
    {
        evenRect.w--;   // make width even
    }
    if (image.h.isOdd)
    {
        evenRect.h--;   // make height even
    }

    writeln("evenRect = ", evenRect);

    SDL_Surface *evenSurface = SDL_CreateSurface(evenRect.w, evenRect.h, image.format);
    
                   //   source srcRect    destination  dstRect
    if (SDL_BlitSurface(image, &evenRect, evenSurface, &evenRect) < 0) {
        writefln("SDL_BlitSurface failed: %s", SDL_GetError());
    }

    string fileName = "./images/" ~ "even5" ~ ".png";

    writeln("fileName = ", fileName);
        
    if (IMG_SavePNG(evenSurface, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }

}


void hugePNGfileIntoQuadPNGfiles()
{
    SDL_Surface *bigImage = loadImageToSurface("./images/quadA0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(bigImage.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("bigImage.w x h = ", bigImage.w, " x ", bigImage.h);

    int width = bigImage.w;
    int height = bigImage.h;
    int halfWidth = width / 2;
    int halfHeight = height / 2;

    if (width % 2 != 0 || height % 2 != 0) 
    {
        writeln("Image dimensions must be divisible by 2");
    }

    SDL_Rect[4] quads =
    [
        SDL_Rect(0,         0,          halfWidth, halfHeight),  // top left
        SDL_Rect(halfWidth, 0,          halfWidth, halfHeight),  // top right
        SDL_Rect(0,         halfHeight, halfWidth, halfHeight),  // bottom left
        SDL_Rect(halfWidth, halfHeight, halfWidth, halfHeight)   // bottom right
    ];

    // Create and save each quadrant foreach (int i; 0 .. 10) {
    foreach (int i; 0..4)
    {
        SDL_Surface *quadSurface = SDL_CreateSurface(halfWidth, halfHeight, bigImage.format);
        if (!quadSurface)
        {
            writefln("SDL_CreateRGBSurface failed: %s", SDL_GetError());
            exit(-1);
        }

        // Copy the quadrant to the new surface
                       //   source    srcRect    destination  dstRect
        if (SDL_BlitSurface(bigImage, &quads[i], quadSurface, null) < 0)
        {
            writefln("SDL_BlitSurface failed: %s", SDL_GetError());
        }

        string fileName = "./images/" ~ "quadE" ~ to!string(i) ~ ".png";

        writeln("fileName = ", fileName);
        
        // Save the quadrant as a PNG
        
        if (IMG_SavePNG(quadSurface, toStringz(fileName)) < 0)
        {
            writefln("IMG_SavePNG failed: %s", SDL_GetError());
        }
    }

}


SDL_Surface* assembleHugeSurface()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    //int winWidth = 1000;
    //int winHeight = 1000;

    //createWindowAndRenderer("Real Big Texture", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    //SDL_PropertiesID props = SDL_GetRendererProperties(renderer);
    //int max_texture_size = cast(int) SDL_GetNumberProperty(props, SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER, 0);
    
    //writeln("max_texture_size = ", max_texture_size);

    SDL_Surface *image0;
    SDL_Surface *image1;
    SDL_Surface *image2;
    SDL_Surface *image3;
    SDL_Surface *image4;

    image0 = loadImageToSurface("./images/1.png");
    image1 = loadImageToSurface("./images/2.png");
    image2 = loadImageToSurface("./images/3.png");
    image3 = loadImageToSurface("./images/4.png");
    image4 = loadImageToSurface("./images/5.png");

    //string pixelFormat = to!string(SDL_GetPixelFormatName(image0.format));
    //writeln("pixelFormat = ", pixelFormat);
    //writeln("image.w x h = ", image0.w, " x ", image0.h);

    int width = image0.w;
    int height = image0.h;


    SDL_Surface *surface0 = createSurface(width, height, image0.format);
    SDL_Surface *surface1 = createSurface(width, height, image1.format);
    SDL_Surface *surface2 = createSurface(width, height, image2.format);
    SDL_Surface *surface3 = createSurface(width, height, image3.format);
    SDL_Surface *surface4 = createSurface(width, height, image4.format);


 // SDL_Surface *huge = createSurface(5*6692, 1*10594, image0.format);
    SDL_Surface *huge = createSurface(5*6692, 1*10594, SDL_PIXELFORMAT_RGBA8888);

    SDL_Rect[5] quads =
    [
        SDL_Rect(0,     0,  6680, 10594),
        SDL_Rect(6681,  0,  6686, 10594),
        SDL_Rect(13368, 0,  6688, 10594),
        SDL_Rect(20057, 0,  6692, 10594),
        SDL_Rect(26749, 0,  6690, 10594)
    ];

    copySurfaceToSurface(image0, null, huge, &quads[0]);
    copySurfaceToSurface(image1, null, huge, &quads[1]);
    copySurfaceToSurface(image2, null, huge, &quads[2]);
    copySurfaceToSurface(image3, null, huge, &quads[3]);
    copySurfaceToSurface(image4, null, huge, &quads[4]);
    
    /+
    string fileName = "./images/" ~ "huge" ~ ".png";
    if (IMG_SavePNG(huge, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    else
    {
        writeln("IMG_SavePNG succeeded");
    }
    +/
    
    return huge;
}




SDL_Surface* assembleTCFNA()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    SDL_Surface * surf0 = assembleTilesIntoOneFile("1_", 1, 2);
    SDL_Surface * surf1 = assembleTilesIntoOneFile("2_", 1, 2);
    SDL_Surface * surf2 = assembleTilesIntoOneFile("3_", 1, 2);
    SDL_Surface * surf3 = assembleTilesIntoOneFile("4_", 1, 2);
    SDL_Surface * surf4 = assembleTilesIntoOneFile("5_", 1, 2);

    writeln("surf0.w x h = ", surf0.w, " x ", surf0.h);
    writeln("surf1.w x h = ", surf1.w, " x ", surf1.h);
    writeln("surf2.w x h = ", surf2.w, " x ", surf2.h);
    writeln("surf3.w x h = ", surf3.w, " x ", surf3.h);
    writeln("surf4.w x h = ", surf4.w, " x ", surf4.h);

 // SDL_Surface *huge = createSurface(5*6692, 1*10594, image0.format);
    SDL_Surface *huge = createSurface(5*6692, 1*10594, SDL_PIXELFORMAT_RGBA8888);

    SDL_Rect[5] quads =   // make dynamic??
    [
        SDL_Rect(0,     0,  6680, 10594),
        SDL_Rect(6681,  0,  6686, 10594),
        SDL_Rect(13368, 0,  6688, 10594),
        SDL_Rect(20057, 0,  6692, 10594),
        SDL_Rect(26749, 0,  6690, 10594)
    ];

    copySurfaceToSurface(surf0, null, huge, &quads[0]);
    copySurfaceToSurface(surf1, null, huge, &quads[1]);
    copySurfaceToSurface(surf2, null, huge, &quads[2]);
    copySurfaceToSurface(surf3, null, huge, &quads[3]);
    copySurfaceToSurface(surf4, null, huge, &quads[4]);
    
    writeln("AFTER copySurfaces");
    
    /+
    string fileName = "./images/" ~ "huge" ~ ".png";
    if (IMG_SavePNG(huge, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    else
    {
        writeln("IMG_SavePNG succeeded");
    }
    +/
    
    return huge;
}




