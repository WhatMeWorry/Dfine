


module breakup;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import sdl_funcs_with_error_handling;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations



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



void getTextureSizeFloats(SDL_Texture *texture, float *width, float *height)
{
    if (SDL_GetTextureSize(texture, width, height) == false)  // new for SDL3
    {
        writeln("getTextureSizeFloats failed: ", to!string(SDL_GetError()));
        exit(-1);
    }
}


void getTextureSizeInts(SDL_Texture *texture, int *width, int *height)
{
    float *w; 
    float *h;
    if (SDL_GetTextureSize(texture, w, h) == false)  // new for SDL3
    {
        writeln("getTextureSizeInts failed: ", to!string(SDL_GetError()));
        exit(-1);
    }
    width = cast(int*) w;
    height = cast(int*) h;

    /+
    SDL_PropertiesID props = SDL_GetTextureProperties(texture);
    SDL_GetNumberProperty(props, SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER, width);
    SDL_GetNumberProperty(props, SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER, height);
    +/
}


SDL_PropertiesID getTextureProperties(SDL_Texture *texture)
{
    SDL_PropertiesID props = SDL_GetTextureProperties(texture);
    if (!props) 
    {
        writeln("SDL_GetTextureProperties failed: ", to!string(SDL_GetError()));
        exit(-1);
    }
    return props;
}









void squareOffTexture(ref float w, ref float h)
{
    writeln("w = ", w);
    writeln("h = ", h);
    if (h > w)
    {
        h = w;
    }
    else
    {
        w = h;
    }
    writeln("w = ", w);
    writeln("h = ", h);
}


/+
struct SDL_Texture
{
    SDL_PixelFormat format;     // The format of the texture, read-only
    int w;                      // The width of the texture, read-only
    int h;                      // The height of the texture, read-only
};

struct SDL_Surface
{
    SDL_SurfaceFlags flags;     // The flags of the surface, read-only
    SDL_PixelFormat format;     // The format of the surface, read-only
    int w;                      // The width of the surface, read-only
    int h;                      // The height of the surface, read-only
    int pitch;                  // The distance in bytes between rows of pixels, read-only
    void *pixels;               // A pointer to the pixels of the surface, the pixels are writeable if non-NULL
};
+/

bool isRectOutsideBiggerRectZoom(SDL_FRect *inner, SDL_FRect *outer)
{
    if (inner.w > outer.w)
    {
        writeln("inner.w is now larger than outer.w");
        //inner.w = outer.w;
        return true;
    }
    if (inner.h > outer.h)
    {
        //inner.h = outer.h;
        writeln("inner.h is now larger than outer.h");
        return true;
    }
    return false;
}

void keepRectWithinBiggerRectArrowMovement(SDL_FRect *inner, SDL_FRect *outer)
{
        /+
        +--------------------------+
        |                          |
        |     +-------+            |
        |     |       |            |
        |     |       |            |
        |     |       |            |
        |     +-------+            |
        |                          |
        |                          |
        |                          |
        +--------------------------+
        +/

    // treat outer as read-only

    if (inner.x < outer.x)
    {
        inner.x = outer.x;  // if outside on left, put back in
    }
    if (inner.y < outer.y)  // if outside on top, put back in
    {
        inner.y = outer.y;
    }
    if ((inner.x + inner.w) >= (outer.x + outer.w))
    {
        inner.x = (outer.x + outer.w) - inner.w;
    }
    if ((inner.y + inner.h) > (outer.y + outer.h))
    {
        inner.y = (outer.y + outer.h) - inner.h;
    }

}


void keepRectWithinBiggerRectArrowMovement(SDL_Rect *inner, SDL_Rect *outer)
{
        /+
        +----------------------+ outer
        |                      |
        |     +-------+        |
        |     |       |inner   |
        |     |       |        |
        |     |       |        |
        |     +-------+        |
        +----------------------+
        +/

    if (inner.x < outer.x)
    {
        inner.x = outer.x;  // if outside on left, put back in
    }
    if (inner.y < outer.y)  // if outside on top, put back in
    {
        inner.y = outer.y;
    }
    if ((inner.x + inner.w) >= (outer.x + outer.w))
    {
        inner.x = (outer.x + outer.w) - inner.w;
    }
    if ((inner.y + inner.h) > (outer.y + outer.h))
    {
        inner.y = (outer.y + outer.h) - inner.h;
    }

}



void createRealBigSurface()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    int winWidth = 1000;
    int winHeight = 1000;

    createWindowAndRenderer("Real Big Texture", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_PropertiesID props = SDL_GetRendererProperties(renderer);
    int max_texture_size = cast(int) SDL_GetNumberProperty(props, SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER, 0);
    
    writeln("max_texture_size = ", max_texture_size);

    SDL_Surface *image0;
    SDL_Surface *image1;
    SDL_Surface *image2;
    SDL_Surface *image3;
    SDL_Surface *image4;

    image0 = loadImageToSurface("./images/1.png");
    image1 = loadImageToSurface("./images/2.png");
    image2 = loadImageToSurface("./images/3.png");
    image3 = loadImageToSurface("./images/4.png");
    image4 = loadImageToSurface("./images/5.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image0.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image0.w, " x ", image0.h);

    int width = image0.w;
    int height = image0.h;


    SDL_Surface *surface0 = createSurface(width, height, image0.format);
    SDL_Surface *surface1 = createSurface(width, height, image1.format);
    SDL_Surface *surface2 = createSurface(width, height, image2.format);
    SDL_Surface *surface3 = createSurface(width, height, image3.format);
    SDL_Surface *surface4 = createSurface(width, height, image4.format);


    SDL_Surface *huge = createSurface(5*6692, 1*10594, image0.format);


    SDL_Rect[5] quads =
    [
        SDL_Rect(0,     0,  6680, 10594),
        SDL_Rect(6681,  0,  6686, 10594),
        SDL_Rect(13368, 0,  6688, 10594),
        SDL_Rect(20057, 0,  6692, 10594),
        SDL_Rect(26749, 0,  6690, 10594)
    ];

    copySurfaceToSurface(image0, null, huge, &quads[0]);
    copySurfaceToSurface(image1, null, huge, &quads[1]);
    copySurfaceToSurface(image2, null, huge, &quads[2]);
    copySurfaceToSurface(image3, null, huge, &quads[3]);
    copySurfaceToSurface(image4, null, huge, &quads[4]);
    
    string fileName = "./images/" ~ "huge" ~ ".png";
    if (IMG_SavePNG(huge, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    else
    {
        writeln("IMG_SavePNG succeeded");
    }
}


        /+                                          Window
        +--------+   +--------+         +--------------------------+
        |        |   |        |         |                          |
        |texture1|   |texture2|         |     +-------+            |         tab key: select textures
        |        |   |        |         |     |texture|            |         arrow keys: move current selected texture up
        +--------+   +--------+         |     |1      |            |                     down, left, right
                                        |     |     +-+------------+-+       F1: increase texture transparency
                                        |     +-----+-+            | |       F2: decrease texture transparency
                                        |           |              | |       Page Up: increase size of texture
                                        |           |   texture 2  | |       Page Down: decrease size of texture
                                        +-----------+--------------+ |
                                                    |                |
                                                    |                |
                                                    +----------------+
                                                    
        The ObjectsWorld will take in multiple textures and display them
        them into the window. The user can select each object and: 
           1) move them (position them) anywhere within or without the Window. 
           2) resize them (zoomed in or out) 
           3) change the opacity anywhere between fully transparent and fully opaque.
        Finally, the composed window can we saved off to a PNG image file.
        +/

void resizeRect(ref SDL_FRect rect, double delta)
{
    rect.x += delta;
    rect.y += delta;
    rect.w -= delta;
    rect.h -= delta;
}

void composingImage()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;

    int winW = 1000;
    int winH = 1000;
    
    Tile[] tiles;

    Tile tile1;
    Tile tile2;

    createWindowAndRenderer("composingImage", winW, winH, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_FRect winRect = { 0, 0, winW, winH };
    SDL_FPoint winCenter = { winRect.x + (winRect.w/2.0f), winRect.y + (winRect.h/2.0f) };



    tile1.surface = loadImageToSurface("./images/1.png");
    tile1.texture = createTextureFromSurface(renderer, tile1.surface);

    tile2.surface = loadImageToSurface("./images/2.png");
    tile2.texture = createTextureFromSurface(renderer, tile2.surface);




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
    //tiles ~= tile2;   //************************************************************************************************

    writeln("tiles[i] = ", tiles[i]);

    SDL_SetTextureBlendMode(tiles[i].texture, SDL_BLENDMODE_BLEND);
     SDL_SetTextureAlphaMod(tiles[i].texture, cast(ubyte) tiles[i].alpha); // 127 is 50% transparency

    //                            SDL_ALPHA_OPAQUE = 255   SDL_ALPHA_TRANSPARENT = 0           
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_TRANSPARENT); // Background color

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
        /+
        SDL_SetTextureAlphaMod(tiles[i].texture, cast(ubyte) tiles[i].alpha);
        SDL_RenderClear(renderer);  // fills the entire rendering target with the current draw color that was previously set
        //SDL_RenderTextureRotated(renderer, tex1, &tex1Rect, &winRect, 0, &winCenter, SDL_FLIP_NONE); // Apply rotation and scaling
          SDL_RenderTextureRotated(renderer, tiles[i].texture, &tiles[i].rect.src, &tiles[i].rect.dst, 0, &winCenter, SDL_FLIP_NONE);

        SDL_RenderPresent(renderer);
        +/
        SDL_RenderClear(renderer);
        foreach( t; tiles)
        {
            SDL_SetTextureAlphaMod(t.texture, cast(ubyte) t.alpha);
            //SDL_RenderClear(renderer);  // fills the entire rendering target with the current draw color that was previously set
            //SDL_RenderTextureRotated(renderer, tex1, &tex1Rect, &winRect, 0, &winCenter, SDL_FLIP_NONE); // Apply rotation and scaling
              SDL_RenderTextureRotated(renderer, t.texture, &t.rect.src, &t.rect.dst, t.angle, &winCenter, SDL_FLIP_NONE);

            //SDL_RenderPresent(renderer);
        }
        SDL_RenderPresent(renderer);

    }






    
    
    
    
    
    
    
  
  /+ 
    foreach(i; 0..23) 
    {
        a = a + 10;
        SDL_SetTextureAlphaMod(tex1, cast(ubyte) a);
        SDL_RenderClear(renderer);  // fills the entire rendering target with the current draw color that was previously set
        SDL_RenderTextureRotated(renderer, tex1, &tex1Rect, &winRect, 0, &winCenter, SDL_FLIP_NONE); // Apply rotation and scaling
        SDL_RenderPresent(renderer);
        SDL_Delay(1000);
    }
SDL_Delay(4000);
    +/
/+
    SDL_FRect tex2Rect;
    tex2Rect.x = 0;
    tex2Rect.y = 0;
    getTextureSizeInts(tex2, &tex2Rect.w, &tex2Rect.h);
    squareOffTexture(tex2Rect.w, tex2Rect.h);
    
    displayTextureProperties(tex2);
    SDL_SetTextureBlendMode(tex2, SDL_BLENDMODE_BLEND);
    SDL_SetTextureAlphaMod(tex2, 75); // 127 is 50% transparency   0: Fully transparent (the texture will be invisible).
                                                               // 255: Fully opaque (no transparency).
    
    SDL_RenderTextureRotated(renderer, tex2, &tex2Rect, &winRect, 0.0, &winCenter, SDL_FLIP_NONE); // Apply rotation and scaling
    SDL_RenderPresent(renderer);
    
    SDL_Delay(8000);
  +/  

}







        /+      Texture
        +--------------------------+        A                 B
        |    a         b           |         +---------------+
        |     +-------+            |         |               |
        |     |Tracker|     O      |         |               |
        |     |Camera |            |         |     Window    |
        |     |  X O  |            |         |               |
        |     +-------+            |         |      X O      |
        |    c         d           |         |               |
        |                      O   |         +---------------+
        |     O                    |        C                 D
        +--------------------------+
        
        The Tracker Camera can move horzontally and vertically as well as zoom in and out. 
        
        The entire contents of the Tracker Camera (a:b:c:d) is drawn (pixel copied)
        from the current position of the Tracker Camera to the Window (A:B:C:D).
        
        The Tracker Camera (inner rectangle) can move up and down so long as all sides remain
        within the texture (outer rectangle).  Additionally, the Tracker Camera can expand or
        shrink proportionally in the horizontal and vertical directions: Uniform Scaling. This
        effectively operates like a zoom in or out operation.
        
        The Texture is a static read-only rectangle.  The Window is is fixed size; though this 
        could easily be made resizable.  The Tracker Camera is dynamic with the exception that
        it must stay within the confines of the Texture. Like wise, the Tracker Camera can grow
        (zoom out) no larger than the Texture.
        +/

void trackerCamera()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    int winWidth = 1000;
    int winHeight = 1000;

    createWindowAndRenderer("trackerCamera", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    // WINDOW RECT/CENTER

    SDL_FRect winRect = { 0, 0, winWidth, winHeight };
    SDL_FPoint winCenter = { winRect.x + (winRect.w/2.0f), winRect.y + (winRect.h/2.0f) };

    // Define the initial destination rectangle

    // surface = loadImageToSurface("./images/earth1024x1024.png");
    // surface = loadImageToSurface("./images/COMBINE_RotatedA.png");
    surface = loadImageToSurface("./images/two.png");

    texture = createTextureFromSurface(renderer, surface);

    // TEXTURE RECT/CENTER
    
    SDL_FRect  texRect;
    texRect.x = 0;
    texRect.y = 0;
    getTextureSizeFloats(texture, &texRect.w, &texRect.h);

    SDL_FPoint texCenter = { texRect.w / 2.0f, texRect.h / 2.0f };

    float angle = 0.0;

    // CAMERA RECT/CENTER

    SDL_FRect  cameraRect;
    cameraRect.x = texCenter.x - (winWidth/2.0f);   // SDL3 positions rects at its upper left corner.
    cameraRect.y = texCenter.y - (winHeight/2.0f);  // Need to adjust in northwest direction
    cameraRect.w = winWidth;
    cameraRect.h = winHeight;

    SDL_FPoint cameraCenter;
    cameraCenter.x = cameraRect.x + (cameraRect.w / 2.0f);
    cameraCenter.y = cameraRect.y + (cameraRect.h / 2.0f);

    writeln("cameraRect = ", cameraRect);
    writeln("cameraCenter = ", cameraCenter);
    writeln("winRect = ", winRect);
    writeln("winCenter = ", winCenter);

    SDL_RenderClear(renderer);
    
    float scale_factor = 1.0;
    
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
                        if (event.key.key == SDLK_PAGEUP) 
                        {
                            //scale_factor *= 1.01f;
                            scale_factor = 1.01;

                            SDL_FPoint delta = { (cameraRect.w * scale_factor) - cameraRect.w, 
                                                 (cameraRect.h * scale_factor) - cameraRect.h };

                            SDL_FRect previous = cameraRect;

                            cameraRect.w = (cameraRect.w * scale_factor);
                            cameraRect.h = (cameraRect.h * scale_factor);

                            cameraRect.x = cameraRect.x - (delta.x/2.0f);
                            cameraRect.y = cameraRect.y - (delta.y/2.0f);

                            writeln("cameraRect = ", cameraRect);
                            //writeln("cameraCenter = ", cameraCenter);
                            
                            if (isRectOutsideBiggerRectZoom(&cameraRect, &texRect))
                            {
                                cameraRect = previous;
                            }
                            
                            
                        }
                        if (event.key.key == SDLK_PAGEDOWN) 
                        {
                            //scale_factor /= 1.1f;
                            
                            scale_factor = 0.99f;
                            
                            SDL_FPoint delta = { (cameraRect.w * scale_factor) - cameraRect.w, 
                                                 (cameraRect.h * scale_factor) - cameraRect.h };
                                                 
                            SDL_FRect previous = cameraRect;

                            cameraRect.w = (cameraRect.w * scale_factor);
                            cameraRect.h = (cameraRect.h * scale_factor);

                            cameraRect.x = cameraRect.x - (delta.x/2.0f);
                            cameraRect.y = cameraRect.y - (delta.y/2.0f);

                            // we zoom in the camera infinitely so we never have to check cameraRects boundaries 

                        }
                        if (event.key.key == SDLK_UP) 
                        {
                            cameraRect.y -= 50;
                            keepRectWithinBiggerRectArrowMovement(&cameraRect, &texRect);
                        }
                        if (event.key.key == SDLK_DOWN) 
                        {
                            cameraRect.y += 50;
                            keepRectWithinBiggerRectArrowMovement(&cameraRect, &texRect);
                        }
                        if (event.key.key == SDLK_LEFT) 
                        {
                            cameraRect.x -= 50;
                            keepRectWithinBiggerRectArrowMovement(&cameraRect, &texRect);
                        }
                        if (event.key.key == SDLK_RIGHT) 
                        {
                            cameraRect.x += 50;
                            keepRectWithinBiggerRectArrowMovement(&cameraRect, &texRect);
                        }
                        
                        cameraCenter.x = cameraRect.x + (cameraRect.w / 2.0f);
                        cameraCenter.y = cameraRect.y + (cameraRect.h / 2.0f);
                        
                        //writeln("cameraRect = ", cameraRect);
                        writeln("cameraCenter = ", cameraCenter);
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
        
        SDL_RenderTextureRotated(renderer, texture, &cameraRect, &winRect, angle, &winCenter, SDL_FLIP_NONE); // Apply rotation and scaling
        SDL_RenderPresent(renderer);

    }
}
    
    
    
    
    
    
/+   
    SDL_RenderTextureRotated(renderer, texture, &cameraRect, &winRect, angle, &winCenter, SDL_FLIP_NONE); // Apply rotation and scaling
    SDL_RenderPresent(renderer);

    SDL_Delay(2000); // Wait for 2 seconds
   
    SDL_RenderPresent(renderer);
+/






// THIS WORKS!!!

// This works fine for zooming in on small and large textures.
// but when zooming out, large textures get smaller but no new pixels are added. you
// would expect to see more of the large texture as is  recedes into the back 
// because the src_rect never changes!

void rotateAndScale()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    int winWidth = 1000;
    int winHeight = 1000;

    createWindowAndRenderer("rotateAndScale", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    // Define the initial destination rectangle
    
    SDL_FRect dst_rect = {0, 0, winWidth, winHeight};

    //surface = loadImageToSurface("./images/earth1024x1024.png");

    //surface = loadImageToSurface("./images/COMBINE_A.png");
    
    surface = loadImageToSurface("./images/two.png");

    texture = createTextureFromSurface(renderer, surface);

    float texWidth; float texHeight;
    getTextureSizeFloats(texture, &texWidth, &texHeight);
    
    // Important Note: x and y of srcRect must stay within the range of 0..maxWidth and 0..maxHeight
    // or else the SDL_RenderTextureRotated will distort the image.
    
    // Another way of thinking about this is that it is invalid to access 
    // any pixels outside of a texture's boundaries.

    SDL_FPoint texCenter = {texWidth / 2.0f, texHeight / 2.0f};
    
    // SDL3 position rects at its upper left corner. Need to adjust in northwest direction

    texCenter.x = texCenter.x - (winWidth/2.0f);
    texCenter.y = texCenter.y - (winHeight/2.0f);
    
    SDL_FRect srcRect = {texCenter.x, texCenter.y, winWidth, winHeight};

    // Rotation angle
    double angle = 90.0;

    // Scaling factor
    float scale_factor = 1.0f;

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
                        if (event.key.key == SDLK_PAGEUP) 
                        {
                            scale_factor *= 1.1f;
                        }
                        if (event.key.key == SDLK_PAGEDOWN) 
                        {
                            scale_factor /= 1.1f;
                        }
                        if (event.key.key == SDLK_UP) 
                        {
                            srcRect.x += 50;
                        }
                        if (event.key.key == SDLK_DOWN) 
                        {
                            srcRect.x -= 50;
                        }
                        if (event.key.key == SDLK_LEFT) 
                        {
                            srcRect.y += 50;
                        }
                        if (event.key.key == SDLK_RIGHT) 
                        {
                            srcRect.y -= 50;
                        }
                    }
                    break;
                case SDL_EVENT_MOUSE_WHEEL:
                    {
                        if (event.wheel.y > 0)
                            //scale_factor *= 1.1f;      // Zoom in
                            angle = angle + 1;
                        else if (event.wheel.y < 0)
                            //scale_factor /= 1.1f;      // Zoom out
                            angle = angle - 1;
                        writeln("scale_factor = ", scale_factor);
                        //zoom = SDL_clamp(zoom, 0.1, 10.0); // Limit zoom range
                    }
                    break;
                default: 
                    break;
            }
        }

        //scale_factor = scale_factor * 0.999;       // 1.001;

        // Adjust the destination rectangle for scaling

        // writeln("First dst_rect.w = ", dst_rect.w);

        dst_rect.w = cast(int)(dst_rect.w * scale_factor);
        dst_rect.h = cast(int)(dst_rect.h * scale_factor);

        // writeln("dst_rect.w = ", dst_rect.w);

        dst_rect.x = ( cast(float) (winWidth - dst_rect.w  ) ) / 2.0f;
        dst_rect.y = ( cast(float) (winHeight - dst_rect.h ) ) / 2.0f;

        const ulong now = SDL_GetTicks();
        
        // we'll have a texture rotate around over 2 seconds (2000 milliseconds). 360 degrees in a circle
        
        //const float angle = (((float) ((int) (now % 2000))) / 2000.0f) * 360.0f;
        //angle = angle + 1.0;

        // Define the rotation center (center of the texture)
        
        SDL_FPoint center = {dst_rect.w / 2.0f, dst_rect.h / 2.0f};

        //writeln("srcRect = ", srcRect);
        //writeln("dst_rect = ", dst_rect);

        // Render the texture with scaling and rotation
        SDL_RenderClear(renderer);
        SDL_RenderTextureRotated(renderer, texture, &srcRect, &dst_rect, angle, &center, SDL_FLIP_NONE); // Apply rotation and scaling
        SDL_RenderPresent(renderer);

        SDL_Delay(400); // Wait for 2 seconds
    }
}


// https://github.com/libsdl-org/SDL/blob/main/examples/renderer/08-rotating-textures/rotating-textures.c

void fromGithub()
{
    // we will use this renderer to draw into this window every frame

    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;
    int texture_width = 0;
    int texture_height = 0;

    int WINDOW_WIDTH = 2048; // 1024;
    int WINDOW_HEIGHT = 2048; // 1024;

    createWindowAndRenderer("fromGithub", WINDOW_WIDTH, WINDOW_HEIGHT, cast(SDL_WindowFlags) 0, &window, &renderer);

    // Textures are pixel data that we upload to the video hardware for fast drawing. Lots of 2D
    // engines refer to these as "sprites." We'll do a static texture (upload once, draw many
    // times) with data from a bitmap file.

    // SDL_Surface is pixel data the CPU can access. SDL_Texture is pixel data the GPU can access.

    surface = loadImageToSurface("./images/earth1024x1024.png");

    texture_width = surface.w;   // SDL_FPoint
    texture_height = surface.h;  // saves call to 

    texture = createTextureFromSurface(renderer, surface);
    
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
                default: 
                    break;
            }
        }

    SDL_FPoint center;
    SDL_FRect dst_rect;
    const ulong now = SDL_GetTicks();

    // we'll have a texture rotate around over 2 seconds (2000 milliseconds). 360 degrees in a circle
    
    const float rotation = (((float) ((int) (now % 2000))) / 2000.0f) * 360.0f;

    // as you can see from this, rendering draws over whatever was drawn before it
    
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);  // black, full alpha
    SDL_RenderClear(renderer);  // start with a blank canvas

    // Center this one, and draw it with some rotation so it spins
    
    dst_rect.x = ( cast(float) (WINDOW_WIDTH - texture_width  ) ) / 2.0f;
    dst_rect.y = ( cast(float) (WINDOW_HEIGHT - texture_height) ) / 2.0f;
    dst_rect.w = cast(float) texture_width;
    dst_rect.h = cast(float) texture_height;
    
    // rotate it around the center of the texture; you can rotate it from a different point, too
    
    center.x = texture_width / 2.0f;
    center.y = texture_height / 2.0f;
    
    SDL_RenderTextureRotated(renderer, texture, null, &dst_rect, rotation, &center, SDL_FLIP_NONE);

    SDL_RenderPresent(renderer);  // put it all on the screen

    }
}






void rotateAndSavePNG()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("RotateAndSavePNG", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_Point win;

    getWindowSize(window, &win.x, &win.y);
    writeln("win size = ", win.x, " X ", win.y);

    SDL_Surface* surface = loadImageToSurface("./images/earth1024x1024.png");
    
    SDL_Texture* texture = createTextureFromSurface(renderer, surface);

    SDL_FPoint *center = null;
    
    
    /+
    In SDL3, there isn't a direct function to copy a texture to a surface. However, 
    you can achieve this by rendering the texture to a new texture, which can then 
    be converted to a surface. This involves setting the new texture as a render target, 
    rendering the original texture to it, and then reading the pixels from the rendering 
    target into a surface using SDL_RenderReadPixels
    +/
    
    // SDL_CreateTexture with the SDL_TEXTUREACCESS_TARGET flag to create a texture that 
    // can be rendered to
    
    // newTexture = SDL_CreateTexture(renderer, SDL_PixelFormat format, SDL_TextureAccess access, int w, int h);
    
    // Set the new texture as the render target: Use SDL_SetRenderTarget to make the new 
    // texture the target for rendering. 
    
    // bool SDL_SetRenderTarget(SDL_Renderer *renderer, SDL_Texture *texture);
    
    // Render the original texture to the new texture: Use SDL_RenderCopy or SDL_RenderCopyEx 
    // to draw the original texture onto the new texture. 
    
    
    
    // Read the pixels from the rendering target into a surface: Use SDL_RenderReadPixels 
    // to copy the pixel data from the new texture (the render target) into a memory buffer. 
    
    // SDL_Surface * SDL_RenderReadPixels(SDL_Renderer *renderer, const SDL_Rect *rect);
    
    // Create a surface from the memory buffer: Use SDL_CreateRGBSurfaceWithFormat to create 
    // an SDL_Surface from the memory buffe
    
    // Destroy the new texture: Use SDL_DestroyTexture to free the memory used by the new texture. 
    
    bool res = SDL_RenderTextureRotated(renderer, texture, null, null, 90.0, center, SDL_FLIP_NONE);
    if (res == false)
    {
        writeln("texture rotation failed");
    }
    

    string filePathAndName = "./images/earthRotated.png";


    saveSurfaceToPNGfile(surface, filePathAndName);
        
}




void zoom_grok()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Zoom Grok", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    int winW;  int winH;
    getWindowSize(window, &winW, &winH);
    writeln("texW x texH = ", winW, "  ", winH);

    //SDL_Surface* surface = loadImageToSurface("./images/earth1024x1024.png");
    
    SDL_Surface* surface = loadImageToSurface("./images/COMBINE.png");
    
    SDL_Texture* texture = createTextureFromSurface(renderer, surface);
    
    int maxX; int maxY;
    //bool r = SDL_GetWindowMaximumSize(window, &maxX, &maxY);
    getWindowSize(window, &maxX, &maxY);

    writeln("maxX and maxY = ", maxX, ", ", maxY);
    
    float tW;  float tH;
    getTextureSizeFloats(texture, &tW, &tH);
    writeln("&tW, &tH = ", tW, "----", tH);
                                 // swap w and h
    SDL_FRect destRect = { 0, 0, 6000,6000};    //cast(float) tH, cast(float) tW };
    SDL_FPoint *center = null;
    bool res = SDL_RenderTextureRotated(renderer, texture, null, /+&destRect+/ null, 90.0, center, SDL_FLIP_NONE); // 90 degree rotation    
    writeln("res = ", res);
        //SDL_RenderTexture(renderer, texture, null, &dstRect);
        SDL_RenderPresent(renderer);
        SDL_Delay(3000);
        exit(-1);
    
    
    float zoom = 1.0f; // Initial zoom level
    bool quit = false;
    SDL_Event event;
    int offsetX;
    int offsetY;
    while (!quit) 
    {
        while (SDL_PollEvent(&event)) 
        {
            switch (event.type)
            {
                case SDL_EVENT_KEY_DOWN:
                    {
                    
                    if (event.key.key == SDLK_UP) 
                    {  
                        offsetY = offsetY + 10;    
                    }
                    else
                    if (event.key.key == SDLK_DOWN) 
                    {  
                        offsetY = offsetY - 10;    
                    }
                    else
                    if (event.key.key == SDLK_LEFT) 
                    {  
                        offsetX = offsetX + 10;    
                    }
                    else
                    if (event.key.key == SDLK_RIGHT) 
                    {  
                        offsetX = offsetX - 10;    
                    }
                    
                    }
                    break;
                case SDL_EVENT_QUIT:
                    quit = true;
                    break;
                case SDL_EVENT_MOUSE_WHEEL:
                    // Adjust zoom based on mouse wheel
                    if (event.wheel.y > 0) zoom *= 1.1f; // Zoom in
                    else if (event.wheel.y < 0) zoom /= 1.1f; // Zoom out
                    //zoom = SDL_clamp(zoom, 0.1, 10.0); // Limit zoom range
                    break;
                default: 
                    break;
            }
        }
        writeln("zoom = ", zoom);

        // Clear the renderer
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_RenderClear(renderer);

        // Get texture dimensions
        float texW, texH;
        
        bool ok = SDL_GetTextureSize(texture, &texW, &texH);

        writeln("texW x texH = ", texW, "  ", texH);

        // Calculate scaled dimensions
        int scaledW = cast(int)(texW * zoom);
        int scaledH = cast(int)(texH * zoom);
        
        writeln("scaledW, scaledH = ", scaledW, ", ", scaledH);

        // Center the image
        int centerX = (winW - scaledW) / 2;
        int centerY = (winH - scaledH) / 2;
        
        centerX = centerX + offsetX;
        centerY = centerY + offsetY;
        
        writeln("centerX, centerY = ", centerX, ", ", centerY);

        // Define destination rectangle
        SDL_FRect dstRect = { cast(float) centerX, cast(float) centerY, cast(float) scaledW, cast(float) scaledH};
        
        writeln("dstRect = ", dstRect);

        // Render the texture with zoom
        SDL_RenderTexture(renderer, texture, null, &dstRect);

        // Present the frame
        SDL_RenderPresent(renderer);
        
    }
}





void zoomAnImage()
{
    SDL_Surface *earth;

    earth = loadImageToSurface("./images/earth1024x1024.png");

    SDL_Window   *window;
    SDL_Renderer *renderer;
    createWindowAndRenderer("Earth", earth.w, earth.h, cast(SDL_WindowFlags) 0, &window, &renderer);

    SDL_Surface *windowSurface = SDL_GetWindowSurface(window);

    /+
    Zooming is achieved by adjusting the source rectangle (srcRect) and destination rectangle (dstRect) 
    when rendering a texture. A smaller srcRect relative to the texture size zooms in by rendering a 
    smaller portion of the texture to a larger dstRect on the screen.
    +/

    //copySurfaceToSurface(earth, null, windowSurface, null);  // 1:1
    

    
    //SDL_Rect src = SDL_Rect(cast(int) earth.w*.25, cast(int)earth.h*.25, cast(int)earth.w*.75, cast(int)earth.h*.75);
    //writeln("src = ", src);
    
    //copySurfaceToSurface(earth, &src, windowSurface, null);

    SDL_UpdateWindowSurface(window);
    
    SDL_Delay(6000);
}






void assembleQuadFilesItoOnePNGfile()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Assemble", 1500, 1500, cast(SDL_WindowFlags) 0, &window, &renderer);

    writeln("window = ", window);
    writeln("renderer = ", renderer);

    SDL_Surface *image;

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA0.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB0.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC0.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD0.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE0.png");

    string pixelFormat = to!string(SDL_GetPixelFormatName(image.format));
    writeln("pixelFormat = ", pixelFormat);
    writeln("image.w x h = ", image.w, " x ", image.h);

    int width = image.w;
    int height = image.h;

    if (isOdd(width*2) || isOdd(height*2)) 
    {
        writeln("Image dimensions must be divisible by 2");
    }

    SDL_Surface *combined = createSurface(width*2, height*2, image.format);

    SDL_Rect[4] quads =
    [
        SDL_Rect(0,     0,      width, height),  // top left
        SDL_Rect(width, 0,      width, height),  // top right
        SDL_Rect(0,     height, width, height),  // bottom left
        SDL_Rect(width, height, width, height)   // bottom right
    ];

    copySurfaceToSurface(image, null, combined, &quads[0]);

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA1.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB1.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC1.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD1.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE1.png");

    copySurfaceToSurface(image, null, combined, &quads[1]);

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA2.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB2.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC2.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD2.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE2.png");

    copySurfaceToSurface(image, null, combined, &quads[2]);

    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadA3.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadB3.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadC3.png");
    //image = loadImageToSurface("./images/CNA_Maps_PNG/quadD3.png");
    image = loadImageToSurface("./images/CNA_Maps_PNG/quadE3.png");

    copySurfaceToSurface(image, null, combined, &quads[3]);

    // /+ ============================================================
    string fileName = "./images/" ~ "COMBINE" ~ "_E" ~ ".png";
    if (IMG_SavePNG(combined, toStringz(fileName)) < 0) {
    writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    exit(-1);
    //  ============================================================ +/

    SDL_Surface *dstSurface = SDL_CreateSurface(1500, 1500, image.format);

    // copySurfaceToSurface(combined, null, dstSurface, null);

    SDL_Surface *windowSurface = SDL_GetWindowSurface(window);

    // Blit the image onto the window surface
    // copySurfaceToSurface(dstSurface, null, windowSurface, null);

    copySurfaceToSurface(combined, &quads[1], windowSurface, null);

    SDL_UpdateWindowSurface(window);

    writeln("after SDL_UpdateWindowSurface");

    //SDL_Delay(3000);


    auto sRect = SDL_Rect(2000, 2000, width, height);

    copySurfaceToSurface(combined, &sRect, windowSurface, null);

    SDL_UpdateWindowSurface(window);

    SDL_Delay(3000);
    
    foreach (int i; 0 .. 100) 
    {
        sRect = SDL_Rect(i*50, i*50, width, height);

        copySurfaceToSurface(combined, &sRect, windowSurface, null);

        SDL_UpdateWindowSurface(window);

        SDL_Delay(50);
    }


    /+
    sRect = SDL_Rect(2200, 2200, width, height);

    copySurfaceToSurface(combined, &sRect, windowSurface, null);

    SDL_UpdateWindowSurface(window);

    SDL_Delay(3000);
    +/
    
    exit(-1);
    
}






/+
void displayTextureProperties(SDL_Texture *texture)
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
    
    //SDL_TextureInfo textureInfo;
    //SDL_GetTextureInfo(texture, &textureInfo);

    //printf("Texture Format: %s\n", SDL_GetPixelFormatName(textureInfo.format));
    
    SDL_PixelFormat format = texture.format;
    writeln("+++++++++++++ format = ", format);

    // Use SDL_GetNumberProperty, SDL_GetStringProperty, etc., to retrieve specific 
    // properties from the returned SDL_PropertiesID
        
    // Get the texture's pixel format
    
    //long format = SDL_GetNumberProperty(texProps, SDL_PROP_TEXTURE_FORMAT_NUMBER, -1);
    //if (format == -1) 
    //{
    //    writeln("SDL_GetNumberProperty failed");  exit(-1);
    //} 
    
    //string pixelFormat = to!string(SDL_GetPixelFormatName(format));
    //writeln("pixelFormat = ", pixelFormat);
    
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
+/

void trimFileIfPixelsAreNotEven()
{
    SDL_Surface *image = loadImageToSurface("./images/quadA0.png");

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
    SDL_Surface *bigImage = loadImageToSurface("./images/quadA0.png");

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

    m1.texture = loadImageToTextureWithAccess(m1.renderer, "./images/1.png", SDL_TEXTUREACCESS_STREAMING);

    m2 = m1;

    m2.window = SDL_CreateWindow("IGNORE", 
                                 m2.win.w, 
                                 m2.win.h, 
                                 SDL_WINDOW_RESIZABLE);

    m2.renderer = SDL_CreateRenderer(m2.window, "Renderer 2");

    m2.texture = loadImageToTextureWithAccess(m2.renderer, "./images/2.png", SDL_TEXTUREACCESS_STREAMING);

    main.win.w = 1000;
    main.win.h = 1000;

    main.window = SDL_CreateWindow("MAIN PNG Viewer", 
                                   main.win.w, 
                                   main.win.h, 
                                   SDL_WINDOW_RESIZABLE);

    main.renderer = SDL_CreateRenderer(main.window, "Renderer 3");

    main.texture = loadImageToTextureWithAccess(main.renderer, "./images/2.png", SDL_TEXTUREACCESS_STREAMING);
    
/+
    main.texture = SDL_CreateTexture(main.renderer,
                                     SDL_PIXELFORMAT_ARGB8888,
                                     SDL_TEXTUREACCESS_STATIC, 
                                     main.win.w, main.win.h); 
+/

    //SDL_SetRenderTarget(main.renderer, largeTexture);  // specify that you want to draw to the target texture instead of the screen.

    displayTextureProperties(m1.texture);
    displayTextureProperties(m2.texture);
    displayTextureProperties(main.texture);
    
    //D2 d2 = getTextureSizeInts(m1.texture);
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


SDL_Surface* assembleHugeSurface()
{
    SDL_Window   *window   = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture  = null;
    SDL_Surface  *surface  = null;

    //int winWidth = 1000;
    //int winHeight = 1000;

    //createWindowAndRenderer("Real Big Texture", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    //SDL_PropertiesID props = SDL_GetRendererProperties(renderer);
    //int max_texture_size = cast(int) SDL_GetNumberProperty(props, SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER, 0);
    
    //writeln("max_texture_size = ", max_texture_size);

    SDL_Surface *image0;
    SDL_Surface *image1;
    SDL_Surface *image2;
    SDL_Surface *image3;
    SDL_Surface *image4;

    image0 = loadImageToSurface("./images/1.png");
    image1 = loadImageToSurface("./images/2.png");
    image2 = loadImageToSurface("./images/3.png");
    image3 = loadImageToSurface("./images/4.png");
    image4 = loadImageToSurface("./images/5.png");

    //string pixelFormat = to!string(SDL_GetPixelFormatName(image0.format));
    //writeln("pixelFormat = ", pixelFormat);
    //writeln("image.w x h = ", image0.w, " x ", image0.h);

    int width = image0.w;
    int height = image0.h;


    SDL_Surface *surface0 = createSurface(width, height, image0.format);
    SDL_Surface *surface1 = createSurface(width, height, image1.format);
    SDL_Surface *surface2 = createSurface(width, height, image2.format);
    SDL_Surface *surface3 = createSurface(width, height, image3.format);
    SDL_Surface *surface4 = createSurface(width, height, image4.format);


 // SDL_Surface *huge = createSurface(5*6692, 1*10594, image0.format);
    SDL_Surface *huge = createSurface(5*6692, 1*10594, SDL_PIXELFORMAT_RGBA8888);

    SDL_Rect[5] quads =
    [
        SDL_Rect(0,     0,  6680, 10594),
        SDL_Rect(6681,  0,  6686, 10594),
        SDL_Rect(13368, 0,  6688, 10594),
        SDL_Rect(20057, 0,  6692, 10594),
        SDL_Rect(26749, 0,  6690, 10594)
    ];

    copySurfaceToSurface(image0, null, huge, &quads[0]);
    copySurfaceToSurface(image1, null, huge, &quads[1]);
    copySurfaceToSurface(image2, null, huge, &quads[2]);
    copySurfaceToSurface(image3, null, huge, &quads[3]);
    copySurfaceToSurface(image4, null, huge, &quads[4]);
    
    /+
    string fileName = "./images/" ~ "huge" ~ ".png";
    if (IMG_SavePNG(huge, toStringz(fileName)) < 0) {
        writefln("IMG_SavePNG failed: %s", SDL_GetError());
    }
    else
    {
        writeln("IMG_SavePNG succeeded");
    }
    +/
    
    return huge;
}





