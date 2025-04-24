


module breakup;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln, write;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes : Location;
import a_star.spot : writeAndPause;

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

    
void breakup1()
{
    Graphic mini;
    Graphic main;

    mini.win.h = 1000;
    mini.win.w = cast (int)(cast(double) mini.win.h * 0.6294);


    mini.window = SDL_CreateWindow("SDL2 PNG Viewer", 
                                   SDL_WINDOWPOS_CENTERED, 
                                   SDL_WINDOWPOS_CENTERED,
                                   mini.win.w, 
                                   mini.win.h, 
                                   SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    
    mini.renderer = SDL_CreateRenderer(mini.window, -1, SDL_RENDERER_ACCELERATED);
     
    main.win.w = 1000;
    main.win.h = 1000;

    main.window = SDL_CreateWindow("MAIN PNG Viewer", 
                                   SDL_WINDOWPOS_CENTERED, 
                                   SDL_WINDOWPOS_CENTERED,
                                   main.win.w, 
                                   main.win.h, 
                                   SDL_WINDOW_SHOWN);

    main.renderer = SDL_CreateRenderer(main.window, -1, SDL_RENDERER_ACCELERATED);

    mini.surface = LoadImageToSurface("./images/1.png");

    mini.texture = LoadImageToTexture(mini.renderer, "./images/1.png");
    
    main.texture = LoadImageToTexture(main.renderer, "./images/1.png");

    uint format;
    SDL_QueryTexture(mini.texture, &format, null, &mini.tex.w, &mini.tex.h);
    writeln("mini.tex.w X mini.tex.h = ", mini.tex.w, " X ", mini.tex.h);
    
    string pixelFormat = to!string(SDL_GetPixelFormatName(format));
    writeln("pixelFormat = ", pixelFormat);

    mini.sur.w = mini.surface.w;
    mini.sur.h = mini.surface.h;    
    writeln("mini.sur.(w,h) = ", mini.sur.w, " X ", mini.sur.h);

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

        // Clear screen
        SDL_RenderClear(mini.renderer);
        SDL_RenderClear(main.renderer);
        
        SDL_Rect totalRect = { 0, 0, mini.sur.w, mini.sur.h };  // 6,668 x 10,594

        SDL_Rect srcRect = { mini.tex.w/2, mini.tex.h/2, 500, 500 };
        
        //SDL_Rect destRect = { 0, imgHeight/2, mainWinWidth, mainWinHeight };

        // Render image centered
        SDL_Rect miniDestRect = { 0, 0, mini.sur.w, mini.sur.h };
        
        //SDL_Rect mainDestRect = { 0, 0, mainWinWidth, mainWinHeight };

        SDL_RenderCopy(mini.renderer, mini.texture, /+&srcRect+/ null /+&totalRect+/, null /+&miniDestRect+/);
        
        // You need a renderer to create an SDL_Texture
        
        SDL_RenderCopy(main.renderer, main.texture, null, null );  // &srcRect /+&totalRect+/, &srcRect /+&miniDestRect+/);
                                                             // SDL_PIXELFORMAT_ARGB8888
        SDL_Texture* largeTexture = SDL_CreateTexture(main.renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STATIC, 100000, 100000);
        
        // SDL_Texture * SDL_CreateTextureFromSurface(SDL_Renderer * renderer, SDL_Surface * surface);
        
        
        //SDL_RenderCopy(mRenderer, texture, /+&srcRect+/ null /+&totalRect+/, &miniDestRect);
        
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
        SDL_RenderPresent(mini.renderer);
        SDL_RenderPresent(main.renderer);
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