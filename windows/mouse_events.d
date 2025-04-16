
module windows.mouse_events;


import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import textures.texture : Texture;

import std.stdio;
import datatypes;
import bindbc.sdl : SDL_WindowEvent;

/+
typedef struct SDL_MouseMotionEvent
{
    Uint32 type;        // SDL_MOUSEMOTION
    Uint32 timestamp;   // In milliseconds, populated using SDL_GetTicks()
    Uint32 windowID;    // The window with mouse focus, if any
    Uint32 which;       // The mouse instance id, or SDL_TOUCH_MOUSEID
  **Uint32 state;       // The current button state
    Sint32 x;           // X coordinate, relative to window
    Sint32 y;           // Y coordinate, relative to window
    Sint32 xrel;        // The relative motion in the X direction
    Sint32 yrel;        // The relative motion in the Y direction
} SDL_MouseMotionEvent;

typedef struct SDL_MouseButtonEvent
{
    Uint32 type;        // SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP
    Uint32 timestamp;   // In milliseconds, populated using SDL_GetTicks()
    Uint32 windowID;    // The window with mouse focus, if any
    Uint32 which;       // The mouse instance id, or SDL_TOUCH_MOUSEID
  **Uint8 button;       // The mouse button index
    Uint8 state;        // SDL_PRESSED or SDL_RELEASED
    Uint8 clicks;       // 1 for single-click, 2 for double-click, etc.
    Uint8 padding1;
    Sint32 x;           // X coordinate, relative to window
    Sint32 y;           // Y coordinate, relative to window
} SDL_MouseButtonEvent;
+/


void handleMouseEvent(SDL_Event event, ref Status status)
{
    if (event.type == SDL_MOUSEMOTION)
    {
        //writeln("Mouse moved");
        return;
    }
    if (event.type == SDL_MOUSEBUTTONDOWN)
    {
        // status???
        writeln("Mouse button down");
        return;
    }
    if (event.type == SDL_MOUSEBUTTONUP)
    {
        // status???
        writeln("Mouse button up");
        return;
    }
}
