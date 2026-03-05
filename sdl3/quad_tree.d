module quad_tree;

import std.algorithm : min, max;
import std.math : abs;
import std.container : Array;
import std.stdio : writeln;
import std.format;
import std.range : repeat, take;
import std.array : array, join;
import core.stdc.stdlib : exit;

import bindbc.sdl;  // SDL_* declarations
import sdl_funcs_with_error_handling;
    
alias T = int; // uint, float, double or whatever type you want 

struct Center
{
    T x;
    T y;
}

struct Half
{
    T w;  // width
    T h;  // height
}

struct AABB  // Simple axis-aligned bounding box
{
    Center center;
    Half   half;

    T left()   const @property { return center.x - half.w; }
    T right()  const @property { return center.x + half.w; }
    T top()    const @property { return center.y - half.h; }
    T bottom() const @property { return center.y + half.h; }

    bool containsPoint(T px, T py) const
    {
        return px >= left  && 
               px <= right && 
               py >= top   && 
               py <= bottom;
    }

    bool intersects(const AABB other) const
    {
        return !(right  < other.left  ||
                 left   > other.right ||
                 bottom < other.top   ||
                 top    > other.bottom);
    }
}

// Generic Quadtree node
// P = your payload type (e.g. GameObject*, size_t, struct, etc.)
 
class QuadTree(P)
{
    private:
    AABB boundary;
    int capacity;
    Array!P objects;

    QuadTree!P nw, ne, sw, se; // children
    bool divided = false;

    public:
    this(AABB boundary, int capacity = 4)
    {
        this.boundary = boundary;
        this.capacity = capacity;
    }

    // Insert one object with its bounding box
    bool insert(P item, AABB itemBounds)
    {
        // Not in this node?
        if (!boundary.intersects(itemBounds))
            return false;

        // Can we store it here?
        if (objects.length < capacity && !divided)
        {
            objects.insert(item);
            return true;
        }

        // Need to subdivide?
        if (!divided)
            subdivide();

        // Try to put it in one of the children
        if (nw.insert(item, itemBounds)) return true;
        if (ne.insert(item, itemBounds)) return true;
        if (sw.insert(item, itemBounds)) return true;
        if (se.insert(item, itemBounds)) return true;

        // If it didn't fit perfectly in one child (straddles lines)
        objects.insert(item);
        return true;
    }



    // Convenience overload when you just have center + radius
    bool insert(P,T)(P item, T x, T y, T radius)
    {
        AABB box = AABB(Center(x, y), Half(radius, radius));
        return insert(item, box);
    }



    // Retrieve all objects that intersect the query range
    void query(AABB range, ref Array!P found)
    {
        if (!boundary.intersects(range))
            return;

        // Check objects in this node
        foreach (obj; objects[])
        {
            writeln("obj = ", obj);
            found.insert(obj);
        }

        // Recurse into children
        if (divided)
        {
            nw.query(range, found);
            ne.query(range, found);
            sw.query(range, found);
            se.query(range, found);
        }
    }



    // Retrieve all objects in quadtree
    void returnAll(AABB range, ref Array!P found)
    {
        if (!boundary.intersects(range))
            return;

        // Check objects in this node
        foreach (obj; objects[])
        {
            writeln("obj = ", obj);
            found.insert(obj);
        }

        // Recurse into children
        if (divided)
        {
            nw.query(range, found);
            ne.query(range, found);
            sw.query(range, found);
            se.query(range, found);
        }
    }



    // Debugging helper
    void print(int depth = 0)
    {
        auto indents = "....".repeat().take(depth);  // indents is a range

        // writeln(typeid(typeof(indents)));
        // std.range.Take!(std.range.Repeat!(immutable(char)[]).Repeat).Take

        auto arrayIndents = indents.array; // convert range to a concrete array, with function .array

        // writeln("arrayIndents = ", arrayIndents);
        // arrayIndents = ["....", "...."]

        string stringIndents = arrayIndents.join();  // join without any separator

        // writeln("stringIndents = ", stringIndents);
        // stringIndents = ............

        writeln(stringIndents, "QuadTree at center ", boundary.center.x, ",", boundary.center.y,
                " size ", boundary.half.w * 2, "x", boundary.half.h * 2,
                "  objects: ", objects.length);

        if (divided)
        {
            nw.print(depth + 1);
            ne.print(depth + 1);
            sw.print(depth + 1);
            se.print(depth + 1);
        }
    }

    // XYWH vs. XYXY: XYWH uses (x, y, width, height), whereas XYXY uses (x1, y1, x2, y2) or top-left and bottom-right corners.
    // CXCYWH: A variant that uses the center point (cx, cy) instead of the top-left corner.

    SDL_FRect convertCXCYWHtoXYWH(SDL_FRect from)
    {
        SDL_FRect to;
        //to.
        return to;
    }
    
    void drawBox(SDL_Renderer *renderer, int depth = 0)
    {
        SDL_FRect rect; // = {100.0f, 100.0f, 500.0f, 350.0f}; // x, y, width, height

        // convert center of box to SDL3 Rect coordinates

        struct UpperLeftCorner
        {
            T x;
            T y;
        }

        UpperLeftCorner upperLeftCorner;
        
        writeln("boundary.half = ", boundary.half);

        upperLeftCorner.x = boundary.center.x - boundary.half.w;
        upperLeftCorner.y = boundary.center.y - boundary.half.h;
        
        writeln("upperLeftCorner = ", upperLeftCorner);

        rect.x = upperLeftCorner.x + boundary.half.w + 1;
        rect.y = upperLeftCorner.y + boundary.half.h + 1;
        rect.w = boundary.half.w * 2 - 1;
        rect.h = boundary.half.h * 2 - 1;
        writeln("rect = ", rect);
        SDL_SetRenderDrawColor(renderer, 0, 0, 122, 255); // blue

        //SDL_FRect xywh = convertCXCYWHtoXYWH(rect);

        renderRect(renderer, &rect);

        if (divided)
        {
            nw.drawBox(renderer, depth + 1);
            ne.drawBox(renderer, depth + 1);
            sw.drawBox(renderer, depth + 1);
            se.drawBox(renderer, depth + 1);
        }

    }

    private:
    void subdivide()
    {
        Half h;
        h.w = boundary.half.w / 2;
        h.h = boundary.half.h / 2;
        Center c;
        c.x = boundary.center.x;
        c.y = boundary.center.y;

        nw = new QuadTree!P(AABB(Center(c.x - h.w, c.y - h.h), Half( h.w, h.h)), capacity);	
        ne = new QuadTree!P(AABB(Center(c.x + h.w, c.y - h.h), Half( h.w, h.h)), capacity);		
        sw = new QuadTree!P(AABB(Center(c.x - h.w, c.y + h.h), Half( h.w, h.h)), capacity);	
        se = new QuadTree!P(AABB(Center(c.x + h.w, c.y + h.h), Half( h.w, h.h)), capacity);	
        divided = true;

        /+
        // Redistribute existing objects
        auto oldObjects = objects.dup;
        objects.clear();

        foreach (obj; oldObjects[])
        {
            // We unfortunately lost the original AABB here.
            // In real usage you would either:
            //   a) store AABB together with T, or
            //   b) ask the object for its current AABB
            // For demo we just re-insert at center with zero size
            // (this is wrong in production!)
            
            //insert(obj, AABB(0,0,0,0)); // placeholder - replace!
        }
        +/
    }
}

// ────────────────────────────────────────────────
//                  Example usage
// ────────────────────────────────────────────────

struct Particle
{
    Center    center;
    T         apothem;  // distance from the center to the midpoint of a side, aka inradius
    int       id;
    SDL_FRect rect;

    string toString() const
    {
        return "P%d(%.1f,%.1f)".format(id, center.x, center.y);
    }
}



void quadrophenia()
{
    enum 
    {
        halfWidth = 600,
        halfHeight = 500,
        inradius = 10,
        numParticles = 25
    }
    auto qt = new QuadTree!Particle( AABB(Center(x: 0, y: 0), Half(w: halfWidth, h: halfHeight)), 4);

    import std.random : uniform;

    foreach (i; 0..numParticles)
    {
        //float x = uniform(-180f, 180f);
        //float y = uniform(-180f, 180f);
        float x = uniform(-halfWidth, halfWidth);
        float y = uniform(-halfHeight, halfHeight);

        auto p = Particle(Center(x: cast(T) x,
                                 y: cast(T) y), 
                          apothem: inradius, 
                          id: i,
                          SDL_FRect(x: cast(T) x - inradius,
                                    y: cast(T) y - inradius,
                                    w: 2 * inradius,
                                    h: 2 * inradius)
                         );
                                 
                                 
        qt.insert(p, cast(T) x, cast(T) y, 5);  // small radius
    }

    writeln("Quadtree structure:");
    qt.print();

    // Query example

    writeln("\nObjects in region [-50..50, -50..50]:");
    Array!Particle results;

    //qt.query(AABB(0, 0, 50, 50), results);
    //AABB(Center(x: 0, y: 0), Half(w: 200, h: 200))

    //qt.query(AABB(Center(x: 0, y: 0), Half(w: 50, h: 50)), results);

    qt.query(AABB(Center(x: 0, y: 0), Half(w: halfWidth, h: halfHeight)), results);

    foreach (int i, p; results[])
        writeln("  ", i, "  ", p);

    writeln("results.length = ", results.length);

    SDL_Window   *window = null;
    SDL_Renderer *renderer = null;
    SDL_Texture  *texture = null;
    bool running = true;

    int winWidth = qt.boundary.half.w * 2;
    int winHeight = qt.boundary.half.h * 2;

    createWindowAndRenderer("QuadTree", winWidth, winHeight, cast(SDL_WindowFlags) 0, &window, &renderer);

    while (running)
    {
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
            {
                running = false;
            }
        }

        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);  // white screen  
        SDL_RenderClear(renderer); // Clear the renderer
        
        qt.drawBox(renderer);

        
        foreach (p; results[])
        {
            SDL_SetRenderDrawColor(renderer, 0, 100, 122, 255); // ???
            SDL_FRect r = p.rect;
            renderFillRect(renderer, &r);
        }
writeln("results.length = ", results.length);
        SDL_RenderPresent(renderer); // Present the rendered content
        exit(-1);
    }
    SDL_Quit();
}


