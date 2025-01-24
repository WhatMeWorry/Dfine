
module windows.simple_directmedia_layer;


import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import textures.texture : Texture;

import std.stdio;

struct SDL_STRUCT
{
    int screenWidth;
    int screenHeight;
    SDL_Window* window = null;      // The window we'll be rendering to
    SDL_Renderer* renderer = null;
}


struct Globals
{
    int i;
    SDL_STRUCT sdl;
    Texture[] textures;
}

void createSDLwindow(ref Globals g)
{

    if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 )  // SDL_INIT_VIDEO
    {
        writeln( "SDL could not initialize. SDL_Error: %s\n", SDL_GetError() );
        assert(0);
    }
    else
    {
        //Create window
        g.sdl.window = SDL_CreateWindow( "SDL Tutorial",
                                         SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
                                         g.sdl.screenWidth, g.sdl.screenHeight, 
                                         SDL_WINDOW_SHOWN );
        if( g.sdl.window == null )
        {
            printf( "sdl Window could not be created. SDL_Error: %s\n", SDL_GetError() );
            assert(0);
        }
        else
        {
            SDL_SetWindowResizable(g.sdl.window, true);
            
            // create a renderer for our window
            g.sdl.renderer = SDL_CreateRenderer( g.sdl.window, -1, SDL_RENDERER_ACCELERATED );
            if( g.sdl.renderer == null )
            {
                printf( "Renderer could not be created. SDL Error: %s\n", SDL_GetError() );
                assert(0);
            }
        }
    }
}