
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
    SDL_Rect    rect;

    this(int x, int y, string fileName) 
    {
        this.rect.x = x;
        this.rect.y = y;
        surface = loadImageToSurface(fileName);
        this.rect.w = surface.w;
        this.rect.h = surface.h;
    }
}


struct CorkBoard
{
    uint active;  // current swatch for scale, translation, rotation, and opacity
    bool borderActive;
    bool locked;  // lock all the swatches together so they will me moved as one

    this(SDL_Renderer *renderer, float x, float y)
    {
        this.swatches ~= Swatch(renderer, 10, 10, "./images/WachA.png");
        //this.swatches ~= Swatch(renderer, 20, 20, "./images/WachB.png");
        //this.swatches ~= Swatch(renderer, 30, 30, "./images/WachC.png");
        //this.swatches ~= Swatch(renderer, 40, 40, "./images/WachD.png");
        //this.active = 0;
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
}


void trimEdges()
{
    // Home Samsung desktop 3840 x 2160
    // Work Lenovo desktop 2560 x 1600
    
    SDL_Window *window = createWindow("Trimmer", 2048, 2048, cast(SDL_WindowFlags) 0);
    
    SDL_Surface *windowSurface = getWindowSurface(window);  // creates a surface if it does not already exist

    HelpWindow helpWin = HelpWindow(SDL_Rect(100, 100, 1000, 1000));
    helpWin.displayHelpMenu(board.delta);
    
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

                    case SDLK_F1:
                        board.increaseByDoubling(board.delta.scale);
                        //board.increaseDeltaScale(board.delta.scale);
                    break;

                    case SDLK_F2:
                        board.decreaseByHalving(board.delta.scale);
                        //board.decreaseDeltaScale(board.delta.scale);
                    break;

                    case SDLK_F3:
                        board.increaseOrderOfMagnitude(board.delta.translate);
                        //board.increaseDeltaTranslate(board.delta.translate);
                    break;

                    case SDLK_F4:
                        board.decreaseOrderOfMagnitude(board.delta.translate);
                        //board.decreaseDeltaTranslate(board.delta.translate);
                    break;

                    case SDLK_F5:
                        board.increaseByDoubling(board.delta.rotate);
                        //board.increaseDeltaRotate(board.delta.rotate);
                    break;

                    case SDLK_F6:
                        board.decreaseByHalving(board.delta.rotate);
                        //board.decreaseDeltaRotate(board.delta.rotate);
                    break;

                    case SDLK_F7:
                        board.increaseByDoubling(board.delta.opaque);
                        //board.increaseDeltaOpacity(board.delta.opaque);
                    break;

                    case SDLK_F8:
                        board.decreaseByHalving(board.delta.opaque);
                        //board.decreaseDeltaOpacity(board.delta.opaque);
                    break;

                    case SDLK_F9:
                        board.borderActive = !board.borderActive;
                    break;

                    case SDLK_F10:
                        board.locked = !board.locked;
                    break;

                    default: // lots of keys are not mapped so not a problem
                }

                debugWin.displayAllSwatches(board);

                helpWin.displayHelpMenu(board.delta);
            }
        }

        updateWindowSurface(window);
    }
    SDL_Quit();

}





