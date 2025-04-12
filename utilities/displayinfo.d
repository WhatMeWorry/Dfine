
module utilities.displayinfo;


import bindbc.sdl;
import std.stdio;


void display_info()
{
    SDL_Init(SDL_INIT_VIDEO);



    writeln("Display Modes: ", SDL_GetNumDisplayModes(0));

    writeln("Num Video Display: ", SDL_GetNumVideoDisplays());

    // The displayIndex needs to be in the range from 0 to SDL_GetNumVideoDisplays() - 1.

    // int SDL_GetNumDisplayModes(int displayIndex);

    // (int) Returns a number >= 1 on success or a negative error code on failure; call SDL_GetError() for more information.


    // int Count{SDL_GetNumDisplayModes(0)};
    
    SDL_DisplayMode mode;
    
    int displayModes = SDL_GetNumDisplayModes(0);
    
    foreach(i; 0..displayModes)
    {
        SDL_GetDisplayMode(0, i, &mode);   // Returns 0 on success or a negative error code on failure
        
                // DisplayIndex: 0, ModeIndex 0: 3620x2036 - 144FPS
                // DisplayIndex: 0, ModeIndex 1: 3620x2036 - 120FPS
                
        writeln("DisplayIndex: 0  ModeIndex ", i, "  ", mode.w, "x", mode.h, " - ", mode.refresh_rate, "FPS");
    }
    
    
    
    
    
    
    SDL_Quit();
}