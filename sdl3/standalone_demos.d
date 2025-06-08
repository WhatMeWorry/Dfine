
module standalone_demos;


import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes;
import a_star.spot : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import breakup;
import magnify;
import sdl_funcs_with_error_handling;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations



void ThreeSurfacesAndOneStreamingTexure()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Demo", 1000, 1000, cast(SDL_WindowFlags) 0, &window, &renderer);

    // Texture dimensions are limited to 16384 x 16384

    //SDL_Texture *texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 16384, 16384);
    SDL_Texture *texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, 8000, 8000);
    displayTextureProperties(texture);
    
    SDL_Surface *one = loadImageToSurface("./images/1.png");
    displaySurfaceProperties(one);
    
    SDL_Surface *two = loadImageToSurface("./images/2.png");
    displaySurfaceProperties(two);
    
    SDL_Surface *three = loadImageToSurface("./images/3.png");
    displaySurfaceProperties(three);
    
    SDL_Surface *four = loadImageToSurface("./images/3.png");
    displaySurfaceProperties(four);

    copySurfaceToTexture(one, null, texture, null);
    
    SDL_Rect dst;     // an SDL_Rect has x, y, w, and h
    
    dst.x = one.w;
    dst.y = 0;      // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = two.w;
    dst.h = two.h;
       
    copySurfaceToTexture(two, null, texture, &dst);


    dst.x = 1000;
    dst.y = 1000;     // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = three.w;
    dst.h = three.h;

    copySurfaceToTexture(three, null, texture, &dst);
    
    dst.x = 4000;
    dst.y = 4000;     // a SDL_Surface only has w and h elements (no x and y position)
    dst.w = four.w;
    dst.h = four.h;

    copySurfaceToTexture(four, null, texture, &dst);
    

    SDL_RenderClear(renderer);
        SDL_RenderTexture(renderer, texture, null, null);
    SDL_RenderPresent(renderer);

    // Keep the window open until the user closes it
    SDL_Event event;
    while (SDL_WaitEvent(&event)) 
    {
        if (event.type == SDL_EVENT_KEY_DOWN)
        {
            if (event.key.key == SDLK_ESCAPE)
            {
                break;
            }
        }
        if (event.type == SDL_EVENT_QUIT) 
        {
            break;
        }
    }
}


