
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


/+
     +----------+ source surface   
     |          | (never changes/ read only)
     |          | no position. Only data
     |          |
     |          |	 
     +----------+
          |
          |(SDL_BlitSurfaceScaled)
          |
          V
     +--------------+ destination surface (can move around and scale up or down in size) 
     |   +-------+  |   
     |   |window |  |  
     |   |surface|  |
     |   |       |  |  window service is considered fixed where upper lefter corner
     |   +-------+  |  is always at (0,0)
     +--------------+
    
    Then destination suface can be be moved and resized so that it is smaller
    or bigger than the source/window surfaces. However, it is critical that only the 	
    intersection of the destination-window surfaces (via SDL_GetRectIntersection) 
	be displayed on the monitor; otherwise the program will abort with out of bounds error.
+/	


struct FixedSurface  // Fixed original size
{
    SDL_Surface *surface; // surface contains w and h  (make const)
	
	SDL_Rect rect;  // Not really needed since we will always use null

    this(string fileName) 
    {
        surface = loadImageToSurface(fileName);
        rect.x = 0;
        rect.y = 0;
        rect.w = surface.w;
        rect.h = surface.h;
    }
}



struct ResizeableSurface  // changeable size and position
{
    SDL_Surface *surface; // surface contains w and h
    SDL_Point   position; // x and y
	SDL_Point   size;     // w and h  
	bool        borderHighlighted;


    this(SDL_Surface *s) 
    {
	    // One Surface per Window: SDL internally manages a single surface per window

        this.surface = createSurface(s.w, s.h, s.format);
	
        size.x = surface.w;
        size.y = surface.h;

        this.position.x = 0;
        this.position.y = 0;

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
	
void enlarge(ref ResizeableSurface d)
{
    d.surface.w += 1;
    d.surface.h += 1;
}
void shrink(ref ResizeableSurface d)
{
    d.surface.w -= 1;
    d.surface.h -= 1;
}
	
void moveLeft(ref ResizeableSurface d)
{
    d.position.x -= 10;
}
void moveRight(ref ResizeableSurface d)
{
    d.position.x += 10;
}
void moveUp(ref ResizeableSurface d)
{
    d.position.y -= 10;	
}
void moveDown(ref ResizeableSurface d)
{
    d.position.y += 10;
}


SDL_Point mapMoveableToFixed(SDL_Point m)
{
    SDL_Point f;
	f.x = 0 - m.x;
	f.y = 0 - m.y;
	return f;
}

void trimEdges()
{
    // Home Samsung desktop 3840 x 2160
    // Work Lenovo desktop 2560 x 1600

    FixedSurface srcSurface = FixedSurface("./images/WachA.png");	
	
    ResizeableSurface dstSurface = ResizeableSurface(srcSurface.surface);  // the destination will the the window	
	
    SDL_Window *window = createWindow("Trimmer", 1500, 1500, cast(SDL_WindowFlags) 0); 
    SDL_Surface *winSurface = SDL_GetWindowSurface(window);

    //HelpWindow helpWin = HelpWindow(SDL_Rect(100, 100, 1000, 1000));
    //helpWin.displayHelpMenu(board.delta);

	
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
					    //clearSurface(winSurface.surface, 1.0, 0.0, 0.0, 1.0);
                        enlarge(dstSurface);
                    break;

                    case SDLK_DELETE:
					    //clearSurface(winSurface.surface, 1.0, 0.0, 0.0, 1.0);
                        shrink(dstSurface);
                    break;


                    case SDLK_LEFT:
                        dstSurface.moveLeft();
                    break;

                    case SDLK_RIGHT:
                        dstSurface.moveRight();
                    break;
					
                    case SDLK_UP:
                        dstSurface.moveUp();
                    break;

                    case SDLK_DOWN:
                        dstSurface.moveDown();
                    break;

                    case SDLK_F9:
                        dstSurface.borderHighlighted = !dstSurface.borderHighlighted;
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

        clearSurface(winSurface, 0.5, 0.5, 0.5, 1.0);
 
        copySurfaceToSurfaceScaled(srcSurface.surface, null, dstSurface.surface, null, SDL_SCALEMODE_LINEAR);  // performs blit
			
		SDL_Point upperLeftPt = mapMoveableToFixed(dstSurface.position);
		
		SDL_Rect r;
		r.x = upperLeftPt.x;
		r.y = upperLeftPt.y;
		r.w = winSurface.w;
		r.h = winSurface.h;
		
        copySurfaceToSurface(dstSurface.surface, &r, winSurface, null);  
		
        updateWindowSurface(window);
		
    }
    SDL_Quit();

}





