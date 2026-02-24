module quad_tree;

import std.algorithm : min, max;
import std.math : abs;
import std.container : Array;
import std.stdio : writeln;
import std.format;

// Simple axis-aligned bounding box

struct AABB
{
    float x, y;     // center
    float halfW, halfH;

    float left()   const @property { return x - halfW; }
    float right()  const @property { return x + halfW; }
    float top()    const @property { return y - halfH; }
    float bottom() const @property { return y + halfH; }

    bool containsPoint(float px, float py) const
    {
        return px >= left  && px <= right &&
               py >= top   && py <= bottom;
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
// T = your payload type (e.g. GameObject*, size_t, struct, etc.)
 
class QuadTree(T)
{
private:
    AABB boundary;
    int capacity;
    Array!T objects;

    QuadTree!T nw, ne, sw, se; // children
    bool divided = false;

public:
    this(AABB boundary, int capacity = 4)
    {
        this.boundary = boundary;
        this.capacity = capacity;
    }

    /// Insert one object with its bounding box
    bool insert(T item, AABB itemBounds)
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

    /// Convenience overload when you just have center + radius
    bool insert(T item, float cx, float cy, float radius)
    {
        AABB box = AABB(cx, cy, radius, radius);
        return insert(item, box);
    }

    /// Retrieve all objects that intersect the query range
    void query(AABB range, ref Array!T found)
    {
        if (!boundary.intersects(range))
            return;

        // Check objects in this node
        foreach (obj; objects[])
            found.insert(obj);

        // Recurse into children
        if (divided)
        {
            nw.query(range, found);
            ne.query(range, found);
            sw.query(range, found);
            se.query(range, found);
        }
    }

    /// Debugging helper
    void print(int depth = 0)
    {
        // repeatedIndents is a range!!!
		// To convert a range into a concrete array, you must explicitly call a function like .array on it.
		import std.range : repeat, take;
		auto indents = "    ".repeat().take(depth);  // Is indents a range?
		writeln(typeid(typeof(indents)));
		import std.array : array;
		auto arrayIndents = indents.array; // convert a range to concrete array, explicitly call a function like .array
		
		//writeln("arrayIndents = ", arrayIndents);
	
        import std.array : join;
		// Join without any separator
        string combinedIndents = arrayIndents.join();
		
        //writeln("combinedIndents = ", combinedIndents, "END");
		

	
        writeln(combinedIndents, "QuadTree at ", boundary.x, ",", boundary.y,
                " size ", boundary.halfW*2, "x", boundary.halfH*2,
                "  objects: ", objects.length);

        if (divided)
        {
            nw.print(depth + 1);
            ne.print(depth + 1);
            sw.print(depth + 1);
            se.print(depth + 1);
        }
    }

private:
    void subdivide()
    {
        float halfW = boundary.halfW / 2;
        float halfH = boundary.halfH / 2;
        float x = boundary.x;
        float y = boundary.y;

        nw = new QuadTree!T(AABB(x - halfW, y - halfH, halfW, halfH), capacity);
        ne = new QuadTree!T(AABB(x + halfW, y - halfH, halfW, halfH), capacity);
        sw = new QuadTree!T(AABB(x - halfW, y + halfH, halfW, halfH), capacity);
        se = new QuadTree!T(AABB(x + halfW, y + halfH, halfW, halfH), capacity);

        divided = true;

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
            insert(obj, AABB(0,0,0,0)); // ← placeholder — replace!
        }
    }
}

// ────────────────────────────────────────────────
//                  Example usage
// ────────────────────────────────────────────────

struct Particle
{
    float x, y;
    int id;

    string toString() const
    {
        return "P%d(%.1f,%.1f)".format(id, x, y);
    }
}

void quadrophenia()
{
    auto qt = new QuadTree!Particle(AABB(0, 0, 200, 200), 4);

    import std.random : uniform;

    foreach (i; 0 .. 30)
    {
        float x = uniform(-180f, 180f);
        float y = uniform(-180f, 180f);
        auto p = Particle(x, y, i);
        qt.insert(p, x, y, 5);  // small radius
    }

    writeln("Quadtree structure:");
    qt.print();

    // Query example
    writeln("\nObjects in region [-50..50, -50..50]:");
    Array!Particle results;
    qt.query(AABB(0, 0, 50, 50), results);

    foreach (p; results[])
        writeln("  ", p);
}
