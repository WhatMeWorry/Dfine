
// void copying_textures_to_surface()
// void copying_surface_to_surface()
// void two_windows_and_surfaces()
// void change_texture_access()
// void smallest_renderer_01()
// void smallest_texture_01a()
// void smallest_texture_with_rect()
// void smallest_texture_01b()
// void no_renderer_02()
// void surface_no_implicit_scaling_03()
// void surface_explicit_scaling_04()
// void texture_implicit_scaling_05()

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

struct Position { float x; float y; }
struct Size { float w; float h; }

struct Swatch
{
    SDL_Texture *texture;
    SDL_FRect   rect;
    double      angle;       // 0.0-360.0	
    int         alpha;       // 0-255
	double      aspectRatio; // ratio of width to height
	
	this(SDL_Renderer *renderer, float x, float y, string fileName) 
	{
        this.rect.x = x;
		this.rect.y = y;
        SDL_Surface *surface = loadImageToSurface(fileName);
        this.rect.w = surface.w;
		this.rect.h = surface.h;
		this.angle = 0.0;
		this.alpha = 128;
		this.aspectRatio = cast(double) surface.w / cast(double) surface.h;
		this.texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, 
		               SDL_TEXTUREACCESS_STREAMING, surface.w, surface.h);
		copySurfaceToTexture(surface, null, this.texture, null);
		SDL_DestroySurface(surface);
    }
}

const SDL_FPoint *CENTER = null;
const SDL_FRect *FULL_TEXTURE = null;

struct CorkBoard
{
    uint active;  // current swatch for scale, translation, rotation, and opacity
    Swatch[] swatches;
	
	this(SDL_Renderer *renderer, float x, float y)
	{
        this.swatches ~= Swatch(renderer, 10, 10, "./images/WachA.png");
        this.swatches ~= Swatch(renderer, 20, 20, "./images/WachB.png");
        this.swatches ~= Swatch(renderer, 30, 30, "./images/WachC.png");		
        this.swatches ~= Swatch(renderer, 40, 40, "./images/WachD.png");		
		this.active = 0;
	}

	void renderAllSwatches(SDL_Renderer *renderer)
	{
        foreach(i, s; this.swatches)
		{
            SDL_RenderTextureRotated(renderer, s.texture, FULL_TEXTURE, &s.rect, s.angle, CENTER, SDL_FLIP_NONE);
			if (active == i)
			{
			    writeln("active==i ", active, "==", i);
				
                ubyte r, g, b, a;
                SDL_GetRenderDrawColor(renderer, &r, &g, &b, &a);  // save off the current color		
		
                SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);  // set color to red	
                SDL_RenderRect(renderer, &s.rect);                 // draw rectangular outline
				
				SDL_SetRenderDrawColor(renderer, r, g, b, a);      // restore the previous color
			}
	    }
	}
}


void corkboard()
{
    //CorkBoard board;
    
    SDL_Window   *window;
    SDL_Renderer *renderer;
	
	double deltaSize = 0.01;
    double angleSize = 0.5;
   
    
    createWindowAndRenderer("Corkboard", 2000, 2000, cast(SDL_WindowFlags) 0, &window, &renderer);
    
    //Swatch swatch = Swatch(renderer, 10, 10, "./images/WachA.png");

    CorkBoard board = CorkBoard(renderer,  10, 10);    

    writeln("board = ", board);
	
    //displayTextureProperties(swatch.texture);


    //SDL_FRect t;  t.x = 10; t.y = 10; t.w = texture.w; t.h = texture.h;


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
					    Swatch t = board.swatches[board.active];
						t.rect.w = t.rect.w + ((t.rect.w * t.aspectRatio) * deltaSize);
						t.rect.h = t.rect.h + ((t.rect.h * t.aspectRatio) * deltaSize);
						board.swatches[board.active] = t;
					    //b.swatches[b.active].rect.w = b.swatches[b.active].rect.w + (b.swatches[b.active].rect.w * b.aspectRatio) * deltaSize;
                        //t.w = t.w + (t.w * aspectRatio) * deltaSize;
                        //t.h = t.h + (t.h * aspectRatio) * deltaSize;
                    break;
                    case SDLK_DELETE:
                        //t.w = t.w - (t.w * aspectRatio) * deltaSize;
                        //t.h = t.h - (t.h * aspectRatio) * deltaSize;
					    Swatch t = board.swatches[board.active];
						t.rect.w = t.rect.w - ((t.rect.w * t.aspectRatio) * deltaSize);
						t.rect.h = t.rect.h - ((t.rect.h * t.aspectRatio) * deltaSize);
						board.swatches[board.active] = t;						
						
                    break;
					
                    case SDLK_LEFT:	
					    Swatch t = board.swatches[board.active];
						t.rect.x = t.rect.x - 3.0;
						board.swatches[board.active] = t;
                    break;
					
                    case SDLK_RIGHT:
 					    Swatch t = board.swatches[board.active];
						t.rect.x = t.rect.x + 3.0;
						board.swatches[board.active] = t;
                    break;
                    case SDLK_UP:
					    Swatch t = board.swatches[board.active];
						t.rect.y = t.rect.y - 3.0;
						board.swatches[board.active] = t;
                    break;
                    case SDLK_DOWN:
					    Swatch t = board.swatches[board.active];
						t.rect.y = t.rect.y + 3.0;
						board.swatches[board.active] = t;
                    break;
					
                    case SDLK_HOME:
					    Swatch t = board.swatches[board.active];
                        t.angle = t.angle - angleSize;
						board.swatches[board.active] = t;
                    break;
                    case SDLK_END:
					    Swatch t = board.swatches[board.active];
                        t.angle = t.angle + angleSize;
						board.swatches[board.active] = t;
                    break;
					
                    default: // lots of keys are not mapped so not a problem
                 }
            }
        }

        SDL_RenderClear(renderer); // Clear the renderer
        
        //SDL_FRect temp;  temp.x = 0; temp.y = 0; temp.w = texture.w; temp.h = texture.h;
        //SDL_FRect temp;  temp.x = 0; temp.y = 0; temp.w = 3312; temp.h = 2093;
		
		//writeln("t = ", t);
        
        //SDL_RenderTexture(renderer, texture, null, &t);
        
		board.renderAllSwatches(renderer);
		
        //const SDL_FPoint *CENTER = null;
        //const SDL_FPoint *FULL_TEXTURE = null;
        //SDL_RenderTextureRotated(renderer, texture, FULL_TEXTURE, &t, swatch.angle, CENTER, SDL_FLIP_NONE);

        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();

}





