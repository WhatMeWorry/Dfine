
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


void tutorial_smallest()
{
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;
    bool running = true;

    createWindowAndRenderer("tutorial_smallest", 640, 480, cast(SDL_WindowFlags) 0, &window, &renderer);
    
    // defaults to black window
    
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);  // white screen  

    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
        }
        
        SDL_RenderClear(renderer); // Clear the renderer
            // Add your drawing calls here (e.g., SDL_RenderFillRect())
        SDL_RenderPresent(renderer); // Present the rendered content
    }
}



// getWindowSurface(), blitSurface() and updateWindowSurface() allows you to bypass the use of renderers
// and thus SDL_RenderClear and SDL_RenderPresent.

void tutorial_no_renderer()
{
    SDL_Window* window = null;
    bool running = true;
    
    createWindow("tutorial_no_renderer", 512, 512, cast(SDL_WindowFlags) 0, &window);

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
    
    displaySurfaceProperties(sourceSurface);
    displaySurfaceProperties(windowSurface);
    blitSurface(sourceSurface, null, windowSurface, null);

    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
        }
        updateWindowSurface(window);
    }
}


/+
Different sizes in srcrect and dstrect in SDL3 trigger automatic scaling of the source texture 
to match the destination's size, controlled by the texture's scale mode. 

Scaling: SDL3 will resize the portion of the source texture defined by srcrect to match the 
dimensions of the dstrect. This is done automatically as part of the rendering process.

Scaling Mode: The way this scaling is performed can be controlled by the texture's scale mode. By 
default, it's set to SDL_SCALEMODE_LINEAR (linear filtering), but you can change it to 
SDL_SCALEMODE_NEAREST (nearest pixel sampling) using SDL_SetTextureScaleMode


SDL_ScaleMode determines how (surfaces and)??? textures are scaled when their size doesn't perfectly 
match the destination. It's an enum that defines different scaling algorithms, primarily impacting how 
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

/+
Unlike textures, SDL3 has no automatic scaling when source and destination rectagles are blitted.
thus the sprites will appear shrunken or truncated
+/

void tutorial_surface_no_implicit_scaling()
{
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;
    SDL_Surface* screenSurface = null;  // one example used display as variable name
    SDL_Surface* globeSurface = null;
    SDL_Surface* redSurface = null;
    SDL_Rect     globeRect;
    bool running = true;
    
    int winWidth = 1000; 
    int winHeight = 1000;
    
    //createWindow("tutorial_surface_no_implicit_scaling", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);
    
    createWindowAndRenderer("tutorial_surface_no_implicit_scaling", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    getWindowSurface(window, &screenSurface);
    
    writeln("screenSurface has");
    displaySurfaceProperties(screenSurface);

    loadImageToSurface("./images/globe256x256.png", &globeSurface);
    
    globeRect.w = globeSurface.w;  // original size   scale is 1:1
    globeRect.h = globeSurface.h;

    writeln("globeSurface has");
    displaySurfaceProperties(globeSurface);

    redSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32); // Using a common format

    writeln("redSurface created with SDL_PIXELFORMAT_RGBA32 has");
    displaySurfaceProperties(redSurface);

    uint fillColor = SDL_MapSurfaceRGBA(redSurface, 255, 0, 0, 255);

    SDL_FillSurfaceRect(redSurface, null, fillColor);

    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
           if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
           {
               running = false;
           }
        }
        
        // blitSurfaceScaled(redSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);

        blitSurface(redSurface, null, screenSurface, null);  

        // blitSurfaceScaled(globeSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);

        blitSurface(globeSurface, null, screenSurface, null);  // if used, globeSurface only takes up quadrant of screen
                                                               // because no scaling
                                                               
        SDL_Rect smaller = { 512, 512, 0, 0 };  // note that when destination < source the entire source is still drawn
                                                               
        blitSurface(globeSurface, null, screenSurface, &smaller); 
                                                               
        // Surfaces are on the CPU so it's not optimal for you to use them to draw. Instead it's recommended 
        // to create a Texture, draw with the renderer to it and then convert it back as a Surface if you need.

        
        //createRenderer(window, "MyRenderer", &renderer);  // create rend when create window
        //SDL_Texture *screenTexture =  createTextureFromSurface(renderer, screenSurface); Doesn't create a Streaming Texture
        
        SDL_Texture *screenTexture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 
                                                   screenSurface.w, screenSurface.h);
                                                   
        //copySurfaceToTexture(screenSurface, null, screenTexture, null);
        
        SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255); // set to blue
        
        SDL_RenderRect(renderer, cast(SDL_FRect*) &globeRect);   // draw blue outline of rectangle around globe
        
        // cannot pass argument `& globeRect` of type `SDL_Rect*` to parameter `const(SDL_FRect)* rect`
        //                                                                           Floating Rect
        
        // screenTexture and screenSurface are same size screenTextrue exists so we may draw to it.
        
        copyTextureToSurface(screenTexture, null, screenSurface, null);

        updateWindowSurface(window);
    }
}


// if blitting chunks of different sizes, need blitSurfaceScaled(..., SDL_SCALEMODE_LINEAR) to stretch or shrink suface copies

void tutorial_surface_exlicit_scaling()
{
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;
    SDL_Surface* screenSurface = null;  // one example used display as variable name
    SDL_Surface* globeSurface = null;
    SDL_Surface* redSurface = null;
    SDL_Rect     globeRect;
    bool running = true;
    
    int winWidth = 1000; 
    int winHeight = 1000;
    
    //createWindow("tutorial_surface_exlicit_scaling", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);
    
    createWindowAndRenderer("tutorial_surface_exlicit_scaling", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    getWindowSurface(window, &screenSurface);
    
    writeln("screenSurface has");
    displaySurfaceProperties(screenSurface);

    loadImageToSurface("./images/globe256x256.png", &globeSurface);
    
    globeRect.w = globeSurface.w;  // original size   scale is 1:1
    globeRect.h = globeSurface.h;

    writeln("globeSurface has");
    displaySurfaceProperties(globeSurface);

    redSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32); // Using a common format

    writeln("redSurface created with SDL_PIXELFORMAT_RGBA32 has");
    displaySurfaceProperties(redSurface);

    uint fillColor = SDL_MapSurfaceRGBA(redSurface, 255, 0, 0, 255);

    SDL_FillSurfaceRect(redSurface, null, fillColor);

    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
           if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
           {
               running = false;
           }
        }
        
        blitSurfaceScaled(redSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);

        // blitSurface(redSurface, null, screenSurface, null);  

        blitSurfaceScaled(globeSurface, null, screenSurface, null, SDL_SCALEMODE_LINEAR);

        // blitSurface(globeSurface, null, screenSurface, null);  // if used, globeSurface only takes up quadrant of screen
                                                               // because no scaling
                                                               
        // Surfaces are on the CPU so it's not optimal for you to use them to draw. Instead it's recommended 
        // to create a Texture, draw with the renderer to it and then convert it back as a Surface if you need.

        
        //createRenderer(window, "MyRenderer", &renderer);  // create rend when create window
        //SDL_Texture *screenTexture =  createTextureFromSurface(renderer, screenSurface); Doesn't create a Streaming Texture
        
        SDL_Texture *screenTexture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 
                                                   screenSurface.w, screenSurface.h);
                                                   
        //copySurfaceToTexture(screenSurface, null, screenTexture, null);
        
        SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255); // set to blue
        
        SDL_RenderRect(renderer, cast(SDL_FRect*) &globeRect);   // draw blue outline of rectangle around globe
        
        // cannot pass argument `& globeRect` of type `SDL_Rect*` to parameter `const(SDL_FRect)* rect`
        //                                                                           Floating Rect
        
        // screenTexture and screenSurface are same size screenTextrue exists so we may draw to it.
        
        copyTextureToSurface(screenTexture, null, screenSurface, null);

        updateWindowSurface(window);
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
    bool running = true;
    
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
    bool running = true;
    
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
