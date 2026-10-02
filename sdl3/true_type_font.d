
module true_type_font;

import bindbc.sdl: SDL_WindowFlags, SDL_Delay, SDL_Window, SDL_Renderer, SDL_AudioStream;
import bindbc.sdl: TTF_Font, 
                   MIX_Track, SDL_PropertiesID, SDL_GetError;

import sdl_funcs_with_error_handling;
import sdl_mixer_funcs_with_error_handling;
import sdl_ttf_funcs_with_error_handling;

import std.string: toStringz;
import core.stdc.stdio: printf;

import useful_functions : getFullPathToExecuableFile;
import std.stdio: writeln;

SDL_Window *window = null;
SDL_Renderer *renderer = null;

//SDL_AudioStream *stream = null;


void ttfForay()
{    writeln("inside ttfForay");

    createWindowAndRenderer("Dlang SDL3 TTF Demo", 800, 600, cast(SDL_WindowFlags) 0, &window, &renderer);

    string pathToExec = getFullPathToExecuableFile();

    string pathToTrueTypeFontFiles = pathToExec ~ `\fonts`;
    
    string ttfFileName = pathToTrueTypeFontFiles ~ `\Courier_Prime\CourierPrime-Regular.ttf`;
    
    float fontSize = 32;
    
    writeln("ttfFileName = ", ttfFileName);
    
    TTF_Font* ttfFont = ttfOpenFont(ttfFileName, fontSize);
    
    
    
    writeln("Goodbye");
    SDL_Delay(2000);

}
