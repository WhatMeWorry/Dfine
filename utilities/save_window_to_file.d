
module utilities.save_window_to_file;


import bindbc.sdl;
import std.stdio;


void saveWindowToFile(G)(G current)
{
    writeln("saveWindowToFile");
    SDL_Surface *screenshot;

    screenshot = SDL_CreateRGBSurface(SDL_SWSURFACE,
                                      current.sdl.screen.width, 
                                      current.sdl.screen.height, 
                                      32, 
                                      0x00FF0000, 
                                      0X0000FF00, 
                                      0X000000FF, 
                                      0XFF000000); 

    SDL_RenderReadPixels(current.sdl.renderer, 
                         null, 
                         SDL_PIXELFORMAT_ARGB8888, 
                         screenshot.pixels, 
                         screenshot.pitch);
                         
    //SDL_SavePNG(screenshot, "screenshot.png"); 
    IMG_SavePNG(screenshot, "screenshot.png"); 
    SDL_FreeSurface(screenshot); 
}