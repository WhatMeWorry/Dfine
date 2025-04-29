
module windows.simple_directmedia_layer;


//import bindbc.sdl : SDL_Window, SDL_Renderer;
//import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import textures.texture : Texture;

import std.stdio;
import core.stdc.stdlib : exit;
import std.string : toStringz;
import datatypes;
import std.string;

import std.conv : to;
import std.string : toStringz;

struct SDL_STRUCT(I)
{
    string name;
    HexBoardSize!(I) board;
    ScreenSize!(I) screen;
    //int screenWidth;
    //int screenHeight;
    SDL_Window*    window = null;      // The window we'll be rendering to
    
    uint windowID;
    
    SDL_Renderer*  renderer = null;
}


struct Globals(I)
{
    SDL_STRUCT!(I) sdl;
    Texture[] textures;
}


void SDL_Initialize()
{
    //if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 )  // SDL_INIT_VIDEO
    //{
    //    writeln( "SDL could not initialize. SDL_Error: %s", SDL_GetError() );
    //    exit(-1);
    //}
}



SDL_STRUCT!(I) createSDLwindow(I)(string name, I width, I height)
{
    SDL_STRUCT!(I) temp;
   
    temp.name = name;
    temp.screen.width = width;
    temp.screen.height = height;
   
    temp.window = SDL_CreateWindow(toStringz(name), width, height, SDL_WINDOW_RESIZABLE);
    if (temp.window == null)
    {
        writeln("sdl Window could not be created. SDL_Error: %s", SDL_GetError());  exit(-1);
    }

    temp.renderer = SDL_CreateRenderer(temp.window, null);
    if (temp.renderer == null)
    {
        writeln( "Renderer could not be created. SDL Error: %s", SDL_GetError() );  exit(-1);
    }
    
    temp.windowID = SDL_GetWindowID(temp.window);
    if (temp.windowID == 0)
    {
        writeln( "SDL_GetWindowID failded. SDL Error: %s", SDL_GetError() );  exit(-1);
    }
    
    auto ok = SDL_SetWindowTitle(temp.window, toStringz("Overwrite Name"));
    if (ok == false)
    {
        writeln("SDL_SetWindowTitle failed. SDL_Error: %s", SDL_GetError());  exit(-1);
    }

    auto ret = SDL_SetWindowResizable(temp.window, false);
    if (ret == false)
    {
        writeln("SDL_SetWindowResizable failed. SDL_Error: %s", SDL_GetError());  exit(-1);
    }

    return temp;
}

/+

SDL_Window

SDL_Window is the struct that holds all info about the Window itself: size, position, full screen, borders etc.

SDL_Renderer

SDL_Renderer is a struct that handles all rendering. It is tied to a SDL_Window so it can only render within that 
SDL_Window. It also keeps track the settings related to the rendering. There are several important functions tied 
to the SDL_Renderer:

    SDL_SetRenderDrawColor(renderer, r, g, b, a)  This sets the color you clear the screen to (see below).

    SDL_RenderClear(renderer)     This clears the rendering target with the draw color set above.

    SDL_RenderCopy(   // This is probably the function you'll be using the most, it's used for rendering a 
                      // SDL_Texture and has the following parameters:
                   SDL_Renderer*   renderer,       // The renderer you want to use for rendering.
                   SDL_Texture*    texture,        // The texture you want to render.
                   const SDL_Rect* srcrect,        // Part of texture you want to render, NULL to render the entire texture.
                   const SDL_Rect* dstrect)        // Where you want to render the texture in the window. If the width and 
                                                   // height of this SDL_Rect is smaller or larger than the dimensions of the 
                                                   // texture itself, the texture will be stretched according to this SDL_Rect.
                   SDL_RenderPresent(renderer)     // The other SDL_Render*() functions draws to a hidden target. This function 
                                                   // will take all of that and draw it in the window tied to the renderer.
SDL_Texture and SDL_Surface

The SDL_Renderer renders SDL_Texture, which stores the pixel information of one element. It's the new version of SDL_Surface which 
is much the same. The difference is mostly that SDL_Surface is just a struct containing pixel information, while SDL_Texture is an 
efficient, driver-specific representation of pixel data.

You can convert an SDL_Surface to SDL_Texture using

SDL_Texture* SDL_CreateTextureFromSurface(SDL_Renderer* renderer, SDL_Surface*  surface)
After this, the SDL_Surface should be freed using

SDL_FreeSurface( SDL_Surface* surface )
Another important difference is that SDL_Surface uses software rendering (via CPU) while 
SDL_Texture uses hardware rendering (via GPU).

SDL_Rect
The simplest struct in SDL. It contains only four shorts: x, y which holds the position and w, h which holds width and height.

It's important to note that 0, 0 is the upper-left corner in SDL. So a higher y-value means lower, 
and the bottom-right corner will have the coordinate x + w, y + h.

+/