

/// Simple example of a SDL/GLFW application that creates multiple windows

/+
https://wiki.libsdl.org/SDL2/MigrationGuide#Overview_of_new_features

For 2D graphics, SDL 1.2 offered a concept called "surfaces," which were memory buffers of pixels.
In SDL 2.0, Surfaces are always in system RAM now, and are always operated on by the CPU, so we want to get away from there.
What you want, if possible, is the new SDL_Texture.

There are very few reasons for using SDL_Surfaces for rendering these days. 
SDL_Renderer and its SDL_Texture is a much better performing choice if you don't need CPU side 
access to individual pixels.



+/

/+
What’s the difference between Texture and Surface?

Surface is stored in RAM and drawing is performed on the CPU. Texture is stored in Video RAM (GPU RAM) and drawing is 
performed by the GPU. If you need best performance, use textures only, because GPU can render things million times 
faster than the CPU.

you don’t need to use surfaces at all. You can create texture using the SDL_CreateTexture 17 function and render anything 
on it. If you need to load image e.g. from file and store it in the form of texture, you can do it via IMG_LoadTexture. 
SDL will do everything for you internally.
+/

/+
Should each hex board have an associated windows/screen???  It would simply parameter passing.
Or will this cause problems further down the road?
+/

module app;


import utilities.sdl_timing;
import utilities.displayinfo : display_info;
import hexboard;
import select_hex;
import hexmath;

import hex;

import libraries.load_sdl_libraries;
import textures.texture;
import a_star.spot;

import windows.simple_directmedia_layer;


import core.stdc.stdio;

import std.conv : roundTo;

import std.stdio : writeln;
import std.string;

// SDL = Simple Directmedia Layer
import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import bindbc.loader;

import datatypes : Location;

/+
SDL coordinates, like most graphic engine coordinates, start at the top left corner of 
the screen/window. The more you go down the screen the more Y increases and as you go 
across to the right the X increases.

If you want an image in the top left corner set X to 0 and Y to 0

Screen coordinates

(0,0)
  +---------------------------------+
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  +---------------------------------+ 
                          (maxWidth, maxHeight)
+/

/+
In SDL, SDL_window is used to create a window, while SDL_surface is used to draw to the window
SDL_window is used to create a window and set flags such as fullscreen, OpenGL, hidden, or obscured.
SDL_window is a struct that holds all info about the itself: size, position, borders etc.
SDL_surface is used to abstract an area for drawing, such as loaded images. SDL_surface is a collection 
of pixels used for software rendering, also known as blitting.
SDL_Surface is used in software rendering. (SDL_Surface is obsolete)
SDL_Texture on the other hand, is used in a hardware rendering, textures are stored in VRAM
SDL_Renderer is a struct that handles all rendering. It is tied to a SDL_Window so it can only render 
within that SDL_Window. It also keeps track the settings related to the rendering.
+/

 
Globals g;  // put all the global variables together in one place

Globals mainMap;

int main()
{

    load_sdl_libraries(); 
    
    SDL_Initialize();
    
    display_info();
    
    // timeIntervalInTicks();
    // timeIntervalInPerformanceMode();
    // frameRate();
    // cappingFrameRate();

    g.sdl.screenWidth  = 900;
    g.sdl.screenHeight = 900;

    uint rows = 200;
    uint cols = 200;

    mainMap.sdl.screenWidth  = 900;
    mainMap.sdl.screenHeight = 900;

    uint mainMapRows = 15;
    uint mainMapCols = 15;


    float hexWidth = hexWidthToFitWindow(rows, cols, Orientation.horizontal);

    float mainMapHexWidth = hexWidthToFitWindow(mainMapRows, mainMapRows, Orientation.horizontal);

    auto h = HexBoard!(real,  int)(hexWidth, rows, cols);   // WORKS!
    
    auto h2 = HexBoard!(real,  int)(mainMapHexWidth, mainMapRows, mainMapRows);   // WORKS!
    
    //auto h = HexBoard!(double,int)(hexWidth, rows, cols); // WORKS!
    //auto h = HexBoard!(float, int)(hexWidth, rows, cols);  // WORKS!

    h.convertNDCoordsToScreenCoords(g.sdl.screenWidth, g.sdl.screenHeight);
    
    h2.convertNDCoordsToScreenCoords(mainMap.sdl.screenWidth, mainMap.sdl.screenHeight);

    h.convertLengthsFromNDCtoSC(g.sdl.screenWidth, g.sdl.screenHeight);
    
    h2.convertLengthsFromNDCtoSC(mainMap.sdl.screenWidth, mainMap.sdl.screenHeight);
    

    // https://github.com/BindBC/bindbc-sdl/issues/53   
    // https://github.com/ichordev/bindbc-sdl/blob/74390eedeb7395358957701db2ede6b48a8d0643/source/bindbc/sdl/config.d#L12

    // createSDLwindow(g); OLD
    
    g.sdl = createSDLwindow("Mini Map", 400, 400);  // screen or pixel width x height
    
    mainMap.sdl = createSDLwindow("Main Map", mainMap.sdl.screenWidth, mainMap.sdl.screenHeight);  // screen or pixel width x height

    h.setRenderOfHexboard(g.sdl.renderer);
    
    h2.setRenderOfHexboard(mainMap.sdl.renderer); 

    g.textures = load_textures(g);
    
    mainMap.textures = load_textures(mainMap);

    writeln("g.textures = ", g.textures);

    h.drawHexBoard(g);
    
    h2.drawHexBoard(mainMap);

    h.setHexboardTexturesAndTerrain(g);
    
    h2.setHexboardTexturesAndTerrain(mainMap);

    //h.displayHexTextures();


    //writeAndPause("after displayHexTextures");


    // https://thenumb.at/cpp-course/sdl2/03/03.html

    SDL_Event event;
    bool running = true;

    while(running)
    {
        while(SDL_PollEvent(&event) != 0)
        {
            switch(event.type)
            {
                case SDL_QUIT:

                    writeln("user clicked on close button of windows");
                    running = false;
                    break;

                case SDL_KEYDOWN:

                    if( event.key.keysym.sym == SDLK_ESCAPE )
                    {
                        writeln("user pressed the Escape Key");
                        running = false;
                    }

                    if( event.key.keysym.sym == SDLK_F1 )
                    {
                        writeln("user pressed the Function Key F1");
                        SDL_Surface *screenshot;

                        screenshot = SDL_CreateRGBSurface(SDL_SWSURFACE,
                                                          g.sdl.screenWidth, 
                                                          g.sdl.screenHeight, 
                                                          32, 
                                                          0x00FF0000, 
                                                          0X0000FF00, 
                                                          0X000000FF, 
                                                          0XFF000000); 

                        SDL_RenderReadPixels(g.sdl.renderer, 
                                             null, 
                                             SDL_PIXELFORMAT_ARGB8888, 
                                             screenshot.pixels, 
                                             screenshot.pitch);
                        //SDL_SavePNG(screenshot, "screenshot.png"); 
                        IMG_SavePNG(screenshot, "screenshot.png"); 
                        SDL_FreeSurface(screenshot); 
                    }

                    if( event.key.keysym.sym == SDLK_DELETE )
                    {
                        writeln("SDLK_DELETE used to just clear out all hex textures");
                        h.clearHexBoard();
                        h.drawHexBoard(g);
                    }

                    if( event.key.keysym.sym == SDLK_F1 )
                    {
                        import std.process : executeShell;
                        //executeShell("cls");

                        h.setHexboardTexturesAndTerrain(g);

                        writeln("after setHexboardTexturesAndTerrain");

                        //h.displayHexTextures();

                        import std.datetime.stopwatch;
                        auto watch = StopWatch(AutoStart.no);
                        watch.start();
                        //                                          millisecond 
                        // units = weeks days hours minutes seconds msecs usecs hnsecs nsecs
                        //                                                microsecond

                        Location begin;
                        Location end;

                        begin.r = 0;
                        begin.c = 0;

                        end.r = h.lastRow;
                        end.c = h.lastColumn;

                        findShortestPathCodingTrain( h, g, begin, end );

                        writeln(watch.peek()); 

                        //h.displayHexTextures();
                    }
                    break;

                case SDL_MOUSEBUTTONDOWN:

                    if( event.button.button == SDL_BUTTON_LEFT )
                    {
                        SDL_GetMouseState(cast (int *) &h.mouseClick.sc.x, cast (int *) &h.mouseClick.sc.y);

                        //writeln(h.mouseClick.sc.x, ", ", h.mouseClick.sc.y);

                        // Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)

                        h.convertScreenCoordinatesToNormalizedDeviceCoordinates(g.sdl.screenWidth, g.sdl.screenHeight);

                        //writeln(h.mouseClick.ndc.x, ", ", h.mouseClick.ndc.y);

                        if (h.getHexMouseClickedOn())
                        {
                            writeln("h.selectedHex = ", h.selectedHex);

                            alias I = typeof(h.integerType);
                            I x = h.selectedHex.row;   I y = h.selectedHex.col;

                            Location first;  
                            Location last; 

                            first.r = 0;
                            first.c = 0;

                            last.r = x; 
                            last.c = y;

                            import std.datetime.stopwatch;
                            auto watch = StopWatch(AutoStart.no);
                            watch.start();
                            //                                          millisecond  hecto-nanosecond
                            // units = weeks days hours minutes seconds msecs usecs hnsecs nsecs
                            //                                                microsecond  nanosecond

                            findShortestPathCodingTrain( h, g, first, last );

                            writeln(watch.peek());

                            /+
                            h.setHexesHorizontally(g, end, 7, Ids.solidRed);
                            h.setHexesVertically(g, end, 5, Ids.solidBlue);
                            h.setHexesSouthWestByNorthEast(g, end, 7, Ids.solidWhite);
                            h.setHexesNorthWestBySouthEast(g, end, 7, Ids.solidGreen);
                            h.setHexesEast(g, end, 7, Ids.solidRed);
                            h.setHexesWest(g, end, 7, Ids.solidRed);
                            h.setHexesNorth(g, end, 7, Ids.solidRed);
                            h.setHexesNorthEast(g, end, 7, Ids.solidBlue);
                            h.setHexesSouthEast(g, end, 7, Ids.solidGreen);
                            h.setHexesSouth(g, end, 7, Ids.solidBrown);
                            h.setHexesNorthWest(g, end, 7, Ids.solidBlack);
                            h.setHexesSouthWest(g, end, 7, Ids.solidWhite);
                            +/

                            h.displayHexTextures();

                            Point2D!(I)[4] t;

                            t[0].x = h.hexes[x][y].points.sc[0].x;
                            t[0].y = h.hexes[x][y].points.sc[0].y; 
                            t[1].x = h.hexes[x][y].points.sc[1].x;
                            t[1].y = h.hexes[x][y].points.sc[1].y;
                            t[2].x = h.hexes[x][y].points.sc[3].x;
                            t[2].y = h.hexes[x][y].points.sc[3].y; 
                            t[3].x = h.hexes[x][y].points.sc[4].x;
                            t[3].y = h.hexes[x][y].points.sc[4].y;

                            //writeln(t);

                            SDL_RenderDrawLine( g.sdl.renderer, t[0].x, t[0].y, t[1].x, t[1].y);
                            SDL_RenderDrawLine( g.sdl.renderer, t[1].x, t[1].y, t[2].x, t[2].y);
                            SDL_RenderDrawLine( g.sdl.renderer, t[2].x, t[2].y, t[3].x, t[3].y);
                            SDL_RenderDrawLine( g.sdl.renderer, t[3].x, t[3].y, t[0].x, t[0].y);
                        }
                    }
                    break;

                default: break;
            }
        }
        SDL_RenderPresent(g.sdl.renderer);
        SDL_RenderPresent(mainMap.sdl.renderer);
    }
    return 0;
}






