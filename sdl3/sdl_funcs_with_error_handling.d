
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

/+
void getTextureSize(SDL_Texture *texture, int *w, int *h)
{
    if (SDL_GetTextureSize(texture, w, h) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }

}
+/

SDL_Surface* loadImageToSurface(string file)
{
    SDL_Surface *surface = IMG_Load(toStringz(file));  // IMG_Load function supports a wide range of image formats,
    if (surface == null)                               // including PCX, GIF, JPG, TIF, LBM, and PNG.
    {
        writeln(__FUNCTION__, " failed with file ",file, " because ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }                
    return surface;
}


SDL_Texture* loadImageToTexture(SDL_Renderer *renderer, string file)
{
    SDL_Texture *texture = IMG_LoadTexture(renderer, toStringz(file));  // Some of the supported formats include 
                                                                        // BMP, GIF, JPG, PNG, TGA, ICO, and CUR
    if (texture == null) 
    {
        writeln(__FUNCTION__, " failed with file ",file, " because ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return texture;
}


SDL_Texture* loadImageToStreamingTexture(SDL_Renderer *renderer, string file)
{
    SDL_Surface *surface = IMG_Load(toStringz(file));
    
    SDL_Texture *texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, surface.w, surface.h);

    copySurfaceToTexture(surface, null, texture, null);

    return texture;
}


void createSurface(int width, int height, SDL_PixelFormat format, SDL_Surface **surface)
{
    *surface =  SDL_CreateSurface(width, height, format);
    if (surface == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


// Uint32 SDL_MapRGBA(const SDL_PixelFormatDetails *format, const SDL_Palette *palette, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

uint mapRGBA(const SDL_PixelFormatDetails *format, const SDL_Palette *palette, ubyte  r, ubyte  g, ubyte  b, ubyte  a)
{
     uint u =  SDL_MapRGBA(format, palette, r, g, b, a);

     return u;
}




void lockTexture(SDL_Texture *texture, const SDL_Rect *rect, void **pixels, int pitch)
{
    bool res = SDL_LockTexture(texture, null, pixels, &pitch);
    if (res == false)
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



void fillSurfaceRect(SDL_Surface *dst, const SDL_Rect *rect, uint color)
{
    if (SDL_FillSurfaceRect(dst, rect, color) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


SDL_Texture* createTextureFromSurface(SDL_Renderer *renderer, SDL_Surface *surface)
{
    SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);
    if (texture == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return texture;
}


SDL_Texture* createTexture(SDL_Renderer *renderer, SDL_PixelFormat format, SDL_TextureAccess access, int width, int height)
{
    SDL_Texture *texture = SDL_CreateTexture(renderer, format, access, width, height);
    if (!texture)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return texture;
}


void setTextureBlendMode(SDL_Texture *texture, SDL_BlendMode blendMode)
{
    if (SDL_SetTextureBlendMode(texture, blendMode) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}



void blitSurfaceScaled(SDL_Surface *srcSurface, const SDL_Rect *srcRect, 
                       SDL_Surface *dstSurface, const SDL_Rect *dstRect, SDL_ScaleMode scaleMode)
{
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


SDL_PropertiesID createProperties()
{
    SDL_PropertiesID props = SDL_CreateProperties();  // 0 on failure
    if (props == 0)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return props;
}



// duplicates textures

void queryTextureSDL3(SDL_Texture *texture, SDL_PixelFormat *format, SDL_TextureAccess  *access, int *w, int *h)
{
    float wf; float hf;
    SDL_GetTextureSize(texture, &wf, &hf);
    
    *w = cast(int) wf;
    *h = cast(int) hf;

    SDL_PropertiesID props = getTextureProperties(texture);

    *format = cast(SDL_PixelFormat) getNumberProperty(props, SDL_PROP_TEXTURE_FORMAT_NUMBER, 0);

    if (*format == SDL_PIXELFORMAT_RGBA8888)
        writeln("format is SDL_PIXELFORMAT_RGBA8888");
    else
        writeln("format is NOT SDL_PIXELFORMAT_RGBA8888");

    *access = cast(SDL_TextureAccess) getNumberProperty(props, SDL_PROP_TEXTURE_ACCESS_NUMBER, 0);

    printTextureAccess(*access);
}



SDL_Texture* createTextureFromTexture(SDL_Texture *texture)
{
    // you can retrieve the renderer associated with a texture using the SDL_GetRenderer function. This 
    // function takes a SDL_Texture pointer as input and returns a pointer to the SDL_Renderer that was 
    // used to create the texture. 
    
    SDL_Renderer *renderer = SDL_GetRendererFromTexture(texture);  // retrieve the renderer associated with this texture
    
    SDL_PropertiesID texProps = getTextureProperties(texture);  // SDL3 only function
    
    SDL_PixelFormat    format;  
    SDL_TextureAccess  access;  
    int w; 
    int h;
    
    queryTextureSDL3(texture, &format, &access, &w, &h);  // SDL_QueryTexture is in SDL2 and was removed from SDL3
    
    writeln("texture = ", texture);
    writeln("format = ", format);
    writeln("access = ", access);
    writeln("w = ", w);
    writeln("h = ", h);
    
    access = SDL_TEXTUREACCESS_TARGET;
    
    SDL_Texture *newTexture = SDL_CreateTexture(renderer, format, access, w, h);  // SDL3 only

    writeln("newTexture = ", newTexture);
    return newTexture;
}









// you cannot directly blit (copy) one texture to another texture
/+
Create a Target Texture:
Ensure it has the SDL_TEXTUREACCESS_TARGET access flag when creating it with SDL_CreateTexture

Set the Render Target:
Use SDL_SetRenderTarget to set the destination texture as the render target for the renderer.

Render the Source Texture
Use SDL_RenderCopy or SDL_RenderCopyEx to copy the source texture onto the render target (destination texture)

Reset the Render Target
After rendering, reset the render target to the default (usually the window) using SDL_SetRenderTarget(renderer, NULL)
+/

void copyTextureToTexture(SDL_Texture *srcTexture, const SDL_Rect *srcRect,
                          SDL_Texture *dstTexture, const SDL_Rect *dstRect)
{
    // SDL_Texture* sourceTexture = ...; // Assume this is already created and loaded
    // SDL_Texture* targetTexture = ...; // Assume this is already created

    SDL_Renderer *renderer = SDL_GetRendererFromTexture(srcTexture);

    // Set the target texture as the render target

    SDL_SetRenderTarget(renderer, dstTexture);

    // Copy the source texture onto the target

    // bool SDL_RenderTexture(SDL_Renderer *renderer, SDL_Texture *texture, const SDL_FRect *srcrect, const SDL_FRect *dstrect);
    // void renderTexture(SDL_Renderer *renderer, SDL_Texture *texture, const SDL_FRect *srcrect, const SDL_FRect *dstrect)

    // SDL_RenderCopy(renderer, srcTexture, null, null);       SDL2 only

    renderTexture(renderer, srcTexture, cast(const(SDL_FRect*)) srcRect, cast(const(SDL_FRect*)) dstRect);  // SDL3 only

    // Reset the render target if needed
    SDL_SetRenderTarget(renderer, null);
}








SDL_Surface* duplicateSurface(SDL_Surface* source) 
{
    SDL_Surface* dest = SDL_CreateSurface(source.w, source.h, SDL_PIXELFORMAT_RGBA8888);
    SDL_BlitSurface(source, null, dest, null);
    return dest;
}




// SDL_TEXTUREACCESS_STATIC: suitable for textures with infrequent updates
// SDL_TEXTUREACCESS_STREAMING: suitable for textures with frequent updates
// SDL_TEXTUREACCESS_TARGET: textures are render targets

SDL_TextureAccess getTextureAccess(SDL_Texture* texture)
{
    SDL_PropertiesID props = getTextureProperties(texture);  // SDL3 only function
    
    SDL_TextureAccess access = cast(SDL_TextureAccess) SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_ACCESS_NUMBER, -1);

    if ((access == SDL_TEXTUREACCESS_STATIC) || (access == SDL_TEXTUREACCESS_STREAMING) ||
        (access == SDL_TEXTUREACCESS_TARGET))
    {
        return access;
    }
    else
    {
        writeln(__FUNCTION__, " failed: invalid texture access ", access);
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


void printTextureAccess(SDL_TextureAccess access)
{
    switch (access) 
    {
        case SDL_TEXTUREACCESS_STATIC:
            writeln("Texture access is SDL_TEXTUREACCESS_STATIC. Suitable for infrequent updates");
            break;
        case SDL_TEXTUREACCESS_STREAMING:
            writeln("Texture access is SDL_TEXTUREACCESS_STREAMING. Suitable for frequent updates");
            break;
        case SDL_TEXTUREACCESS_TARGET:
            writeln("Texture access is SDL_TEXTUREACCESS_TARGET. Texture is a render target");
            break;
        default:
            writeln("Unknown texture access mode: ", access);
            break;
    }
}


void displayTextureProperties(SDL_Texture* texture) 
{
    writeln("Texture Properties");
    writeln("------------------");
    writeln("texture = ", texture);
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

    //void *pixels;
    //int pitch;
                
    //lockTexture(texture, null, &pixels, pitch);  // note: texture must be streaming for locking to work

    SDL_TextureAccess access = cast(SDL_TextureAccess) SDL_GetNumberProperty(props, SDL_PROP_TEXTURE_ACCESS_NUMBER, -1);

    printTextureAccess(access);

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


// Eventually replace with void createRenderer(...) below

// Keeps failing with "Parameter 'renderer' is invalid"

SDL_Renderer* createRenderer(SDL_Window *window, string rendererName)
{
    import std.utf : toUTFz;
    SDL_Renderer *renderer =  SDL_CreateRenderer(window, toUTFz!(const(char)*)(rendererName) );
    if (renderer == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return renderer;
}


void createRenderer(SDL_Window *window, string rendererName, SDL_Renderer **renderer)
{
    import std.utf : toUTFz;
    *renderer =  SDL_CreateRenderer(window, toUTFz!(const(char)*)(rendererName) );
    if (renderer == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}





void createWindow(string winName, int w, int h, SDL_WindowFlags flags, SDL_Window **window)
{
    *window = SDL_CreateWindow(winName.toStringz(), w, h, flags);
    if (window == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}



void getWindowSurface(SDL_Window *window, SDL_Surface** windowSurface)
{
    *windowSurface = SDL_GetWindowSurface(window);
    if (windowSurface == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
}


//bool SDL_RenderTexture(SDL_Renderer *renderer, SDL_Texture *texture, const SDL_FRect *srcrect, const SDL_FRect *dstrect);

void renderTexture(SDL_Renderer *renderer, SDL_Texture *texture, const SDL_FRect *srcrect, const SDL_FRect *dstrect)
{
    if (SDL_RenderTexture(renderer, texture, srcrect, dstrect) == false)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
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


SDL_PixelFormatDetails* getPixelFormatDetails(SDL_PixelFormat pixelFormat)
{
    const SDL_PixelFormatDetails* details = SDL_GetPixelFormatDetails(pixelFormat);
    if (details == null)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return cast(SDL_PixelFormatDetails*) details;  // cast away the constness with cast(SDL_PixelFormatDetails*)
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
    program execution. Think of it like a dynamic structure where you can add, retrieve, and manage different 
    types of data without having to pre-define everything in a fixed structure.
+/


// Renderer Properties (not a complete list but these seem to be the most used
/+
SDL_PROP_RENDERER_NAME_STRING: the name of the rendering driver
SDL_PROP_RENDERER_WINDOW_POINTER: the window where rendering is displayed, if any
SDL_PROP_RENDERER_SURFACE_POINTER: the surface where rendering is displayed, if this is a software renderer without a window
SDL_PROP_RENDERER_VSYNC_NUMBER: the current vsync setting
SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER: the maximum texture width and height
SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER: a (const SDL_PixelFormat *) array of pixel formats, terminated with SDL_PIXELFORMAT_UNKNOWN, 
representing the available texture formats for this renderer.
+/



SDL_PropertiesID getRendererProperties(SDL_Renderer *renderer)
{
    SDL_PropertiesID props = SDL_GetRendererProperties(renderer);
    if (props == 0)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return props;
}


long getNumberProperty(SDL_PropertiesID props, const char *name, long default_value)
{
    long number = SDL_GetNumberProperty(props, name, default_value);
    if (number == default_value)
    {
        writeln(__FUNCTION__, " failed: ", to!string(SDL_GetError()));
        writeln(name, " is not set or not a number property");
        writeln("in file ",__FILE__, " at line ", __LINE__ );  exit(-1);
    }
    return number;
}


int getMaxTextureSizeForRenderer(SDL_Renderer *renderer)
{
    SDL_PropertiesID props = getRendererProperties(renderer);
    
    int maxTextureSize = cast(int) getNumberProperty(props, SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER, -1);
    return maxTextureSize;
}





/+ 
The function IMG_LoadTexture in SDL2/SDL3 is designed to load an image from a file path and create a GPU texture
 that is usable by SDL's 2D rendering API. This function is generally intended for static textures which are loaded
 once and rendered multiple times without frequent modification. 
 
To create a streaming texture in SDL, you would typically follow these steps:

Create a blank texture with SDL_TEXTUREACCESS_STREAMING access mode: Use SDL_CreateTexture and specify 
SDL_TEXTUREACCESS_STREAMING as the access mode. This creates a texture optimized for frequent updates.
Load or obtain your image data: You can load an image into an SDL_Surface using functions like IMG_Load() 
or handle the image data directly from another source (e.g., a video stream).
Lock the streaming texture: Use SDL_LockTexture to gain access to the raw pixel data buffer of the streaming 
texture. This function will provide you with a pointer to the pixel data and its pitch (the number of bytes 
in a row of the texture).
Copy your image data into the locked texture buffer: Copy the pixel data from your source (e.g., the 
SDL_Surface you loaded) to the locked texture buffer. Make sure to consider the pixel format and pitch.
Unlock the streaming texture: Use SDL_UnlockTexture to signal to SDL that you are finished modifying the 
texture's pixel data. This makes the texture available for rendering.
Render the streaming texture: Use SDL_RenderCopy to draw the streaming texture onto the screen. 

Important Notes:
IMG_LoadTexture directly creates a GPU texture, but it is not optimized for streaming.
Streaming textures are designed for situations where the texture data needs to be updated frequently, 
like in video playback.
When using SDL_LockTexture, you are expected to fill the entire locked area with new data, as the buffer
 may not contain the texture's existing contents. 
In summary, IMG_LoadTexture is not the way to create a streaming texture. You need to use SDL_CreateTexture 
with the SDL_TEXTUREACCESS_STREAMING flag and then manage the texture's pixel data using SDL_LockTexture and SDL_UnlockTexture.
+/