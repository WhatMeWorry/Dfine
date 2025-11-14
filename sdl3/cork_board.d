
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
    double opacity;
}


const SDL_FPoint *CENTER = null;
const SDL_FRect *FULL_TEXTURE = null;

struct CorkBoard
{
    uint active;  // current swatch for scale, translation, rotation, and opacity
    Swatch[] swatches;
    Delta delta;  
	
	this(SDL_Renderer *renderer, float x, float y)
	{
        this.swatches ~= Swatch(renderer, 10, 10, "./images/WachA.png");
        this.swatches ~= Swatch(renderer, 20, 20, "./images/WachB.png");
        this.swatches ~= Swatch(renderer, 30, 30, "./images/WachC.png");
        this.swatches ~= Swatch(renderer, 40, 40, "./images/WachD.png");
		this.active = 0;
        delta.scale = 0.01;
		delta.translate = 3.0;
		delta.rotate = 0.5; 
		delta.opacity = 5;
	}

    void renderAllSwatches(SDL_Renderer *renderer)
    {
        foreach(i, s; this.swatches)
        {
		    SDL_SetTextureAlphaMod(s.texture, s.opacity);
		
            SDL_RenderTextureRotated(renderer, s.texture, FULL_TEXTURE, &s.rect, s.angle, CENTER, SDL_FLIP_NONE);
			
            if (active == i)
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
    void moveRight(ref Swatch s)
    {
        s.rect.x = s.rect.x + delta.translate;
    }
    void moveUp(ref Swatch s)
    {
        s.rect.y = s.rect.y - delta.translate;
    }
    void moveDown(ref Swatch s)
    {
        s.rect.y = s.rect.y + delta.translate;
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
}


void corkboard()
{
    SDL_Window   *window;
    SDL_Renderer *renderer;

    createWindowAndRenderer("Corkboard", 2000, 2000, cast(SDL_WindowFlags) 0, &window, &renderer);

    CorkBoard board = CorkBoard(renderer,  10, 10);    

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
                        board.moveLeft(board.swatches[board.active]);
                    break;

                    case SDLK_RIGHT:
                        board.moveRight(board.swatches[board.active]);
                    break;
                    
                    case SDLK_UP:
                        board.moveUp(board.swatches[board.active]);
                    break;
                    case SDLK_DOWN:
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

                    default: // lots of keys are not mapped so not a problem
                 }
            }
        }

        SDL_RenderClear(renderer); // Clear the renderer
        
        board.renderAllSwatches(renderer);

        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();

}





