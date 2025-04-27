
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
   
    temp.window = SDL_CreateWindow(toStringz(name),
                                   //SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,  // SDL2
                                   //SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                   width, height, 
                                   SDL_WINDOW_RESIZABLE );
    if( temp.window == null )
    {
        writeln( "sdl Window could not be created. SDL_Error: %s", SDL_GetError() );
        exit(-1);
    }
    else
    {
        
        if (SDL_SetWindowResizable(temp.window, true))
        {
            //writeln("Line 71 simple_directmedia_layer");
            //const char* errorMessage = SDL_GetError();
            
            writeln("SDL_SetWindowResizable failed: ", to!string(SDL_GetError()));
            
            //writeln("SDL_SetWindowResizable failed: ", toStringz(SDL_GetError()));
            
            writeln("SDL_SetWindowResizable failed: ", fromStringz(SDL_GetError()));
      
            
            //fprintf("Failed to create window: %s\n", SDL_GetError());
            //writeln( "sdl Window could not be resized. SDL_Error: %s", SDL_GetError() );
            exit(-1);
        }
        
        // create a renderer for our window
        temp.renderer = SDL_CreateRenderer( temp.window, null );
        if( temp.renderer == null )
        {
            writeln( "Renderer could not be created. SDL Error: %s", SDL_GetError() );
            exit(-1);
        }
    }
    
    temp.windowID = SDL_GetWindowID(temp.window);
    
    return temp;
}

/+
void createSDLwindow(ref Globals g)   // ABSOLETE
{
    if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 )  // SDL_INIT_VIDEO
    {
        writeln( "SDL could not initialize. SDL_Error: %s", SDL_GetError() );
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
            printf( "sdl Window could not be created. SDL_Error: %s", SDL_GetError() );
            assert(0);
        }
        else
        {
            SDL_SetWindowResizable(g.sdl.window, true);
            
            // create a renderer for our window
            g.sdl.renderer = SDL_CreateRenderer( g.sdl.window, -1, SDL_RENDERER_ACCELERATED );
            if( g.sdl.renderer == null )
            {
                printf( "Renderer could not be created. SDL Error: %s", SDL_GetError() );
                assert(0);
            }
        }
    }
}
+/





/+
prebuilt SDL3 .lib files can be found on GitHub under the "Assets" section of official 
releases. You can also build them yourself from the source code available on the same repository. 
Here's a breakdown of how to get them:

1. Official Releases on GitHub:

Navigate to the official SDL3 GitHub repository releases page. https://github.com/libsdl-org/SDL/releases


Look for the desired release version (e.g., "SDL 3.0.4").

Under "Assets", you'll find prebuilt .lib files for different platforms and architectures (e.g., Windows, macOS, Linux). 

Download the appropriate archive (e.g., a zip file for Windows





Error: linker exited with status 1
       C:\D\dmd2\windows\bin64\lld-link.exe /NOLOGO "C:\Users\kheas\AppData\Local\dub\cache\dfine\~master\build\application-debug-HFIG97JEvO1MRYFNHQr6DA\dfine.obj" /OUT:"C:\Users\kheas\AppData\Local\dub\cache\dfine\~master\build\application-debug-HFIG97JEvO1MRYFNHQr6DA\dfine.exe" 
       /DEFAULTLIB:"C:\Users\kheas\AppData\Local\dub\cache\bindbc-sdl\2.2.0\build\dynamic-debug-2k-KrVMSYO5IGhu7k4SOgA\BindBC_SDL.lib" /DEFAULTLIB:"C:\Users\kheas\AppData\Local\dub\cache\bindbc-common\1.0.5\build\noBC-debug-K5h0lBB6NE8JpYAJvoDElg\BindBC_Common.lib" /DEFAULTLIB:"C:\Users\kheas\AppData\Local\dub\cache\bindbc-loader\1.1.5\build\noBC-debug-zNtnC9KlQyih0pXEUgoocA\BindBC_Loader.lib" 
       /DEFAULTLIB:"SDL3.lib" 
       /DEFAULTLIB:"SDL3_net.lib" 
       /DEFAULTLIB:phobos64 /DEBUG  
       /LIBPATH:"C:\D\dmd2\windows\bin64\..\lib64\mingw"
       
+/