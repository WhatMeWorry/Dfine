

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


struct GLFW_STRUCT
{   
    const int SCREEN_WIDTH = 640;
    const int SCREEN_HEIGHT = 480;
    GLFWwindow* window;  
}

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
    load_sdl_libraries(); 

    g.sdl.screenWidth  = 1000;
    g.sdl.screenHeight = 1000;


    int rowCount = 3;
    int colCount = 3;

    float hexDiameter = calculateHexDiameter(rowCount, colCount, Direction.horizontally );

    //float hexDiameter = calculateHexDiameter(rowCount, colCount, Direction.vertically );

    writeln("hexDiameter = ", hexDiameter);

    //return 1;

    //hexDiameter = .6;
    HexBoard h = HexBoard(hexDiameter, rowCount, colCount);  // hex board is created with NDC coordinates

                          // diameter
    //HexBoard h = HexBoard(.05, 50, 50);  // hex board is created with NDC coordinates

    h.displayHexBoard();  // hex board initially defined in NDC (Normalized Device Coordinates)

    //writeAndPause("After displayHexBoard");

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

            //h.initializeHexTextures(g);

            writeln(g.textures);

            h.drawHexBoard;

            h.displayHexTextures();

            /+
            //Clear screen
            SDL_SetRenderDrawColor( g.sdl.renderer, 128, 128, 128, 0xFF );

            //Clear screen
            SDL_RenderClear( g.sdl.renderer );

            SDL_SetRenderDrawColor( g.sdl.renderer, 0xFF, 0x00, 0x00, 0xFF );        

            D2_SC[6] s;
            uint maxRows = h.numberOfRows();
            uint maxCols = h.numberOfColumns();
            foreach(r; 0..maxRows)
            {
                foreach(c; 0..maxCols)
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
                                h.clearAllHexTextures();
								h.drawHexBoard;
                            }

                            if( event.key.keysym.sym == SDLK_F3 )
                            {
                                writeln("SDLK_F3");
                                h.initializeHexTextures(g);
								h.debugSpots();
                                h.displayHexTextures();
                                //writeln("g = ", g);
                                enteringLandOfPathFinding( h, g );
                                writeln("After call");
                            }

                            if( event.key.keysym.sym == SDLK_F12 )
                            {   
                                writeln("F12 Key Pressed");
                                //h.initializeHexTextures(g);
                                //h.displayHexTextures();
                                //writeln("g = ", g);
                                enteringLandOfPathFinding( h, g );
                                h.displayHexTextures();
                            }
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
 
                                    HexPosition start;  
                                    HexPosition end; 
                                    
                                    start.row = 0;
                                    start.column = 0;
                                    
                                    end.row = x; 
                                    end.column = y;
                                    
                                    //h.setHexRowTexture(g, start.row, Ids.solidRed);
                                    
                                    //h.setHexColTexture(g, start.column, Ids.solidRed);                                    

                                    //h.setHexTexture(g, start, Ids.solidBlack);
									                    // h.selectedHex has end point
									enteringLandOfPathFinding( h, g );

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
