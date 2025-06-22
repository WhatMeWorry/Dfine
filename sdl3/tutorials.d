
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


void tutorial_1()  // Creates a white filled 640x480 window that can be closed with window
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



// blitSurface() and updateWindowSurface() allows you to bypass the use of renderers
// and thus SDL_RenderClear and SDL_RenderPresent.
//
// At least for blit operations, 


void tutorial_2()
{
    SDL_Window* window = null;
    
    createWindow("tutorial_2", 512, 512, cast(SDL_WindowFlags) 0, &window);

    SDL_Surface* windowSurface;

    getWindowSurface(window, &windowSurface);

    SDL_Surface* sourceSurface;

    loadImageToSurface("./images/earth1024x1024.png", &sourceSurface);

    // Set a destination rectangle (where to blit on the window)
    SDL_Rect dstRect;
    dstRect.x = 0; // Position on the window
    dstRect.y = 0;
    dstRect.w = sourceSurface.w; // Use source surface's width and height
    dstRect.h = sourceSurface.h;

    // Blit the source surface to the window's surface
    
    //blitSurface(sourceSurface, &srcRect, windowSurface, &dstRect);
    
    blitSurface(sourceSurface, null, windowSurface, null);
 
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
    }
}

/+
SDL_ScaleMode determines how (surfaces and)??? textures are scaled when their size doesn't perfectly match the 
destination. It's an enum that defines different scaling algorithms, primarily impacting how 
pixel art looks when stretched or shrunk

SDL_SCALEMODE_NEAREST:
This mode uses nearest-neighbor sampling, meaning it selects the closest pixel to the destination 
coordinate. This results in a blocky, pixelated look when scaling up, but it's fast and can be 
desirable for pixel art.

SDL_SCALEMODE_LINEAR:
This mode uses linear filtering, which averages the colors of surrounding pixels to create a 
smoother scaling effect. Generally preferred for images where a sharp, pixelated look is not desired.

SDL_SCALEMODE_PIXELART:
This mode is similar to SDL_SCALEMODE_NEAREST but includes some additional logic to improve scaling
for pixel art, particularly when scaling by non-integer factors
+/

void tutorial_3()
{

    SDL_Window* window = null;
    SDL_Surface* screenSurface = null;  // one example used display as variable name
    SDL_Surface* globeSurface = null;
    SDL_Surface* greenSurface = null;
    
    int winWidth = 512; 
    int winHeight = 512;
    
    createWindow("tutorial_3", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);

    getWindowSurface(window, &screenSurface);
    
    writeln("screenSurface has");
    displaySurfaceProperties(screenSurface);

    loadImageToSurface("./images/globe256x256.png", &globeSurface);

    writeln("globeSurface has");
    displaySurfaceProperties(globeSurface);

    greenSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32); // Using a common format

    writeln("greenSurface created with SDL_PIXELFORMAT_RGBA32 has");
    displaySurfaceProperties(greenSurface);

    uint fillColor = SDL_MapSurfaceRGBA(greenSurface, 0, 255, 0, 255);

    SDL_FillSurfaceRect(greenSurface, null, fillColor);

     blitSurfaceScaled(greenSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);
    
    // blitSurface(greenSurface, null, screenSurface, null);  

     blitSurfaceScaled(globeSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);
    
    // blitSurface(globeSurface, null, screenSurface, null);  // if used, globeSurface only takes up quadrant of screen
                                                              // because no scaling
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
    }
    
    
}



void tutorial_4()
{
    SDL_Window* window = null;
    SDL_Surface* windowSurface = null;  // one example used display as variable name
    SDL_Surface* globeSurface = null;
    SDL_Surface* greenSurface = null;
    
    int winWidth = 512; 
    int winHeight = 512;
    
    createWindow("Tutorial 4 - Alpha Blending", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);

    getWindowSurface(window, &windowSurface);

    // Create a source surface with alpha channel (RGBA format)
    
    
    SDL_Surface *sourceSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32);

/+
    greenSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32); // Using a common format
    writeln("greenSurface created with SDL_PIXELFORMAT_RGBA32 has");
    displaySurfaceProperties(greenSurface);
    uint fillColor = SDL_MapSurfaceRGBA(greenSurface, 0, 255, 0, 255);
    SDL_FillSurfaceRect(greenSurface, null, fillColor);
    blitSurfaceScaled(greenSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);
+/
    // Fill the source surface with a semi-transparent color (e.g., red with 50% alpha)
    
    uint semiTransparentRed = SDL_MapSurfaceRGBA(sourceSurface, 255, 0, 0, 128); // 128 is ~50% alpha
    
    SDL_FillSurfaceRect(sourceSurface, null, semiTransparentRed);

    // Set the blend mode for the source surface to enable alpha blending
    
    SDL_SetSurfaceBlendMode(sourceSurface, SDL_BLENDMODE_BLEND);

    // (Optional) Adjust the overall alpha modulation of the source surface
    
    // SDL_SetSurfaceAlphaMod(sourceSurface, 192); // Set overall transparency to ~75%

    // Main loop
    bool running = true;
    SDL_Event event;
    while (running) {
        while (SDL_PollEvent(&event) != 0) {
            if (event.type == SDL_EVENT_QUIT) {
                running = false;
            }
        }

        // Clear the window surface
        
        SDL_FillSurfaceRect(windowSurface, null, SDL_MapSurfaceRGB(windowSurface, 255, 255, 255)); // Fill with white

        // Blit the source surface onto the window surface
        SDL_Rect destRect = { 100, 100, 200, 200 }; // Destination rectangle
        SDL_BlitSurface(sourceSurface, null, windowSurface, &destRect);

        // Update the window surface
        SDL_UpdateWindowSurface(window);

        // Add a small delay
        SDL_Delay(16); // ~60 fps
    }

}





