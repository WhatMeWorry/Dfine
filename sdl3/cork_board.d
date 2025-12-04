
module cork_board;

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
import debug_window;
import help_window;

struct Swatch
{
    SDL_Texture *texture;
    SDL_FRect   rect;
    double      angle;       // 0.0-360.0
    ubyte       opacity;     // 0-255
    double      aspectRatio; // ratio of width to height

    this(SDL_Renderer *renderer, float x, float y, string fileName) 
    {
        this.rect.x = x;
        this.rect.y = y;
        SDL_Surface *surface = loadImageToSurface(fileName);
        this.rect.w = surface.w;
        this.rect.h = surface.h;
        this.angle = 0.0;
        this.opacity = 255;  // completely opaque
        this.aspectRatio = cast(double) surface.w / cast(double) surface.h;
        this.texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, 
                       SDL_TEXTUREACCESS_STREAMING, surface.w, surface.h);

        // enable blending for the texture once after creation.
        SDL_SetTextureBlendMode(this.texture, SDL_BLENDMODE_BLEND);

        copySurfaceToTexture(surface, null, this.texture, null);
        SDL_DestroySurface(surface);
    }
}



struct Delta
{
    double scale;
    double rotate;
    double translate;
    double opaque;
}


const SDL_FPoint *CENTER = null;
const SDL_FRect *FULL_TEXTURE = null;

struct CorkBoard
{
    uint active;  // current swatch for scale, translation, rotation, and opacity
    bool borderActive;
	bool locked;  // lock all the swatches together so they will me moved as one
    Swatch[] swatches;
    Delta delta;  

    this(SDL_Renderer *renderer, float x, float y)
    {
        this.swatches ~= Swatch(renderer, 10, 10, "./images/WachA.png");
        this.swatches ~= Swatch(renderer, 20, 20, "./images/WachB.png");
        //this.swatches ~= Swatch(renderer, 30, 30, "./images/WachC.png");
        //this.swatches ~= Swatch(renderer, 40, 40, "./images/WachD.png");
        //this.active = 0;
        delta.scale = 0.01;
        delta.translate = 3.0;
        delta.rotate = 0.5; 
        delta.opaque = 5;
        borderActive = true;
		locked = false;
    }

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
    void enlarge(ref Swatch s)
    {
        s.rect.w = s.rect.w + ((s.rect.w * s.aspectRatio) * delta.scale);
        s.rect.h = s.rect.h + ((s.rect.h * s.aspectRatio) * delta.scale);
    }
    void reduce(ref Swatch s)
    {
        s.rect.w = s.rect.w - ((s.rect.w * s.aspectRatio) * delta.scale);
        s.rect.h = s.rect.h - ((s.rect.h * s.aspectRatio) * delta.scale);
    }
    void moveLeft(ref Swatch s)
    {
        s.rect.x = s.rect.x - delta.translate;
    }
    void moveAllSwatchesLeft(ref Swatch[] swatches)
    {
        foreach (int i, ref s; swatches)
		{	
            s.rect.x = s.rect.x - delta.translate;
		}
    }		
    void moveRight(ref Swatch s)
    {
        s.rect.x = s.rect.x + delta.translate;
    }
    void moveAllSwatchesRight(ref Swatch[] swatches)
    {
        foreach (int i, ref s; swatches)
		{	
            s.rect.x = s.rect.x + delta.translate;
		}
    }	
    void moveUp(ref Swatch s)
    {
        s.rect.y = s.rect.y - delta.translate;
    }
	void moveAllSwatchesUp(ref Swatch[] swatches)
    {
        foreach (int i, ref s; swatches)
		{	
            s.rect.y = s.rect.y - delta.translate;
		}
    }		
    void moveDown(ref Swatch s)
    {
        s.rect.y = s.rect.y + delta.translate;
    }
	void moveAllSwatchesDown(ref Swatch[] swatches)
    {
        foreach (int i, ref s; swatches)
		{	
            s.rect.y = s.rect.y + delta.translate;
		}
    }		
    void rotateClockwise(ref Swatch s)
    {
        s.angle = s.angle + delta.rotate;
    }
    void rotateCounterClockwise(ref Swatch s)
    {
        s.angle = s.angle - delta.rotate;
    }
    void moreOpaque(ref Swatch s)
    {
        if (s.opacity < 255)
        {
            s.opacity++;
        }
    }
    void lessOpaque(ref Swatch s)
    {
        if (s.opacity > 0)
        {
            s.opacity--;
        }
    }
    void increaseDeltaScale(ref double dScale)
    {
        dScale = dScale * 2.0;
    }
    void decreaseDeltaScale(ref double dScale)
    {
        dScale = dScale / 2.0;
    }
    void increaseDeltaTranslate(ref double dTrans)
    {
        dTrans = dTrans * 2.0;
    }
    void decreaseDeltaTranslate(ref double dTrans)
    {
        dTrans = dTrans / 2.0;
    }
    void increaseDeltaRotate(ref double dRotate)
    {
        dRotate = dRotate * 2.0;
    }
    void decreaseDeltaRotate(ref double dRotate)
    {
        dRotate = dRotate / 2.0;
    }
    void increaseDeltaOpacity(ref double dOpacity)
    {
        dOpacity = dOpacity * 2.0;
    }
    void decreaseDeltaOpacity(ref double dOpacity)
    {
        dOpacity = dOpacity / 2.0;
    } 

    SDL_FRect calculateRectThatEncompassesAllSwatches()
    {
        float min_x = swatches[0].rect.x;
        foreach (s; swatches)
        {
            if (s.rect.x < min_x)
                min_x = s.rect.x;
        }	
		
		float min_y = swatches[0].rect.y;
        foreach (s; swatches)
        {
            if (s.rect.y < min_y)
                min_y = s.rect.y;
        }	
		
		float max_w = swatches[0].rect.x + swatches[0].rect.w;
        foreach (s; swatches)
        {
            if ((s.rect.x + s.rect.w) > max_w)
                max_w = s.rect.x + s.rect.w;
        }			
		
		float max_h = swatches[0].rect.y + swatches[0].rect.h;
        foreach (s; swatches)
        {
            if ((s.rect.y + s.rect.h) > max_h)
            max_h = s.rect.y + s.rect.h;
        }					
		
        writeln("min_x = ", min_x);
        writeln("min_y = ", min_y);
        writeln("max_w = ", max_w);
        writeln("max_h = ", max_h);
		
		SDL_FRect rect;
		
		rect.x = min_x;
		rect.y = min_y;
        rect.w = max_w;
        rect.h = max_h;
		
        return rect;
	}


    SDL_Point moveAllSwatchesRelativeToUpperLeftCorner(SDL_FRect rect)
    {
        SDL_Point offsetVector;                     // We need to move all swatches relative to (0,0) origin
        offsetVector.x = cast(int) (0.0 - rect.x);  // when we save the contents. Can't use negative coordinates
        offsetVector.y = cast(int) (0.0 - rect.y);  // for swatches laying outside of corkboard and not waste space
        return offsetVector;                        // for swatches inside of the corkboard not on its edges.
	}	                                            
	
	
	









}







void corkboard()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Corkboard", 3600, 2000, cast(SDL_WindowFlags) 0, &window, &renderer);

    CorkBoard board = CorkBoard(renderer,  10, 10);

    DebugWindow debugWin = DebugWindow(SDL_Rect(25, 25, 1000, 1000));

    HelpWindow helpWin = HelpWindow(SDL_Rect(100, 100, 1000, 1000));
    helpWin.displayHelpMenu(board.delta);

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

                    case SDLK_TAB:
                        if (board.active == (board.swatches.length - 1))
                            board.active = 0;
                        else
                            board.active++;
                    break;

                    case SDLK_INSERT:
                        board.enlarge(board.swatches[board.active]);
                    break;

                    case SDLK_DELETE:
                        board.reduce(board.swatches[board.active]);
                    break;

                    case SDLK_LEFT:
                        if (board.locked)
                            board.moveAllSwatchesLeft(board.swatches);
                        else
                            board.moveLeft(board.swatches[board.active]);
                    break;

                    case SDLK_RIGHT:
                        if (board.locked)
                            board.moveAllSwatchesRight(board.swatches);
                        else
                            board.moveRight(board.swatches[board.active]);
                    break;

                    case SDLK_UP:
                        if (board.locked)
                            board.moveAllSwatchesUp(board.swatches);
                        else					
                            board.moveUp(board.swatches[board.active]);
                    break;
					
                    case SDLK_DOWN:
                        if (board.locked)
                            board.moveAllSwatchesDown(board.swatches);
                        else										
                            board.moveDown(board.swatches[board.active]);
                    break;

                    case SDLK_HOME:
                        board.rotateClockwise(board.swatches[board.active]);
                    break;

                    case SDLK_END:
                        board.rotateCounterClockwise(board.swatches[board.active]);
                    break;

                    case SDLK_PAGEUP:
                        board.moreOpaque(board.swatches[board.active]);
                    break;

                    case SDLK_PAGEDOWN:
                        board.lessOpaque(board.swatches[board.active]);
                    break;

                    case SDLK_F1:
                        board.increaseDeltaScale(board.delta.scale);
                    break;

                    case SDLK_F2:
                        board.decreaseDeltaScale(board.delta.scale);
                    break;

                    case SDLK_F3:
                        board.increaseDeltaTranslate(board.delta.translate);
                    break;

                    case SDLK_F4:
                        board.decreaseDeltaTranslate(board.delta.translate);
                    break;

                    case SDLK_F5:
                        board.increaseDeltaRotate(board.delta.rotate);
                    break;

                    case SDLK_F6:
                        board.decreaseDeltaRotate(board.delta.rotate);
                    break;

                    case SDLK_F7:
                        board.increaseDeltaOpacity(board.delta.opaque);
                    break;

                    case SDLK_F8:
                        board.decreaseDeltaOpacity(board.delta.opaque);
                    break;

                    case SDLK_F9:
                        board.borderActive = !board.borderActive;
                    break;
					
                    case SDLK_F10:
                        board.locked = !board.locked;
                    break;	

                    case SDLK_F12:
                        SDL_FRect rect = board.calculateRectThatEncompassesAllSwatches();
						SDL_Point offsetVector = board.moveAllSwatchesRelativeToUpperLeftCorner(rect);
						
						writeln("offsetVector = ", offsetVector);
						
						/+
                        writeln("rect = ", rect);
						int width = cast (int) (rect.w - rect.x);  // rect.w represents the far left side of the rect (not het width)
						int height = cast (int) (rect.h - rect.y); // rect.h represent the bottom side to the rect (not the height)
						writeln("width = ", width);
						writeln("height = ", height);
						SDL_Surface *bigSurface = createSurface(width, height, SDL_PIXELFORMAT_RGBA8888);
						+/
					break;
					
                    default: // lots of keys are not mapped so not a problem
                }
                //debugWin.displaySwatch(board.swatches[board.active], board.active);

                debugWin.displayAllSwatches(board);

                helpWin.displayHelpMenu(board.delta);
            }
        }

        SDL_RenderClear(renderer); // Clear the renderer

        board.renderAllSwatches(renderer);

        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();

}





