

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


import set;
import utilities.sdl_timing;
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



int main() 
{
/+
Set s;

NodeX n1 = NodeX( Locale(1,2), 33);
NodeX n2 = NodeX( Locale(3,4), 12);
NodeX n3 = NodeX( Locale(5,6), 77);
NodeX n4 = NodeX( Locale(7,8), 5);

s.put(n1);
s.put(n2);
s.put(n3);
s.put(n4);

s.display;

NodeX tmp;
tmp = s.removeMin;
writeln("removeMin returned ", tmp);
s.display;
tmp = s.removeMin;
writeln("removeMin returned ", tmp);
s.display;
tmp = s.removeMin;
writeln("removeMin returned ", tmp);
s.display;
tmp = s.removeMin;
writeln("removeMin returned ", tmp);
s.display;
+/


/+ 

Lenovo AMD Ryzen 7 PRO 7840U
AMD Radeon 780M
16 GB
Microsoft Windows 11 Professional (x64) Build 22631.3810 (23H2)
DUB version 1.37.0, built on Apr  1 2024
DMD64 D Compiler v2.108.0

core.exception.ArrayIndexError@a_star\spot.d(349): index [155] is out of bounds for array of length 100
core.exception.ArrayIndexError@a_star\spot.d(349): index [168] is out of bounds for array of length 100
core.exception.ArrayIndexError@a_star\spot.d(349): index [147] is out of bounds for array of length 100


===================================================

All results were run on a 

Lenovo AMD Ryzen 5 PRO 5650GE with
AMD Cezanne - Internal GPU [Lenovo]
8 GB RAM with
Microsoft Windows 11 Professional (x64) Build 22631.3737 (23H2)
DUB version 1.37.0, built on May  2 2024
DMD64 D Compiler v2.108.1

100x100 returned these times. 

1 sec, 347 ms
2 secs, 620 ms
1 sec, 791 ms
1 sec, 238 ms
1 sec, 106 ms
2 secs, 664 ms
1 sec, 243 ms
1 sec, 247 ms

--------------------------------------------
125x125 

Below 6 seconds, black dots are displayed, Above 6 seconids, black dots disappear???

3 secs, 284 ms,
3 secs, 994 ms,
3 secs, 538 ms,
5 secs, 111 ms
3 secs, 258 ms
6 secs, 598 ms
6 secs, 221 ms
4 secs, 381 ms
6 secs, 325 ms
6 secs, 552 ms
3 secs, 928 ms
3 secs, 783 ms

--------------------------------------------

150x150 returned these times BUT BLACK DOTS WERE NOT DISPLAYED???
7 secs, 342 ms
8 secs, 851 ms
4 secs, 321 ms
7 secs, 721 ms
12 secs, 978 ms
9 secs, 71 ms

150x150 again and THIS TIME THEY ALL DISPLAYED PERFECTLY
13 secs, 555 ms
4 secs, 35 ms
13 secs, 479 ms
13 secs, 486 ms
8 secs, 522 ms
13 secs, 390 ms
2 secs, 641 ms
6 secs, 844 ms
13 secs, 854 ms

200x200 again and they all displayed perfectly

24 secs, 758 ms
39 secs, 292 ms
41 secs, 607 ms
27 secs, 293 ms

250x250 again and they all displayed perfectly
1 minute, 10 secs, 490 ms
53 secs, 52 msecs
55 secs, 91 ms
1 minute, 5 secs
1 minute, 6 secs

300x300 they all displayed perfectly
3 minutes, 31 secs
1 minute, 26 secs
1 minute, 36 secs
1 minute, 28 secs

350x350 they all displayed perfectly
3 minutes, 33 secs
3 minutes, 33 secs
1 minute, 59 secs

400x400 they all displayed perfectly
11 minutes, 30 secs
5 minutes, 31 secs
6 minutes, 33 secs

500x500 too small to see if any black dots were displayed
13 minutes, 35 secs
12 minutes, 24 secs

1000x1000 too small to see if any black dots were displayed But finally finished!
4 hours, 26 minutes, 20 secs

+/

    load_sdl_libraries(); 
    
    // timeIntervalInTicks();
    // timeIntervalInPerformanceMode();
    // frameRate();
    // cappingFrameRate();
    
    g.sdl.screenWidth  = 900;
    g.sdl.screenHeight = 900;

    uint rows = 50;
    uint cols = 50;

    float hexWidth = hexWidthToFitWindow(rows, cols, Orientation.horizontal);
    
    
    auto h = HexBoard!(real,  int)(hexWidth, rows, cols);   // WORKS!
    //auto h = HexBoard!(double,int)(hexWidth, rows, cols); // WORKS!
    //auto h = HexBoard!(float, int)(hexWidth, rows, cols);  // WORKS!

    //h.displayHexBoardDataNDC();

    //writeAndPause("==== HexBoard is only constructed with NDC values ====");

    h.convertNDCoordsToScreenCoords(g.sdl.screenWidth, g.sdl.screenHeight);
    
    //h.displayHexBoardDataSC();

    //writeAndPause("==== NDC converted to SC values ====");

    h.convertLengthsFromNDCtoSC(g.sdl.screenWidth, g.sdl.screenHeight);

    writeln("h.sc = ", h.sc);

    // https://github.com/BindBC/bindbc-sdl/issues/53   

    // https://github.com/ichordev/bindbc-sdl/blob/74390eedeb7395358957701db2ede6b48a8d0643/source/bindbc/sdl/config.d#L12

    // Initialize SDL

    createSDLwindow(g);

    h.setRenderOfHexboard(g.sdl.renderer);

    g.textures = load_textures(g);

    writeln("g.textures = ", g.textures);

    h.drawHexBoard;
    
    h.setHexboardTexturesAndTerrain(g);

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
                        h.drawHexBoard;
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
                        
                        begin.r = 1;
                        begin.c = 1;
                        
                        end.r = h.lastRow;
                        end.c = h.lastColumn;

                        //end.r = h.selectedHex.row;
                        //end.c = h.selectedHex.col;

                        findShortestPathNEW( h, g, begin, end );

                        //findShortestPathRedBlack( h, g, begin, end );

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

                            first.r = 1;
                            first.c = 1;

                            last.r = x; 
                            last.c = y;
                            
                            findShortestPathCodingTrain( h, g, first, last );
                            
                            //findShortestPathWikipedia( h, g, first, last );
                            
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
    }
    return 0;
}






