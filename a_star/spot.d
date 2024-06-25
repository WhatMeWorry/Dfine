
module a_star.spot;
 
import std.stdio;
import std.process : executeShell;     // executeShell()
import std.algorithm.mutation : remove;
import std.math : ceil, floor;
import std.string;
import core.stdc.stdlib;  // for exit()

import honeycomb;
import app;
import textures.load_textures;
import distance;



void debugSpots( ref HexBoard hB )
{
    writeln("Spots = ");
    foreach(i; 0..(hB.maxRows))
    {
        foreach(j; 0..(hB.maxCols))
        {
            writeln(hB.spots[i][j].location, "  f g h = ", hB.spots[i][j].f, " ", hB.spots[i][j].g, " ", 
            hB.spots[i][j].h, "  terrain = ", hB.spots[i][j].terrainCost, "  previous = ", hB.spots[i][j].previous);
        }
    }
}


void writeAndPause(string s = "")
{
    writeln();
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

        writeln();
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

    Location[6] neighbors = [Location(-1,-1), Location(-1,-1), Location(-1,-1), Location(-1,-1), 
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
bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);
}
+/



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

const uint N  = 0;  // North
const uint NE = 1;  // North-East
const uint SE = 2;  // South-East
const uint S  = 3;  // South
const uint SW = 4;  // South-West
const uint NW = 5;  // North-West


void addNeighbors(ref HexBoard h)
{
    foreach(int r; 0..(h.maxRows))        // Note: maxRows and maxCols are defined as uint 
    {                                     // this caused problems with < 0 boundary checking
        foreach(int c; 0..(h.maxCols))    // causing -1 to be 4294967295
        {                                 // had to declare the local r and c as ints

            foreach(int i; 0..6)
            {
                h.spots[r][c].neighbors[i].r = -1;
                h.spots[r][c].neighbors[i].c = -1;
            }
            if (c.isEven)
            {
                // north
                if (r+1 <= h.maxRows-1)
                {
                    h.spots[r][c].neighbors[N].r = r+1;
                    h.spots[r][c].neighbors[N].c = c;
                }

                // north-east
                if (c+1 <= (h.maxCols-1))
                {
                    h.spots[r][c].neighbors[NE].r = r;
                    h.spots[r][c].neighbors[NE].c = c+1;
                }

                // south-east  
                if ((c+1 <= h.maxCols-1) && (r-1 >= 0))
                {
                    h.spots[r][c].neighbors[SE].r = r-1;
                    h.spots[r][c].neighbors[SE].c = c+1;
                }

                // south
                if (r-1 >= 0)
                {
                    h.spots[r][c].neighbors[S].r = r-1;
                    h.spots[r][c].neighbors[S].c = c;
                }

                // south-west
                if ((r-1 >= 0) && (c-1 >= 0))
                {
                    h.spots[r][c].neighbors[SW].r = r-1;
                    h.spots[r][c].neighbors[SW].c = c-1;
                }

                // north-west
                if (c-1 >= 0)
                {
                    h.spots[r][c].neighbors[NW].r = r;
                    h.spots[r][c].neighbors[NW].c = c-1;
                }
            }
            else   // On Odd Column
            {
                // north
                if (r+1 <= h.maxRows-1)
                {
                    h.spots[r][c].neighbors[N].r = r+1;
                    h.spots[r][c].neighbors[N].c = c;
                }

                // north-east
                if ((r+1 <= h.maxRows-1) && (c+1 <= h.maxCols-1))
                {
                    h.spots[r][c].neighbors[NE].r = r+1;
                    h.spots[r][c].neighbors[NE].c = c+1;
                }

                // south-east
                if (c+1 <= h.maxCols-1)
                {
                    h.spots[r][c].neighbors[SE].r = r;
                    h.spots[r][c].neighbors[SE].c = c+1;
                }

                // south
                if (r-1 >= 0)
                {
                    h.spots[r][c].neighbors[S].r = r-1;
                    h.spots[r][c].neighbors[S].c = c;
                }

                // south-west
                if (c-1 >= 0)
                {
                    h.spots[r][c].neighbors[SW].r = r;
                    h.spots[r][c].neighbors[SW].c = c-1;
                }

                // north-west
                if ((r+1 <= h.maxRows-1) && (c-1 >= 0))
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
    writeln();
    if (set.length > 0)
    {
        writeln("Set ", name, " has the following elements");
        foreach(element; set)
        {
            write("    (", element.r, ",", element.c, ")" );
        }
    }
    else
    {
        writeln("set ", name, " is empty");
    }
    writeln();
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


Location[] getNeighbors(Location loc, ref HexBoard hB)
{
    Location[] locs;

    Location[6] neighbors = hB.spots[loc.r][loc.c].neighbors;

    foreach(n; neighbors)
    {
        if (n != invalidLoc)  // strip out invalid neighbors (edge of hexboard)
            locs ~= n;
    } 
    return locs;
}


Location lowestFscore(ref ulong c, Location[] set, ref HexBoard hB)
{
    Location min;

    assert(set.length > 0);

    min = set[0];

    writeln();
    writeln("---------- lowest F score ----------");
    foreach(int i, s; set)
    {
        writeln(" (", s.r, ",", s.c, ") f = ", hB.spots[s.r][s.c].f);
        if (hB.spots[s.r][s.c].f < hB.spots[min.r][min.c].f)
        {
            min = s;
            c = i;
        }
    }
    writeln("lowest f score is (", min.r, ",", min.c, ") f = ", hB.spots[min.r][min.c].f);
    writeln();
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

void findShortestPath( ref HexBoard hB, Globals g )
{
    Location[] open;    // open set contains nodes that need to be evaluated
    Location[] closed;  // closed set stores all nodes that have finished being evaluated. Don't need to revisit

    Location[] path;

    Location current; // current is the node in open having the lowest f score 

    Location begin;
    Location end;

    begin.r = 0;
    begin.c = 0;
    end.r = hB.maxRows - 1;
    end.c = hB.maxCols - 1;  
    
    addNeighbors(hB);

    //===========================================================================
    //  Path finding starts here
    //===========================================================================

    Spot start;  // start is a full node, not just a location

    start = hB.spots[begin.r][begin.c];

    start.g = 0;  // the beginning of the path as no history (of walked spots)
    start.h = heuristic(start.location, end);  // heuristic
    start.f = start.g + start.h;

    writeln("start.g = ", start.g);
    writeln("start.h = ", start.h);
    writeln("start.f = ", start.f);

    hB.spots[begin.r][begin.c] = start;

    open ~= start.location;  // put the start node on the openList (leave its f at zero)

    while (open.isNotEmpty)     // while there are spots that still need evaluating
    {
        writeln();
        displaySet(open, "open");
        displaySet(closed, "closed");

        ulong c;
        current = lowestFscore(c, open, hB);  // find the node with the smallest f value.

        writeln("lowest F score in openset CURRENT = ", current);

        if (current == end)
        {
            Location here = hB.spots[end.r][end.c].location;
            while (here != invalidLoc)
            {
                path ~= here;
                here = hB.spots[here.r][here.c].previous;
            }

            foreach( p; path)
            {
                writeln("p = ", p);
                hB.setHexTexture(g, p, Ids.blackDot);
            }

            return;
        }

        open = open.remove(c);  // remove the currentNode from the open
        closed ~= current;      // add the currentNode to the closed

        Location[] neighbors = getNeighbors(current, hB);   // get neighbors of current and cull out the (-1,-1)

        // Time 32:15 in Coding Train Youtube video  all neighbors will be added to open set, 
        // but before we put them in the open set, we need to evaluate them
        // What if neighbor is in the closed set?

        foreach(neighbor; neighbors)   // for each neighbor of current
        {
            Spot neighborSpot = hB.spots[neighbor.r][neighbor.c];
            writeln();
            writeln("neighbor = ", neighbor);
            //writeAndPause();

            if (closed.excludes(neighbor))  // only proceed with this neighbor if it hasn't already been evaluated.
            {
                uint currentG = hB.spots[current.r][current.c].g;
                uint neighborG = hB.spots[neighbor.r][neighbor.c].terrainCost;
                uint neighborH = heuristic(neighbor, end);

                writeln("currentG, neighborG, neighborH = ", currentG, " ", neighborG, " ", neighborH);

                tempG = currentG + neighborG;
                writeln("tempG = currentG + neighborG = ", tempG);

                // is this a better path than before?

                //if (open.excludes(neighbor))  // if neighbor is not in open set, then add it
                if (neighbor.isNotInSet(open))     // if neighbor is not in open set, then add it
                {
                    writeln("neighbor was not in open, add to open");
                    open ~= neighbor;
                }
                else
                {
                    writeln("neighbor was in open");
                    if (tempG >= neighborSpot.g)
                    {
                        writeln("No, it is not a better path");
                        continue;
                    }
                } 

                hB.spots[neighbor.r][neighbor.c].g = tempG;

                hB.spots[neighbor.r][neighbor.c].h = neighborH;

                hB.spots[neighbor.r][neighbor.c].f = tempG + neighborH;

                hB.spots[neighbor.r][neighbor.c].previous = current;

                writeln("========================================== neighbor(", neighbor.r, ",", neighbor.c, ") was updated" );

                //debugSpots( hB );
            }
        }
        writeln("finished with neighbors for current");
    }
    writeln("open is empty");

}

/+
struct Node
{
    Location loc;
    int f;
    int g;
}


void displaySet(ref Node[] set)  // with or without ref, the f's were changed by the assignment
{
    foreach(i, n; set)
    {
        writeln("i = ", i );
        writeln("set[i] = ", set[i]);
        set[i].f = 777;
    }
}


void playWithSpots( HexBoard hB, Globals g )
{
Node[] open;    
Node[] closed;
//      open = open.remove(c);  // remove the currentNode from the open
//      closed ~= current;         // add the currentNode to the closed
Node n1 = { Location(1, 1), 11, 11 };
Node n2 = { Location(2, 2), 22, 22 };
Node n3 = { Location(3, 3), 33, 33 };
Node n4 = { Location(4, 4), 44, 44 };
open ~= n2;
open ~= n1;
open ~= n4;
open ~= n3;
writeln("open = ", open);
displaySet(open);
writeln("open = ", open);
open = open.remove(2);
writeln("open = ", open);
open = open.remove(1);
writeln("open = ", open);
}
+/