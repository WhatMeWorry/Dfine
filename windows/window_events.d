
module windows.window_events;


import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import textures.texture : Texture;

import std.stdio;
import datatypes;
import bindbc.sdl : SDL_WindowEvent;

/+
typedef struct SDL_WindowEvent
{
    Uint32 type;        // SDL_WINDOWEVENT
    Uint32 timestamp;   // In milliseconds, populated using SDL_GetTicks()
    Uint32 windowID;    // The associated window
    Uint8 event;        // SDL_WindowEventID (See Below)
    Uint8 padding1;
    Uint8 padding2;
    Uint8 padding3;
    Sint32 data1;       // event dependent data
    Sint32 data2;       // event dependent data
} SDL_WindowEvent;


typedef enum SDL_WindowEventID
{
    SDL_WINDOWEVENT_NONE,           // Never used
    SDL_WINDOWEVENT_SHOWN,          // Window has been shown
    SDL_WINDOWEVENT_HIDDEN,         // Window has been hidden
    SDL_WINDOWEVENT_EXPOSED,        // Window has been exposed and should be redrawn
    SDL_WINDOWEVENT_MOVED,          // Window has been moved to data1, data2
    SDL_WINDOWEVENT_RESIZED,        // Window has been resized to data1xdata2
    SDL_WINDOWEVENT_SIZE_CHANGED,   // The window size has changed, either as
                                    // a result of an API call or through the
                                         system or user changing the window size.
    SDL_WINDOWEVENT_MINIMIZED,      // Window has been minimized
    SDL_WINDOWEVENT_MAXIMIZED,      // Window has been maximized
    SDL_WINDOWEVENT_RESTORED,       // Window has been restored to normal size and position
    SDL_WINDOWEVENT_ENTER,          // Window has gained mouse focus
    SDL_WINDOWEVENT_LEAVE,          // Window has lost mouse focus
    SDL_WINDOWEVENT_FOCUS_GAINED,   // Window has gained keyboard focus
    SDL_WINDOWEVENT_FOCUS_LOST,     // Window has lost keyboard focus
    SDL_WINDOWEVENT_CLOSE,          // The window manager requests that the window be closed
    SDL_WINDOWEVENT_TAKE_FOCUS,     // Window is being offered a focus (should SetWindowInputFocus()
                                    // on itself or a subwindow, or ignore)
    SDL_WINDOWEVENT_HIT_TEST,       // Window had a hit test that wasn't SDL_HITTEST_NORMAL.
    SDL_WINDOWEVENT_ICCPROF_CHANGED,// The ICC profile of the window's display has changed.
    SDL_WINDOWEVENT_DISPLAY_CHANGED // Window has been moved to display data1.
} SDL_WindowEventID;
+/

void handleWindowEvent(SDL_WindowEvent window, ref Status status)
{
    //writeln("Window ID: ", window.windowID);
    
    if(window.event == SDL_WINDOWEVENT_SHOWN)
    {
        //writeln("window.event was SHOWN");
    }
    if(window.event == SDL_WINDOWEVENT_HIDDEN)
    {
        //writeln("window.event was HIDDEN");
    }
    if(window.event == SDL_WINDOWEVENT_EXPOSED)
    {
        //writeln("window.event was EXPOSED");
    }
    if(window.event == SDL_WINDOWEVENT_MOVED)
    {
        //writeln("window.event was MOVED");
    }
    if(window.event == SDL_WINDOWEVENT_RESIZED)
    {
        //writeln("window.event was RESIZED");
    }
    if(window.event == SDL_WINDOWEVENT_SIZE_CHANGED)
    {
        //writeln("window.event was SIZE_CHANGED");
    }
    if(window.event == SDL_WINDOWEVENT_MINIMIZED)
    {
        //writeln("window.event was MINIMIZED");
    }
    if(window.event == SDL_WINDOWEVENT_MAXIMIZED)
    {
        //writeln("window.event was MAXIMIZED");
    }
    if(window.event == SDL_WINDOWEVENT_RESTORED)
    {
        //writeln("window.event was RESTORED");
    }
    if(window.event == SDL_WINDOWEVENT_ENTER)
    {
        //writeln("window.event was ENTER with Window ID: ", window.windowID);
        status.active.windowID = window.windowID;
    }

    if(window.event == SDL_WINDOWEVENT_LEAVE)
    {
        //writeln("window.event was LEAVE");
    }
    if(window.event == SDL_WINDOWEVENT_FOCUS_GAINED)
    {
        //writeln("window.event was FOCUS_GAINED");
    }
    if(window.event == SDL_WINDOWEVENT_FOCUS_LOST)
    {
        //writeln("window.event was FOCUS_LOST");
    }
    if(window.event == SDL_WINDOWEVENT_CLOSE)  // clicked on the window close icon X
    {                                          // Not ideal since closing one window
        writeln("window.event was CLOSE");     // should not exit the entire application
        status.running = false;
    }

 
}
