
module tutorials;


import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import breakup;
import magnify;
import sdl_funcs_with_error_handling;
import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 
import bindbc.sdl;  // SDL_* all remaining declarations


void tutorial_1()  // Creates a black filled 640x480 window that can be closed with window
{
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;
    bool done = false;

    createWindowAndRenderer("tutorial_1", 640, 480, cast(SDL_WindowFlags) 0, &window, &renderer);
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);  // white screen
    
    while (!done)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_QUIT)
            {
                done = true;
            }
        }

        SDL_RenderClear(renderer); // Clear the renderer
            // Add your drawing calls here (e.g., SDL_RenderFillRect())
        SDL_RenderPresent(renderer); // Present the rendered content
    }
}


void tutorial_2()
{
    SDL_Window* window = null;
    
    //createWindow("tutorial_2", 640, 480, cast(SDL_WindowFlags) 0, &window);

/+
    // Create window
    SDL_Window* window = SDL_CreateWindow("My SDL Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, 0);
    if (!window) {
        std::cerr << "Failed to create window: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // Get the window's surface
    SDL_Surface* windowSurface = SDL_GetWindowSurface(window);
    if (!windowSurface) {
        std::cerr << "Failed to get window surface: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    // Create a source surface (example: a colored rectangle)
    SDL_Surface* sourceSurface = SDL_CreateRGBSurface(0, 100, 100, 32, 0, 255, 0, 255); // Example with green color
    if (!sourceSurface) {
        std::cerr << "Failed to create source surface: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    // Set a destination rectangle (where to blit on the window)
    SDL_Rect destRect;
    destRect.x = 50; // Position on the window
    destRect.y = 50;
    destRect.w = sourceSurface->w; // Use source surface's width and height
    destRect.h = sourceSurface->h;

    // Blit the source surface to the window's surface
    if (SDL_BlitSurface(sourceSurface, NULL, windowSurface, &destRect) != true) { // Note: SDL3's SDL_BlitSurface returns bool
        std::cerr << "Failed to blit surface: " << SDL_GetError() << std::endl;
        // Handle error appropriately
    }

    // Update the window to display the blitted surface
    if (SDL_UpdateWindowSurface(window) != 0) {
        std::cerr << "Failed to update window surface: " << SDL_GetError() << std::endl;
        // Handle error appropriately
    }

    // Keep the window open (example: until a quit event)
    SDL_Event e;
    bool quit = false;
    while (!quit) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                quit = true;
            }
        }
    }

    // Clean up
    SDL_FreeSurface(sourceSurface);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
    +/
}






