
module debug_window;

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

/+
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
+/


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
		
        // Set the text color (e.g., white)
        SDL_SetRenderDrawColor(ren, 255, 255, 255, SDL_ALPHA_OPAQUE);
    
        // Render the debug text
        SDL_RenderDebugText(ren, 50.0f, 50.0f, "Hello, world!");
        SDL_RenderDebugText(ren, 50.0f, 70.0f, "This is some debug text.");
		
        SDL_RenderPresent(ren); // Present the rendered content
	}

    void debugText(int x, int y, string str)
    {
        writeln("in debugText ", str);
  
        SDL_RenderClear(ren); // Clear the renderer
            SDL_RenderDebugText(ren, x, y, str.toStringz);
			SDL_RenderDebugText(ren, 3, 50, "***********************************");
        SDL_RenderPresent(ren); // Present the rendered content		
		
    }

}