

module a_star.spot;
 

import std.stdio;

import std.algorithm.mutation : remove;

import std.math : ceil, floor;

import std.string;
import std.conv;
import core.stdc.stdlib;  // for exit()

import honeycomb;
import app;


struct Location   // screen cordinates 2d point
{
    int r;
    int c;
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
    Location[6] neighbors = [Location(-1,-1), Location(-1,-1), Location(-1,-1), Location(-1,-1), Location(-1,-1), Location(-1,-1)];  // ignoring edges of a hex board, each hex has 6 adjoining neighbors	
    uint f;
    uint g;
    uint h;
    Location previous = Location(-1,-1);

}

uint tempG;

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

          

int calculateDistanceBetweenHexes(HexPosition a, HexPosition b)
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

bool isNotEmpty(Spot[] set)
{
    if (set.length > 0)
        return true;
    else
	    return false;
}




void displaySet(ref Spot[] set, string comment = "")
{
    writeln("");
    writeln("set ", comment, " has the following elements");
    foreach(elem; set)
    {
        write(elem.location);
        write("    ");
    }
    writeln("");
    writeln("end set ", comment);

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

bool excludes(Spot[] set, Location element)
{
    foreach(e; set)
    {
        if (e.location == element)
            return false;
    }
    return true;
}





Location[] getNeighbors(Spot spot)
{
    Location[] locs;

    foreach(loc; spot.neighbors)
    {
        if (loc != invalidLoc)
            locs ~= loc;
    } 
    return locs;
}


Spot lowestFscore(ref ulong c, Spot[] set)
{
    Spot min;

    assert(set.length > 0);
    min = set[0];
    foreach(int i, s; set)
    {
        writeln("set[i].f = ",set[i].f, "   and min.f = ", min.f); 
        if (set[i].f < min.f)
        {
            min = set[i];
            c = i;
        }
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

Spot[] openSet;    // needs to be evaluated
Spot[] closedSet;  // stores all nodes that have finished being evaluated. Don't need to revisit

Spot current; // current is the node in openSet having the lowest f score
Spot start;   // the beginning node (spot, hex) of the path   

Location[] path;  // hold shortest path

Location invalidLoc = { -1, -1 };

void enteringLandOfPathFinding( ref HexBoard hB, Globals g )
{
    writeln("inside enteringLandOfPathFinding");

    Location begin;
    Location end;

    begin.r = 0;
    begin.c = 0;
    end.r = hB.maxRows - 1;
    end.c = hB.maxCols - 1;  

    hB.spots = new Spot[][](hB.maxRows, hB.maxCols);

    //writeln("hB.spots = ", hB.spots);

    foreach(r; 0..(hB.maxRows))
    {
        foreach(c; 0..(hB.maxCols))
        {
            //writeln("hB.hexes[r][c].texture.id = ", hB.hexes[r][c].texture.id);
            hB.spots[r][c].location.r = r;
            hB.spots[r][c].location.c = c;
        }
    }
    
    addNeighbors(hB);

    //===========================================================================
    //  Path finding starts here
    //===========================================================================



    //writeln("hB.spots = ", hB.spots);


    start = hB.spots[begin.r][begin.c];

    start.g = 0;  // the beginning of the path as no history (of walked spots)
    start.h = calculateDistanceBetweenHexes( cast(HexPosition) start.location, cast(HexPosition) end);  // heuristic
    start.f = start.g + start.h;
	
    writeln("start.f = ", start.f);

    openSet ~= start;  // put the start node on the openList (leave its f at zero)

    displaySet(openSet, "openSet");

    while (openSet.isNotEmpty)     // while there are spots that still need evaluating
    {
        writeln("---------------------------MAIN LOOP-------------------------------------");

        ulong c;                             
        current = lowestFscore(c, openSet);  // find the node with the smallest f value.
                                             // set the current spot to the spot with the least f value

        writeln("current.location = ", current.location);

        if (current.location == end)
        {
			writeln("hB.spots = ", hB.spots);
             buildShortestPath(current, hB);
             writeln("DONE!!!");
             return;
        }
		
        // Move best option from openSet to closedSet
        openSet = openSet.remove(c);  // openSet.remove(current)  remove the currentNode from the openList
        closedSet ~= current;         // closedSet.push(current)  add the currentNode to the closedList

        //displaySet(openSet, "openSet");
        //displaySet(closedSet, "closedSet");

        Location[] neighbors = getNeighbors(current);   // get neighbors of current and cull out the (-1,-1)

        writeln("neighbors = ", neighbors);

        // Time 32:15 in Coding Train Youtube video
        // all neighbors will be added to open set, but before we put them
        // in the open set, we need to evaluate them
        // What if neighbor is in the closed set?

        foreach(neighbor; neighbors)   // for each neighbor of current
        {
            Spot neighborSpot = hB.spots[neighbor.r][neighbor.c];
            //writeln("neighbor = ", neighbor);

            if (closedSet.excludes(neighbor))  // ignore the neighbor which is alread evaluated
            {
                writeln("1111111111111111111111 neighbor already evaluated");
                continue;                      // continue to beginning of for loop
            }

             uint tempG = current.g + 1; //  + dist_between(current, neighbor) // replace with terrain cost of neighbor 
			 
             writeln("tempG = ", tempG);

             if (openSet.excludes(neighbor))   // discover a new node?
             {
                 writeln("2222222222222222222 discoverd a new node");
                 openSet ~= neighborSpot;
             }
             else 
             {
                 if (tempG >= neighborSpot.g)
                 {
                      writeln("333333333333333333 this is now a better path");
                      continue;      // this is not a better pat
                 }
             }
 
            // Create the f, g, and h values
            writeln("current.location is added to path", current.location);
            neighborSpot.previous = current.location;
			
            neighborSpot.g = tempG;
            neighborSpot.f = neighborSpot.g + calculateDistanceBetweenHexes( cast(HexPosition) neighborSpot.location, cast(HexPosition) end);

            if (openSet.excludes(neighbor))  
            {
                writeln("add neighbor to openSet");
                openSet ~= neighborSpot;
            }

        }
    }
	

	writeln("openSet is empty");


}