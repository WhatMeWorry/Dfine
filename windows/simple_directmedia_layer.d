
module windows.simple_directmedia_layer;


import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations

import textures.texture : Texture;

import std.stdio;
import core.stdc.stdlib : exit;
import std.string : toStringz;
import datatypes;

struct SDL_STRUCT(I)
{
    string name;
    HexBoardSize!(I) board;
    ScreenSize!(I) screen;
    //int screenWidth;
    //int screenHeight;
    SDL_Window*    window = null;      // The window we'll be rendering to
    SDL_Renderer*  renderer = null;
}


struct Globals(I)
{
    SDL_STRUCT!(I) sdl;
    Texture[] textures;
}


void SDL_Initialize()
{
    if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 )  // SDL_INIT_VIDEO
    {
        writeln( "SDL could not initialize. SDL_Error: %s\n", SDL_GetError() );
        exit(-1);
    }
}



SDL_STRUCT!(I) createSDLwindow(I)(string name, I width, I height)
{
    SDL_STRUCT!(I) temp;
   
    temp.name = name;
    temp.screen.width = width;
    temp.screen.height = height;
   
    temp.window = SDL_CreateWindow(toStringz(name),
                                   //SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                   SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                   width, height, 
                                   SDL_WINDOW_SHOWN );
    if( temp.window == null )
    {
        writeln( "sdl Window could not be created. SDL_Error: %s\n", SDL_GetError() );
        exit(-1);
    }
    else
    {
        SDL_SetWindowResizable(temp.window, true);
            
        // create a renderer for our window
        temp.renderer = SDL_CreateRenderer( temp.window, -1, SDL_RENDERER_ACCELERATED );
        if( temp.renderer == null )
        {
            writeln( "Renderer could not be created. SDL Error: %s\n", SDL_GetError() );
            exit(-1);
        }
    }
    return temp;
}

/+
void createSDLwindow(ref Globals g)   // ABSOLETE
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
                                         //SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                         SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
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
+/