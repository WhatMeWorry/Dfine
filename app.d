

/// Simple example of a SDL/GLFW application that creates multiple windows

/+
https://wiki.libsdl.org/SDL2/MigrationGuide#Overview_of_new_features

Support for OpenGL 3.0+ in various profiles (core, compatibility, debug, robust, etc)
Support for multiple windows and multiple displays
Simple 2D rendering API that can use Direct3D, OpenGL, OpenGL ES, or software rendering behind the scenes
Shaped windows
32-bit audio (int and float)
Simplified Game Controller API (the Joystick API is still here, too!)
Touch support (multitouch, gestures, etc)
Better keyboard support (scancodes vs keycodes, etc).
Message boxes
Clipboard support
APIs for building robust GUI toolkits on top of SDL
Basic Drag'n'Drop support
A really powerful assert macro
zlib license instead of LGPL.

For 2D graphics, SDL 1.2 offered a concept called "surfaces," which were memory buffers of pixels.
In SDL 2.0, Surfaces are always in system RAM now, and are always operated on by the CPU, so we want to get away from there.
What you want, if possible, is the new SDL_Texture.

There are very few reasons for using SDL_Surfaces for rendering these days, except if you 100% know 
what you are doing (and are perhaps writing a low resolution raytracer that runs on the CPU?). 
SDL_Renderer and its SDL_Texture is a much better performing choice if you don't need CPU side 
access to individual pixels.


SDL coordinates are like most graphic engine coordinates, they start at the top left corner of your screen/window. 
The more you go down the screen the Y increases and as you go across to the right the X increases.

If you want an image in the top left corner set its X to 0 and it's Y to 0

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

import honeycomb;
import select_hex;
import hexmath;

import libraries.load_sdl_libraries;
import textures.load_textures;
import a_star.spot;


import glfw3.api;
import core.stdc.stdio;

import std.conv : roundTo;

import std.stdio : writeln;
import std.string;

import bindbc.sdl;
import bindbc.sdl : IMG_SavePNG;

import bindbc.loader;

import redblacktree : placeHolder;


struct GLFW_STRUCT
{   
    const int SCREEN_WIDTH = 640;
    const int SCREEN_HEIGHT = 480;
    GLFWwindow* window;  
}


/+ Screen coordinates

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
                          (screenWidth, screenHeight)
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
struct SDL_STRUCT
{
    int screenWidth = 4024;
    int screenHeight = 2024;  // .866 * 1024
    SDL_Window* window = null;      // The window we'll be rendering to
    SDL_Renderer* renderer = null;
    //SDL_Surface* screenSurface = null;
}


struct Globals
{
    int i;
    GLFW_STRUCT glfw;
    SDL_STRUCT sdl;
    Texture[] textures;
}
 
Globals g;  // put a the globals variable together in one place


int main() 
{

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

    g.sdl.screenWidth  = 1000;
    g.sdl.screenHeight = 1000;

    uint rows = 3;
    uint cols = 3;

    float hexWidth = hexWidthToFitWindow(rows, cols, Direction.horizontal);

    HexBoard h = HexBoard(hexWidth, rows, cols);

    h.displayHexBoardData();  // hex board initially defined in NDC (Normalized Device Coordinates)

    writeAndPause("==== After displayHexBoard");

    h.convertNDCoordsToScreenCoords(g.sdl.screenWidth, g.sdl.screenHeight); 

    h.convertNDClengthsToSClengths(g.sdl.screenWidth, g.sdl.screenHeight);

    h.displayHexBoardScreenCoordinates();

    glfwSetErrorCallback(&errorCallback);

    if (!glfwInit()) { return -1; }
    scope(exit) glfwTerminate();

    // https://github.com/BindBC/bindbc-sdl/issues/53   

    // https://github.com/ichordev/bindbc-sdl/blob/74390eedeb7395358957701db2ede6b48a8d0643/source/bindbc/sdl/config.d#L12

    // Initialize SDL
    if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
    {
        writeln( "SDL could not initialize. SDL_Error: %s\n", SDL_GetError() );
    }
    else
    {
        //Create window
        g.sdl.window = SDL_CreateWindow( "SDL Tutorial",
                                         SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                                         g.sdl.screenWidth, g.sdl.screenHeight, 
                                         SDL_WINDOW_SHOWN );
        if( g.sdl.window == null )
        {
            printf( "sdl Window could not be created. SDL_Error: %s\n", SDL_GetError() );
        }
        else
        {
            SDL_SetWindowResizable(g.sdl.window, true);

            //Create renderer for window
            g.sdl.renderer = SDL_CreateRenderer( g.sdl.window, -1, SDL_RENDERER_ACCELERATED );
            if( g.sdl.renderer == null )
            {
                printf( "Renderer could not be created. SDL Error: %s\n", SDL_GetError() );
            }
            h.setRenderOfHexboard(g.sdl.renderer);

            g.textures = load_textures(g);

            writeln("g.textures = ", g.textures);

            //h.initializeHexTextures(g);

            writeln(g.textures);

            h.drawHexBoard;

            h.displayHexTextures();

            writeln("after displayHexTextures");

            /+
            //Clear screen
            SDL_SetRenderDrawColor( g.sdl.renderer, 128, 128, 128, 0xFF );

            //Clear screen
            SDL_RenderClear( g.sdl.renderer );

            SDL_SetRenderDrawColor( g.sdl.renderer, 0xFF, 0x00, 0x00, 0xFF );        

            D2_SC[6] s;
            foreach(r; 0..(h.rows))
            {
                foreach(c; 0..(h.columns))
                {  
                    // writeln("r = ", r, " c = ", c);

                    foreach(p; 0..6)
                    {
                        s[0].x = h.hexes[r][c].sc[0].x;
                        s[0].y = h.hexes[r][c].sc[0].y;
                        s[1].x = h.hexes[r][c].sc[1].x;
                        s[1].y = h.hexes[r][c].sc[1].y;
                        s[2].x = h.hexes[r][c].sc[2].x;
                        s[2].y = h.hexes[r][c].sc[2].y;
                        s[3].x = h.hexes[r][c].sc[3].x;
                        s[3].y = h.hexes[r][c].sc[3].y;
                        s[4].x = h.hexes[r][c].sc[4].x;
                        s[4].y = h.hexes[r][c].sc[4].y;
                        s[5].x = h.hexes[r][c].sc[5].x;
                        s[5].y = h.hexes[r][c].sc[5].y;

                        SDL_RenderDrawLine( g.sdl.renderer, s[0].x, s[0].y, s[1].x, s[1].y);
                        SDL_RenderDrawLine( g.sdl.renderer, s[1].x, s[1].y, s[2].x, s[2].y);
                        SDL_RenderDrawLine( g.sdl.renderer, s[2].x, s[2].y, s[3].x, s[3].y);
                        SDL_RenderDrawLine( g.sdl.renderer, s[3].x, s[3].y, s[4].x, s[4].y);
                        SDL_RenderDrawLine( g.sdl.renderer, s[4].x, s[4].y, s[5].x, s[5].y);
                        SDL_RenderDrawLine( g.sdl.renderer, s[5].x, s[5].y, s[0].x, s[0].y);
                    }
                }
            }

            // Update screen
            SDL_RenderPresent( g.sdl.renderer );
            +/


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

                            if( event.key.keysym.sym == SDLK_F3 )
                            {
                                import std.process : executeShell;
                                //executeShell("cls");

                                h.setHexboardTexturesAndTerrain(g);

                                writeln("after setHexboardTexturesAndTerrain");

                                h.displayHexTextures();

                                writeln("after displayHexTextures");

                                import std.datetime.stopwatch;
                                auto watch = StopWatch(AutoStart.no);
                                watch.start();
                                //                                          millisecond 
                                // units = weeks days hours minutes seconds msecs usecs hnsecs nsecs
                                //                                                microsecond

                                h.validateHexboard();

                                Location begin;
                                Location end;
                                begin.r = 0;
                                begin.c = 0;
                                end.r = h.lastRow;
                                end.c = h.lastColumn;  

                                //findShortestPath( h, g, begin, end );

                                findShortestPathRedBlack( h, g, begin, end );
                                
                                //placeHolder();

                                writeln(watch.peek()); 

                                h.displayHexTextures();  // AGAIN ????  FIXES PROBLEM THOUGH
                            }

                            SDL_RenderPresent( g.sdl.renderer );  // refresh screen for any keydown event
                            break;


                        case SDL_MOUSEBUTTONDOWN:
                            if( event.button.button == SDL_BUTTON_LEFT )
                            {
                                SDL_GetMouseState(&h.mouseClick.sc.x, &h.mouseClick.sc.y);

                                writeln(h.mouseClick.sc.x, ", ", h.mouseClick.sc.y);
                                
                                // Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)
                                
                                h.convertScreenCoordinatesToNormalizedDeviceCoordinates(g.sdl.screenWidth, g.sdl.screenHeight);

                                writeln(h.mouseClick.ndc.x, ", ", h.mouseClick.ndc.y);
                                
                                if (getHexMouseClickedOn(h))
                                {   
                                    int x = h.selectedHex.row;   int y = h.selectedHex.col;
 
                                    Location start;  
                                    Location end; 
                                    
                                    start.r = 0;
                                    start.c = 0;
                                    
                                    end.r = x; 
                                    end.c = y;
                                    
                                    //h.setHexRowTexture(g, start.row, Ids.solidRed);
                                    
                                    //h.setHexColTexture(g, start.column, Ids.solidRed);                                    

                                    //h.setHexTexture(g, start, Ids.solidBlack);
                                    // h.selectedHex has end point
                                    findShortestPathRedBlack( h, g, start, end );

                                    h.displayHexTextures();
                                    
                                    //writeln("start (", start.row, ", ", start.column, ")   end (", end.row, ",", end.column, ")" );
                                    
                                    //int distance = heuristic(start, end);
                                    
                                    //writeln("DISTANCE = ", distance);
 
                                    D2_SC[4] t;
                                    
                                    t[0].x = h.hexes[x][y].sc[0].x;
                                    t[0].y = h.hexes[x][y].sc[0].y; 
                                    t[1].x = h.hexes[x][y].sc[1].x;
                                    t[1].y = h.hexes[x][y].sc[1].y;
                                    t[2].x = h.hexes[x][y].sc[3].x;
                                    t[2].y = h.hexes[x][y].sc[3].y; 
                                    t[3].x = h.hexes[x][y].sc[4].x;
                                    t[3].y = h.hexes[x][y].sc[4].y;

                                    //writeln(t);
                                    
                                    SDL_RenderDrawLine( g.sdl.renderer, t[0].x, t[0].y, t[1].x, t[1].y);
                                    SDL_RenderDrawLine( g.sdl.renderer, t[1].x, t[1].y, t[2].x, t[2].y);
                                    SDL_RenderDrawLine( g.sdl.renderer, t[2].x, t[2].y, t[3].x, t[3].y);
                                    SDL_RenderDrawLine( g.sdl.renderer, t[3].x, t[3].y, t[0].x, t[0].y);
                                }
                         
                                SDL_RenderPresent( g.sdl.renderer );
                            }
                            break;          

                        default: break;
                    }

                }
            }
            return 0;
        }
    }  
    
    
    //printClipboardState();
    //printJoystickState();
    //printMonitorState();

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);

    WindowData data;
    
    g.glfw.window = glfwCreateWindow(g.glfw.SCREEN_WIDTH, g.glfw.SCREEN_HEIGHT, 
                                     "Black window - press F11 to toggle fullscreen, press ESC to exit", 
                                     null, null);
    scope(exit) glfwDestroyWindow(g.glfw.window);
    
    if (!g.glfw.window) 
    { 
        glfwTerminate();
        return -1;
    }
    glfwSetWindowUserPointer(g.glfw.window, &data);

    glfwSetKeyCallback(g.glfw.window, &keyCallback);
    glfwMakeContextCurrent(g.glfw.window);
    glfwSwapInterval(1); // Set vsync on so glfwSwapBuffers will wait for monitor updates.
    // note: 1 is not a boolean! Set e.g. to 2 to run at half the monitor refresh rate.

    double oldTime = glfwGetTime();
    while (!glfwWindowShouldClose(g.glfw.window)) 
    {
        const newTime = glfwGetTime();
        const elapsedTime = newTime - oldTime;
        oldTime = newTime;

        glfwSwapBuffers(g.glfw.window);
        glfwPollEvents();
    }
    return 0;
}

/// Data stored in the window's user pointer
///
/// Note: assuming you only have one window, you could make these global variables.


struct WindowData 
{
    // These are stored in the window's user data so that when exiting fullscreen,
    // the window can be set to the position where it was before entering fullscreen
    // instead of resetting to e.g. (0, 0)
    int xpos;
    int ypos;
    int width;
    int height;

    @nogc nothrow void update(GLFWwindow* window) 
    {
        glfwGetWindowPos(window, &this.xpos, &this.ypos);
        glfwGetWindowSize(window, &this.width, &this.height);
    }
}


extern(C) @nogc nothrow void errorCallback(int error, const(char)* description) 
{
    fprintf(stderr, "Error: %s\n", description);
}


extern(C) @nogc nothrow void keyCallback(GLFWwindow* window, int key, int scancode, int action, int mods) 
{
    if (action == GLFW_PRESS) 
    {
        switch (key) 
        {
            case GLFW_KEY_ESCAPE:
                glfwSetWindowShouldClose(window, GLFW_TRUE);
                break;
            case GLFW_KEY_F11:
                toggleFullScreen(window);
                break;
            default: break;
        }
    }
}


@nogc nothrow void toggleFullScreen(GLFWwindow* window) 
{
    WindowData* wd = cast(WindowData*) glfwGetWindowUserPointer(window);
    assert(wd);
    if (glfwGetWindowMonitor(window)) 
    {
        glfwSetWindowMonitor(window, null, wd.xpos, wd.ypos, wd.width, wd.height, 0);
    } 
    else 
    {
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        if (monitor) 
        {
            const GLFWvidmode* mode = glfwGetVideoMode(monitor);
            wd.update(window);
            glfwSetWindowMonitor(window, monitor, 0, 0, mode.width, mode.height, mode.refreshRate);
        }
    }
}



void printClipboardState() 
{
    printf("Clipboard contents: `%s.80`\n", glfwGetClipboardString(null));
}


void printMonitorState() 
{
    int monitorsLength;
    GLFWmonitor** monitorsPtr = glfwGetMonitors(&monitorsLength);
    GLFWmonitor*[] monitors = monitorsPtr[0..monitorsLength];

    foreach(GLFWmonitor* mt; monitors) 
    {
        int widthMM, heightMM;
        int xpos, ypos, width, height;
        glfwGetMonitorPos(mt, &xpos, &ypos);
        glfwGetMonitorPhysicalSize(mt, &widthMM, &heightMM);
        const(GLFWvidmode)* mode = glfwGetVideoMode(mt);
        printf("Monitor `%s` has size %dx%d mm\n", glfwGetMonitorName(mt), widthMM, heightMM);
        printf("  current video mode: %dx%d %dHz r%dg%db%d\n", mode.width, mode.height, mode.refreshRate, mode.redBits, mode.greenBits, mode.blueBits);
        printf("  position: %d, %d\n", xpos, ypos);
        glfwGetMonitorWorkarea(mt, &xpos, &ypos, &width, &height);
        printf("  work area: (%d, %d), size (%d, %d)\n", xpos, ypos, width, height);
    }
}


void printJoystickState() 
{
    for (int js = GLFW_JOYSTICK_1; js <= GLFW_JOYSTICK_LAST; js++) 
    {
        if (glfwJoystickPresent(js)) 
        {
            //glfwSetJoystickRumble(js, /*slow*/ 0.25, /*fast*/ 0.25);
            printf("Joystick %d has name `%s` and GUID `%s`\n", js, glfwGetJoystickName(js), glfwGetJoystickGUID(js));
            int buttonsLength, axesLength, hatsLength;
            const(ubyte)* buttonsPtr = glfwGetJoystickButtons(js, &buttonsLength);
            const(float)* axesPtr = glfwGetJoystickAxes(js, &axesLength);
            const(ubyte)* hatsPtr = glfwGetJoystickHats(js, &hatsLength);
            const(ubyte)[] buttons = buttonsPtr[0..buttonsLength];
            const(float)[] axes = axesPtr[0..axesLength];
            const(ubyte)[] hats = hatsPtr[0..hatsLength];
            printf("number of axes: %d\n", cast(int) axes.length);

            if (glfwJoystickIsGamepad(js)) 
            {
                printf("  It is a gamepad with name `%s`\n", glfwGetGamepadName(js));
                GLFWgamepadstate state;
                if (glfwGetGamepadState(js, &state)) 
                {
                    printf("Left stick: %f,%f\n", state.axes[GLFW_GAMEPAD_AXIS_LEFT_X], state.axes[GLFW_GAMEPAD_AXIS_LEFT_Y]);
                    printf("A: %d, B: %d\n", state.buttons[GLFW_GAMEPAD_BUTTON_A], state.buttons[GLFW_GAMEPAD_BUTTON_B]);
                }
            }
        } 
        else 
        {
            printf("Joystick %d not present\n", js);
        }
    }
    
    

}
