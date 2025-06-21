
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
    
    // defaults to black window if SDL_SetRenderDrawColor is not present
    
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
    
    createWindow("tutorial_2", 1024, 1024, cast(SDL_WindowFlags) 0, &window);

    writeln("window = ", window);


    SDL_Surface* windowSurface; //  = SDL_GetWindowSurface(window);

    getWindowSurface(window, &windowSurface);

    writeln("windowSurface = ", windowSurface);

    // SDL_Surface* sourceSurface = SDL_CreateRGBSurface(0, 100, 100, 32, 0, 255, 0, 255); // Example with green color
    
    SDL_Surface* sourceSurface;
    
    loadImageToSurface("./images/earth1024x1024.png", &sourceSurface);
    

    writeln("sourceSurface = ", sourceSurface);


    // Set a destination rectangle (where to blit on the window)
    
    SDL_Rect dstRect;
    dstRect.x = -200; // Position on the window
    dstRect.y = -200;
    dstRect.w = sourceSurface.w; // Use source surface's width and height
    dstRect.h = sourceSurface.h;

    // Blit the source surface to the window's surface
    
    //blitSurface(sourceSurface, &srcRect, windowSurface, &dstRect);
    
    blitSurface(sourceSurface, null, windowSurface, &dstRect);
 
    updateWindowSurface(window);
    
    bool done = false;
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

        //SDL_RenderClear(renderer); // Clear the renderer
            // Add your drawing calls here (e.g., SDL_RenderFillRect())
        //SDL_RenderPresent(renderer); // Present the rendered content
    }

}






