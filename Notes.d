/+


https://github.com/patrickodacre/odin-space-shooter

https://www.youtube.com/watch?v=gtzIZZazuG0&list=PLuZ3rcIdDc9EA4YqLJSsrzYeUDv8Mucxz&index=2


Why are you looping instate of using a Sleep function or even SDL_Delay()

Good question. Delay or sleep means i have to wait for the operating system to restart the loop. 
The OS may not check the delay timer as frequently as we need to maintain our target frame rate. 
In other words, if we want a loop every 16 millisecond, but the OS only checks for delayed processes 
every 30 milliseconds, we're going to miss some frames. 

Here... In the SDL docs it mentions that delay can take longer because of os scheduling... 
https://wiki.libsdl.org/SDL2/SDL_Delay.  We don't want that.

Sleeping is never a wise move in any game loop, the granularity of a sleep call is not good for 
anything accurate. It might be "good enough" for some small 2D game using a single fixed-step loop 
and a simple "update game" function, but if falls apart when more complexity is added, such as 
different systems updating at different rates.





bool SDL_RenderPresent(SDL_Renderer *renderer);

SDL's rendering functions operate on a backbuffer; that is, calling a rendering function such as SDL_RenderLine() 
does not directly put a line on the screen, but rather updates the backbuffer. As such, you compose your entire 
scene and present the composed backbuffer to the screen as a complete picture.

Therefore, when using SDL's rendering API, one does all drawing intended for the frame, and then calls this function,
SDL_RenderPresent, once per frame to present the final drawing to the user.


The backbuffer should be considered invalidated after each present; do not assume that previous contents will exist 
between frames. You are strongly encouraged to call SDL_RenderClear() to initialize the backbuffer before starting 
each new frame's drawing, even if you plan to overwrite every pixel.































//=============================================================================================

SDL_Texture* rock_tex;
SDL_Texture* paper_tex;
SDL_Texture* scissors_tex;

https://github.com/SpaghettiBorgar/rps-battle-sim/blob/master/source/app.d


auto window = SDL_CreateWindow("SDL Application", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                windowW, windowH, SDL_WINDOW_SHOWN);

SDL_Renderer* sdlr = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);

SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");

// SDL_SetHint(SDL_HINT_RENDER_LINE_METHOD, "2");

SDL_SetRenderDrawBlendMode(sdlr, SDL_BLENDMODE_BLEND);

rock_tex = SDL_CreateTextureFromSurface(sdlr, IMG_Load("./rock.png"));


SDL_Texture*     rock_tex = SDL_CreateTextureFromSurface(sdlr, IMG_Load("./rock.png"));
SDL_Texture*    paper_tex = SDL_CreateTextureFromSurface(sdlr, IMG_Load("./paper.png"));
SDL_Texture* scissors_tex = SDL_CreateTextureFromSurface(sdlr, IMG_Load("./scissors.png"));

if(rock_tex is null || paper_tex is null || scissors_tex is null) 
{
    throw new SDLException();
}








// typeof is a way to specify a type based on the type of an expression. For example:

void func(int i)
{
    typeof(i) j;       // j is of type int
    typeof(3 + 6.0) x; // x is of type double
    typeof(1)* p;      // p is of type pointer to int
    int[typeof(p)] a;  // a is of type int[int*]

    writeln(typeof('c').sizeof); // prints 1
    double c = cast(typeof(1.0))j; // cast j to double
}


//===========================================================

import std.stdio;

class D
{
    this() { }
    ~this() { }
    void foo() { }
    int foo(int) { return 2; }
}

void main()
{
    D d = new D();

    foreach (t; __traits(getVirtualMethods, D, "foo"))
        writeln("1 ",typeid(typeof(t)));

    alias b = typeof(__traits(getVirtualMethods, D, "foo"));
    foreach (t; b)
        writeln("2 ",typeid(t));

    auto i = __traits(getVirtualMethods, d, "foo")[1](1);
        writeln("3 ",i);
}

//===========================================================


+/




