
module honeycomb;


import std.conv: roundTo;
import std.stdio: writeln, readf;
import core.stdc.stdlib: exit;

import std.math.rounding: floor;
import std.math.algebraic: abs;





struct D3_point
{
    float x;
    float y; 
    float z;
}

struct Hex
{
    D3_point[6] points;  // each hex is made up of 6 vertices
    D3_point center;     // each hex has a center
}

struct Edges
{                // This is the hex board edges, not the window's
    float top;  // The hex board can be smaller or larger than the window
    float bottom; 
    float left;
    float right;	
}

struct HexBoard
{
    @disable this();   // disables default constructor HexBoard h;
	
    this(float diameter, uint rows, uint cols) 
	{
	    diameter    = diameter;
        radius      = diameter * 0.5;	
        halfRadius  = radius * 0.5;	
									
        perpendicular = diameter * 0.866;	
        apothem       = perpendicular * 0.5; 

        //rows = rows;
        //cols = cols;

        hexCols.length = cols;
        foreach(c; 0..hexCols.length-1)
        {		
            writeln("c = ", c);
			writeln("hexCols[c] = ", hexCols[c]);
        }			
        foreach(c; 0..hexCols.length-1)
        {		
		    writeln("Inside");
            hexRows[c].length = rows;
        }					
		
        //hexRows[].length = cols;
        		
    }
	
    uint rows;  // number of rows on the board [0..rows-1]
    uint cols;  // number of columns on the bord [0..cols-1]
	
    Edges edge;

    // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
    // which because of the hex board stagger makes a row of 5 (not 4) hexes.
    // A diameter of 2.0, would display a single hex which would fill the full width 
    // of the window and 0.866 of the window's height.

    float diameter;  // diameter is used to define all the other hex parameters 
    float radius;	
    float halfRadius;	
    float perpendicular;	
    float apothem;

    // Hex[cols][rows] hexes;  // Note: call with hexes[rows][cols];  // REVERSE ORDER!   
    //Hex[][] hexes;
	Hex[] hexCols;
	Hex*[] hexRows;
	
    //SelectedPair selected;	
	//D3_point[4] squarePts;

    void displayHexBoard()
    {
        foreach(r; 0..rows)
        {
            foreach(c; 0..cols)
            {
                //writeln("hexes[", r, "][", c, "].center ", hexes[r][c].center );    
				
                foreach(p; 0..6)
                {
                    //writeln("hexes(r,c) ) ", hexes[r][c].points[p] );                   
                }				 	
            }
        }			
    }
}