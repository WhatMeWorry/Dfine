


module breakup;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes : Location;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;

import std.string : toStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations

struct D2 { int w; int h; }
struct F2 { float w; float h; }

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


void assembleQuadFilesItoOnePNGfile()
{
    SDL_Surface *image;

    image = LoadImageToSurface("./images/CNA_Maps_PNG/quadA0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image.w, " x ", image.h);

    int width = image.w;
    int height = image.h;

    if (isOdd(width*2) || isOdd(height*2)) 
    {
        writeln("Image dimensions must be divisible by 2");
    }

    SDL_Surface *combined = SDL_CreateSurface(width*2, height*2, image.format);
    if (combined == null)
    {
        writefln("SDL_CreateSurface failed: %s", SDL_GetError());  exit(-1);
    }

    SDL_Rect[4] quads =
    [
        SDL_Rect(0,     0,      width, height),  // top left
        SDL_Rect(width, 0,      width, height),  // top right
        SDL_Rect(0,     height, width, height),  // bottom left
        SDL_Rect(width, height, width, height)   // bottom right
    ];

    if (SDL_BlitSurface(image, null, combined, &quads[0]) < 0) {
        writefln("SDL_BlitSurface failed: %s", SDL_GetError());  exit(-1);
    }
    
    image = LoadImageToSurface("./images/CNA_Maps_PNG/quadA1.png");

    if (SDL_BlitSurface(image, null, combined, &quads[1]) < 0) {
        writefln("SDL_BlitSurface failed: %s", SDL_GetError());  exit(-1);
    }
    
    image = LoadImageToSurface("./images/CNA_Maps_PNG/quadA2.png");

    if (SDL_BlitSurface(image, null, combined, &quads[2]) < 0) {
        writefln("SDL_BlitSurface failed: %s", SDL_GetError());  exit(-1);
    }
    
    image = LoadImageToSurface("./images/CNA_Maps_PNG/quadA3.png");

    if (SDL_BlitSurface(image, null, combined, &quads[3]) < 0) {
        writefln("SDL_BlitSurface failed: %s", SDL_GetError());  exit(-1);
    }
    
    
    
    //if (SDL_BlitSurface(combined, NULL, window_surface, &dest_rect) < 0) {
    //    SDL_Log("Failed to blit surface: %s", SDL_GetError());  exit(-1);
    //}

    
}







void textureProperties(SDL_Texture *texture)
{
    //uint format;
    string pixelFormat;
    float w; float h;

    if (SDL_GetTextureSize(texture, &w, &h) == false)
    {
        writeln("SDL_GetTextureSize failed");
        exit(-1);
    }

    writeln("texture width, height = ", w, " X ", h);
    
    // This SDL_PropertiesID represents a container of properties associated with that texture. 
    
    SDL_PropertiesID texProps = SDL_GetTextureProperties(texture);
    if (texProps == 0) 
    {
        writeln("SDL_GetTextureProperties failed");
        exit(-1);
    }

    // Use SDL_GetNumberProperty, SDL_GetStringProperty, etc., to retrieve specific 
    // properties from the returned SDL_PropertiesID
        
    // Get the texture's pixel format
    
    long format = SDL_GetNumberProperty(texProps, SDL_PROP_TEXTURE_FORMAT_NUMBER, -1);
    if (format == -1) 
    {
        writeln("SDL_GetNumberProperty failed");  exit(-1);
    } 
    
    writefln("Texture format: %d", format);

    // Optional: Convert format to a human-readable string
    
    const char *formatName = SDL_GetPixelFormatName(cast (SDL_PixelFormat) format);
    if (formatName) 
    {
        writefln("Texture format name: %s", formatName);
    } 
    else 
    {
        writefln("Unknown pixel format\n");  exit(-1);
    }


}


F2 getTextureSize(SDL_Texture *texture)
{
    //uint format;
    F2 dims;
    
    //SDL_QueryTexture(texture, &format, null, &dims.w, &dims.h);
    
    if (SDL_GetTextureSize(texture, &dims.w, &dims.h) == false)
    {
        writeln("SDL_GetTextureSize failed");
        exit(-1);
    }

    return dims;
}

void trimFileIfPixelsAreNotEven()
{
    SDL_Surface *image = LoadImageToSurface("./images/quadA0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image.w, " x ", image.h);

    SDL_Rect evenRect;
    evenRect.x = 0;
    evenRect.y = 0;
    evenRect.w = image.w;
    evenRect.h = image.h;

    if (image.w.isOdd)
    {
        evenRect.w--;   // make width even
    }
    if (image.h.isOdd)
    {
        evenRect.h--;   // make height even
    }

    writeln("evenRect = ", evenRect);

    SDL_Surface *evenSurface = SDL_CreateSurface(evenRect.w, evenRect.h, image.format);
    
                   //   source srcRect    destination  dstRect
    if (SDL_BlitSurface(image, &evenRect, evenSurface, &evenRect) < 0) {
        writefln("SDL_BlitSurface failed: %s", SDL_GetError());
    }

    string fileName = "./images/" ~ "even5" ~ ".png";

    writeln("fileName = ", fileName);
        
    if (IMG_SavePNG(evenSurface, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }

}


void hugePNGfileIntoQuadPNGfiles()
{
    SDL_Surface *bigImage = LoadImageToSurface("./images/quadA0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(bigImage.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("bigImage.w x h = ", bigImage.w, " x ", bigImage.h);

    int width = bigImage.w;
    int height = bigImage.h;
    int halfWidth = width / 2;
    int halfHeight = height / 2;

    if (width % 2 != 0 || height % 2 != 0) 
    {
        writeln("Image dimensions must be divisible by 2");
    }

    SDL_Rect[4] quads =
    [
        SDL_Rect(0,         0,          halfWidth, halfHeight),  // top left
        SDL_Rect(halfWidth, 0,          halfWidth, halfHeight),  // top right
        SDL_Rect(0,         halfHeight, halfWidth, halfHeight),  // bottom left
        SDL_Rect(halfWidth, halfHeight, halfWidth, halfHeight)   // bottom right
    ];

    // Create and save each quadrant foreach (int i; 0 .. 10) {
    foreach (int i; 0..4)
    {
        SDL_Surface *quadSurface = SDL_CreateSurface(halfWidth, halfHeight, bigImage.format);
        if (!quadSurface)
        {
            writefln("SDL_CreateRGBSurface failed: %s", SDL_GetError());
            exit(-1);
        }

        // Copy the quadrant to the new surface
                       //   source    srcRect    destination  dstRect
        if (SDL_BlitSurface(bigImage, &quads[i], quadSurface, null) < 0)
        {
            writefln("SDL_BlitSurface failed: %s", SDL_GetError());
        }

        string fileName = "./images/" ~ "quadE" ~ to!string(i) ~ ".png";

        writeln("fileName = ", fileName);
        
        // Save the quadrant as a PNG
        
        if (IMG_SavePNG(quadSurface, toStringz(fileName)) < 0)
        {
            writefln("IMG_SavePNG failed: %s", SDL_GetError());
        }
    }

}







void breakup1()
{
    Graphic m1;
    Graphic m2;
    Graphic main;

    m1.win.h = 1000;
    m1.win.w = cast (int)(cast(double) m1.win.h * 0.6294);

    m1.window = SDL_CreateWindow("IGNORE", 
                                 m1.win.w, 
                                 m1.win.h, 
                                 SDL_WINDOW_RESIZABLE);

    m1.renderer = SDL_CreateRenderer(m1.window, "Renderer 1");

    m1.texture = LoadImageToTexture(m1.renderer, "./images/1.png");  // file to texture

    m2 = m1;

    m2.window = SDL_CreateWindow("IGNORE", 
                                 m2.win.w, 
                                 m2.win.h, 
                                 SDL_WINDOW_RESIZABLE);

    m2.renderer = SDL_CreateRenderer(m2.window, "Renderer 2");

    m2.texture = LoadImageToTexture(m2.renderer, "./images/2.png");  // file to texture

    main.win.w = 1000;
    main.win.h = 1000;

    main.window = SDL_CreateWindow("MAIN PNG Viewer", 
                                   main.win.w, 
                                   main.win.h, 
                                   SDL_WINDOW_RESIZABLE);

    main.renderer = SDL_CreateRenderer(main.window, "Renderer 3");

    main.texture = LoadImageToTexture(main.renderer, "./images/2.png");
    
/+
    main.texture = SDL_CreateTexture(main.renderer,
                                     SDL_PIXELFORMAT_ARGB8888,
                                     SDL_TEXTUREACCESS_STATIC, 
                                     main.win.w, main.win.h); 
+/

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
    
    
    SDL_RenderTexture(m1.renderer, m1.texture, null, null);

    SDL_Rect destRect2 = {main.win.w/2, 0, main.win.w, main.win.h}; // Example destination rectangle


    SDL_RenderPresent(main.renderer);
    SDL_RenderPresent(m1.renderer);


    //writeAndPause("breakup.d line 84");

    bool running = true;
    SDL_Event e;
    while (running) 
    {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_EVENT_QUIT || (e.type == SDL_EVENT_KEY_DOWN && e.key.key == SDLK_ESCAPE)) {
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

/+
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <stdio.h>

int main(int argc, char *argv[]) {

    // Load the input PNG
    SDL_Surface *image = IMG_Load(argv[1]);
    if (!image) {
        fprintf(stderr, "IMG_Load failed: %s\n", IMG_GetError());
    }

    int width = image->w;
    int height = image->h;
    int half_width = width / 2;
    int half_height = height / 2;

    if (width % 2 != 0 || height % 2 != 0) {
        fprintf(stderr, "Image dimensions must be divisible by 2\n");
        SDL_FreeSurface(image);
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
        }

        // Copy the quadrant to the new surface
        if (SDL_BlitSurface(image, &quadrants[i], quad_surface, NULL) < 0) {
            fprintf(stderr, "SDL_BlitSurface failed: %s\n", SDL_GetError());
        }

        // Generate output filename
        char filename[32];
        snprintf(filename, sizeof(filename), "quadrant_%d.png", i + 1);

        // Save the quadrant as a PNG
        if (IMG_SavePNG(quad_surface, filename) < 0) {
            fprintf(stderr, "IMG_SavePNG failed: %s\n", IMG_GetError());
        }

        SDL_FreeSurface(quad_surface);
    }
}
+/

/+
    // Create a properties group
    SDL_PropertiesID props = SDL_CreateProperties();
    if (props == 0) {

    }

    // Set window properties
    SDL_SetStringProperty(props, SDL_PROP_WINDOW_CREATE_TITLE_STRING, "My SDL3 Window");
    SDL_SetBooleanProperty(props, SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN, true);
    SDL_SetNumberProperty(props, SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER, 800);
    SDL_SetNumberProperty(props, SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER, 600);

    // Create window with properties
    SDL_Window* window = SDL_CreateWindowWithProperties(props);
    if (!window) {
 
    }

+/

/+
    SDL_PropertiesID props = SDL_CreateProperties();
    if (props == 0) {

    }

    // Set a string property for the window title
    SDL_SetStringProperty(props, SDL_PROP_WINDOW_CREATE_TITLE_STRING, "My SDL Window");

    // Create a window with the properties
    SDL_Window *window = SDL_CreateWindowWithProperties(props);
    if (!window) {

    }

    // Retrieve the window title using SDL_GetStringProperty
    const char *title = SDL_GetStringProperty(props, SDL_PROP_WINDOW_CREATE_TITLE_STRING, "Default Title");
    SDL_Log("Window title: %s", title);

+/

/+
    // Create a texture
    SDL_Texture *texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, 
                                           SDL_TEXTUREACCESS_STATIC, 256, 256);
    if (!texture) {

    }

    // Get texture properties
    SDL_PropertiesID props = SDL_GetTextureProperties(texture);
    
    if (props == 0) {
        printf("Failed to get texture properties: %s\n", SDL_GetError());
    } 
    else 
    {
        Uint32 format = SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, 0);
        
        // Convert format to human-readable string
        const char *format_name = SDL_GetPixelFormatName(format);
        printf("Texture pixel format: %s\n", format_name);
    }
+/

/+
    
    int format = SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, -1);
    if (format == -1) {
        printf("Failed to get texture format\n");
    } else {
        printf("Texture format: %d\n", format);

        // Optional: Convert format to a human-readable string
        const char *format_name = SDL_GetPixelFormatName((SDL_PixelFormat)format);
        if (format_name) {
            printf("Texture format name: %s\n", format_name);
        } else {
            printf("Unknown pixel format\n");
        }
    }
+/








