
module utilities.displayinfo;


import bindbc.sdl;
import std.stdio;


void display_info()
{
    if (SDL_Init(SDL_INIT_VIDEO) != 0) 
    {
        writefln("SDL initialization failed: %s", SDL_GetError());  //exit(-1);
    }
/+
    int num_displays;
    SDL_DisplayID* displays = SDL_GetDisplays(&num_displays);
    if (!displays) {
      fprintf(stderr, "SDL_GetDisplays failed: %s\n", SDL_GetError());
      SDL_Quit();
      return 1;
    }
    if (num_displays > 0) {
      SDL_DisplayID displayID = displays[0]; // Use the first display for example
      
      int count;
      SDL_DisplayMode** modes = SDL_GetFullscreenDisplayModes(displayID, &count);
      if (modes) {
          printf("Number of fullscreen display modes: %d\n", count);

          // Example: Iterate and print each mode details
          for (int i = 0; i < count; i++) {
              printf("Mode %d: %dx%d, %.2fHz, Pixel Density: %.2f\n",
                      i,
                      modes[i]->w,
                      modes[i]->h,
                      modes[i]->refresh_rate,
                      modes[i]->pixel_density
                     );
          }
          SDL_free(modes); // Free the allocated array
      } else {
          fprintf(stderr, "SDL_GetFullscreenDisplayModes failed: %s\n", SDL_GetError());
      }
    } else {
      fprintf(stderr, "No displays found.\n");
    }
+/

/+
    int num_display_modes = SDL_GetNumDisplayModes(0);

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
    
    
+/   
}