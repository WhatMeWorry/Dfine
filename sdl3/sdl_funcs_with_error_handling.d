
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
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}




void lockTextureToSurface(SDL_Texture *texture, const SDL_Rect *rect, SDL_Surface **surface)
{
    if (SDL_LockTextureToSurface(texture, rect, surface) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


SDL_PropertiesID getTextureProperties(SDL_Texture *texture)
{
    SDL_PropertiesID props = SDL_GetTextureProperties(texture);  // SDL3 only function
    if (props == 0) 
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return props;
}


SDL_PropertiesID getSurfaceProperties(SDL_Surface *surface)
{
    SDL_PropertiesID props = SDL_GetSurfaceProperties(surface);
    if (props == 0) 
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return props;
}





//bool SDL_BlitSurfaceScaled(SDL_Surface *src, const SDL_Rect *srcrect, SDL_Surface *dst, const SDL_Rect *dstrect, SDL_ScaleMode scaleMode);
void blitSurfaceScaled(SDL_Surface *srcSurface, const SDL_Rect *srcRect, 
                       SDL_Surface *dstSurface, const SDL_Rect *dstRect, SDL_ScaleMode scaleMode)
{
    writeln("srcSurface = ", srcSurface, "  srcRect = ", srcRect, "  dstSurface = ", dstSurface, "   dstRect = ", dstRect);
    if (SDL_BlitSurfaceScaled(srcSurface, srcRect, dstSurface, dstRect, scaleMode) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


void blitSurface(SDL_Surface *srcSurface, const SDL_Rect *srcRect, 
                 SDL_Surface *dstSurface, const SDL_Rect *dstRect)
{
    if (SDL_BlitSurface(srcSurface, srcRect, dstSurface, dstRect) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


void blitSurfaceToSurface(SDL_Surface *src, SDL_Rect *srcRect, SDL_Surface *dst, SDL_Rect *dstRect)
{
    if (SDL_BlitSurface(src, srcRect, dst, dstRect) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
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



void getWindowSurface(SDL_Window *window, SDL_Surface** windowSurface)
{
    *windowSurface = SDL_GetWindowSurface(window);
    if (windowSurface == null)
    {
        writeln("SDL_GetWindowSurface failed: ", to!string(SDL_GetError()) );
        exit(-1);
    }
}


void createWindowAndRenderer(string title, int width, int height, SDL_WindowFlags windowFlags, 
                             SDL_Window **window, SDL_Renderer **renderer)
{
    // If you pass 0 for the flags parameter
    // Essentially, passing 0 results in a standard, visible, non-resizable window with decorations, 
    // positioned according to the system's default placement (or SDL_WINDOWPOS_UNDEFINED).

    if (SDL_CreateWindowAndRenderer(toStringz(title), width, height, windowFlags, window, renderer) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    if ((window == null) || (renderer == null))
    {
        writeln("either window or renderer or both were not initialized");
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}



void loadImageToSurface(string file, SDL_Surface** surface)
{
    *surface = IMG_Load(toStringz(file));  // IMG_Load function supports a wide range of image formats,
    if (surface == null)                               // including PCX, GIF, JPG, TIF, LBM, and PNG.
    {
        writeln("IMG_Load failed with file: ", file, " because ", to!string(SDL_GetError()));
        exit(-1);    // IMG_Load failed with file: ./images/huge.png because Image too large to decode
    }                // IMG_Load failed with file: ./images/9.png because Couldn't open ./images/9.png: 
}





void updateWindowSurface(SDL_Window *window)
{
    if (SDL_UpdateWindowSurface(window) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


void getPixelFormatDetails(SDL_PixelFormat pixelFormat, SDL_PixelFormatDetails *details)
{
    //details = SDL_GetPixelFormatDetails(pixelFormat);
    //if (pixelFormatDetails != 0)
    //{
    //    writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
    //    writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    //}
}

/+

// Surface >> props >> pixelFormat >> details

void displayPixelFormatDetails(SDL_Surface *surface)
{
    SDL_PixelFormat pixelFormat;
    SDL_PropertiesID props = getSurfaceProperties(surface);
    
    pixelFormat = cast (SDL_PixelFormat) SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, SDL_PIXELFORMAT_UNKNOWN);

    //const char *formatName = SDL_GetPixelFormatName(pixelFormat);
    //printf("    Surface pixel format name: %s\n", formatName);
    writeln("after SDL_GetNumberProperty and before SDL_GetPixelFormatDetails");
    const SDL_PixelFormatDetails* details = SDL_GetPixelFormatDetails(pixelFormat);
    if (!details)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }

    const char *formatName = SDL_GetPixelFormatName(pixelFormat);
    printf("     Surface pixel format: %s\n", formatName);
    writeln("    Bits per Pixel: ", details.bits_per_pixel);
    writeln("    Bytes per Pixel: ", details.bytes_per_pixel);
    writefln("   Rmask: 0x%08X, Gmask: 0x%08X, Bmask: 0x%08X, Amask: 0x%08X\n",
                 details.Rmask, details.Gmask, details.Bmask, details.Amask);
}
+/


/+
    SDL_PropertiesID SDL_GetSurfaceProperties(SDL_Surface *surface);  // SDL3 only
    
    SDL_PropertiesID SDL_GetTextureProperties(SDL_Texture *texture);  // SDL3 only
    
    SDL_PropertiesID SDL_GetWindowProperties(SDL_Window *window);
    
    typedef Uint32 SDL_PropertiesID;  // SDL3 only
    
    In SDL3, SDL_PropertiesID is a data type used to represent a property group.
    
    What is a property group?
    
    A property group is a collection of variables (properties) that can be created and accessed by name during 
    rogram execution. Think of it like a dynamic structure where you can add, retrieve, and manage different 
    types of data without having to pre-define everything in a fixed structure.
+/