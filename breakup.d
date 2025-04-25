


module breakup;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln, write;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes : Location;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;

import std.string : toStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations

struct D2 { int w; int h; }

struct Graphic
{
    SDL_Window   *window;
    D2           win;
    SDL_Renderer *renderer;
    SDL_Texture  *texture;  // created with IMG_LoadTexture(renderer, image.png) or SDL_CreateTextureFromSurface()
    D2           tex;
    SDL_Surface  *surface;
    D2           sur;
}

/+
IMG_LoadTexture requires a renderer because it creates a GPU texture, which needs a rendering 
context to be uploaded to and managed by the graphics card. The renderer provides the interface
between the application and the graphics hardware, ensuring the texture data is correctly stored 
and used for rendering. 

IMG_LoadTexture doesn't just load a simple image; it creates a GPU texture, which is a special
type of memory managed by the graphics card.
Renderer as Context: The renderer provides the necessary context for interacting with the graphics 
card, including the creation and management of textures.

There isn't a hard limit to the number of SDL surfaces you can create
+/

SDL_Surface* LoadImageToSurface(string fileName)
{
    SDL_Surface *surface = IMG_Load(toStringz(fileName));
    if (surface == null) 
    {
        writeln("IMG_Load failed with file: ", fileName);
        exit(-1);
    }
    return surface;
}

SDL_Texture* LoadImageToTexture(SDL_Renderer *renderer, string fileName)
{
    SDL_Texture *texture = IMG_LoadTexture(renderer, toStringz(fileName));
    if (texture == null) 
    {
        writeln("IMG_LoadTexture failed with file: ", fileName);
        exit(-1);
    }
    return texture;
}

void textureProperties(SDL_Texture *texture)
{
    uint format;
    string pixelFormat;
    int w; int h;
    
    SDL_QueryTexture(texture, &format, null, &w, &h);
    writeln("texture width, height = ", w, " X ", h);

    pixelFormat = to!string(SDL_GetPixelFormatName(format));
    writeln("main pixelFormat = ", pixelFormat);
}

D2 getTextureSize(SDL_Texture *texture)
{
    uint format;
    D2 dims;
    
    SDL_QueryTexture(texture, &format, null, &dims.w, &dims.h);
    return dims;
}

void breakup1()
{
    Graphic m1;
    Graphic m2;
    Graphic main;

    m1.win.h = 1000;
    m1.win.w = cast (int)(cast(double) m1.win.h * 0.6294);

    m1.window = SDL_CreateWindow("IGNORE", 
                                 SDL_WINDOWPOS_CENTERED, 
                                 SDL_WINDOWPOS_CENTERED,
                                 m1.win.w, 
                                 m1.win.h, 
                                 SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);

    m1.renderer = SDL_CreateRenderer(m1.window, -1, SDL_RENDERER_ACCELERATED);

    m1.texture = LoadImageToTexture(m1.renderer, "./images/1.png");  // file to texture

    m2 = m1;

    m2.window = SDL_CreateWindow("IGNORE", 
                                 SDL_WINDOWPOS_CENTERED, 
                                 SDL_WINDOWPOS_CENTERED,
                                 m2.win.w, 
                                 m2.win.h, 
                                 SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);

    m2.renderer = SDL_CreateRenderer(m2.window, -1, SDL_RENDERER_ACCELERATED);

    m2.texture = LoadImageToTexture(m2.renderer, "./images/2.png");  // file to texture

    main.win.w = 1000;
    main.win.h = 1000;

    main.window = SDL_CreateWindow("MAIN PNG Viewer", 
                                   SDL_WINDOWPOS_CENTERED, 
                                   SDL_WINDOWPOS_CENTERED,
                                   main.win.w, 
                                   main.win.h, 
                                   SDL_WINDOW_SHOWN);

    main.renderer = SDL_CreateRenderer(main.window, -1, SDL_RENDERER_ACCELERATED);

    main.texture = LoadImageToTexture(main.renderer, "./images/2.png");
    
/+
    main.texture = SDL_CreateTexture(main.renderer,
                                     SDL_PIXELFORMAT_ARGB8888,
                                     SDL_TEXTUREACCESS_STATIC, 
                                     main.win.w, main.win.h); +/

    //SDL_SetRenderTarget(main.renderer, largeTexture);  // specify that you want to draw to the target texture instead of the screen.

    textureProperties(m1.texture);
    textureProperties(m2.texture);
    textureProperties(main.texture);
    
    //D2 d2 = getTextureSize(m1.texture);
    //int w = d2.w * 2;
    //int h = d2.h * 2;
    //writeln("w x h = ", w, " ", h);

    
    //SDL_Surface* hugeSurface = SDL_CreateRGBSurface(0, w, h, 32, 0, 0, 0, 0);

    //SDL_SetRenderDrawColor(main.renderer, 0, 0, 0xFF, SDL_ALPHA_OPAQUE);
    //SDL_RenderClear(main.renderer);


    SDL_Rect destRect1 = {0, 0, 500, 500 /+main.win.w/2, main.win.h+/}; // Example destination rectangle
    
    writeln("destRect1 = ", destRect1);
    
    SDL_RenderCopy(m1.renderer, m1.texture, null, null);

    SDL_Rect destRect2 = {main.win.w/2, 0, main.win.w, main.win.h}; // Example destination rectangle
    
    //writeln("destRec2 = ", destRect2);
    
    //SDL_RenderCopy(main.renderer, m2.texture, null, &destRect2);

    //SDL_RenderPresent(main.renderer);

    SDL_RenderPresent(main.renderer);
    SDL_RenderPresent(m1.renderer);
    
    //SDL_SetRenderTarget(main.renderer, null); // set the render target back to the screen 
    
    //SDL_RenderCopy(main.renderer, largeTexture, null, null);

    //writeAndPause("breakup.d line 84");

    bool running = true;
    SDL_Event e;
    while (running) 
    {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT || (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)) {
                running = false;
            }
        }
        
        /+
        In SDL, you can't directly "create a surface from a texture" in the way you might imagine. 
        Instead, you create a texture from a surface, or you can render a texture to a surface 
        (effectively creating a new surface with the texture data). SDL_CreateTextureFromSurface() 
        is used to create a texture from a surface, and SDL_RenderReadPixels() can be used to read 
        the contents of a texture into a surface. 
        +/
        
        /+
        int SDL_RenderCopyEx(SDL_Renderer * renderer,
                   SDL_Texture * texture,
                   const SDL_Rect * srcrect,
                   const SDL_Rect * dstrect,
                   const double angle,
                   const SDL_Point *center,
                   const SDL_RendererFlip flip);
        +/

        // Update screen
        
    }
}

/+
1. Create the destination texture:

Create a new texture with the SDL_TEXTUREACCESS_TARGET access flag to allow it to be used as a render target.

 
2. Set the destination texture as the render target:

Use SDL_SetRenderTarget(renderer, target_texture) to specify that you want to draw to the target_texture instead of the screen. 

3. Copy the source texture:

Use SDL_RenderCopy(renderer, source_texture, NULL, NULL) to draw the source_texture onto the target_texture. 
You can use a SDL_Rect if you want to copy a portion of the source texture. 

4. Reset the render target:

Use SDL_SetRenderTarget(renderer, NULL) to set the render target back to the screen (or the default target). 

5. Draw the target texture:

You can now draw the target_texture onto the screen or another texture as needed. 
+/

/+

// Create a render target texture
SDL_Texture *target_texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, width, height);

// Set the target texture as the render target
SDL_SetRenderTarget(renderer, target_texture);

// Render your content to the texture
SDL_SetDrawColor(renderer, 0x00, 0xFF, 0x00, 0xFF); // Green
SDL_RenderClear(renderer);
// ... (draw your shapes/images) ...

// Reset the target to the screen
SDL_SetRenderTarget(renderer, NULL);

// Now you can render the target texture onto the screen or other places
SDL_RenderCopy(renderer, target_texture, NULL, NULL);

// ... (SDL cleanup) ...

+/

/+
  window = SDL_CreateWindow("Example", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_SHOWN);


  renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);

  // Create a texture (must be of type SDL_TEXTUREACCESS_TARGET for rendering)
  texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 320, 240);

  // 1. Render to the texture
  SDL_SetRenderTarget(renderer, texture); // Set texture as target
  SDL_SetRenderDrawColor(renderer, 0xFF, 0x00, 0x00, 0xFF); // Red
  SDL_RenderClear(renderer); // Clear the texture
  SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0xFF, 0xFF); // Blue
  SDL_RenderDrawLine(renderer, 0, 0, 320, 240);  // Draw a diagonal line
  SDL_RenderSetViewport(renderer, NULL);

  // 2. Reset target back to the window
  SDL_SetRenderTarget(renderer, NULL); // Set window as target

  // 3. Render the texture to the window
  SDL_RenderClear(renderer); // Clear the window
  SDL_SetRenderDrawColor(renderer, 0x00, 0xFF, 0x00, 0xFF);  // Green
  SDL_Rect dstrect = { 100, 100, 320, 240 }; // Destination rectangle
  SDL_RenderCopy(renderer, texture, NULL, &dstrect); // Copy the texture to the window

  // Present the window
  SDL_RenderPresent(renderer);

+/


/+
To copy pixels between SDL textures and surfaces, you can use 
SDL_RenderReadPixels() to read from a texture into a surface
SDL_UpdateTexture() to copy from a surface to a texture. 
SDL_RenderCopy() to copy between textures if one of the textures is a render target. 
+/

/+
One option for displaying extremely large images is to split it up into multiple textures and render each. 


To draw multiple SDL2 textures onto the same screen, you can render each texture individually within a 
loop, then present the rendered image using SDL_RenderPresent. This approach allows you to position and 
combine textures as needed. 


while (running) 
{
    // Clear the renderer (optional, but good practice)
    
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);

    // Render texture1
    SDL_Rect destRect1 = {x1, y1, width1, height1}; // Example destination rectangle
    SDL_RenderCopy(renderer, texture1, NULL, &destRect1);

    // Render texture2
    SDL_Rect destRect2 = {x2, y2, width2, height2}; // Example destination rectangle
    SDL_RenderCopy(renderer, texture2, NULL, &destRect2);

    // ... render more textures if needed

    // Present the rendered image
    SDL_RenderPresent(renderer);
}

+/

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_png>\n", argv[0]);
        return 1;
    }

    // Initialize SDL and SDL_image
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }
    if (!(IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG)) {
        fprintf(stderr, "IMG_Init failed: %s\n", IMG_GetError());
        SDL_Quit();
        return 1;
    }

    // Load the input PNG
    SDL_Surface *image = IMG_Load(argv[1]);
    if (!image) {
        fprintf(stderr, "IMG_Load failed: %s\n", IMG_GetError());
        IMG_Quit();
        SDL_Quit();
        return 1;
    }

    int width = image->w;
    int height = image->h;
    int half_width = width / 2;
    int half_height = height / 2;

    if (width % 2 != 0 || height % 2 != 0) {
        fprintf(stderr, "Image dimensions must be divisible by 2\n");
        SDL_FreeSurface(image);
        IMG_Quit();
        SDL_Quit();
        return 1;
    }

    // Define the four quadrants
    SDL_Rect quadrants[4] = {
        {0, 0, half_width, half_height},                  // Top-left
        {half_width, 0, half_width, half_height},         // Top-right
        {0, half_height, half_width, half_height},        // Bottom-left
        {half_width, half_height, half_width, half_height} // Bottom-right
    };

    // Create and save each quadrant
    for (int i = 0; i < 4; i++) {
        // Create a new surface for the quadrant
        SDL_Surface *quad_surface = SDL_CreateRGBSurfaceWithFormat(0, half_width, half_height, 32, image->format->format);
        if (!quad_surface) {
            fprintf(stderr, "SDL_CreateRGBSurface failed: %s\n", SDL_GetError());
            SDL_FreeSurface(image);
            IMG_Quit();
            SDL_Quit();
            return 1;
        }

        // Copy the quadrant to the new surface
        if (SDL_BlitSurface(image, &quadrants[i], quad_surface, NULL) < 0) {
            fprintf(stderr, "SDL_BlitSurface failed: %s\n", SDL_GetError());
            SDL_FreeSurface(quad_surface);
            SDL_FreeSurface(image);
            IMG_Quit();
            SDL_Quit();
            return 1;
        }

        // Generate output filename
        char filename[32];
        snprintf(filename, sizeof(filename), "quadrant_%d.png", i + 1);

        // Save the quadrant as a PNG
        if (IMG_SavePNG(quad_surface, filename) < 0) {
            fprintf(stderr, "IMG_SavePNG failed: %s\n", IMG_GetError());
            SDL_FreeSurface(quad_surface);
            SDL_FreeSurface(image);
            IMG_Quit();
            SDL_Quit();
            return 1;
        }

        SDL_FreeSurface(quad_surface);
    }

    // Clean up
    SDL_FreeSurface(image);
    IMG_Quit();
    SDL_Quit();
    printf("Successfully split %s into 4 quadrants\n", argv[1]);
    return 0;
}


