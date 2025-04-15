
module windows.events;

import std.stdio;
import core.stdc.stdlib : exit;
import std.string : toStringz;
import datatypes;

import bindbc.sdl : SDL_Event, SDL_WINDOWEVENT;
import windows.window_events : handleWindowEvent;

/+
typedef union SDL_Event
{
    Uint32 type;                            // Event type, shared with all events
    SDL_CommonEvent      common;            // Common event data
    SDL_DisplayEvent     display;           // Display event data
    SDL_WindowEvent      window;            // Window event data    (See window_events.d)
    SDL_KeyboardEvent    key;               // Keyboard event data  (See key_events.d)
        (text editing    events)
    SDL_MouseMotionEvent motion;            // Mouse motion event data
    SDL_MouseButtonEvent button;            // Mouse button event data
    SDL_MouseWheelEvent  wheel;             // Mouse wheel event data
        (joystick events)
        (controller events)
    SDL_AudioDeviceEvent adevice;           // Audio device event data
    SDL_SensorEvent      sensor;            // Sensor event data
    SDL_QuitEvent        quit;              // Quit request event data  (See below)
    SDL_UserEvent        user;              // Custom event data
    SDL_SysWMEvent       syswm;             // System dependent window event data
    SDL_TouchFingerEvent tfinger;           // Touch finger event data
        (gesture events)
    SDL_DropEvent drop;                     // Drag and drop event data
} SDL_Event;

The SDL_QUIT event is activated when a user attempts to close the application window. 
This can occur through various actions, such as clicking the window's close button (X), 
pressing Alt+F4, or any other method the operating system uses to signal application 
termination. In Microsoft Windows, pressing Alt + F4 is a keyboard shortcut that closes 
the currently active application

+/

void handleEvents(ref SDL_Event event, ref CurrentStatus status)
{

    if (event.type == SDL_WINDOWEVENT)
    {
        //writeln("event = ", event.type, " is SDL_WINDOWEVENT");
        handleWindowEvent(event.window, status);
    }



}
