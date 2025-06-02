
module magnify;

import breakup;
import datatypes;
import bindbc.sdl;
import std.stdio;
import std.conv;
import core.stdc.stdlib : exit;

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
    SDL_Texture* source_texture = SDL_CreateTextureFromSurface(renderer, SDL_CreateRGBSurface(NULL, 640, 480, 32, 0, 0, 0, 0));
    SDL_Texture* destination_texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 640, 480);

    // Set destination texture as render target
    SDL_SetRenderTarget(renderer, destination_texture);

    // Draw the source texture to the destination texture
    SDL_RenderCopy(renderer, source_texture, NULL, NULL);

    // Reset render target to the window
    SDL_SetRenderTarget(renderer, NULL);

    // Draw the destination texture to the window
    SDL_RenderCopy(renderer, destination_texture, NULL, NULL);
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
        |     |   ( +-+-)----------+-+       F1: increase texture transparency
        |     +---(-+-+ )          | |       F2: decrease texture transparency
        |           |              | |       Page Up: increase size of texture
        |           |     tex 2    | |       Page Down: decrease size of texture
        +-----------+--------------+ |
                    |                |   The contents of the loupe will be displayed in
                    |                |   the mannification windows.  The loupe can likewise
                    +----------------+   be moved and resized.
                                                    
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
    
    SDL_Dimensions inWinDim = { 500, 1000 };
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
    getTextureSize(tile1.texture, &tile1.rect.src.w, &tile1.rect.src.h);
    squareOffTexture(tile1.rect.src.w, tile1.rect.src.h);
    
    

    tile1.rect.dst = winRect;
    displayTextureProperties(tile1.texture);
    tile1.alpha = 127;
    tile1.angle = 0.0;

    tile2.rect.src.x = 0;
    tile2.rect.src.y = 0;
    getTextureSize(tile2.texture, &tile2.rect.src.w, &tile2.rect.src.h);
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

    SDL_Window *window = createWindow("Texture Composition", 1000, 1000, cast(SDL_WindowFlags) 0 );

    SDL_Renderer *renderer = createRenderer(window, null);
    
    int wi, he;
    getWindowSize(window, &wi, &he);
    
    SDL_Texture *textureOut = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, wi, he);

    //SDL_Texture *texture = loadImageToTexture(renderer, "./images/3.png");

    SDL_Texture *tex1 = loadImageToTexture(renderer, "./images/1.png");
    SDL_Texture *tex2 = loadImageToTexture(renderer, "./images/2.png");

    // Create a new texture to copy into (optional)
    //float w, h;
    // SDL_QueryTexture(texture, NULL, NULL, &width, &height);  // SDL2 only

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


