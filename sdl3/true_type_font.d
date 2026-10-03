
module true_type_font;

import bindbc.sdl; //: SDL_WindowFlags, SDL_Delay, SDL_Window, SDL_Renderer, SDL_AudioStream;
/+
import bindbc.sdl: TTF_Font, SDL_Color, SDL_Surface, SDL_Texture, SDL_FRect,SDL_Event,SDL_PollEvent,
                   SDL_SetRenderDrawColor,SDL_QUIT,SDL_SetRenderCopy,
                   MIX_Track, SDL_PropertiesID, SDL_GetError;
                   +/

import sdl_funcs_with_error_handling;
import sdl_mixer_funcs_with_error_handling;
import sdl_ttf_funcs_with_error_handling;

import std.string: toStringz;
import core.stdc.stdio: printf;

import useful_functions : getFullPathToExecuableFile;
import std.stdio: writeln;

SDL_Window *window = null;
SDL_Renderer *renderer = null;
SDL_Surface* fontSurface = null;
SDL_Texture *fontTexture = null;


//SDL_AudioStream *stream = null;


void ttfForay()
{    writeln("inside ttfForay");

    createWindowAndRenderer("Dlang SDL3 TTF Demo", 800, 600, cast(SDL_WindowFlags) 0, &window, &renderer);

    string pathToExec = getFullPathToExecuableFile();

    string pathToTrueTypeFontFiles = pathToExec ~ `\fonts`;
    
    string ttfFileName = pathToTrueTypeFontFiles ~ `\Courier_Prime\CourierPrime-Regular.ttf`;
    
    float fontSize = 32;
    
    writeln("ttfFileName = ", ttfFileName);
    
    TTF_Font* ttfFont = openFont(ttfFileName, fontSize);
    
    SDL_Color purple = SDL_Color(r: 128, g: 0, b: 128, a: 255);
    
    //SDL_Rect destRect = { x: 50, y: 50, w: textSurface.w, h: textSurface.h };

    enum size_t NullTerminated = 0;
    
    fontSurface = renderText_Blended(ttfFont, "Hello World", NullTerminated, purple);
    
    writeln("fontSurface = ", fontSurface);
    
    fontTexture = createTextureFromSurface(renderer, fontSurface);
    
    writeln("fontTexture = ", fontTexture);
    
    SDL_FRect textRect = SDL_FRect(x: 10, y: 10, w:500, h: 100); 
    renderTexture(renderer, fontTexture, null, &textRect);
    
 
        //renderPresent(renderer);
    
    
 // Get exact dimensions from the surface for placement
    SDL_FRect dstRect = SDL_FRect(50, 50, fontSurface.w, fontSurface.h);   
    
    
    //writeln("Goodbye");
    //SDL_Delay(6000);

    bool running = true;
    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) running = false;
        }


        // Clear screen with a dark blue background
        SDL_SetRenderDrawColor(renderer, 20, 30, 40, 255);
        SDL_RenderClear(renderer);

        // Draw the text texture to the screen (SDL3 uses SDL_RenderTexture)
        SDL_RenderTexture(renderer, fontTexture, null, &dstRect);

        // Present frame
        SDL_RenderPresent(renderer);    
        
        
        

        // Update screen
        //SDL_RenderPresent(renderer);
        SDL_Delay(16); // ~60 FPS
    }



}
