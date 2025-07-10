
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


void copying_textures_to_surface()
{
    SDL_Window  *window = null;
    SDL_Renderer *renderer = null;

    createWindowAndRenderer("copying_surface_to_surface", 500, 500, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_Surface *windowSurface = getWindowSurface(window);  // creates a surface if it does not already exist

    SDL_Texture *texture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STREAMING);
    // SDL_Texture *texture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_TARGET);
    // SDL_Texture *texture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STATIC);

    displayTextureProperties(texture);

    SDL_Surface* surface = convertTextureToSurface(texture);
    
    displaySurfaceProperties(surface);
    bool running = true;
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

        copySurfaceToSurface(surface, null, windowSurface, null);

        updateWindowSurface(window);
    }
    SDL_Quit();
}





// tests copySurfaceToSurface() to update a surface attached to the current window. Additionally,
// the arrow keys my be used to move the viewing window to different parts of the larger image.

void copying_surface_to_surface()
{
    SDL_Window  *window = null;
    SDL_Renderer *renderer = null;

    createWindowAndRenderer("copying_surface_to_surface", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_Surface *windowSurface = getWindowSurface(window);  // creates a surface if it does not already exist

    SDL_Surface *surface = loadImageToSurface("./images/Wach1.png");

    SDL_Rect boundsRect = { 0, 0, surface.w, surface.h };   // outer bounds

    SDL_Rect surRect = { 0, 0, windowSurface.w, windowSurface.h };  // inner bounds

    bool running = true;
    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
            if (event.key.key == SDLK_UP) 
            {
                surRect.y -= 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
            if (event.key.key == SDLK_DOWN) 
            {
                surRect.y += 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
            if (event.key.key == SDLK_LEFT) 
            {
                surRect.x -= 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
            if (event.key.key == SDLK_RIGHT) 
            {
                surRect.x += 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
        }

        copySurfaceToSurface(surface, &surRect, windowSurface, null);

        updateWindowSurface(window);
    }
    SDL_Quit();
}



void two_windows_and_surfaces()
{
    SDL_Window *windowMain = createWindow("main", 1000, 1000, cast(SDL_WindowFlags) 0);
    
    SDL_Window *windowMini = createWindow("mini", 750, 750, cast(SDL_WindowFlags) 0);

    SDL_Surface *surfaceMain = getWindowSurface(windowMain);  // creates a surface if it does not already exist

    SDL_Surface *surfaceMini = getWindowSurface(windowMini);  // creates a surface if it does not already exist

    SDL_Surface *surface = loadImageToSurface("./images/Wach2.png");
    displaySurfaceProperties(surface);

    SDL_Rect boundsRect = { 0, 0, surface.w, surface.h };  // outer boundaries

    SDL_Rect surRect = { 0, 0, surfaceMain.w, surfaceMain.h };

    bool running = true;
    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
            if (event.key.key == SDLK_UP) 
            {
                surRect.y -= 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
            if (event.key.key == SDLK_DOWN) 
            {
                surRect.y += 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
            if (event.key.key == SDLK_LEFT) 
            {
                surRect.x -= 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
            if (event.key.key == SDLK_RIGHT) 
            {
                surRect.x += 50;
                keepRectWithinBiggerRectArrowMovement(&surRect, &boundsRect);
            }
        }

        copySurfaceToSurface(surface, &surRect, surfaceMain, null);
        
        updateWindowSurface(windowMain);
        
        //copySurfaceToSurface(surface, &boundsRect, surfaceMini, null);
        
        blitSurfaceScaled(surface, null, surfaceMini, null, SDL_SCALEMODE_LINEAR);
        
        updateWindowSurface(windowMini);
    }
    SDL_Quit();
}



// This function tests the changeTextureAccess() function.  The important lesson of this function is that
// the SDL_RenderTexture() will only render a Streaming texture.  Target and Static results in a black screen

void change_texture_access()
{
    SDL_Texture *texture;
    SDL_Window  *window;
    SDL_Renderer *renderer = null;

    createWindowAndRenderer("change_texture_access", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_Texture *srcStatic = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STATIC, 256, 256);
    SDL_Texture *srcTarget = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 256, 256);
    SDL_Texture *srcStream = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 256, 256);

    SDL_Texture *dstStatic = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STATIC, 256, 256);
    SDL_Texture *dstTarget = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 256, 256);
    SDL_Texture *dstStream = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 256, 256);

    copyTextureToTexture(srcStatic, null, dstStatic, null);
    
    copyTextureToTexture(srcStatic, null, dstTarget, null);
    
    copyTextureToTexture(srcStatic, null, dstStream, null);
    
    copyTextureToTexture(srcTarget, null, dstStatic, null);
    
    copyTextureToTexture(srcTarget, null, dstTarget, null);
    
    copyTextureToTexture(srcTarget, null, dstStream, null);
    
    copyTextureToTexture(srcStream, null, dstStatic, null);
    
    copyTextureToTexture(srcStream, null, dstTarget, null);
    
    copyTextureToTexture(srcStream, null, dstStream, null);

/+
    SDL_PIXELFORMAT_RGBA8888 is more portable because its layout is consistent across all platforms.
    SDL_PIXELFORMAT_RGBA32 may require extra care when handling pixel data across platforms with different endianness.
    +/
    /+
    SDL_Texture *texStream = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STREAMING);
    displayTextureAccess(texStream);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texStream, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(2000);
    
    
    SDL_Texture *texStatic = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STATIC);
    displayTextureAccess(texStatic);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texStatic, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(2000);
    
    
    SDL_Texture *texTarget = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_TARGET);
    displayTextureAccess(texTarget);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texTarget, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(2000);
+/

    texture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_TARGET);

    displayTextureAccess(texture);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(2000);


    texture = changeTextureAccess(texture, SDL_TEXTUREACCESS_STATIC);

    displayTextureAccess(texture);

    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(2000);
    
    texture = changeTextureAccess(texture, SDL_TEXTUREACCESS_TARGET);
    
    displayTextureAccess(texture);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(2000);

exit(-1);

    texture = changeTextureAccess(texture, SDL_TEXTUREACCESS_STATIC);

    displayTextureAccess(texture);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(3000);
    
   
    
    texture = changeTextureAccess(texture, SDL_TEXTUREACCESS_STREAMING);
    
    displayTextureProperties(texture);
    //displayTextureAccess(texture);
    
    SDL_RenderClear(renderer); // Clear the renderer
    SDL_RenderTexture(renderer, texture, null, null); // loading the image (above) is not rendering
    SDL_RenderPresent(renderer); // Present the rendered content
    SDL_Delay(3000);
    
    
/+
    SDL_Texture *staticTexture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STATIC, 256, 256);

    createSurface(256, 256, SDL_PIXELFORMAT_RGBA8888, &surface);

    SDL_Texture *targetTexture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 256, 256);

    copyTextureToTexture(staticTexture, null, targetTexture, null);

    displayTextureProperties(staticTexture);
    displayTextureProperties(targetTexture);
+/
}



void smallest_renderer_01()
{
    SDL_Window   *window = null;
    SDL_Renderer *renderer = null;

    createWindowAndRenderer("smallest 01", 640, 480, cast(SDL_WindowFlags) 0, &window, &renderer);

    bool running = true;
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
        
        SDL_RenderClear(renderer); // defaults to black window
            // Add your drawing calls here (e.g., SDL_RenderFillRect())
        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();
}


void smallest_texture_01a()
{
    SDL_Window   *window = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture = null;
    bool running = true;

    createWindowAndRenderer("smallest_texture_01a", 640, 480, cast(SDL_WindowFlags) 0, &window, &renderer);
    
    texture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STREAMING);
    
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
        
        SDL_RenderTexture(renderer, texture, null, null); // loading the image (above) is not rendering
            
        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();
}


void smallest_texture_with_rect()
{
    SDL_Window   *window = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture = null;

    createWindowAndRenderer("smallest_texture_with_rect", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    texture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STREAMING);

    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);  // white screen  

    bool running = true;
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

        SDL_RenderTexture(renderer, texture, null, null);  // FIRST DRAW THE IMAGE
        
        SDL_FRect rect = { 50, 50, 400, 400 };             
        SDL_SetRenderTarget(renderer, texture);
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);  // red
        
        SDL_RenderFillRect(renderer, &rect);               // SECOND DRAW THE RECTANGLE
        
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);  // white
        SDL_SetRenderTarget(renderer, null);  // set render target back to the default (window)

        
        SDL_RenderPresent(renderer); // Present the rendered content of IMAGE and RECTANGLE

    }
    SDL_Quit();
}




void smallest_texture_01b()
{
    SDL_Window   *window = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture = null;
    bool running = true;

    createWindowAndRenderer("smallest_texture_01b", 640, 480, cast(SDL_WindowFlags) 0, &window, &renderer);

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
        
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);  // white screen  
        SDL_RenderClear(renderer); // Clear the renderer
        
        SDL_FRect rect = {100.0f, 100.0f, 200.0f, 150.0f}; // x, y, width, height
        SDL_FRect rect1 = {200.0f, 200.0f, 200.0f, 150.0f};
        
        SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255); // green

        SDL_RenderFillRect(renderer, &rect); // Draw the filled rectangle
        
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255); // red
        
        SDL_RenderFillRect(renderer, &rect1); // Draw the filled rectangle
        
        SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255); // blue
        
        SDL_RenderLine(renderer, 0, 0, 640, 480);
            
        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();
}

/+
In SDL3, a window does not inherently have a surface. While SDL3 provides the ability to associate a surface 
with a window (using SDL_GetWindowSurface or SDL_CreateWindowSurface), it's not a default or automatic pairing. 
A window can be created without a surface, and the surface, if needed, is explicitly created and managed separately. 

SDL3 windows are distinct objects that represent a window on the screen. Surfaces, on the other hand, are areas of 
memory that can be drawn to. 

SDL_GetWindowSurface: This function retrieves a surface associated with a window, creating one if it doesn't already exist. 
SDL_CreateWindowSurface: This function explicitly creates a surface for a window. 
+/

// getWindowSurface(), blitSurface() and updateWindowSurface() allows you to bypass the use of renderers
// and thus SDL_RenderClear and SDL_RenderPresent.

void no_renderer_02()
{
    SDL_Window *window = createWindow("no_renderer_02", 512, 512, cast(SDL_WindowFlags) 0);

    SDL_Surface *windowSurface = getWindowSurface(window);  // creates a surface if it does not already exist

    SDL_Surface *sourceSurface = loadImageToSurface("./images/earth1024x1024.png");

    displaySurfaceProperties(sourceSurface);
    displaySurfaceProperties(windowSurface);

    copySurfaceToSurface(sourceSurface, null, windowSurface, null);  // performs blit

    bool running = true;
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
    SDL_Quit();
}



/+
Unlike textures, SDL3 surfaces have no automatic scaling when source and destination rectagles of 
different sizes are blitted. Thus the sprites will are not?? shrunken or expanded?? truncated??
+/

void surface_no_implicit_scaling_03()
{
    SDL_Window   *window = null;
    SDL_Surface  *screenSurface = null;
    SDL_Surface  *globeSurface = null;
    SDL_Surface  *solidColorSurface = null;
    SDL_Rect globeRect;
    bool running = true;
    
    int winWidth = 900; 
    int winHeight = 900;
    
    createWindow("surface_no_implicit_scaling_03", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);

    getWindowSurface(window, &screenSurface);

    loadImageToSurface("./images/globe256x256.png", &globeSurface);

    // maybe make function called fill a solid surface with color?
    solidColorSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32); // Using a common format
    uint fillColor = SDL_MapSurfaceRGBA(solidColorSurface, 204, 204, 255, 255);
    SDL_FillSurfaceRect(solidColorSurface, null, fillColor);

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

        copySurfaceToSurface(solidColorSurface, null, screenSurface, null);
        
        SDL_Rect same = { 0, 0, globeSurface.w, globeSurface.h };
        
        copySurfaceToSurface(globeSurface, null, screenSurface, &same);

        SDL_Rect larger = { 256, 256, globeSurface.w * 2, globeSurface.h * 2 };
        
        copySurfaceToSurface(globeSurface, null, screenSurface, &larger);

        SDL_Rect smaller = { 512, 512, globeSurface.w / 2, globeSurface.h / 2 };  // note that when destination < source the entire source is still drawn

        copySurfaceToSurface(globeSurface, null, screenSurface, &smaller);

        updateWindowSurface(window);
    }
    SDL_Quit();
}








// use blitSurfaceScaled(..., SDL_SCALEMODE_LINEAR) to stretch or shrink suface copies

void surface_explicit_scaling_04()
{
    SDL_Window   *window = null;
    SDL_Surface  *screenSurface = null;
    SDL_Surface  *globeSurface = null;
    SDL_Surface  *solidColorSurface = null;
    SDL_Rect globeRect;
    bool running = true;
    
    int winWidth = 900; 
    int winHeight = 900;
    
    createWindow("surface_explicit_scaling_04", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window);

    getWindowSurface(window, &screenSurface);

    loadImageToSurface("./images/globe256x256.png", &globeSurface);

    // maybe make function called fill a solid surface with color?
    solidColorSurface = SDL_CreateSurface(winWidth, winHeight, SDL_PIXELFORMAT_RGBA32); // Using a common format
    uint fillColor = SDL_MapSurfaceRGBA(solidColorSurface, 204, 204, 255, 255);
    SDL_FillSurfaceRect(solidColorSurface, null, fillColor);

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

        copySurfaceToSurface(solidColorSurface, null, screenSurface, null);
        
        SDL_Rect same = { 0, 0, globeSurface.w, globeSurface.h };

        blitSurfaceScaled(globeSurface, null, screenSurface, &same, SDL_SCALEMODE_LINEAR);

        SDL_Rect smaller = { 256, 256, globeSurface.w / 2, globeSurface.h / 2 };

        blitSurfaceScaled(globeSurface, null, screenSurface, &smaller, SDL_SCALEMODE_LINEAR);

        SDL_Rect larger = { 512, 512, globeSurface.w * 2, globeSurface.h * 2 };

        blitSurfaceScaled(globeSurface, null, screenSurface, &larger, SDL_SCALEMODE_LINEAR); 

        updateWindowSurface(window);
    }
    SDL_Quit();
}






/+
Different sizes in srcRect and dstRect in SDL3 trigger automatic scaling of the source texture 
to match the destination's size, controlled by the texture's scale mode. 

Scaling: SDL3 will resize the portion of the source texture defined by srcRect to match the 
dimensions of the dstRect. This is done automatically as part of the rendering process.

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

void texture_implicit_scaling_05()
{
    SDL_Window   *window = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *screenTexture = null;
    SDL_Surface  *globeSurface = null;
    SDL_Texture  *globeTexture = null;
    SDL_Surface  *blueSurface = null;
    SDL_Rect     globeRect;
    bool running = true;
    
    int winWidth = 1000; 
    int winHeight = 1000;
    
    createWindowAndRenderer("texture_implicit_scaling_05", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    globeTexture = loadImageToTextureWithAccess(renderer, "./images/globe256x256.png", SDL_TEXTUREACCESS_STREAMING);

    // maybe make this a function
    SDL_SetRenderTarget(renderer, screenTexture);  // Set the render target to the texture
    SDL_SetRenderDrawColor(renderer, 119, 252, 3, 255); // Set the color you want to paint with
    SDL_RenderFillRect(renderer, null);  // Fill the entire texture with the color
    SDL_SetRenderTarget(renderer, null);  // Reset the render target to the window

    SDL_Texture *duplicateTexture = createTextureFromTexture(globeTexture);

    writeln("globeTexture --------------------------");
    displayTextureProperties(globeTexture);

    writeln("duplicateTexture --------------------------");
    displayTextureProperties(duplicateTexture);

    copyTextureToTexture(globeTexture, null, duplicateTexture, null);
    
    SDL_Renderer *rend1 = getRendererFromTexture(globeTexture);
    SDL_Renderer *rend2 = getRendererFromTexture(duplicateTexture);
    
    writeln("rend1 = ", rend1);
    writeln("rend2 = ", rend2);

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

        SDL_FRect rect = {0,0,256,256};

        SDL_RenderClear(renderer); // Clear the renderer
        
            SDL_RenderTexture(renderer, duplicateTexture, null, null);   
            SDL_RenderTexture(renderer, globeTexture, null, &rect);
            
        SDL_RenderPresent(renderer); // Present the rendered content
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
/+
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
+/



/+
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
+/