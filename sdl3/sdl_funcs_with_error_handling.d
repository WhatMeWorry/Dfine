
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



void lockTextureToSurface(SDL_Texture *texture, const SDL_Rect *rect, SDL_Surface **surface)
{
    bool res = SDL_LockTextureToSurface(texture, rect, surface);
    if (res == false)
    {
        writeln("SDL_LockTextureToSurface failed: ", to!string(SDL_GetError()));  
        exit(-1);
    }
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
    SDL_PropertiesID props = SDL_GetTextureProperties(texture);  // SDL3 only function
    if (props == 0) 
    {
        printf("Failed to get texture properties: %s\n", SDL_GetError());
    } 
    else 
    {                                        // SDL3 only function
        pixelFormat = cast (SDL_PixelFormat) SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, SDL_PIXELFORMAT_UNKNOWN);
        
                                 // SDL2 and SDL3 function
        const char *formatName = SDL_GetPixelFormatName(pixelFormat);
        printf("    Texture pixel format name: %s\n", formatName);
    }
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
    SDL_SurfaceFlags flags;     /**< The flags of the surface, read-only */
    SDL_PixelFormat format;     /**< The format of the surface, read-only */
    int w;                      /**< The width of the surface, read-only. */
    int h;                      /**< The height of the surface, read-only. */
    int pitch;                  /**< The distance in bytes between rows of pixels, read-only */
    void *pixels;               /**< A pointer to the pixels of the surface, the pixels are writeable if non-NULL */

    int refcount;               /**< Application reference count, used when freeing surface */

    void *reserved;             /**< Reserved for internal use */
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

