
module help_window;

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


struct HelpWindow
{
    SDL_Window   *win;
    SDL_Renderer *ren;

    this(SDL_Rect rect)
    {
        createWindowAndRenderer("Help Window", rect.w, rect.h, cast(SDL_WindowFlags) 0, &win, &ren);

        SDL_SetWindowPosition(win, rect.x, rect.y);
    }


    void displayHelpMenu(Delta d)
    {
        // Set the background clear color to light blue
        SDL_SetRenderDrawColor(ren, 0, 0, 128, SDL_ALPHA_OPAQUE);
        SDL_RenderClear(ren);

        // Set the text color to white
        SDL_SetRenderDrawColor(ren, 255, 255, 255, SDL_ALPHA_OPAQUE);

        SDL_SetRenderScale(ren, 3, 3);

        SDL_RenderDebugText(ren, 5, 5, toStringz("             HELP MENU          "));

        SDL_SetRenderScale(ren, 2, 2);

        SDL_RenderDebugText(ren, 5.0f, 30.0f, toStringz("Insert = zoom in:  " ~ to!string(d.scale) ~ " scale factor" ));
        SDL_RenderDebugText(ren, 5.0f, 40.0f,           "Delete = zoom out:");

        SDL_RenderDebugText(ren, 5.0f, 50.0f, "------------------------------------");

        SDL_RenderDebugText(ren, 5.0f, 60.0f, toStringz("Up Arrow, Down Arrow,     : " ~ to!string(d.translate) ~ " pixels" ));
        SDL_RenderDebugText(ren, 5.0f, 70.0f,           "Left Arrow, Right Arrow   ");

        SDL_RenderDebugText(ren, 5.0f, 80.0f, "------------------------------------");

        SDL_RenderDebugText(ren, 5.0f, 90.0f, toStringz("Home = rotate clockwise:        " ~ to!string(d.rotate) ~ " degrees"));
        SDL_RenderDebugText(ren, 5.0f, 100.0f,          "End = rotate counter-clockwise: ");

        SDL_RenderDebugText(ren, 5.0f, 110.0f, "------------------------------------");

        SDL_RenderDebugText(ren, 5.0f, 120.0f, toStringz("Page Up = increase opacity:        " ~ to!string(d.opaque) ~ " alpha"));		
        SDL_RenderDebugText(ren, 5.0f, 130.0f,          "Page Down = increase transparency: ");

        SDL_RenderDebugText(ren, 5.0f, 140.0f, "------------------------------------");

        SDL_RenderDebugText(ren, 5.0f, 150.0f, "tab = advance to next swatch");
        SDL_RenderDebugText(ren, 5.0f, 160.0f, "F9 = toggle border of current swatch");
		
        SDL_RenderDebugText(ren, 5.0f, 170.0f, "F10 = all swatches are locked (Move together)");
        SDL_RenderDebugText(ren, 5.0f, 180.0f, "F11 = move all swatches relative to upper left corner");	
        SDL_RenderDebugText(ren, 5.0f, 190.0f, "F12 = save all swatches on and off screen to PNG file");
		
        SDL_RenderDebugText(ren, 5.0f, 200.0f, "------------------------------------");
        SDL_RenderDebugText(ren, 5.0f, 210.0f, "Keypad 4 = trim left side one pixel");		
        SDL_RenderDebugText(ren, 5.0f, 220.0f, "Keypad 6 = trim right side one pixel");		
        SDL_RenderDebugText(ren, 5.0f, 230.0f, "Keypad 8 = trim top by one pixel");
        SDL_RenderDebugText(ren, 5.0f, 240.0f, "Keypad 2 = trim bottom by one pixel");
		
        SDL_RenderDebugText(ren, 5.0f, 250.0f, "------------------------------------");
	   
        SDL_RenderDebugText(ren, 5.0f, 260.0f, "F1 = increase delta scale");
        SDL_RenderDebugText(ren, 5.0f, 270.0f, "F2 = decrease delta scale");
        SDL_RenderDebugText(ren, 5.0f, 280.0f, "F3 = increase delta translate");
        SDL_RenderDebugText(ren, 5.0f, 290.0f, "F4 = decrease delta translate");
        SDL_RenderDebugText(ren, 5.0f, 300.0f, "F5 = increase delta rotation");
        SDL_RenderDebugText(ren, 5.0f, 310.0f, "F6 = decrease delta rotation");
        SDL_RenderDebugText(ren, 5.0f, 320.0f, "F7 = increase delta opacity");
        SDL_RenderDebugText(ren, 5.0f, 330.0f, "F8 = decrease delta opacity");

        SDL_RenderPresent(ren); // Present the rendered content
    }

}