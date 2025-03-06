
module a_star.spot;
 
import std.stdio;
import std.process : executeShell;     // executeShell()
import std.algorithm.mutation : remove;
import std.math : ceil, floor;
import std.string;
import core.stdc.stdlib;  // for exit()

import hexboard;
import hexmath;
import app;
import textures.texture;
import distance;
import redblacktree;
import std.container : RedBlackTree;

import windows.simple_directmedia_layer;


void debugSpots(HB)(ref HB h)
{
    //writeln("Spots = ");
    foreach(i; 0..(h.rows))
    {
        foreach(j; 0..(h.columns))
        {
        /+
            writeln(h.spots[i][j].location, "  f g h = ", h.spots[i][j].f, " ", h.spots[i][j].g, " ", 
                    h.spots[i][j].h, "  terrain = ", h.spots[i][j].terrainCost, "  previous = ", h.spots[i][j].previous);
        +/
        }
    }
}


//void writeAndPause(string s = "")
void writeAndPause(string s)
{
    //writeln();
    writeln(s);
    version(Windows)
    {  
        // pause command prints out
        // "Press any key to continue..."

        // auto ret = executeShell("pause");
        // if (ret.status == 0)
        //     writeln(ret.output);

        // The functions capture what the child process prints to both its standard output 
        // and standard error streams, and return this together with its exit code.
        // The problem is we don't have the pause return output until after the user
        // hits a key.

        //writeln();
        writeln("Press any key to continue...");       
        executeShell("pause");  // don't bother with standard output the child returns

    }
    else // Mac OS or Linux
    {
        writeln("Press any key to continue...");
        executeShell(`read -n1 -r`);    // -p option did not work
    }
    writeln();
}


struct Spot
{
    //@disable this();   // disables default constructor

    Location location = Location(-1,-1);   // each spot needs to know where it is on the hexboard

    Location[6] neighbors = [Location(-1,-1), Location(-1,-1), 
                             Location(-1,-1), Location(-1,-1), 
                             Location(-1,-1), Location(-1,-1)];  // ignoring edges, each hex has 6 adjoining neighbors
    uint f;
    uint g;
    uint h;
    Location previous = Location(-1,-1);
    uint terrainCost;
}

uint tempG;
ulong c;




/+
enum Dir 
{ 
    N,   // North
    NE,  // North-East
    SE,  // South-East
    S,   // South
    SW,  // South-West
    NW   // North-West
} 
+/

enum Direction { North = 1, NorthEast, SouthEast, South, SouthWest, NorthWest }



const uint N  = 0;  // North
const uint NE = 1;  // North-East
const uint SE = 2;  // South-East
const uint S  = 3;  // South
const uint SW = 4;  // South-West
const uint NW = 5;  // North-West


void addNeighbors(HB)(ref HB h)
{
    foreach(r; 0..(h.rows))          // Note: rows and columns are defined as uint 
    {                                // this caused problems with < 0 boundary checking
        foreach(c; 0..(h.columns))   // causing -1 to be 4294967295
        {                            // had to declare the local r and c as ints
            foreach(i; 0..6)
            {
                h.spots[r][c].neighbors[i].r = -1;
                h.spots[r][c].neighbors[i].c = -1;
            }
            
            if (c.isEven)
            {
                if (r+1 <= h.lastRow)                     // north
                {
                    h.spots[r][c].neighbors[N].r = r+1;
                    h.spots[r][c].neighbors[N].c = c;
                }
                if (c+1 <= h.lastColumn)                  // north-east
                {
                    h.spots[r][c].neighbors[NE].r = r;
                    h.spots[r][c].neighbors[NE].c = c+1;
                }
                if ((c+1 <= h.lastColumn) && (r-1 >= 0))  // south-east
                {
                    h.spots[r][c].neighbors[SE].r = r-1;
                    h.spots[r][c].neighbors[SE].c = c+1;
                }
                if (r-1 >= 0)                             // south
                {
                    h.spots[r][c].neighbors[S].r = r-1;
                    h.spots[r][c].neighbors[S].c = c;
                }
                if ((r-1 >= 0) && (c-1 >= 0))             // south-west
                {
                    h.spots[r][c].neighbors[SW].r = r-1;
                    h.spots[r][c].neighbors[SW].c = c-1;
                }
                if (c-1 >= 0)                             // north-west
                {
                    h.spots[r][c].neighbors[NW].r = r;
                    h.spots[r][c].neighbors[NW].c = c-1;
                }
            }
            else   // On Odd Column
            {
                
                if (r+1 <= h.lastRow)                     // north
                {
                    h.spots[r][c].neighbors[N].r = r+1;
                    h.spots[r][c].neighbors[N].c = c;
                }
                if ((r+1 <= h.lastRow) && (c+1 <= h.lastColumn)) // north-east
                {
                    h.spots[r][c].neighbors[NE].r = r+1;
                    h.spots[r][c].neighbors[NE].c = c+1;
                }
                if (c+1 <= h.lastColumn)                  // south-east
                {
                    h.spots[r][c].neighbors[SE].r = r;
                    h.spots[r][c].neighbors[SE].c = c+1;
                }
                if (r-1 >= 0)                             // south
                {
                    h.spots[r][c].neighbors[S].r = r-1;
                    h.spots[r][c].neighbors[S].c = c;
                }
                if (c-1 >= 0)                             // south-west
                {
                    h.spots[r][c].neighbors[SW].r = r;
                    h.spots[r][c].neighbors[SW].c = c-1;
                }
                if ((r+1 <= h.lastRow) && (c-1 >= 0))     // north-west
                {
                    h.spots[r][c].neighbors[NW].r = r+1;
                    h.spots[r][c].neighbors[NW].c = c-1;
                }
            }
            //writeln("(r,c) = ", "(", r, ",", c, ")"); 
            //writeln("h.spots[r][c].neighbors = ", h.spots[r][c].neighbors);
        }
    }
}






void displaySet(Location[] set, string name = "")
{
    //writeln();
    if (set.length > 0)
    {
        //writeln("Set ", name, " has the following elements");
        foreach(element; set)
        {
            //write("    (", element.r, ",", element.c, ")" );
        }
    }
    else
    {
        //writeln("set ", name, " is empty");
    }
    //writeln();
}



// UFCS usage:  if (set.includes(element))
//                  writeln("element is in set"); 

bool includes(Spot[] set, Location element)
{
    foreach(e; set)
    {
        if (e.location == element)
            return true;
    }
    return false;
}


 
// UFCS usage:  if (element.isInSet(open))
//                  writeln("element is in set open");

bool isInSet(Location element, Location[] set)
{
    foreach(item; set)
    {
        if (item == element)
            return true;
    }
    return false;
}



// UFCS usage:  if (set.excludes(element))
//                   writeln("element is not in set");

bool excludes(Location[] set, Location item)
{
    foreach(element; set)
    {
        if (element == item)
            return false;
    }
    return true;
}

/+
minPriorityQueue

bool excludes(Location[] set, Location item)
{
    foreach(element; set)
    {
        if (element == item)
            return false;
    }
    return true;
}
+/



// UFCS usage:  if (element.isNotInSet(open))
//                  writeln("element is not in set open");

bool isNotInSet(Location element, Location[] set)
{
    foreach(item; set) 
    {
        if (item == element)
            return false;
    }
    return true;
}

// foo(variable, arguments)  == UFCS ==>  variable.foo(arguments)
// isNotEmpty(set)           == UFCS ==>  set.isNotEmpty() or set.isNotEmpty

bool isNotEmpty(Location[] set)
{
    if (set.length > 0)
        return true;
    else
        return false;
}
/+  REPLACE ABOVE????

bool isNotEmpty(Location[] set)
{
    return (set.length > 0);
}
+/

alias minPriorityQueue = RedBlackTree!(Node, "a.f < b.f", true);

bool isNotEmpty(minPriorityQueue redBlack)
{
    return !(redBlack.empty);
}


bool isNotEmpty(uint[Location] associativeArray)
{
    return (associativeArray.length > 0);
}


Location[] getNeighbors(HB)(Location loc, ref HB h)
{
    Location[] locs;

    Location[6] neighbors = h.spots[loc.r][loc.c].neighbors;

    foreach(n; neighbors)
    {
        if (n != invalidLoc)  // strip out invalid neighbors (edge of hexboard)
            locs ~= n;
    } 
    return locs;
}


Node[] getAdjNeighbors(HB)(Location home, ref HB h)
{
    Node[] nodes;
    Node node;

    writeln("h.spots[home.r][home.c].neighbors = ", h.spots[home.r][home.c].neighbors);

    //Node[6] neighbors = h.spots[home.r][home.c].neighbors;
    
    foreach(n; h.spots[home.r][home.c].neighbors)
    {
        if (n != invalidLoc)  // strip out invalid neighbors (edge of hexboard)
        {
            node.location = n;
            node.f = 0;
            nodes ~= node;
        }
    }    
    
    return nodes;
}




Location lowestFscore(HB)(ref ulong c, Location[] set, ref HB h)
{
    Location min;

    assert(set.length > 0);

    min = set[0];

    //writeln();
    writeln("---------- lowest F score ----------");
    writeln("set.length = ", set.length);
    foreach(int i, s; set)
    {
        //writeln(" (", s.r, ",", s.c, ")");
        if (h.spots[s.r][s.c].f < h.spots[min.r][min.c].f)
        {
            min = s;
            c = i;
        }
    }
    //writeln("lowest f score is (", min.r, ",", min.c, ") f = ", h.spots[min.r][min.c].f);
    //writeln();
    return min;
}


// f(n) = g(n) + h(n)
//
// f(n) is the 
// g(n) is the known length from the beginning. Since we have been keeping track, this is a know value
// h(n) is an "educated guess" as to the length to the end.  We could used geometic distance or taxi distance.

// The A* algorithm finishes in one of two conditions:
// 1) The algorithm arrives at the end. We now know successfully know the shortest path.
// 2) No nodes in the open remain to be evaluated. This means that there is no solution.

// ================== BAD BUG!  MOVE THESE VARIABLES INSIDE findShortestPath ===================
// Otherwise the dynamic arrays will hold values of previous runs.
//Location[] open;    // open set contains nodes that need to be evaluated
//Location[] closed;  // closed set stores all nodes that have finished being evaluated. Don't need to revisit
//Location[] path;  // hold shortest path

Location invalidLoc = { -1, -1 };

/+
struct Node
{
    this(Location location, uint f) 
    {
        this.location = location;
        this.f = f;
    }
    Location location;  
    uint f;
}
+/






void findShortestPath(HB)(ref HB h, Globals g, Location begin, Location end)
{
    Location[] open;    // open set contains nodes that need to be evaluated
    Location[] closed;  // closed set stores all nodes that have finished being evaluated. Don't need to revisit

    open.reserve(8192);
    closed.reserve(8192);

    Location[] path;

    Location current; // current is the node in open having the lowest f score 

    //===========================================================================
    //  Path finding starts here
    //===========================================================================

    Spot start;  // start is a full node, not just a location

    start = h.spots[begin.r][begin.c];

    start.g = 0;  // the beginning of the path as no history (of walked spots)
    start.h = heuristic(start.location, end);  // heuristic
    start.f = start.g + start.h;

    //writeln("start.g = ", start.g);
    //writeln("start.h = ", start.h);
    //writeln("start.f = ", start.f);

    h.spots[begin.r][begin.c] = start;

    open ~= start.location;  // put the start node on the openList (leave its f at zero)

    while (open.isNotEmpty)     // while there are spots that still need evaluating
    {
        //writeln();
        //displaySet(open, "open");
        //displaySet(closed, "closed");

        ulong c;
        writeln("open.length ", open.length);
        current = lowestFscore(c, open, h);  // find the node with the smallest f value.
        writeln("open.length ", open.length);

        //writeln("lowest F score in openset CURRENT = ", current);

        if (current == end)
        {
            Location here = h.spots[end.r][end.c].location;
            while (here != invalidLoc)
            {
                path ~= here;
                here = h.spots[here.r][here.c].previous;
            }

            foreach( p; path)
            {
                //writeln("p = ", p);
                h.setHexTexture(g, p, Ids.blackDot);
            }

            return;
        }

        open = open.remove(c);  // remove the currentNode from the open
        closed ~= current;      // add the currentNode to the closed

        Location[] neighbors = getNeighbors(current, h);   // get neighbors of current and cull out the (-1,-1)

        // Time 32:15 in Coding Train Youtube video  all neighbors will be added to open set, 
        // but before we put them in the open set, we need to evaluate them
        // What if neighbor is in the closed set?

        foreach(neighbor; neighbors)   // for each neighbor of current
        {
            Spot neighborSpot = h.spots[neighbor.r][neighbor.c];
            //writeln();
            //writeln("neighbor = ", neighbor);
            //writeAndPause();

            if (closed.excludes(neighbor))  // only proceed with unevaluated neighbors
            {
                uint currentG = h.spots[current.r][current.c].g;
                uint neighborG = h.spots[neighbor.r][neighbor.c].terrainCost;
                uint neighborH = heuristic(neighbor, end);

                //writeln("currentG, neighborG, neighborH = ", currentG, " ", neighborG, " ", neighborH);

                tempG = currentG + neighborG;
                //writeln("tempG = currentG + neighborG = ", tempG);

                // is this a better path than before?

                //if (open.excludes(neighbor))  // if neighbor is not in open set, then add it
                if (neighbor.isNotInSet(open))     // if neighbor is not in open set, then add it
                {
                    //writeln("neighbor was not in open, add to open");
                    open ~= neighbor;
                }
                else
                {
                    //writeln("neighbor was in open");
                    if (tempG >= neighborSpot.g)
                    {
                        //writeln("No, it is not a better path");
                        continue;
                    }
                } 

                h.spots[neighbor.r][neighbor.c].g = tempG;

                h.spots[neighbor.r][neighbor.c].h = neighborH;

                h.spots[neighbor.r][neighbor.c].f = tempG + neighborH;

                h.spots[neighbor.r][neighbor.c].previous = current;

                //debugSpots( h );
            }
        }
        //writeln("finished with neighbors for current");
    }
    //writeln("open is empty");
}




// The alias seemed to cause a run time error, went with new

// alias minPriorityQueue = RedBlackTree!(Node, "a.f < b.f", true);

    //minPriorityQueue open;
    //minPriorityQueue closed;
    

void findShortestPathRedBlack(HB)(ref HB h, Globals g, Location begin, Location end)
{
    // open set contains nodes that need to be evaluated
    // closed set contains all nodes that have finished being evaluated. Don't need to revisit
	
    // value_type[key_type] associative_array_name;

    // int[string] dayNumbers;	

    uint[Location] openAA;  // open set associative array
    uint[Location] closedAA;  // closed set associative array

    auto open = new RedBlackTree!(Node, "a.f < b.f", true);    // true: allowDuplicates
    auto closed = new RedBlackTree!(Node, "a.f < b.f", true);

    Location[] path;

    Node current; // current is the node in open having the lowest f score 

    Spot start = h.spots[begin.r][begin.c];  // start is a full node, not just a location

    start.g = 0;  // the beginning of the path as no history (of walked spots)
    start.h = heuristic(start.location, end);  // heuristic
    start.f = start.g + start.h;

    h.spots[begin.r][begin.c] = start;
 
    Node s = Node(start.location, start.f);

    open.insert(s);  // put the start node on the open set (leave its f at zero)
    openAA[s.location] = s.f;

/+
    if (s.location in openAA)
    {
        writeln("s.location is in openAA");
    }

    openAA.remove(s.location);

    if (s.location !in openAA)
    {
        writeln("s.location is not in openAA");
    }
+/
    writeln("open = ", open);

    //while (open.isNotEmpty)     // while there are spots that still need evaluating
    while (openAA.isNotEmpty)
    {
        current = open.front;  // GETS the the node with the SMALLEST f value to current
        open.removeFront;      // and remove it from the open min priority queue
        openAA.remove(current.location);
        
        writeln("current = ", current);

        if (current.location == end)
        {
            Location here = h.spots[end.r][end.c].location;
            while (here != invalidLoc)
            {
                path ~= here;
                here = h.spots[here.r][here.c].previous;
            }

            foreach( p; path)
            {
                //writeln("p = ", p);
                h.setHexTexture(g, p, Ids.blackDot);
            }

            return;
        }

        writeln("insert current");

        closed.insert(current);
        closedAA[current.location] = current.f;

        Node[] neighbors = getAdjNeighbors(current.location, h);   // get neighbors of current and cull out the (-1,-1)

        writeln("neighbors = ", neighbors);

        // Time 32:15 in Coding Train Youtube video  all neighbors will be added to open set, 
        // but before we put them in the open set, we need to evaluate them
        // What if neighbor is in the closed set?

        foreach(neighbor; neighbors)   // for each neighbor of current
        {
            Spot neighborSpot = h.spots[neighbor.location.r][neighbor.location.c];
            
            writeln("lookin at neighbor ", neighbor);

            if (neighbor.location !in closedAA)
            {
                writeln("neighbor is not in closed set");
            
                uint currentG = h.spots[current.location.r][current.location.c].g;
                uint neighborG = h.spots[neighbor.location.r][neighbor.location.c].terrainCost;
                uint neighborH = heuristic(neighbor.location, end);

                tempG = currentG + neighborG;

                // is this a better path than before?

                //if (neighbor.isNotInSet(open))     // if neighbor is not in open set, then add it
                if (neighbor.location !in openAA)
                {
                    //open ~= neighbor;
                    openAA[neighbor.location] = neighbor.f;  // Add to Associative Array
                    open.insert(neighbor);                   // Add to Red Black Tree
                    
                }
                else
                {
                    writeln("neighbor was in open");
                    if (tempG >= neighborSpot.g)
                    {
                        //writeln("No, it is not a better path");
                        continue;
                    }
                } 

                h.spots[neighbor.location.r][neighbor.location.c].g = tempG;
                
                h.spots[neighbor.location.r][neighbor.location.c].h = neighborH;

                h.spots[neighbor.location.r][neighbor.location.c].f = tempG + neighborH;

                h.spots[neighbor.location.r][neighbor.location.c].previous = current.location;

                //debugSpots( h );
            }
        }
        writeln("finished with neighbors for current");
    }
    //writeln("open is empty");

}

