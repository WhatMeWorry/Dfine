
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

/+
In digital displays like computer screens and televisions, the primary colors are red, green, and blue (RGB). 
These colors are used in an additive color model, where mixing them in varying intensities creates a wide range 
of colors, including white when all three are at full intensity

The secondary colors are cyan, magenta, and yellow. These are created by combining two primary colors of light 
(red, green, and blue) at full intensity. Specifically, cyan is green + blue, magenta is red + blue, and yellow 
is red + green. 

+/

void tutorial_4()
{
    SDL_Window* window = null;
    SDL_Surface* windowSurface = null;  // one example used display as variable name
    SDL_Surface* globeSurface = null;
    //SDL_Surface* greenSurface = null;
    
    int winWidth = 1000; 
    int winHeight = 1000;
    
    createWindow("Tutorial 4 - Alpha Blending", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);

    // windowSurface has format = xrgb8888 which means it does not have an alpha channel
    
    getWindowSurface(window, &windowSurface);
    
    writeln("windowSurface has");
    displaySurfaceProperties(windowSurface);
    
    SDL_Surface *rgbaSurface   = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32);

    // Create a source surface with alpha channel (RGBA format)

    SDL_Surface *redSurface   = SDL_CreateSurface(winWidth/3, winHeight/3, SDL_PIXELFORMAT_RGBA32);
    SDL_Surface *greenSurface = SDL_CreateSurface(winWidth/3, winHeight/3, SDL_PIXELFORMAT_RGBA32);
    SDL_Surface *blueSurface  = SDL_CreateSurface(winWidth/3, winHeight/3, SDL_PIXELFORMAT_RGBA32);

    // Fill the source surface with a semi-transparent color (e.g., red with 50% alpha)
    
    uint semiTransparentRed   = SDL_MapSurfaceRGBA(redSurface,   255, 0, 0, 128); // 128 is ~50% alpha
    uint semiTransparentGreen = SDL_MapSurfaceRGBA(greenSurface, 0, 255, 0, 128); // 128 is ~50% alpha
    uint semiTransparentBlue  = SDL_MapSurfaceRGBA(blueSurface,  0, 0, 255, 128); // 128 is ~50% alpha
    
    SDL_FillSurfaceRect(redSurface,   null, semiTransparentRed);
    SDL_FillSurfaceRect(greenSurface, null, semiTransparentGreen);
    SDL_FillSurfaceRect(blueSurface,  null, semiTransparentBlue);
        
    // Set the blend mode for the source surface to enable alpha blending
    
    SDL_SetSurfaceBlendMode(redSurface,   SDL_BLENDMODE_BLEND);
    SDL_SetSurfaceBlendMode(greenSurface, SDL_BLENDMODE_BLEND);
    SDL_SetSurfaceBlendMode(blueSurface,  SDL_BLENDMODE_BLEND);

    // (Optional) Adjust the overall alpha modulation of the source surface
    
    // SDL_SetSurfaceAlphaMod(redSurface, 192); // Set overall transparency to ~75%

    bool running = true;
    SDL_Event event;
    while (running) 
    {
        while (SDL_PollEvent(&event) != 0) 
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
        }

        // Clear the window surface
        SDL_FillSurfaceRect(windowSurface, null, SDL_MapSurfaceRGB(windowSurface, 255, 255, 255)); // Fill with white

        SDL_FillSurfaceRect(rgbaSurface, null, SDL_MapSurfaceRGBA(windowSurface, 255, 255, 255, 128)); // Fill with white

        // Blit the source surface onto the window surface
        
        SDL_Rect redDestRect = { 100, 100, 200, 200 }; // Destination rectangle
        //SDL_BlitSurface(redSurface, null, windowSurface, &redDestRect);
        SDL_BlitSurface(redSurface, null, rgbaSurface, &redDestRect);
        
        SDL_Rect greenDestRect = { 300, 300, 200, 200 }; // Destination rectangle
        //SDL_BlitSurface(greenSurface, null, windowSurface, &greenDestRect); 
        SDL_BlitSurface(greenSurface, null, rgbaSurface, &greenDestRect); 
        
        SDL_BlitSurface(rgbaSurface, null, windowSurface, null); 

        // Update the window surface
        SDL_UpdateWindowSurface(window);

        // Add a small delay
        SDL_Delay(16); // ~60 fps
    }

}





void tutorial_5()
{
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;
    SDL_Surface* redSurface = null;
    SDL_Surface* greenSurface = null;
    
    int winWidth = 1000; 
    int winHeight = 1000;
    
    //createWindow("Tutorial 4 - Texture Alpha Blending", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);

    //SDL_Renderer* renderer = SDL_CreateRenderer(window, "Tutorial 5 Renderer");

    createWindowAndRenderer("Tutorial 5 - Texture Alpha Blending", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);


    // Create surfaces for red and green rectangles
    // SDL_Surface* SDL_CreateRGBSurfaceWithFormat(Uint32 flags, int width, int height, int depth, Uint32 format);
    
    //SDL_Surface* redSurface = createRGBSurfaceWithFormat(0, 100, 100, 32, SDL_PIXELFORMAT_RGBA32);
    //SDL_Surface* greenSurface = createRGBSurfaceWithFormat(0, 100, 100, 32, SDL_PIXELFORMAT_RGBA32);
    
    createSurface(200, 200, SDL_PIXELFORMAT_RGBA32, &redSurface);
    createSurface(200, 200, SDL_PIXELFORMAT_RGBA32, &greenSurface);

    writeln("redSurface greenSurface = ",redSurface, "  ", greenSurface);

    // Fill surfaces with red and green colors (with alpha)
    //Uint32 redColor = SDL_MapRGBA(redSurface->format, 255, 0, 0, 128); // 128 alpha (semi-transparent)
    
    
    // To get the SDL_PixelFormatDetails from an SDL_Surface in SDL3, you need to first access 
    // the format field of the SDL_Surface struct, which is an SDL_PixelFormat. Then, you can 
    // use SDL_GetPixelFormatDetails() with that SDL_PixelFormat to retrieve a pointer to an SDL_PixelFormatDetails structure. 
    
    SDL_PixelFormatDetails* details = getPixelFormatDetails(redSurface.format);
    writeln("details = ", details);
    
    uint redColor = mapRGBA(details, null, 255, 0, 0, 128); // 128 alpha (semi-transparent)

    fillSurfaceRect(redSurface, null, redColor);

    //details = getPixelFormatDetails(greenSurface.format);
    //uint greenColor = mapRGBA(details, null, 0, 255, 0, 128); // 128 alpha (semi-transparent)
    
    uint greenColor = mapRGBA(getPixelFormatDetails(greenSurface.format), null, 0, 255, 0, 128); 
    
    fillSurfaceRect(greenSurface, null, greenColor);

    // Create textures from surfaces
    SDL_Texture* redTexture = createTextureFromSurface(renderer, redSurface);
    SDL_Texture* greenTexture = createTextureFromSurface(renderer, greenSurface);

    // Set blend mode for textures
    setTextureBlendMode(redTexture, SDL_BLENDMODE_BLEND);
    setTextureBlendMode(greenTexture, SDL_BLENDMODE_BLEND);

    bool running = true;
    SDL_Event event;
    while (running) 
    {
        while (SDL_PollEvent(&event) != 0) 
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
        }

        // Clear renderer
        SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        SDL_RenderClear(renderer);

        // Render textures with alpha blending
        SDL_Rect redRect = { 100, 100, 100, 100 }; // Position and size for red rectangle
        
        renderTexture(renderer, redTexture, null, cast(const SDL_FRect*) &redRect);

        SDL_Rect greenRect = { 150, 150, 100, 100 }; // Position and size for green rectangle
        
        SDL_RenderTexture(renderer, greenTexture, null, cast(const SDL_FRect*) &greenRect);

        // Update screen
        SDL_RenderPresent(renderer);
        SDL_Delay(16); // ~60 fps

    }

}
