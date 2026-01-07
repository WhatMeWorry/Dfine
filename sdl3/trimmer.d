
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



struct SrcSurface  // Fixed original size
{
    SDL_Surface *surface; // surface contains w and h  (make const)
	
	SDL_Rect rect;  // not used. Alway use null when needed

    this(string fileName) 
    {
        surface = loadImageToSurface(fileName);
    }
}



struct DstSurface  // changeable size and position
{
    SDL_Point position;   // x and y
    SDL_Surface *surface; // surface contains w and h  (make const)
    SDL_Rect    rect;     // composed of position's x and y and surface's w and h          
	bool borderHighlighted;


    this(SDL_Window *window) 
    {
        this.surface = getWindowSurface(window);  // creates a surface if it does not already exist	
        writeln("surface.w = ", surface.w);
        writeln("surface.h = ", surface.h);       		
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
	
void enlarge(ref DstSurface d)
{
    d.surface.w += 1;
    d.surface.h += 1;
}
void shrink(ref DstSurface d)
{
    d.surface.w -= 1;
    d.surface.h -= 1;
}
	
void moveLeft(ref DstSurface d)
{
    d.position.x -= 1;
}
void moveRight(ref DstSurface d)
{
    d.position.x += 1;
}
void moveUp(ref DstSurface d)
{
    d.position.y -= 1;
}
void moveDown(ref DstSurface d)
{
    d.position.y += 1;
}


void trimEdges()
{
    // Home Samsung desktop 3840 x 2160
    // Work Lenovo desktop 2560 x 1600
    	
    SrcSurface srcSurface = SrcSurface("./images/WachA.png");	
	
    SDL_Window *window = createWindow("Trimmer", 2000, 1400, cast(SDL_WindowFlags) 0);
  
    DstSurface winSurface = DstSurface(window);  // the destination will the the window
	
    //HelpWindow helpWin = HelpWindow(SDL_Rect(100, 100, 1000, 1000));
    //helpWin.displayHelpMenu(board.delta);
	
	// winSurface has no data yet
	
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
                        enlarge(winSurface);
                    break;

                    case SDLK_DELETE:
                        shrink(winSurface);
                    break;


                    case SDLK_LEFT:
                        winSurface.moveLeft();
                    break;

                    case SDLK_RIGHT:
                        winSurface.moveRight();
                    break;
					
                    case SDLK_UP:
                        winSurface.moveUp();
                    break;

                    case SDLK_DOWN:
                        winSurface.moveDown();
                    break;

                    case SDLK_F9:
                        winSurface.borderHighlighted = !winSurface.borderHighlighted;
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
        SDL_Rect r;
        r.x = winSurface.position.x;
        r.y = winSurface.position.y;
        r.w = winSurface.surface.w;
        r.h = winSurface.surface.h;
        copySurfaceToSurfaceScaled(srcSurface.surface, null, winSurface.surface, &r, SDL_SCALEMODE_LINEAR);  // performs blit
		//                         canvas.surface, canvas.rect, 
								   
								   
        updateWindowSurface(window);
    }
    SDL_Quit();

}





