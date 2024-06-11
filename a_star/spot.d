

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
    Location location; 
    Location[6] neighbors;  // ignoring edges of a hex board, each hex has 6 adjoining neighbors	
    uint f;
    uint g;
    uint h;  // heuristic
	
}



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
    NW	 // North-West
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
    foreach(r; 0..(h.maxRows))
    {	
        foreach(c; 0..(h.maxCols))
        {
            if (c.isEven)
            {   
			    writeln("WEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
                // north
                if (r+1 <= h.maxRows)
                {
                    h.spots[r][c].neighbors[N].r = r+1;
                    h.spots[r][c].neighbors[N].c = c;
                }
                else 
                {
                    h.spots[r][c].neighbors[N].r = -1;
                    h.spots[r][c].neighbors[N].c = -1;
                }								
                // north-east
                if (c+1 <= h.maxCols)
                {
                    h.spots[r][c].neighbors[NE].r = r;
                    h.spots[r][c].neighbors[NE].c = c+1;
                }
                else 
                {
                    h.spots[r][c].neighbors[NE].r = -1;
                    h.spots[r][c].neighbors[NE].c = -1;
                }											
                // south-east
                if ((c+1 <= h.maxCols) && (r-1 >= 0))
                {
                    h.spots[r][c].neighbors[SE].r = r-1;
                    h.spots[r][c].neighbors[SE].c = c+1;
                }
                else 
                {
                    h.spots[r][c].neighbors[SE].r = -1;
                    h.spots[r][c].neighbors[SE].c = -1;
                }																	
                // south
                if (r-1 >= 0)
                {
                    h.spots[r][c].neighbors[S].r = r-1;
                    h.spots[r][c].neighbors[S].c = c;
                }
                else 
                {
                    h.spots[r][c].neighbors[S].r = -1;
                    h.spots[r][c].neighbors[S].c = -1;
                }															
                // south-west
                if ((r-1 >= 0) && (c-1 >= 0))
                {
                    h.spots[r][c].neighbors[SW].r = r-1;
                    h.spots[r][c].neighbors[SW].c = c-1;
                }
                else 
                {
                    h.spots[r][c].neighbors[SW].r = -1;
                    h.spots[r][c].neighbors[SW].c = -1;
                }								
                // north-west				
                if (c-1 >= 0)
                {
                    h.spots[r][c].neighbors[NW].r = r;
                    h.spots[r][c].neighbors[NW].c = c-1;
                }
                else 
                {
                    h.spots[r][c].neighbors[NW].r = -1;
                    h.spots[r][c].neighbors[NW].c = -1;
                }											
            }
            else   // ON ODD COLUMN
            {
			    writeln("ODD   ODD   ODD");
                // north
                if (r+1 <= h.maxRows)
                {
                    h.spots[r][c].neighbors[N].r = r+1;
                    h.spots[r][c].neighbors[N].c = c;
                }
                else 
                {
                    h.spots[r][c].neighbors[N].r = -1;
                    h.spots[r][c].neighbors[N].c = -1;
                }								
                // north-east
                if ((r+1 <= h.maxRows) && (c+1 <= h.maxCols))
                {
                    h.spots[r][c].neighbors[NE].r = r+1;
                    h.spots[r][c].neighbors[NE].c = c+1;
                }
                else 
                {
                    h.spots[r][c].neighbors[NE].r = -1;
                    h.spots[r][c].neighbors[NE].c = -1;
                }											
                // south-east
                if (c+1 <= h.maxCols)
                {
                    h.spots[r][c].neighbors[SE].r = r;
                    h.spots[r][c].neighbors[SE].c = c+1;
                }
                else 
                {
                    h.spots[r][c].neighbors[SE].r = -1;
                    h.spots[r][c].neighbors[SE].c = -1;
                }																	
                // south
                if (r-1 >= 0)
                {
                    h.spots[r][c].neighbors[S].r = r-1;
                    h.spots[r][c].neighbors[S].c = c;
                }
                else 
                {
                    h.spots[r][c].neighbors[S].r = -1;
                    h.spots[r][c].neighbors[S].c = -1;
                }															
                // south-west
                if (c-1 >= 0)
                {
                    h.spots[r][c].neighbors[SW].r = r;
                    h.spots[r][c].neighbors[SW].c = c-1;
                }
                else 
                {
                    h.spots[r][c].neighbors[SW].r = -1;
                    h.spots[r][c].neighbors[SW].c = -1;
                }								
                // north-west				
                if ((r+1 <= h.maxRows) && (c-1 >= 0))
                {
                    h.spots[r][c].neighbors[NW].r = r;
                    h.spots[r][c].neighbors[NW].c = c-1;
                }
                else 
                {
                    h.spots[r][c].neighbors[NW].r = -1;
                    h.spots[r][c].neighbors[NW].c = -1;
                }										
            }
		
            //writeln("hB.hexes[r][c].texture.id = ", hB.hexes[r][c].texture.id);
            //hB.spots[r][c].location.r = r;
            //hB.spots[r][c].location.c = c;			
        }
    }
}	



uint whatQuadrant(HexPosition a, HexPosition b)
{
    int dR = a.row - b.row;
    int dC = a.column - b.column;

    if (dR < 0)
	    if (dC < 0)
            { writeln("Quad I");    /* (-,-) */  return 1; }
        else
            { writeln("Quad II");   /* (-,+) */  return 2; }
    else
        if (dC < 0)
            { writeln("Quad IV");   /* (+,-) */  return 3; }
        else
            { writeln("Quad III");  /* (+,+) */  return 4; }
}

          

int calculateDistanceBetweenHexes(HexPosition a, HexPosition b)
{
    if (a == b)
    {
        writeln("End is same as Start");
        return 0;
    }
    if (a.row == b.row)
    {
        writeln("On same row");
        return (abs(a.column - b.column));
    }	
    if (a.column == b.column)
    {
        writeln("On same column");
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
     
            writeln("hexesToCutOff = ", hexesToCutOff);	

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
		
            writeln("hexesToCutOff = ", hexesToCutOff);
	
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
            writeln("hexesToCutOff = ", hexesToCutOff);	

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);	
            return length;
        }	
    }
    return 0;   	
}



// Spot[][] spots;    // put in HexBoard object. So a hexBoard "has-a" spots object	

Spot[] openSet;    // needs to be evaluated
Spot[] closedSet;  // stores all nodes that have finished being evaluated. Don't need to revisit

void enteringLandOfPathFinding( ref HexBoard hB, Globals g )
{
    writeln("inside enteringLandOfPathFinding");

    Spot begin;
    Spot end;

    begin.location.r = 0;
    begin.location.c = 0;
    end.location.r = hB.maxRows;
    end.location.c = hB.maxCols;  
	
    hB.spots = new Spot[][](hB.maxRows, hB.maxCols);

    writeln("hB.spots = ", hB.spots);
	
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
	

    writeln("hB.spots = ", hB.spots);	

    openSet ~= begin; 
	writeln("A - openSet.length = ", openSet.length);
	
    while (openSet.length > 0)   // while there are spots that still need evaluating
    {
	    ulong winner = 0;
        Spot current; // current is the node in openSet having the lowest f score
    
        foreach(i; 0..openSet.length)
        {
            writeln("i = ", i);
            if (openSet[i].f < openSet[winner].f)
            {
                winner = i;
            }
        }
		
		current = openSet[winner];
		
        if (current == end)
        {
             writeln("DONE!!!");
        }

        writeln("1 openSet.length = ", openSet.length);  
 
        openSet = openSet.remove(winner);  // openSet.remove(current)
		
        writeln("2 openSet.length = ", openSet.length);

        writeln("3 closedSet.length = ", closedSet.length);
		
        closedSet ~= current;    // closedSet.push(current)
		
        writeln("4 closedSet.length = ", closedSet.length);
		
       

        break;
		
    }
	
	
}