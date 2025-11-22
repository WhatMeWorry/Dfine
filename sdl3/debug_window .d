
module debug_window;

import cork_board;
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
import helper_funcs;
import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 
import bindbc.sdl;  // SDL_* all remaining declarations


struct DebugWindow
{
    SDL_Window   *win;
    SDL_Renderer *ren;

    this(SDL_Rect rect)
    {
        createWindowAndRenderer("Debug Window", rect.w, rect.h, cast(SDL_WindowFlags) 0, &win, &ren);

        SDL_SetWindowPosition(win, rect.x, rect.y);

        SDL_SetRenderDrawColor(ren, 128, 128, 128, 255);  // must be down before SDL_RenderClear

        // Set the background clear color to blue
        SDL_SetRenderDrawColor(ren, 0, 0, 128, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(ren);

        // Set the text color to white
        SDL_SetRenderDrawColor(ren, 255, 255, 255, SDL_ALPHA_OPAQUE);

        // Render the debug text
        SDL_RenderDebugText(ren, 50.0f, 50.0f, "Hello, world!");
        SDL_RenderDebugText(ren, 50.0f, 70.0f, "This is some debug text.");

        SDL_RenderPresent(ren); // Present the rendered content
    }

    void debugText(int x, int y, string str)
    {
        // Set the background clear color to green
        SDL_SetRenderDrawColor(ren, 0, 128, 0, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(ren); // Clear the renderer
        
            // Set the text color to black
            SDL_SetRenderDrawColor(ren, 0, 0, 0, SDL_ALPHA_OPAQUE);
               SDL_SetRenderScale(ren, 3, 3);  // where scale_x and scale_y are values greater than 1.
            SDL_RenderDebugText(ren, x, y, str.toStringz);
            SDL_RenderDebugText(ren, 3, 50, "***********************************");
                SDL_SetRenderScale(ren, 1.0, 1.0);  // where scale_x and scale_y are = 1.0
        SDL_RenderPresent(ren); // Present the rendered content
    }

    void displaySwatch(Swatch s, int i)
    {
        // Set the background clear color to yellow
        SDL_SetRenderDrawColor(ren, 255, 255, 0, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(ren); // Clear the renderer
    
        // Set the text color to black
        SDL_SetRenderDrawColor(ren, 0, 0, 0, SDL_ALPHA_OPAQUE);
        SDL_SetRenderScale(ren, 3, 3);  // where scale_x and scale_y are values greater than 1.
        
        string str = "Current Swatch: " ~ to!string(i);
        SDL_RenderDebugText(ren, 5, 5, str.toStringz);
        
        str = "position (x,y): (" ~ to!string(s.rect.x) ~ "," ~ to!string(s.rect.y) ~ ")";
        SDL_RenderDebugText(ren, 5, 15, str.toStringz);
        
        str = "width x Height: w x h: " ~ to!string(s.rect.w) ~ " x " ~ to!string(s.rect.h) ~ ")";
        SDL_RenderDebugText(ren, 5, 25, str.toStringz);
        
        str = "angle: " ~ to!string(s.angle);
        SDL_RenderDebugText(ren, 5, 35, str.toStringz);
        
        str = "opacity: " ~ to!string(s.opacity);
        SDL_RenderDebugText(ren, 5, 45, str.toStringz);
        
        SDL_SetRenderScale(ren, 1.0, 1.0);  // where scale_x and scale_y are = 1.0
        SDL_RenderPresent(ren); // Present the rendered content
    }

}