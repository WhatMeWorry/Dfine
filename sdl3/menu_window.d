
module menu_window;

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
import std.format;
import std.string;


struct MenuWindow
{
    SDL_Window   *win;
    SDL_Renderer *ren;
	string       str;

    this(SDL_Rect rect)
    {
        createWindowAndRenderer("Debug Window", rect.w, rect.h, cast(SDL_WindowFlags) 0, &win, &ren);

        SDL_SetWindowPosition(win, rect.x, rect.y);

        // Set the background clear color to light blue
        SDL_SetRenderDrawColor(ren, 0, 0, 128, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(ren);

        // Set the text color to white
        SDL_SetRenderDrawColor(ren, 255, 255, 255, SDL_ALPHA_OPAQUE);
		
		SDL_SetRenderScale(ren, 3, 3);
		
        str = "             HELP MENU          ";
        SDL_RenderDebugText(ren, 5, 5, str.toStringz);

        SDL_SetRenderScale(ren, 2, 2);

        // Render the debug text
        SDL_RenderDebugText(ren, 5.0f, 20.0f, "Insert = zoom in");
        SDL_RenderDebugText(ren, 5.0f, 30.0f, "Delete = zoom out");
        SDL_RenderDebugText(ren, 5.0f, 40.0f, "Home = rotate clockwise");
        SDL_RenderDebugText(ren, 5.0f, 50.0f, "End = rotate counter-clockwise");
        SDL_RenderDebugText(ren, 5.0f, 60.0f, "Page Up = increase opacity");
        SDL_RenderDebugText(ren, 5.0f, 70.0f, "Page Down = increase transparency");

        SDL_RenderDebugText(ren, 5.0f, 90.0f, "tab = advance to next swatch");
        SDL_RenderDebugText(ren, 5.0f, 100.0f, "F9 = toggle border of current swatch");	

        SDL_RenderDebugText(ren, 5.0f, 120.0f, "F1 = increase delta scale");
        SDL_RenderDebugText(ren, 5.0f, 130.0f, "F2 = decrease delta scale");	        
        SDL_RenderDebugText(ren, 5.0f, 140.0f, "F3 = increase delta translage");
        SDL_RenderDebugText(ren, 5.0f, 150.0f, "F4 = decrease delta translate");
        SDL_RenderDebugText(ren, 5.0f, 160.0f, "F5 = increase delta opacity");
        SDL_RenderDebugText(ren, 5.0f, 170.0f, "F6 = decrease delta opacity");
        SDL_RenderDebugText(ren, 5.0f, 180.0f, "F7 = increase delta rotation");
        SDL_RenderDebugText(ren, 5.0f, 190.0f, "F8 = decrease delta rotation");		
				
        SDL_RenderPresent(ren); // Present the rendered content
    }

}