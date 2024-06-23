

module a_star.spot;
 

import std.stdio;
import std.process : executeShell;     // executeShell()

import std.algorithm.mutation : remove;

import std.math : ceil, floor;

import std.string;
import std.conv;
import core.stdc.stdlib;  // for exit()

import honeycomb;
import app;
import textures.load_textures;


struct Location   // screen cordinates 2d point
{
    int r;
    int c;
}



void debugSpots( ref HexBoard hB )
{
    writeln("Spots = ");
    foreach(i; 0..(hB.maxRows))
    {
        foreach(j; 0..(hB.maxCols))
        {
            writeln(hB.spots[i][j].location, "  f g h = ", hB.spots[i][j].f, " ", hB.spots[i][j].g, " ", 
            hB.spots[i][j].h, "  terrain = ", hB.spots[i][j].terrainCost);
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
/+
    this() 
    {
        // These three parametes suffice to define the hexboard as well as each individual hex
        location.r = -1;
        location.c = -1;
        previous.r = -1;
        previous.c = -1;
    }
    +/

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
int distance;

struct Slope
{
    int rise;
    int run;
}



bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);
}

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



uint whatQuadrant(HexPosition a, HexPosition b)
{
    int dR = a.row - b.row;
    int dC = a.column - b.column;

    if (dR < 0)
        if (dC < 0)
            { /+writeln("Quad I");+/    /* (-,-) */  return 1; }
        else
            { /+writeln("Quad II");+/   /* (-,+) */  return 2; }
    else
        if (dC < 0)
            { /+writeln("Quad IV");+/   /* (+,-) */  return 3; }
        else
            { /+writeln("Quad III");+/  /* (+,+) */  return 4; }
}

          

// int calculateDistanceBetweenHexes(HexPosition a, HexPosition b)
int heuristic(HexPosition a, HexPosition b)
{
    if (a == b)
    {
        //writeln("End is same as Start");
        return 0;
    }
    if (a.row == b.row)
    {
        //writeln("On same row");
        return (abs(a.column - b.column));
    }
    if (a.column == b.column)
    {
        //writeln("On same column");
        return (abs(a.row - b.row));
    }

    uint quad = whatQuadrant(a, b);

    if (a.column.isEven)
    {
        if ((quad == 1) || (quad == 2))
        {
            Slope delta; 
            int length;

            delta.run = abs(a.column - b.column);
            delta.rise = abs(a.row - b.row);

            int hexesToCutOff = delta.run / 2;  // did not need a float

            //writeln("hexesToCutOff = ", hexesToCutOff);

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);
            return length;
        }
        if ((quad == 3) || (quad == 4))
        {
            Slope delta; 
            int length;

            delta.run = abs(a.column - b.column);
            delta.rise = abs(a.row - b.row);

            int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float

            //writeln("hexesToCutOff = ", hexesToCutOff);

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);
            return length;
        }
    }

    if (a.column.isOdd)
    {
        if ((quad == 1) || (quad == 2))
        {
            Slope delta; 
            int length;

            delta.run = abs(a.column - b.column);
            delta.rise = abs(a.row - b.row);

            //int hexesToCutOff = delta.run / 2;  // did not need a float
            int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float

            //writeln("hexesToCutOff = ", hexesToCutOff);

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);
            return length;
        }
        if ((quad == 3) || (quad == 4))
        {
            Slope delta; 
            int length;

            delta.run = abs(a.column - b.column);
            delta.rise = abs(a.row - b.row);

            //int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float
            int hexesToCutOff = delta.run / 2;  // did not need a float
            //writeln("hexesToCutOff = ", hexesToCutOff);

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);
            return length;
        }
    }
    return 0;
}

// foo(variable, arguments)  ===== UFCS =====>  variable.foo(arguments)
// isNotEmpty(set)           ===== UFCS =====>  set.isNotEmpty() or set.isNotEmpty

bool isNotEmpty(Location[] set)
{
    if (set.length > 0)
        return true;
    else
        return false;
}




void displaySet(Location[] set, string comment = "")
{
    writeln();
    if (set.length > 0)
    {
        writeln("set ", comment, " has the following elements");
        foreach(element; set)
        {
            write("    (", element.r, ",", element.c, ")" );
        }
        //writeln();
    }
    else
    {
        writeln("set ", comment, " is empty");
    }
   writeln();
}


// foo(variable, arguments)

// if there is no member function named foo that can be called on variable with the provided arguments, 
// then the compiler also tries to compile the following expression:

/// variable.foo(arguments)   elem.isIn(openset)

bool isIn(Location elem, Spot[] set)
{
    foreach(e; set)
    {
        if (e.location == elem)
            return true;
    }
    return false;
}

bool isNotIn(Location elem, Spot[] set)
{
    foreach(e; set)
    {
        if (e.location == elem)
            return false;
    }
    return true;
}

// foo(variable, arguments)  ===== UFCS =====>  variable.foo(arguments)
// includes(set, element)    ===== UFCS =====>  set.includes(element)

// UFCS usage:  if (set.includes(element))
//                  // element is in set 

bool includes(Spot[] set, Location element)
{
    foreach(e; set)
    {
        if (e.location == element)
            return true;
    }
    return false;
}

// UFCS usage:  if (set.excludes(element))
//                  // element is not in set 

bool excludes(Location[] set, Location item)
{
    foreach(element; set)
    {
        if (element == item)    
            return false;      // item is in the set
    }
    return true;
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
    //min = set[0];
	writeln(".....................................................");
	writeln("             lowestFscore");
	writeln(".....................................................");
    foreach(int i, s; set)
    {
	    writeln("(", s.r, ",", s.c, ") f = ", hB.spots[s.r][s.c].f);
        //writeln("set[i] = ", set[i]);
        //writeln("s = ", s);
        //writeln("i = ", i);
        //writeln("spots[s.location.r][s.location.c].location = ", hB.spots[s.r][s.c].location);
        /+
        writeln("set[i].f = ",set[i].f, "   and min.f = ", min.f); 
        if (set[i].f < min.f)
        {
            min = set[i];
            c = i;
        }
        +/
    }
    
    return min;
}


// h.spots[r][c].neighbors[i].r = -1;

void buildShortestPath(Spot current, ref HexBoard h)
{
    Spot temp = current;
    path ~= temp.location;
    while(temp.previous != invalidLoc)
    {
        path ~= temp.previous;
        temp = h.spots[temp.previous.r][temp.previous.c];
    }
}

// f(n) = g(n) + h(n)
//
// f(n) is the 
// g(n) is the known length from the beginning. Since we have been keeping track, this is a know value
// h(n) is an "educated guess" as to the length to the end.  We could used geometic distance or taxi distance.

// The A* algorithm finishes in one of two conditions:
// 1) The algorithm arrives at the end. We now know successfully know the shortest path.
// 2) No nodes in the openSet remain to be evaluated. This means that there is no solution.


// Spot[][] spots;    // put in HexBoard object. So a hexBoard "has-a" spots object

Location[] openSet;    // needs to be evaluated
Location[] closedSet;  // stores all nodes that have finished being evaluated. Don't need to revisit

Location current; // current is the node in openSet having the lowest f score
Spot start;   // the beginning node (spot, hex) of the path   

Location[] path;  // hold shortest path

Location invalidLoc = { -1, -1 };

void enteringLandOfPathFinding( ref HexBoard hB, Globals g )
{
    Location begin;
    Location end;

    begin.r = 0;
    begin.c = 0;
    end.r = hB.maxRows - 1;
    end.c = hB.maxCols - 1;  
    //end.r = hB.selectedHex.row;
    //end.c = hB.selectedHex.col;
    
    addNeighbors(hB);

    //===========================================================================
    //  Path finding starts here
    //===========================================================================

    start = hB.spots[begin.r][begin.c];

    start.g = 0;  // the beginning of the path as no history (of walked spots)
    start.h = heuristic( cast(HexPosition) start.location, cast(HexPosition) end);  // heuristic
    start.f = start.g + start.h;

    writeln("start.g = ", start.g);
    writeln("start.h = ", start.h);
    writeln("start.f = ", start.f);
	
	hB.spots[begin.r][begin.c] = start;

    openSet ~= start.location;  // put the start node on the openList (leave its f at zero)


    displaySet(openSet, "openSet BEFORE WHILE");
	
    while (openSet.isNotEmpty)     // while there are spots that still need evaluating
    {
        writeln();
        displaySet(openSet, "openSet");
		
        writeAndPause("while openSet is not empty");

        ulong c;                             
        current = lowestFscore(c, openSet, hB);  // find the node with the smallest f value.
                                             // set the current spot to the spot with the least f value

        writeln("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        writeln("lowest F score in openset CURRENT = ", current);
		//writeln("hB.spots = ", hB.spots);
		
        writeln("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        //writeAndPause();

        if (current == end)
        {
            //writeln("hB.spots = ", hB.spots);
            //buildShortestPath(current, hB);
            writeln("DONE!!!");

            Location[] path;
            Location here = hB.spots[end.r][end.c].location;
            while (here != invalidLoc)
            {
                path ~= here;
                here = hB.spots[here.r][here.c].previous;
            }

            foreach( p; path)
            {
                writeln("p = ", p);
                hB.setHexTexture(g, cast(HexPosition) p, Ids.solidBlack);
            }

            return;
        }

        //displaySet(openSet, "openSet");
        //displaySet(closedSet, "closedSet");
		
        writeln("move currentNode from openList to closedSet");

        openSet = openSet.remove(c);  // remove the currentNode from the openSet
        closedSet ~= current;         // add the currentNode to the closedSet

        //displaySet(openSet, "openSet");
        //displaySet(closedSet, "closedSet");

        Location[] neighbors = getNeighbors(current, hB);   // get neighbors of current and cull out the (-1,-1)

        // Time 32:15 in Coding Train Youtube video
        // all neighbors will be added to open set, but before we put them
        // in the open set, we need to evaluate them
        // What if neighbor is in the closed set?

        foreach(neighbor; neighbors)   // for each neighbor of current
        {
            Spot neighborSpot = hB.spots[neighbor.r][neighbor.c];
            writeln();
            writeln("------------------------------------------");
            writeln("neighbor = ", neighbor);
            writeln("------------------------------------------");
            //writeAndPause();

            if (closedSet.excludes(neighbor))  // only proceed with this neighbor if it hasn't already been evaluated.
            {
                //distance = heuristic( cast(HexPosition) neighborSpot.location, cast(HexPosition) current.location);

                distance = neighborSpot.terrainCost;
				writeln("distance = ", distance);

                //tempG = current.g + distance;

                writeln("tempG = ", tempG, "    distance = ", distance);

                // is this a better path than before?

                if (openSet.excludes(neighbor))  // if neighbor is not in openSet, then add it
                {
                    writeln("place neighbor in openSet");
                    openSet ~= neighbor;
                }
                else
                {
                    //writeln("neighbor WAS IN OPENSET");
                    if (tempG >= neighborSpot.g)
                    {
                        // No, it's not a better path
                        writeln("No, it is not a better path");
                        continue;
                    }
                } 
            
                neighborSpot.g = tempG;
                neighborSpot.h = heuristic( cast(HexPosition) neighborSpot.location, cast(HexPosition) end);
                neighborSpot.f = neighborSpot.g + neighborSpot.h;
                //neighborSpot.previous = current.location;

                hB.spots[neighbor.r][neighbor.c] = neighborSpot;

                //hB.spots[neighborSpot.location.r][neighborSpot.location.c].previous = current.location;

                writeln("================== ANOTHER NEIGHBOR PROCESSED ==================================");
                writeln("neighborSpot.location f g h = ", neighborSpot.location, " ", neighborSpot.f, " ", neighborSpot.g, " ", neighborSpot.h);
                writeln("neighborSpot.previous = ", neighborSpot.previous);
				
				debugSpots( hB );
            }
        }
        writeln("finished with neighbors for current");
    }
    writeln("openSet is empty");

}

/+
struct Node
{
    Location loc;
    int f;
    int g;
}
+/

/+
void displaySet(ref Node[] set)  // with or without ref, the f's were changed by the assignment
{
    foreach(i, n; set)
    {
        writeln("i = ", i );
	    writeln("set[i] = ", set[i]);
		set[i].f = 777;
    }
}
+/

/+
void playWithSpots( HexBoard hB, Globals g )
{
Node[] openSet;    
Node[] closedSet;
//      openSet = openSet.remove(c);  // remove the currentNode from the openSet
//      closedSet ~= current;         // add the currentNode to the closedSet
Node n1 = { Location(1, 1), 11, 11 };
Node n2 = { Location(2, 2), 22, 22 };
Node n3 = { Location(3, 3), 33, 33 };
Node n4 = { Location(4, 4), 44, 44 };
openSet ~= n2;
openSet ~= n1;
openSet ~= n4;
openSet ~= n3;
writeln("openSet = ", openSet);
displaySet(openSet);
writeln("openSet = ", openSet);
openSet = openSet.remove(2);
writeln("openSet = ", openSet);
openSet = openSet.remove(1);
writeln("openSet = ", openSet);
}
+/