
module magnify;

import breakup;
import datatypes;
import bindbc.sdl;
import std.stdio;
import std.conv;
import core.stdc.stdlib : exit, malloc;
import core.stdc.string : memcpy;
import sdl_funcs_with_error_handling;
/+
Yes, in SDL3, you can display the same texture to two different renderers. A texture in SDL3 
is not bound to a specific renderer; it’s a resource that can be used by any renderer, provided
the texture is compatible with the rendering context. However, there are some nuances to consider,
as textures are typically created for a specific renderer, and sharing them across renderers may
require careful handling.

Key Points for Using the Same Texture with Multiple Renderers

Texture Creation:

Textures are created using SDL_CreateTexture or related functions (e.g., SDL_CreateTextureFromSurface) 
and are associated with a specific renderer at creation time. The texture’s format and properties (e.g., 
pixel format, dimensions) are tied to the renderer it was created for.

Sharing Textures Across Renderers:

SDL3 does not natively support sharing a single texture object directly between multiple renderers 
because textures are renderer-specific (e.g., they are tied to the underlying graphics API like OpenGL, 
Direct3D, or Metal). You cannot directly pass the same SDL_Texture pointer to different renderers, as 
textures are tied to the renderer’s graphics context. To display the same texture content in two 
different renderers, you typically need to create separate texture objects for each renderer, copying
the pixel data to both.

Approaches to Achieve This:

Option 1: Create Two Textures from the Same Source:

Load the source data (e.g., an image or surface) and create a separate texture for each renderer using
SDL_CreateTextureFromSurface or similar. This ensures each renderer has its own texture with the same 
visual content.

Option 2: Copy Pixel Data:

If you need to dynamically update the texture, use SDL_UpdateTexture to copy the same pixel data to 
both textures.

Option 3: Render to Texture and Copy:

If you want to render something complex to a texture and reuse it, you can render to a target texture 
in one renderer, extract the pixel data (e.g., using SDL_RenderReadPixels), and then create or update 
a texture in the second renderer with that data.

Option 4: Shared Context (Advanced):

In some graphics APIs (e.g., OpenGL), you can share textures between contexts if the renderers are 
using compatible contexts. However, this is low-level, not directly supported by SDL’s high-level API, 
and requires manual handling of the underlying graphics API.

Performance Considerations:

Creating and maintaining two textures with the same data requires additional memory.
Copying pixel data frequently (e.g., via SDL_RenderReadPixels or SDL_UpdateTexture) can be slow, 
especially for large textures or real-time applications. If possible, cache the textures and minimize
updates to optimize performance

+/

/+
int main(int argc, char* argv[]) {
    SDL_Window* window = SDL_CreateWindow("Texture Transfer", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_Texture* source_texture = SDL_CreateTextureFromSurface(renderer, SDL_CreateRGBSurface(null, 640, 480, 32, 0, 0, 0, 0));
    SDL_Texture* destination_texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 640, 480);

    // Set destination texture as render target
    SDL_SetRenderTarget(renderer, destination_texture);

    // Draw the source texture to the destination texture
    SDL_RenderCopy(renderer, source_texture, null, null);

    // Reset render target to the window
    SDL_SetRenderTarget(renderer, null);

    // Draw the destination texture to the window
    SDL_RenderCopy(renderer, destination_texture, null, null);
    SDL_RenderPresent(renderer);

    return 0;
}
+/

/+           Light Window  (Input)
        +--------------------------+
        |                          |         one or more textures may be put into the light board
        |     +-------+            |         tab key: select textures
        |     |tex 1  |            |         arrow keys: move current selected texture up
        |     |   (   | )loupe     |                     down, left, right
        |     |   ( +-+-)----------|.+       F1: increase texture transparency
        |     +---(-+-+ )          | .       F2: decrease texture transparency
        |           |              | .       Page Up: increase size of texture
        |           |     tex 2    | .       Page Down: decrease size of texture
        +--------------------------+ .
                    .                .   The contents of the loupe will be displayed in
                    .                .   the mannification windows.  The loupe can likewise
                    +................+   be moved and resized.
                                                    
        The ObjectsWorld will take in multiple textures and display them
        them into the window. The user can select each object and: 
           1) move them (position them) anywhere within or without the Window. 
           2) resize them (zoomed in or out) 
           3) change the opacity anywhere between fully transparent and fully opaque.
        Finally, the composed window can we saved off to a PNG image file.
        
           Magnification Window (Output)
        +------------------------+
        |   texture 1   |        |loupe
        |               |        |
        |       +-------+--------|
        |       |       |        |
        |       |       |        |
        |-------+-------+        |
        |       |                |
        |       |     texture 2  |
        +------------------------+
+/

void resizeRect(ref SDL_FRect rect, double delta)
{
    rect.x += delta;
    rect.y += delta;
    rect.w -= delta;
    rect.h -= delta;
}

void magnifyImage()
{
    SDL_Window   *inWindow   = null;
    SDL_Renderer *inRenderer = null;
    
    SDL_Window   *outWindow   = null;
    SDL_Renderer *outRenderer = null;

    //int winW = 500;
    //int winH = 500;
    
    SDL_Dimensions inWinDim = { 1500, 1500 };
    SDL_Dimensions outWinDim = { 500, 1000 };
    
    SDL_FRect outWinRect = { 0, 0, outWinDim.w, outWinDim.h };
    
    Tile[] tiles;
    
    Tile outTile;
    
    
    outTile.texture = SDL_CreateTexture(outRenderer, SDL_PIXELFORMAT_RGBA8888, 
                                        SDL_TEXTUREACCESS_TARGET, outWinDim.w, outWinDim.h);
                                        
    outTile.rect.dst = outWinRect;

    Tile tile1;
    Tile tile2;

    createWindowAndRenderer("Light Board Window", inWinDim.w, inWinDim.h, cast(SDL_WindowFlags) 0, &inWindow, &inRenderer);
    
    createWindowAndRenderer("Display", outWinDim.w, outWinDim.h, cast(SDL_WindowFlags) 0, &outWindow, &outRenderer);

    SDL_FRect winRect = { 0, 0, inWinDim.w, inWinDim.h };
    SDL_FPoint winCenter = { winRect.x + (winRect.w/2.0f), winRect.y + (winRect.h/2.0f) };


    tile1.surface = loadImageToSurface("./images/1.png");
    tile1.texture = createTextureFromSurface(inRenderer, tile1.surface);

    tile2.surface = loadImageToSurface("./images/2.png");
    tile2.texture = createTextureFromSurface(inRenderer, tile2.surface);




    tile1.rect.src.x = 0;
    tile1.rect.src.y = 0;
    getTextureSizeFloats(tile1.texture, &tile1.rect.src.w, &tile1.rect.src.h);
    squareOffTexture(tile1.rect.src.w, tile1.rect.src.h);
    
    

    tile1.rect.dst = winRect;
    displayTextureProperties(tile1.texture);
    tile1.alpha = 127;
    tile1.angle = 0.0;

    tile2.rect.src.x = 0;
    tile2.rect.src.y = 0;
    getTextureSizeFloats(tile2.texture, &tile2.rect.src.w, &tile2.rect.src.h);
    squareOffTexture(tile2.rect.src.w, tile2.rect.src.h);

    tile2.rect.dst = winRect;
    displayTextureProperties(tile2.texture);
    tile2.alpha = 127;
    tile2.angle = 0.0;

    int i = 0;  // index to current tile

    tiles ~= tile1;
    tiles ~= tile2;   //************************************************************************************************

    writeln("tiles[i] = ", tiles[i]);
    writeln("outTile = ", outTile);

    SDL_SetTextureBlendMode(tiles[i].texture, SDL_BLENDMODE_BLEND);
     SDL_SetTextureAlphaMod(tiles[i].texture, cast(ubyte) tiles[i].alpha); // 127 is 50% transparency

    //                            SDL_ALPHA_OPAQUE = 255   SDL_ALPHA_TRANSPARENT = 0           
    SDL_SetRenderDrawColor(inRenderer, 0, 0, 0, SDL_ALPHA_TRANSPARENT); // Background color

    bool quit = false;
    SDL_Event event;
    while (!quit) 
    {
        while (SDL_PollEvent(&event)) 
        {
            switch (event.type)
            {
                case SDL_EVENT_QUIT:
                    quit = true;
                    break;
               case SDL_EVENT_KEY_DOWN:
                    {
                        if (event.key.key == SDLK_ESCAPE)
                        {
                            quit = true;
                        }
                        if (event.key.key == SDLK_TAB)   // PICK TILE
                        {
                            writeln("tiles.length = ", tiles.length);
                            writeln("i = ", i);
                            if (i == (tiles.length-1))
                                i = 0;
                            else
                                i++;
                        }
                        if (event.key.key == SDLK_HOME)   // ROTATE
                        {
                            writeln("tiles[i].angle = ", tiles[i].angle);
                            tiles[i].angle += .1;
                        }
                        if (event.key.key == SDLK_END) 
                        {
                            writeln("tiles[i].angle = ", tiles[i].angle);
                            tiles[i].angle -= .1;
                        }
                        
                        if (event.key.key == SDLK_PAGEUP) // RESIZE RECT
                        {
                            resizeRect(tiles[i].rect.src, 10.0);
                            writeln("tiles[i].rect.src = ", tiles[i].rect.src);
                        }
                        if (event.key.key == SDLK_PAGEDOWN)
                        {
                            resizeRect(tiles[i].rect.src, -10.0);
                            writeln("tiles[i].rect.src = ", tiles[i].rect.src);
                        }
                        
                        if (event.key.key == SDLK_UP)    // MOVE RECT
                        {
                            tiles[i].rect.dst.y -= 2;
                        }
                        if (event.key.key == SDLK_DOWN)
                        {
                            tiles[i].rect.dst.y += 2;
                        }
                        if (event.key.key == SDLK_LEFT)
                        {
                            tiles[i].rect.dst.x -= 2;
                        }
                        if (event.key.key == SDLK_RIGHT)
                        {
                            tiles[i].rect.dst.x += 2;
                        }
                        
                        if (event.key.key == SDLK_F1)      // ALPHA
                        {
                            tiles[i].alpha += 2;   writeln("tiles[i].alpha = ", tiles[i].alpha);
                        }
                        if (event.key.key == SDLK_F2)
                        {
                            tiles[i].alpha -= 2;   writeln("tiles[i].alpha = ", tiles[i].alpha);
                        }
                    }
                    break;
                case SDL_EVENT_MOUSE_WHEEL:
                    {
                    }
                    break;
                default:
                    break;
            }
        }
        
        SDL_RenderClear(inRenderer);
        SDL_RenderClear(outRenderer);
        
        foreach( t; tiles)
        {
            SDL_SetTextureAlphaMod(t.texture, cast(ubyte) t.alpha);
            SDL_RenderTextureRotated(inRenderer, t.texture, &t.rect.src, &t.rect.dst, t.angle, &winCenter, SDL_FLIP_NONE);
        }

        // Define rectangle (x, y, width, height)
        SDL_FRect rect = { 100.0f, 100.0f, 200.0f, 200.0f };

        ubyte ur, ug, ub, ua;
        SDL_GetRenderDrawColor(inRenderer, &ur, &ug, &ub, &ua);

        // Draw red rectangle border
        SDL_SetRenderDrawColor(inRenderer, 255, 0, 0, 255);

        SDL_RenderRect(inRenderer, &rect);
        
        SDL_RenderPresent(inRenderer);
        
        SDL_SetRenderDrawColor(inRenderer, ur, ug, ub, ua);  // RESTORE COLOR
        
        
        SDL_GetRenderDrawColor(inRenderer, &ur, &ug, &ub, &ua);
        // Draw green rectangle border
        SDL_SetRenderDrawColor(outRenderer, 0, 255, 0, 255);

        SDL_RenderRect(outRenderer, &rect);
        
        SDL_SetRenderDrawColor(outRenderer, ur, ug, ub, ua);  // RESTORE COLOR
        
        //SDL_RenderPresent(outRenderer);
        
        //+
        // Set the render target from Window (default) to destination texture
        
        SDL_SetRenderTarget(outRenderer, outTile.texture);

        // Draw the source texture to the destination texture
        //            (dest texture) (source texture)

        SDL_RenderTexture(outRenderer,  tiles[0].texture, &tiles[0].rect.src, &outTile.rect.dst);  // remember: renderer is actually dest texture

        SDL_SetRenderTarget(outRenderer, null);  // set renderer back to its associated window

        //SDL_RenderTexture(outRenderer, outTile.texture, null, null);
        
        SDL_RenderPresent(outRenderer);

        //+/
       

    }
}


void google()
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0) 
    {
        writeln(SDL_GetError());
        return;
    }
    //void createWindow(string winName, int w, int h, SDL_WindowFlags flags, SDL_Window **window)
    
    //SDL_Window *window = createWindow("Texture Composition", 1000, 1000, cast(SDL_WindowFlags) 0, window );
    SDL_Window *window;
    createWindow("Texture Composition", 1000, 1000, cast(SDL_WindowFlags) 0, &window );
    
    SDL_Renderer *renderer = createRenderer(window, null);
    
    int wi, he;
    getWindowSize(window, &wi, &he);
    
    SDL_Texture *textureOut = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, wi, he);

    //SDL_Texture *texture = loadImageToTexture(renderer, "./images/3.png");

    SDL_Texture *tex1 = loadImageToTextureWithAccess(renderer, "./images/1.png", SDL_TEXTUREACCESS_STREAMING);
    SDL_Texture *tex2 = loadImageToTextureWithAccess(renderer, "./images/2.png", SDL_TEXTUREACCESS_STREAMING);

    // Create a new texture to copy into (optional)
    //float w, h;
    // SDL_QueryTexture(texture, null, null, &width, &height);  // SDL2 only

    //SDL_GetTextureSize(texture, &w, &h);  // new for SDL3
    
    //writeln("SDL_GetTextureSize returned ", w, " and ", h);

    /+
    SDL_PropertiesID props = getTextureProperties(texture);
    long width, height;
     width = SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_WIDTH_NUMBER,  0);  // 0 as default
    height = SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_HEIGHT_NUMBER, 0);  // 0 as default
    writeln("Texture Width x Height: ", width, " x ", height);
    +/
    
    // make the new
    //SDL_Texture *textureOut = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, cast(int) width, cast(int) height);

    /+     THE BELOW PARAGRAPH IS WRONG AND CAME UP IN GOOGLE GEMINI AI
    In SDL3, SDL_RenderCopy is still the primary function for copying a portion of a texture to 
                    GROK 3 replied correctly with:
    In SDL3, the function SDL_RenderCopy is not listed in the official SDL3 documentation, and the 
    SDL Wiki explicitly states that no page exists for SDL3/SDL_RenderCopy. Instead, SDL3 introduces 
    SDL_RenderTexture, which serves a similar purpose—copying a portion of a texture to the current 
    rendering target with subpixel precision. It is defined in SDL3/SDL_render.h and has the signature:
    bool SDL_RenderTexture(SDL_Renderer *renderer, SDL_Texture *texture, const SDL_FRect *srcrect, const SDL_FRect *dstrect);
    +/

    // Copy the texture (either to a new texture or directly to the window)
    
    // Example 1: Copy to a new texture

    SDL_SetRenderTarget(renderer, textureOut);  // Set the new textureOut as the rendering target

    SDL_RenderClear(renderer); // Clear the new texture

    SDL_FRect rect1 = {0,0, 500, 500};

    SDL_FRect leftHalf  = {  0, 0, 500, 1000};
    SDL_FRect rightHalf = {500, 0, 500, 1000};

    SDL_RenderTexture(renderer, tex1, &leftHalf, &leftHalf);
    
    //SDL_FRect rect2 = {200, 200, 1500, 1500};
    
    SDL_FRect srcRect = { 3000, 3000, 500, 1000};
    //SDL_FRect dstRect = { 0, 0, 500, 500 };
    
    SDL_RenderTexture(renderer, tex1, &srcRect, &leftHalf);
    SDL_RenderTexture(renderer, tex2, &srcRect, &rightHalf);


    // Example 2: Copy directly to the window (without a new texture)
    /+
    SDL_SetRenderTarget(renderer, null); // Set back to the window
    SDL_RenderClear(renderer);
    SDL_RenderTexture(renderer, texture, null, null);
    +/

    SDL_SetRenderTarget(renderer, null); // Set back to the window

    // Render the copied texture to the window

    SDL_RenderTexture(renderer, textureOut, null, null);

    // Present the renderer (display the image on the screen)
    SDL_RenderPresent(renderer);

    // Keep the window open until the user closes it
    SDL_Event event;
    while (SDL_WaitEvent(&event)) 
    {
        if (event.type == SDL_EVENT_QUIT) 
        {
            break;
        }
    }

}





void enlargeAndReduce()
{
    SDL_Window *window;
    
    createWindow("Texture Composition", 1000, 1000, cast(SDL_WindowFlags) 0, &window );

    SDL_Renderer *renderer = createRenderer(window, null);
    
    int wi, he;
    getWindowSize(window, &wi, &he);
    
    SDL_Texture *textureOut = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, wi, he);

    SDL_Texture *tex1 = loadImageToTextureWithAccess(renderer, "./images/1.png", SDL_TEXTUREACCESS_STREAMING);
    SDL_Texture *tex2 = loadImageToTextureWithAccess(renderer, "./images/2.png", SDL_TEXTUREACCESS_STREAMING);

    // Example 1: Copy to a new texture

    SDL_SetRenderTarget(renderer, textureOut);  // Set the new textureOut as the rendering target

    SDL_RenderClear(renderer); // Clear the new texture

    SDL_FRect leftHalf  = {  0, 0, 500, 1000};
    SDL_FRect rightHalf = {500, 0, 500, 1000};

    //SDL_RenderTexture(renderer, tex1, &leftHalf, &leftHalf);

    SDL_FRect srcRect = { 3000, 3000, 200, 400};

    SDL_RenderTexture(renderer, tex1, /+&srcRect+/ null, &leftHalf);
    SDL_RenderTexture(renderer, tex2, &srcRect, &rightHalf);


    SDL_SetRenderTarget(renderer, null); // Set back to the window

    // Render the compositioned texture to the window

    SDL_RenderTexture(renderer, textureOut, null, null);

    SDL_RenderPresent(renderer);  // display the image on the screen

    // Keep the window open until the user closes it
    SDL_Event event;
    while (SDL_WaitEvent(&event)) 
    {
        if (event.type == SDL_EVENT_QUIT) 
        {
            break;
        }
    }

}




void LightBoard()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;
    
    SDL_Window   *minWin;
    SDL_Renderer *minRen;

    createWindowAndRenderer("Viewer", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    createWindowAndRenderer("minWin", 750, 750, cast(SDL_WindowFlags) 0, &minWin, &minRen);

    // SDL_CreateTextureFromSurface failed: Texture dimensions are limited to 16384 x 16384

    SDL_Texture *lightBoard = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 16384, 16384);
    
    SDL_Surface *minSur = loadImageToSurface("./images/4.png");
    
    displaySurfaceProperties(minSur);

    //SDL_Surface *minSur = createSurface(temp.w, temp.h, SDL_PIXELFORMAT_RGBA8888);

    SDL_Texture *minTex = createTexture(minRen, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, minSur.w, minSur.h);
    
    displayTextureProperties(minTex);

    Slide[] slides;
    Slide slide;
    float w, h;

    slide.texture = loadImageToTextureWithAccess(renderer, "./images/1.png", SDL_TEXTUREACCESS_STREAMING);
    getTextureSizeFloats(slide.texture, &w, &h);
    slide.size.w = w;  slide.size.h = h;
    slide.position.x = 0;  slide.position.y = 0;
    slides ~= slide;

    slide.texture = loadImageToTextureWithAccess(renderer, "./images/2.png", SDL_TEXTUREACCESS_STREAMING);
    getTextureSizeFloats(slide.texture, &w, &h);
    slide.size.w = w;  slide.size.h = h;
    slide.position.x = 6600;  slide.position.y = 0;
    slides ~= slide;
    
    slide.texture = loadImageToTextureWithAccess(renderer, "./images/3.png", SDL_TEXTUREACCESS_STREAMING);
    getTextureSizeFloats(slide.texture, &w, &h);
    slide.size.w = w;  slide.size.h = h;
    slide.position.x = 13200;  slide.position.y = 0;
    slides ~= slide;

    // Example 1: Place images onto the lightBoard

    SDL_SetRenderTarget(renderer, lightBoard);  // Set the new textureOut as the rendering target

    SDL_RenderClear(renderer); // Clear the lightBoard

    foreach( s; slides)
    {
        SDL_FRect dstRect;
        dstRect.x = s.position.x;  dstRect.y = s.position.y;
        dstRect.w = s.size.w;  dstRect.h = s.size.h;
        SDL_RenderTexture(renderer, s.texture, null, &dstRect);
    }

    SDL_SetRenderTarget(renderer, null);  // set the renderer back to the Window

    SDL_FRect viewerRect = {500, 500, 1000, 1000};  // SDL_FRect rightHalf = {500, 0, 500, 1000};

    SDL_RenderTexture(renderer, lightBoard, null, null);
    SDL_RenderPresent(renderer);

    //minSur = loadImageToSurface("./images/4.png");  // did not seem to require a previous createSurface to work.
    //displaySurfaceProperties(minSur);
    
    copySurfaceToStreamingTexture(minSur, minTex);
    
    displayTextureProperties(minTex);
    
    SDL_RenderClear(minRen);
        SDL_RenderTexture(minRen, minTex, /+&viewerRect+/ null, null);
    SDL_RenderPresent(minRen); 
 
 

    // Keep the window open until the user closes it
    SDL_Event event;
    while (SDL_WaitEvent(&event)) 
    {
        if (event.type == SDL_EVENT_KEY_DOWN)
        {
            if (event.key.key == SDLK_ESCAPE)
            {
                break;
            }
        }
        if (event.type == SDL_EVENT_QUIT) 
        {
            break;
        }
    }
}



void copySurfaceToStreamingTexture(SDL_Surface *surface, SDL_Texture *texture)
{
    /+
    To update a streaming texture, you need to lock it first. This gets you access to the pixels
    Note that this is considered a write-only operation: the buffer you get from locking
    might not acutally have the existing contents of the texture, and you have to write to every
    locked pixel

    You can use SDL_LockTexture() to get an array of raw pixels, but we're going to use
    SDL_LockTextureToSurface() here, because it wraps that array in a temporary SDL_Surface,
    letting us use the surface drawing or blit functions instead of lighting up individual pixels.
    +/

    SDL_Surface *lockedSurface = null;
    lockTextureToSurface(texture, null, &lockedSurface);  // only works with streaming textures

      
    SDL_Rect r = { 0, 0, 4000, 6000 };
    /+
    SDL_FillSurfaceRect(surface, null, SDL_MapRGB(SDL_GetPixelFormatDetails(surface.format), null, 0, 255, 0));
    SDL_FillSurfaceRect(surface, &r, SDL_MapRGB(SDL_GetPixelFormatDetails(surface.format), null, 0, 0, 255));
     +/

    copySurfaceToSurface(surface, &r /+null+/, lockedSurface, &r /+null+/);
    
    SDL_UnlockTexture(texture);  // upload the changes (and frees the temporary surface)
}



/+

Are the following conclusions correct?

1) I have heard that rendering textures is much faster than rendering surfaces. This 
applies to only rendering right? Not handling them?  Exampe: loading images, modifying, 
(blitting surfaces) / (rendering textures into another textures) etc.

2) Textures aren't as modifiable as surfaces. If something keeps changing, it is better 
    to use surfaces and then create a texture just to render it to the screen.

========== Answer 1 =================

1. Surfaces use the CPU/RAM. Textures normally use the GPU/VRAM (unless you use a software renderer).

By using textures you're able to take advantage of your graphics hardware which usually makes drawing 
them, onto another texture or onto the screen, much faster. This depends on your graphics hardware and 
drivers but it is usually the case.

If you're using surfaces you don't only suffer from the slower performance of the CPU to perform these 
actions but you also pay the price of having to transfer all the pixels to the VRAM each frame. By using 
SDL_UpdateWindowSurfaceRects instead of SDL_UpdateWindowSurface to only send the parts that have changed 
each frame you might still get acceptable performance but this complicates the code and doesn't help if 
there are too much changes happening all the time (such as when the background is scrolling).

     SDL3
bool SDL_UpdateWindowSurfaceRects(SDL_Window *window, const SDL_Rect *rects, int numrects);
Function Parameters
SDL_Window     *window   the window to update.
const SDL_Rect *rects    an array of SDL_Rect structures representing areas of the surface to copy, in pixels.
int            numrects  the number of rectangles.



When loading an image from file you always load it into RAM first and then it has to be transferred onto 
the VRAM when you create the texture. There is no performance advantage of using IMG_LoadTexture instead 
of IMG_Load followed by SDL_CreateTextureFromSurface. It's just there for convenience.

========== Answer 2 =================

2. You cannot access the pixels directly but you can lock the texture and update the pixels (this will 
involve sending pixel data from RAM to VRAM). It's also possible to use a texture as a render target 
(if supported) to render directly to it just like you would render to the screen using SDL_RenderFillRect, 
SDL_RenderCopy, etc. I have very little experience with this but I think you might have to set the access 
pattern when creating the texture, or maybe it only affects the performance of these operations, I'm not sure.

+/


/+
SDL_Texture *texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, width, height);
SDL_Surface *surface = IMG_Load(file_path);
if (surface) {
    SDL_LockTexture(texture, NULL, &pixels, &pitch);
    SDL_ConvertSurface(surface, SDL_PIXELFORMAT_RGBA8888, 0); // Convert to the same format as the texture
    SDL_Memcpy(pixels, surface->pixels, pitch * surface->h); // Copy the image data to the texture
    SDL_UnlockTexture(texture);
}

SDL_RenderClear(renderer);
SDL_RenderCopy(renderer, texture, NULL, NULL);
SDL_RenderPresent(renderer);
+/


// TEXTURE TO TEXTURE
// This Example demonstrates a Texture to Texture copy
//

/+
textureToTextureCopy() 
{
    // SDL_Init(SDL_INIT_VIDEO);
    // IMG_Init(IMG_INIT_PNG); // If you're using PNG

    //SDL_Window* window = SDL_CreateWindow("Texture Copy", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, 0);
    //SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);

    // Load a source texture (replace "image.png" with your image)
    //SDL_Texture* sourceTexture = IMG_LoadTexture(renderer, "image.png");
    //SDL_Texture* sourceTexture = SDL_CreateTextureFromSurface(renderer, surface); // Or create from surface



    // Create a target texture
    SDL_Texture* targetTexture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 800, 600);

    // Set target texture as the rendering target
    SDL_SetRenderTarget(renderer, targetTexture);

    // Render the source texture to the target texture
    SDL_Rect dstrect;
    dstrect.x = 0;
    dstrect.y = 0;
    dstrect.w = 800;
    dstrect.h = 600;
    SDL_RenderCopy(renderer, sourceTexture, NULL, &dstrect);

    // Reset the rendering target to the window
    SDL_SetRenderTarget(renderer, NULL);

    // Now, you can render the targetTexture to the screen
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, targetTexture, NULL, &dstrect);
    SDL_RenderPresent(renderer);

    SDL_Delay(2000);

    SDL_DestroyTexture(sourceTexture);
    SDL_DestroyTexture(targetTexture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    IMG_Quit();
    SDL_Quit();

    return 0;
}
+/





/+

https://examples.libsdl.org/SDL3/renderer/07-streaming-textures/#:~:text=07%2Dstreaming%2Dtextures,function%20runs%20once%20at%20startup.


+/








