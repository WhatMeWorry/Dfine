
module utilities.save_window_to_file;


import bindbc.sdl;
import std.stdio;


void saveWindowToFile(G)(G current)
{
    SDL_Surface *screenshot;

    screenshot = SDL_CreateSurface(current.sdl.screen.width,
                                   current.sdl.screen.height,
                                   SDL_PIXELFORMAT_RGBA8888);

    SDL_RenderReadPixels(current.sdl.renderer, null);

    IMG_SavePNG(screenshot, "screenshot.png");
    
    SDL_DestroySurface(screenshot); 
}