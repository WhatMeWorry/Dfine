
module windows.events;

import std.stdio;
import core.stdc.stdlib : exit;
import std.string : toStringz;
import datatypes;

//import bindbc.sdl : SDL_Event, SDL_WINDOWEVENT, SDL_QUIT;
import bindbc.sdl;  // all the others
import windows.window_events : handleWindowEvent;
import windows.key_events : handleKeyEvent;
import windows.mouse_events : handleMouseEvent;

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
    SDL_LASTEVENT    = 0xFFFF
} SDL_EventType;

+/

void handleEvents(SDL_Event event, ref Status status)
{
    if ( (SDL_EVENT_WINDOW_FIRST <= event.type)  && (event.type <= SDL_EVENT_WINDOW_LAST) )
    //if (event.type == SDL_EVENT_WINDOW)
    {
        //writeln("event = ", event.type, " is SDL_EVENT_WINDOWEVENT");
        handleWindowEvent(event.window, status);
        return;
    }
    
    auto sdlEventKeyFirst = SDL_EVENT_KEY_DOWN;  // define a range of all possible key events
    auto sdlEventKeyLast = SDL_EVENT_TEXT_EDITING_CANDIDATES;
    
    if ( (sdlEventKeyFirst <= event.type)  && (event.type <= sdlEventKeyLast) )
    //if (event.type == SDL_EVENT_KEY_DOWN || event.type == SDL_EVENT_KEY_UP)
    {
        //writeln("event = ", event.type, " is one of the key events");
        handleKeyEvent(event.key, status);
        return;
    }

    auto sdlEventMouseFirst = SDL_EVENT_MOUSE_MOTION;  // define a range of all possible mouse events
    auto sdlEventMouseLast = SDL_EVENT_MOUSE_REMOVED;

    if ( (sdlEventMouseFirst <= event.type)  && (event.type <= sdlEventMouseLast) )
    //if (event.type == SDL_EVENT_MOUSE_MOTION || event.type == SDL_EVENT_MOUSE_BUTTON_DOWN ||
    //    event.type == SDL_EVENT_MOUSE_BUTTON_UP)  // for future - SDL_EVENT_MOUSE_WHEEL
    {
        handleMouseEvent(event, status);
        return;
    }
    

    if (event.type == SDL_EVENT_QUIT)
    {
        // The SDL_EVENT_QUIT event is activated when a user attempts to close the application window. 
        // this can occur through various actions, such as clicking the window's close button (X), 
        // pressing Alt+F4, or any other method the operating system uses to signal application 
        // termination. In Microsoft Windows, pressing Alt + F4 is a keyboard shortcut that closes 
        // the currently active application
        writeln("event = ", event.type, " is SDL_EVENT_QUIT");
        status.running = false;
        return;
    }


}
