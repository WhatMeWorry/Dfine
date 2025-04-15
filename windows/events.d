
module windows.events;

import std.stdio;
import core.stdc.stdlib : exit;
import std.string : toStringz;
import datatypes;

import bindbc.sdl : SDL_Event, SDL_WINDOWEVENT, SDL_QUIT;
import bindbc.sdl;  // all the others
import windows.window_events : handleWindowEvent;
import windows.key_events : handleKeyEvent;

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


typedef enum SDL_EventType
{
    SDL_QUIT           = 0x100, // User-requested quit
      (Application events)
      (Window events)
    SDL_WINDOWEVENT    = 0x200, // Window state change
    SDL_SYSWMEVENT,             // System specific event
       (Keyboard events)
    SDL_KEYDOWN        = 0x300, // Key pressed down
    SDL_KEYUP,                  // Key released
    SDL_TEXTEDITING,            // Keyboard text editing (composition)
    SDL_TEXTINPUT,              // Keyboard text input
    SDL_TEXTEDITING_EXT,        // Extended keyboard text editing (composition)
        (Mouse events)
    SDL_MOUSEMOTION    = 0x400, // Mouse moved
    SDL_MOUSEBUTTONDOWN,        // Mouse button pressed
    SDL_MOUSEBUTTONUP,          // Mouse button released
    SDL_MOUSEWHEEL,             // Mouse wheel motion
        (Joystick events)
        (Game controller events)
        (Touch Finger events)
        (Gesture events)
        (Clipboard events)
        (Drag and drop events)
        (Audio hotplug events)
        (Sensor events)
        (Render events)
        (Internal events)
    //  This last event is only for bounding internal arrays
    SDL_LASTEVENT    = 0xFFFF
} SDL_EventType;

+/

void handleEvents(ref SDL_Event event, ref Status status)
{

    if (event.type == SDL_WINDOWEVENT)
    {
        //writeln("event = ", event.type, " is SDL_WINDOWEVENT");
        handleWindowEvent(event.window, status);
        return;
    }
    
    if (event.type == SDL_KEYDOWN || event.type == SDL_KEYUP)
    {
        //writeln("event = ", event.type, " is SDL_WINDOWEVENT");
        handleKeyEvent(event.key, status);
        return;
    }

    if (event.type == SDL_QUIT)
    {
        // The SDL_QUIT event is activated when a user attempts to close the application window. 
        // this can occur through various actions, such as clicking the window's close button (X), 
        // pressing Alt+F4, or any other method the operating system uses to signal application 
        // termination. In Microsoft Windows, pressing Alt + F4 is a keyboard shortcut that closes 
        // the currently active application
        writeln("event = ", event.type, " is SDL_QUIT");
        status.running = false;
        return;
    }


}
