
module sdl_funcs_with_error_handling;


import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import breakup;
import magnify;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations




void getWindowMaximumSize(SDL_Window *window, int *w, int *h)
{
    int width;  int height;
    if (SDL_GetWindowMaximumSize(window, &width, &height) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );
        exit(-1);
    }
    writeln("width = ", width);
    writeln("height = ", height);
    
}




void lockTextureToSurface(SDL_Texture *texture, const SDL_Rect *rect, SDL_Surface **surface)
{
    bool res = SDL_LockTextureToSurface(texture, rect, surface);
    if (res == false)
    {
        writeln("SDL_LockTextureToSurface failed: ", to!string(SDL_GetError()));  
        exit(-1);
    }
}


SDL_PropertiesID getTextureProperties(SDL_Texture *texture)
{
    SDL_PropertiesID props = SDL_GetTextureProperties(texture);  // SDL3 only function
    if (props == 0) 
    {
        writeln("SDL_GetTextureProperties failed: ", to!string(SDL_GetError()));  
        exit(-1);
    }
    return props;
}


void blitSurface(SDL_Surface *srcSurface, const SDL_Rect *srcRect, 
                 SDL_Surface *dstSurface, const SDL_Rect *dstRect)
{
    // 
    if (SDL_BlitSurface(srcSurface, srcRect, dstSurface, dstRect) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );
        exit(-1);
    }
}

// This is a generalized function of copySurfaceToStreamingTexture

void copySurfaceToTexture(SDL_Surface *surface, const SDL_Rect *surRect,
                          SDL_Texture *texture, const SDL_Rect *texRect)
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
    lockTextureToSurface(texture, null, &lockedSurface);  // will fail if texture is STATIC

    /+
    SDL_FillSurfaceRect(surface, null, SDL_MapRGB(SDL_GetPixelFormatDetails(surface.format), null, 0, 255, 0));
    SDL_FillSurfaceRect(surface, &r, SDL_MapRGB(SDL_GetPixelFormatDetails(surface.format), null, 0, 0, 255));
     +/

    blitSurface(surface, surRect, lockedSurface, texRect);

    SDL_UnlockTexture(texture);  // upload the changes (and frees the temporary surface)
}


// experimental

void copyTextureToSurface(SDL_Texture *texture, const SDL_Rect *texRect,
                          SDL_Surface *surface, const SDL_Rect *surRect)
{
    SDL_Surface *lockedSurface = null;
    
    lockTextureToSurface(texture, null, &lockedSurface);  // will fail if texture is STATIC

    blitSurface(lockedSurface, texRect, surface, surRect);

    SDL_UnlockTexture(texture);  // upload the changes (and frees the temporary surface)
}


void copySurfaceToSurface(SDL_Surface *srcSurface, const SDL_Rect *srcRect,
                          SDL_Surface *dstSurface, const SDL_Rect *dstRect)
{
    //SDL_Surface *lockedSurface = null;
    
    //lockTextureToSurface(texture, null, &lockedSurface);  // will fail if texture is STATIC

    blitSurface(srcSurface, srcRect, dstSurface, dstRect);

    //SDL_UnlockTexture(texture);  // upload the changes (and frees the temporary surface)
}


SDL_Surface* duplicateSurface(SDL_Surface* source) 
{
    SDL_Surface* dest = SDL_CreateSurface(source.w, source.h, SDL_PIXELFORMAT_RGBA8888);
    SDL_BlitSurface(source, null, dest, null);
    return dest;
}


void displayTextureProperties(SDL_Texture* texture) 
{
    writeln("Texture Properties");
    writeln("------------------");
    /+
    https://wiki.libsdl.org/SDL3/README-migration
    
    SDL_QueryTexture() has been removed. The properties of the texture can be queried using 
        SDL_PROP_TEXTURE_FORMAT_NUMBER, 
        SDL_PROP_TEXTURE_ACCESS_NUMBER, 
        SDL_PROP_TEXTURE_WIDTH_NUMBER, and 
        SDL_PROP_TEXTURE_HEIGHT_NUMBER. 
    A function SDL_GetTextureSize() has been added to get the size of the texture as floating point values.
    +/

    SDL_PixelFormat pixelFormat;
    SDL_PropertiesID props = getTextureProperties(texture);  // SDL3 only function

                                      // SDL3 only function
    pixelFormat = cast (SDL_PixelFormat) SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, SDL_PIXELFORMAT_UNKNOWN);
        
                          // SDL2 and SDL3 function
    const char *formatName = SDL_GetPixelFormatName(pixelFormat);
    printf("    Texture pixel format name: %s\n", formatName);

                                            // SDL3 only
    const SDL_PixelFormatDetails* details = SDL_GetPixelFormatDetails(pixelFormat);
    if (!details)
    {
        printf("SDL_GetPixelFormatDetails failed: %s\n", SDL_GetError());
    }

    writeln("    Bits per Pixel: ", details.bits_per_pixel);
    writeln("    Bytes per Pixel: ", details.bytes_per_pixel);
    writefln("    Rmask: 0x%08X, Gmask: 0x%08X, Bmask: 0x%08X, Amask: 0x%08X\n",
             details.Rmask, details.Gmask, details.Bmask, details.Amask);

    void *pixels;
    int pitch;
                
    lockTexture(texture, null, &pixels, pitch);  // note: texture must be streaming for locking to work

    SDL_TextureAccess access = cast(SDL_TextureAccess) SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_ACCESS_NUMBER, -1);

    writeln("    access = ", access);
    
    switch (access) 
    {
        case SDL_TEXTUREACCESS_STATIC:
            printf("    Texture is SDL_TEXTUREACCESS_STATIC. Suitable for infrequent updates.\n");
            break;
        case SDL_TEXTUREACCESS_STREAMING:
            printf("    Texture is SDL_TEXTUREACCESS_STREAMING. Suitable for frequent updates.\n");
            break;
        case SDL_TEXTUREACCESS_TARGET:
            printf("    SDL_TEXTUREACCESS_TARGET. Texture is a render target.\n");
            break;
        default:
            printf("Unknown texture access mode: %d\n", access);
            break;
    }

    // The SDL_GetNumberProperty function, when used with integers in SDL 3, returns a 64-bit integer 
    // instead of a 32-bit int for several reasons related to design and flexibility: Support for Large 
    // Values, Consistency Across Properties, Future-Proofing, and Platform Portability

    long wide = SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_WIDTH_NUMBER, 0);
    long high = SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_HEIGHT_NUMBER, 0);

    writeln("    wide = ", wide);
    writeln("    high = ", high);

}

/+
struct SDL_Surface
{
    SDL_SurfaceFlags flags;     // The flags of the surface, read-only
    SDL_PixelFormat format;     // The format of the surface, read-only
    int w;                      // The width of the surface, read-only
    int h;                      // The height of the surface, read-only
    int pitch;                  // The distance in bytes between rows of pixels, read-only
    void *pixels;               // A pointer to the pixels of the surface, the pixels are writeable if non-NULL

    int refcount;               // Application reference count, used when freeing surface
    void *reserved;             // Reserved for internal use
};
+/

void displaySurfaceProperties(SDL_Surface* surface) 
{
    writeln("Surface Properties");
    writeln("------------------");
    writeln("    surface = ", surface);
    writeln("    flags   = ", surface.flags);
    writeln("    format  = ", surface.format);
    writeln("    width   = ", surface.w);
    writeln("    height  = ", surface.h);
    writeln("    pitch   = ", surface.pitch);
    writeln("    pixels  = ", surface.pixels);
    writeln("    refcount = ", surface.refcount);
}

void getSurfaceWidthAndHeight(SDL_Surface* surface, int *w, int *h) 
{
    *w = surface.w;
    *h = surface.h;
}



SDL_Renderer* createRenderer(SDL_Window *window, string rendererName)
{
    import std.utf : toUTFz;
    SDL_Renderer *renderer =  SDL_CreateRenderer(window, toUTFz!(const(char)*)(rendererName) );
    if (renderer == null)
    {
        writeln("SDL_CreateRenderer failed: ", to!string(SDL_GetError()));
        exit(-1);
    }
    return renderer;
}


void createWindow(string winName, int w, int h, SDL_WindowFlags flags, SDL_Window **window)
{
    *window = SDL_CreateWindow(winName.toStringz(), w, h, flags);
    if (window == null)
    {
        writeln("SDL_CreateWindow failed: ", to!string(SDL_GetError()) );
        exit(-1);
    }
}


/+
void createWindowAndRenderer(string title, int width, int height, SDL_WindowFlags windowFlags, 
                             SDL_Window **window, SDL_Renderer **renderer)
{
    // If you pass 0 for the flags parameter
    // Essentially, passing 0 results in a standard, visible, non-resizable window with decorations, 
    // positioned according to the system's default placement (or SDL_WINDOWPOS_UNDEFINED).

    bool result = SDL_CreateWindowAndRenderer(toStringz(title), width, height, 
                                              windowFlags, window, renderer);
    if (result == false)
    {
        writeln("SDL_CreateWindowAndRenderer failed: ", to!string(SDL_GetError())); 
        exit(-1);
    }
    if ((window == null) || (renderer == null))
    {
        writeln("either window or renderer or both were not initialized");
        exit(-1);
    }
}
+/