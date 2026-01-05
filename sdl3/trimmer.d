
module trimmer;

import std.stdio : writeln, write, writefln;
import std.range : empty;  // for aa 
import std.datetime.systime : Clock, SysTime;
import std.string : replace;
import core.stdc.stdlib : exit;
import datatypes;
import hexmath : isOdd, isEven;
import breakup;
import magnify;
import sdl_funcs_with_error_handling;
import helper_funcs;
import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 
import bindbc.sdl;  // SDL_* all remaining declarations


struct Canvas
{
    SDL_Surface *surface;
    SDL_Rect rect;       // original size of rect
	bool borderHighlighted;

    this(int x, int y, string fileName) 
    {
        this.rect.x = x;
        this.rect.y = y;
        surface = loadImageToSurface(fileName);
        this.rect.w = surface.w;
        this.rect.h = surface.h;
    }
}


/+
    void renderAllSwatches(SDL_Renderer *renderer)
    {
        foreach(i, s; this.swatches)
        {
            SDL_SetTextureAlphaMod(s.texture, s.opacity);

            SDL_RenderTextureRotated(renderer, s.texture, FULL_TEXTURE, &s.rect, s.angle, CENTER, SDL_FLIP_NONE);

            if ((active == i) & borderActive)
            {
                ubyte r, g, b, a;
                SDL_GetRenderDrawColor(renderer, &r, &g, &b, &a);  // save off the current color

                SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);  // set color to red
                SDL_RenderRect(renderer, &s.rect);                 // draw rectangular outline

                SDL_SetRenderDrawColor(renderer, r, g, b, a);      // restore the previous color
            }
        }
    }
+/	
	
    void enlarge(ref Canvas c)
    {
        c.rect.w += 1;
        c.rect.h += 1;
    }
    void shrink(ref Canvas c)
    {
        c.rect.w -= 1;
        c.rect.h -= 1;
    }
	
    void moveLeft(ref Canvas c)
    {
        c.rect.x -= 1;
    }
    void moveRight(ref Canvas c)
    {
        c.rect.x += 1;
    }
    void moveUp(ref Canvas c)
    {
        c.rect.y -= 1;
    }
    void moveDown(ref Canvas c)
    {
        c.rect.y += 1;
    }


void trimEdges()
{
    // Home Samsung desktop 3840 x 2160
    // Work Lenovo desktop 2560 x 1600
    
    SDL_Window *window = createWindow("Trimmer", 2000, 1400, cast(SDL_WindowFlags) 0);
    
    SDL_Surface *windowSurface = getWindowSurface(window);  // creates a surface if it does not already exist

    //HelpWindow helpWin = HelpWindow(SDL_Rect(100, 100, 1000, 1000));
    //helpWin.displayHelpMenu(board.delta);
    
    Canvas canvas = Canvas(100, 200, "./images/WachA.png");

    bool running = true;
    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_KEY_DOWN) 
            {
                switch(event.key.key)
                {
                    case SDLK_ESCAPE:
                        running = false;
                    break;
                    
                    case SDLK_KP_8:
                        writeln("Key Pad 8 pressed trim top");
                    break;
                    
                    case SDLK_KP_4:
                        writeln("Key Pad 4 pressed trim left");
                    break;

                    case SDLK_KP_6:
                        writeln("Key Pad 6 pressed trim right");
                    break;

                    case SDLK_KP_2:
                        writeln("Key Pad 2 pressed trim bottom");
                    break;



                    case SDLK_INSERT:
                        canvas.enlarge();
                    break;

                    case SDLK_DELETE:
                        canvas.shrink();
                    break;



                    case SDLK_LEFT:
                        canvas.moveLeft();
                    break;

                    case SDLK_RIGHT:
                        canvas.moveRight();
                    break;
					
                    case SDLK_UP:
                        canvas.moveUp();
                    break;

                    case SDLK_DOWN:
                        canvas.moveDown();
                    break;

                    case SDLK_F9:
                        canvas.borderHighlighted = !canvas.borderHighlighted;
                    break;
					
                    case SDLK_F12:					
					    //saveSurfaceToPNGfile(bigSurface, "./images/TEST_" ~ noSpaces ~ ".png");
					break;
					
					

                    default: // lots of keys are not mapped so not a problem
                }

                //debugWin.displayAllSwatches(board);

                //helpWin.displayHelpMenu(board.delta);
            }
        }
		
		//copySurfaceToSurfaceScaled(SDL_Surface *srcSurface, const SDL_Rect *srcRect,
        //                        SDL_Surface *dstSurface, const SDL_Rect *dstRect, SDL_ScaleMode scaleMode);

        updateWindowSurface(window);
    }
    SDL_Quit();

}





