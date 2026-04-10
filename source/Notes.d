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





//======================================================================================================

https://rosettacode.org/wiki/A*_search_algorithm

import std.stdio;
import std.algorithm;
import std.range;
import std.array;



struct Point
{
    int x;
    int y;
    
    // Point p1 = Point(2,2);
    // Point p2 = Point(3,3);
    // Point p3 = p1 + p2;
    // writeln("p3 = ", p3);  // returns  p3 = Point(5, 5)
    
    Point opBinary(string op = "+")(Point o) 
    {
        return Point( o.x + x, o.y + y );
    }
}

struct Map 
{
    int w = 8;
    int h = 8;
    bool[][] m = [
            [0, 1, 0, 0, 1, 0, 0, 0],
            [0, 1, 0, 0, 1, 0, 0, 0],
            [0, 0, 1, 0, 1, 0, 1, 0],
            [0, 0, 1, 0, 1, 0, 1, 0],
            [0, 0, 1, 0, 1, 0, 1, 0],
            [0, 0, 1, 0, 1, 0, 1, 0],
            [0, 0, 1, 0, 1, 0, 1, 0],
            [0, 0, 1, 0, 0, 0, 1, 0]
        ];
}

struct Tile 
{
    Point position;
    Point parent;
    int dist;
    int cost;
    bool opEquals(const Tile n) { return position == n.position; }
    bool opEquals(const Point p) { return position == p; }
    // opCmp is only used for the inequality operators <, <=, >=, and >
    int opCmp(ref const Tile n) const 
    { 
        return (n.dist + n.cost) - (dist + cost); 
    }
}

bool wasFound(I)(I result)
{
    return(result != -1); // -1 is returned if no point b is found in the range (haystack)
}                         // returns true if not equal to -1

bool isValid(P, M)(P p, M m) 
{
    return ( (p.x > -1) && (p.y > -1) && (p.x < m.w) && (p.y < m.h) );
}


struct AStar 
{
    Map m;
    Point end;
    Point start;
   	Point[8] neighbors = [Point(-1,-1), Point(1,-1), Point(-1,1), Point(1,1), 
                          Point(0,-1),  Point(-1,0), Point(0,1),  Point(1,0)];
    Tile[] open;
    Tile[] closed;

    int calcDist(Point b)
    {
        // need a better heuristic
        int x = end.x - b.x; 
        int y = end.y - b.y;
        return( x * x + y * y );
    }


    bool existPoint(Point b, int cost)
    {
        auto i = closed.countUntil(b);  // Note: closed
        
        if(i.wasFound)   // -1 is returned if no point b is found in the range (haystack)
        {
            if( (closed[i].cost + closed[i].dist) < cost )
            {
                return true;
            }
            else 
            {   // eliminates elements at given offsets from range and returns the shortened range.
                closed = closed.remove!(SwapStrategy.stable)(i); 
                return false; 
            }
        }
        
        i = open.countUntil(b);   // Note: open
        
        if(i.wasFound) 
        {
            if( (open[i].cost + open[i].dist) < cost )
            {
                return true;
            }
            else 
            { 
                open = open.remove!(SwapStrategy.stable)(i); 
                return false; 
            }
        }
        return false;
    }


    bool fillOpen( ref Tile n )
    {
        int stepCost;
        int nc;
        int dist;
        Point neighbor;

        for( int x = 0; x < 8; ++x )
        {
            // one can make diagonals have different cost
            stepCost = x < 4 ? 1 : 1;  // condition ? value_if_true : value_if_false
            neighbor = n.position + neighbors[x];
            
            if( neighbor == end ) 
                return true;

            if( neighbor.isValid(m) && m.m[neighbor.y][neighbor.x] != 1 )  // on map not a wall
            {
                nc = stepCost + n.cost;
                dist = calcDist( neighbor );
                if( !existPoint( neighbor, nc + dist ) )
                {
                    Tile t;
                    t.cost = nc; 
                    t.dist = dist;
                    t.position = neighbor;
                    t.parent = n.position;
                    open ~= t;
                }
            }
        }
        return false;
    }


    bool searchFunc(ref Point s, ref Point e, ref Map mp) 
    {
        Tile n;
        start = s;
        end = e;
        //m = mp;
        n.cost = 0;
        n.position = s;
        n.parent = Point();
        writeln("n.parent = ", n.parent);
        n.dist = calcDist(s);
        open ~= n;
        while( !open.empty() )
        {
            //open.sort();
            Tile nx = open.front();
            open = open.drop(1).array;  // https://dlang.org/phobos/std_array.html#array
                                        // std.array
                                        // array Returns a copy of the input in a newly allocated dynamic array.
            //open = open.drop(1);  // this seems to work. at least in testing that was done.                            
            closed ~= nx ;
            if(fillOpen(nx)) 
                return true;
        }
        return false;
    }


    int pathFunc( ref Point[] path )
    {
        path = end ~ path;
        int cost = 1 + closed.back().cost;
        path = closed.back().position ~ path;
        Point parent = closed.back().parent;

        foreach(ref i; closed.retro()) 
        {
            if( i.position == parent && !( i.position == start ) ) 
            {
                path = i.position ~ path;
                parent = i.parent;
            }
        }
        path = start ~ path;
        return cost;
    }
}

//void main(string[] argv)
void main()
{
    Map map;
    Point s;
    Point e = Point( 7, 7 );
    AStar as;
    
    Point p1 = Point(2,2);
    Point p2 = Point(3,3);
    Point p3 = p1 + p2;
    writeln("p3 = ", p3);

    if( as.searchFunc(s, e, map) )
    {
        Point[] path;
        int c = as.pathFunc( path );
        for( int y = -1; y < 9; y++ ) 
        {
            for( int x = -1; x < 9; x++ )
            {
                if( x < 0 || y < 0 || x > 7 || y > 7 || (map.m[y][x] == 1) )
                {
                    write(cast(char)0xdb);
                }
                else 
                {
                    if( path.canFind(Point(x,y)) )
                        write("x");
                    else 
                        write(".");
                }
            }
            writeln();
        }

        write("\nPath cost ", c, ": ");
        foreach( i; path ) 
        {
            write("(", i.x, ", ", i.y, ") ");
        }
    }
    write("\n\n");
}

//======================================================================================================





























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




