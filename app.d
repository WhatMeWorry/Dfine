

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

module app;

import honeycomb : HexBoard;

import glfw3.api;
import core.stdc.stdio;

import std.stdio : writeln;
import bindbc.sdl;
import bindbc.loader;


bool loadSimpleDirectMediaLibary()
{
    SDLSupport ret = loadSDL();	
	
    if(ret == sdlSupport)
    {
        SDL_version ver;
        SDL_GetVersion(&ver);
		
        writeln("version = ", ver);	  // displays: version = SDL_version(2, 30, 2)
        return true;
    }

    writeln("SDL library was not found or bad version");
    return false;
}




struct GLFW_STRUCT
{	
    const int SCREEN_WIDTH = 640;
    const int SCREEN_HEIGHT = 480;		
    GLFWwindow* window;  
}

struct SDL_STRUCT
{
    const int SCREEN_WIDTH = 640;
    const int SCREEN_HEIGHT = 480;		
    SDL_Window* window = null;            // The window we'll be rendering to
	SDL_Renderer* renderer = null;
    //SDL_Surface* screenSurface = null;
}	

struct Globals
{
    int i;
    GLFW_STRUCT glfw;
    SDL_STRUCT sdl;
}	
 
Globals g;

/// Global variables
/// Idea taken from Mike Shah



int main() 
{

    HexBoard hexB = HexBoard(.43, 3, 5);

    glfwSetErrorCallback(&errorCallback);

    if (!glfwInit()) { return -1; }
    scope(exit) glfwTerminate();
	
    loadSimpleDirectMediaLibary();

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
                                         g.sdl.SCREEN_WIDTH, g.sdl.SCREEN_HEIGHT, 
                                         SDL_WINDOW_SHOWN );
        if( g.sdl.window == null )
        {
            printf( "sdl Window could not be created. SDL_Error: %s\n", SDL_GetError() );
        }	
        else
        {
            //Get window surface
            //g.sdl.screenSurface = SDL_GetWindowSurface( g.sdl.window );

            //Fill the surface white
            //SDL_FillRect( g.sdl.screenSurface, null, SDL_MapRGB( g.sdl.screenSurface.format, 0xFF, 0xFF, 0xFF ) );
            
            //Update the surface
            //SDL_UpdateWindowSurface( g.sdl.window );
			
            //Create renderer for window
            g.sdl.renderer = SDL_CreateRenderer( g.sdl.window, -1, SDL_RENDERER_ACCELERATED );
            if( g.sdl.renderer == null )
            {
                printf( "Renderer could not be created. SDL Error: %s\n", SDL_GetError() );
                //success = false;
            }
			
            //Clear screen
            SDL_SetRenderDrawColor( g.sdl.renderer, 128, 128, 128, 0xFF );
            SDL_RenderClear( g.sdl.renderer );		
			
            //Render red filled quad
            SDL_Rect fillRect = { g.sdl.SCREEN_WIDTH / 4, g.sdl.SCREEN_HEIGHT / 4, g.sdl.SCREEN_WIDTH / 2, g.sdl.SCREEN_HEIGHT / 2 };
            SDL_SetRenderDrawColor( g.sdl.renderer, 0xFF, 0x00, 0x00, 0xFF );        
            SDL_RenderFillRect( g.sdl.renderer, &fillRect );			
			
			
            //Update screen
            SDL_RenderPresent( g.sdl.renderer );			
			

            //Hack to get window to stay up
            
            SDL_Event e; bool quit = false; 
            while( quit == false )
            { 
                while( SDL_PollEvent(&e) )
                { 
                    if( e.type == SDL_QUIT ) quit = true; 
                } 
            }
            
        }
    }  
	
	
	

    //printClipboardState();
    //printJoystickState();
    //printMonitorState();

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);

    WindowData data;
    g.glfw.window = glfwCreateWindow(800, 600, "Black window - press F11 to toggle fullscreen, press ESC to exit", null, null);
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