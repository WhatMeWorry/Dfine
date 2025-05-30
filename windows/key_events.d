
module windows.key_events;


import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import textures.texture : Texture;

import std.stdio;
import datatypes;
import bindbc.sdl : SDL_WindowEvent;

/+

typedef struct SDL_KeyboardEvent
{
    Uint32 type;        // SDL_KEYDOWN or SDL_KEYUP
    Uint32 timestamp;   // In milliseconds, populated using SDL_GetTicks()
    Uint32 windowID;    // The window with keyboard focus, if any
    Uint8 state;        // SDL_PRESSED or SDL_RELEASED
    Uint8 repeat;       // Non-zero if this is a key repeat
    Uint8 padding2;
    Uint8 padding3;
    SDL_Keysym keysym;  // The key that was pressed or released
} SDL_KeyboardEvent;

typedef struct SDL_Keysym
{
    SDL_Scancode scancode;      // SDL physical key code - see SDL_Scancode for details
    SDL_Keycode sym;            // SDL virtual key code - see SDL_Keycode for details
    Uint16 mod;                 // current key modifiers
    Uint32 unused;
} SDL_Keysym;

In SDL (Simple DirectMedia Layer), scan codes represent the physical position of keys 
on the keyboard, while key codes represent the character or symbol associated with that 
key press within the current keyboard layout. 

typedef enum SDL_KeyCode
{
    SDLK_UNKNOWN = 0,

    SDLK_RETURN    = '\r',
    SDLK_ESCAPE    = '\x1B',
    SDLK_BACKSPACE = '\b',
    SDLK_TAB       = '\t',
    SDLK_SPACE     = ' ',
    SDLK_EXCLAIM   = '!',
    SDLK_QUOTEDBL  = '"',
    SDLK_HASH      = '#',
    SDLK_PERCENT   = '%',
    SDLK_DOLLAR    = '$',
    SDLK_AMPERSAND = '&',
    SDLK_QUOTE     = '\'',
    SDLK_LEFTPAREN = '(',
    SDLK_RIGHTPAREN = ')',
    SDLK_ASTERISK  = '*',
    SDLK_PLUS      = '+',
    SDLK_COMMA     = ',',
    SDLK_MINUS     = '-',
    SDLK_PERIOD    = '.',
    SDLK_SLASH     = '/',
      . . .
    SDLK_0         = '0',
    SDLK_1         = '1',
      . . .
    SDLK_9         = '9',
    SDLK_COLON     = ':',
    SDLK_SEMICOLON = ';',
    SDLK_LESS      = '<',
    SDLK_EQUALS    = '=',
    SDLK_GREATER   = '>',
    SDLK_QUESTION  = '?',
    SDLK_AT        = '@',

    // Skip uppercase letters

    SDLK_LEFTBRACKET  = '[',
    SDLK_BACKSLASH    = '\\',
    SDLK_RIGHTBRACKET = ']',
    SDLK_CARET        = '^',
    SDLK_UNDERSCORE   = '_',
    SDLK_BACKQUOTE    = '`',
    
    SDLK_a = 'a',
    SDLK_b = 'b',
       (removed for brevity)
    SDLK_y = 'y',
    SDLK_z = 'z',
+/


void handleKeyEvent(SDL_KeyboardEvent keyEvent, ref Status status)
{
    if(keyEvent.key == SDLK_F1)
    {
        status.saveWindowToFile = true;
        return;
    }
    if(keyEvent.key == SDLK_ESCAPE )
    {
        //writeln("user pressed the Escape Key");
        status.running = false;
    }
 
}
