
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

struct Float2 { float w; float h; }

struct Pin
{
    SDL_Texture *texture;
    Float2      position;
    Float2      size;
    int         alpha;  // 0-255
    double      angle;  // 0.0-360.0
}

struct Pins
{
    uint current; // currently active slide for scale, translation, and rotation
    Pin[] pins;
}


void corkboard()
{
    Pins board;
    Pin swatch;
    
    SDL_Window   *window;
    SDL_Renderer *renderer;
    SDL_Texture  *texture;
    SDL_Surface  *surface;
	
	double deltaSize = 0.01;
    double angleSize = 0.5;
    
    double angle = 0.0;
    
    createWindowAndRenderer("Corkboard", 2000, 2000, cast(SDL_WindowFlags) 0, &window, &renderer);
    
    surface = loadImageToSurface("./images/WachA.png");
    
    displaySurfaceProperties(surface);
    
    texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, surface.w, surface.h);
	
	writeln("texture.w = ", texture.w);
	writeln("texture.h = ", texture.h);
    
    copySurfaceToTexture(surface, null, texture, null);
    swatch.texture = texture;
    board.current = 0;
    board.pins ~= swatch;
    
    SDL_DestroySurface(surface);
    
    displayTextureProperties(texture);
	
	
	// Most scanned textures are not perfect squares but rectangular. When resizing these images
	// you can't just increase or decrease the width/height by the same amount. 
	
    writeln("texture.w = ", texture.w);
	writeln("texture.h = ", texture.h);
	double widthToHeightRatio = cast(double) texture.w / cast(double) texture.h;  // widthToHeightRatio == 1.0 means width equals height (square)
	                                                                              // widthToHeightRatio > 1.0 means width longer than height
																				  // widthToHeightRatio < 1.0 means height longer than width
	writeln("widthToHeightRatio = ", widthToHeightRatio);
    
    // same as above.  Turn into a function?
    /+
    surface = loadImageToSurface("./images/WachC.png");
    displaySurfaceProperties(surface);
    texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, surface.w, surface.h);
    copySurfaceToTexture(surface, null, texture, null);
    SDL_DestroySurface(surface);
    displayTextureProperties(texture);

    swatch.texture = texture;
    board.pins ~= swatch;
    +/
    writeln("board = ", board);
    writeln("board.pins.length = ", board.pins.length);

    SDL_FRect t;  t.x = 10; t.y = 10; t.w = texture.w; t.h = texture.h;

    /+
    createWindowAndRenderer("Texture", w, h, cast(SDL_WindowFlags) 0, &windowTex, &renderer);
    texture = createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, w, h);
    
    float adjustFactorW = cast(float) w / cast(float) 33460;
    float adjustFactorH = cast(float) h / cast(float) 10594;
    
    writeln("w x h = ", w, " x ", h);
    writeln("adjustFactorW = ", adjustFactorW);
    writeln("adjustFactorH = ", adjustFactorH);

    SDL_Surface *surfaceMain = getWindowSurface(windowMain);  // creates a surface if it does not already exist

    SDL_Surface *surfaceMini = getWindowSurface(windowMini);  // creates a surface if it does not already exist

    //SDL_Surface *surface = loadImageToSurface("./images/HUGE.png");
    writeln("after loadImageToSurface");

    SDL_Surface *surface = assembleTCFNA();  // Super Slow to load
    
    copySurfaceToTexture(surfaceMini, null, texture, null);  // ***************

    displaySurfaceProperties(surface);

    SDL_Rect boundsRect = { 0, 0, surface.w, surface.h };  // outer boundaries

    SDL_Rect surRect = { 0, 0, surfaceMain.w, surfaceMain.h };
    +/
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
                    case SDLK_INSERT:
                        t.w = t.w + (t.w * widthToHeightRatio) * deltaSize;
                        t.h = t.h + (t.h * widthToHeightRatio) * deltaSize;
                    break;
                    case SDLK_DELETE:
                        t.w = t.w - (t.w * widthToHeightRatio) * deltaSize;
                        t.h = t.h - (t.h * widthToHeightRatio) * deltaSize;
                    break;
                    case SDLK_LEFT:
                        t.x = t.x - 1.0;
                    break;
                    case SDLK_RIGHT:
                        t.x = t.x + 1.0;
                    break;
                    case SDLK_UP:
                        t.y = t.y - 1.0;
                    break;
                    case SDLK_DOWN:
                        t.y = t.y + 1.0;
                    break;
                    case SDLK_HOME:
                        angle = angle - angleSize;
                    break;
                    case SDLK_END:
                        angle = angle + angleSize;
                    break;
                    default: // lots of keys are not mapped so not a problem
                 }
            }
        }

/+
        copySurfaceToSurface(surface, &surRect, surfaceMain, null);

        updateWindowSurface(windowMain);

        copySurfaceToSurface(surface, &boundsRect, surfaceMini, null);  //  took: 0.0025443 seconds

        //displaySurfaceProperties(surface);
        //displaySurfaceProperties(surfaceMini);

        // get the current value of the high resolution counter - typically used for profiling
        ulong start_counter = SDL_GetPerformanceCounter(); // Get the initial timestamp
        
        // blitSurfaceScaled(surface, null, surfaceMini, null, SDL_SCALEMODE_LINEAR);  // took: 2.19031 seconds
           blitSurfaceScaled(surface, null, surfaceMini, null, SDL_SCALEMODE_NEAREST);  // took: 0.0092878 seconds
        // blitSurfaceScaled(surface, null, surfaceMini, null, SDL_SCALEMODE_PIXELART); // compile error

        ulong end_counter = SDL_GetPerformanceCounter(); // Get the timestamp after function execution
        ulong frequency = SDL_GetPerformanceFrequency(); // Get the number of counter increments per second
        // Calculate the time taken in seconds and milliseconds
        double seconds = (double)(end_counter - start_counter) / frequency;
        double milliseconds = seconds * 1000.0;
        //writeln("while loop took: ", seconds, " seconds");
        //writeln("while loop took: ", milliseconds, " milliseconds");

        updateWindowSurface(windowMini);  // took: 0.0015916 seconds

        SDL_RenderClear(renderer); // Clear the renderer
        copySurfaceToTexture(surfaceMini, null, texture, null);
            
        SDL_RenderTexture(renderer, texture, null, null); // loading the image (above) is not rendering

        SDL_FRect rect = { surRect.x * adjustFactorW, surRect.y * adjustFactorH, w1 * adjustFactorW, h1 * adjustFactorH }; 

        SDL_SetRenderTarget(renderer, texture);
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);  // red

        // *******************************************************
        //SDL_RenderRect(renderer, &rect);
        drawRectWithThickness(renderer, &rect, 2.0); 
        // *******************************************************
        
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);  // white
        SDL_SetRenderTarget(renderer, null);  // set render target back to the default (window)

        SDL_RenderPresent(renderer); // Present the rendered content
+/
        SDL_RenderClear(renderer); // Clear the renderer
        
        //SDL_FRect temp;  temp.x = 0; temp.y = 0; temp.w = texture.w; temp.h = texture.h;
        //SDL_FRect temp;  temp.x = 0; temp.y = 0; temp.w = 3312; temp.h = 2093;
		
		//writeln("t = ", t);
        
        SDL_RenderTexture(renderer, texture, null, &t);
        
        const SDL_FPoint *Center = null;
        
        SDL_RenderTextureRotated(renderer, texture, null, &t, angle, Center, SDL_FLIP_NONE);

        SDL_RenderPresent(renderer); // Present the rendered content
    }
    SDL_Quit();

}





