

module a_star.spot;
 

import std.stdio;
import std.math : ceil, floor;
import std.string;
import std.conv;
import core.stdc.stdlib;  // for exit()

import honeycomb;
import app;

struct Spot
{
    
    float f;
    float g;
    float h;  // huristic
}


struct Slope
{
    int rise;
    int run;
}



//   |\          |  /        |\          |  /        |\          |  /
//   |X\         | /         |X\         | /         |X\         | /
//   |XX\________|/__________|XX\________|/__________|XX\________|/__
//   |  /        |\          |  /         \          |  /        |\ 
//   | /         |X\         | /           \         | /         |X\ 
//   |/          |XX\________|/      3      \________|/          |XX\
//   |\          |  /         \             /        |\          |  /
//   |X\         | /           \           /         |X\         | /
//   |XX\________|/      2      \_________/          |XX\________|/__
//   |  /         \             /        |\          |  /        |\ 
//   | /           \           /         |X\         | /         |X\ 
//   |/      1      \________ /          |XX\________|/          |XX\    
//   |\             /        |\          |  /        |\          |  /
//   | \           /         |X\         | /         |X\         | /
//   |  \________ /__________|XX\________|/__________|XX\________|/__



uint asTheBirdFlys( HexPosition begin, HexPosition end)
{
    writeln("****************************");
	
	
    if ( (begin.row <= end.row) && (begin.column <= end.column))
    {
        writeln("start in lower left, end in upper right");	
    }
    if ( (begin.row > end.row) && (begin.column > end.column))
    {
        writeln("start in upper right, end in lower left left");
        writeln("REVERSI");	
        HexPosition temp;
		temp = begin;
		begin = end;
		end = temp;
    }	
   

    Slope delta; 
 
    int length;
	
    delta.run = abs(begin.column - end.column);
	
    delta.rise = abs(begin.row - end.row);  // r for rows (not rise or run)
	
    int hexesToCutOff = delta.run / 2;  // did not need a float	
	
    //writeln("delta.run = ", delta.run);	
    //writeln("delta.rise = ", delta.rise);
    //writeln("hexesToCutOff = ", hexesToCutOff);
	
    if (delta.rise <= hexesToCutOff)
    {
        length = delta.run;  
 
    }
    else
    {
        length = delta.run + abs(delta.rise - hexesToCutOff);		
    }
	
	writeln("length = ", length);		
 
    return 1;
}



// Spot[][] spots;    // put in HexBoard object. So a hexBoard "has-a" spots object	

void enteringLandOfPathFinding( ref HexBoard hB, Globals g )
{
    writeln("inside enteringLandOfPathFinding");
	
	D2_SC start;	
    D2_SC end;

    start.x = 0;
    start.y = 0;
    end.x = hB.maxRows;
    end.y = hB.maxCols;  
	
    //D2_SC diff = asTheBirdFlys(start, end);
	
    // writeln("hB = ", hB);  // This displays a ton of data as expected
    // writeln("g = ", g);    // 

    hB.spots = new Spot[][](hB.maxRows, hB.maxCols);

    writeln("hB.spots = ", hB.spots);
	
    foreach(r; 0..(hB.maxRows))
    {
        foreach(c; 0..(hB.maxCols))
        {
            writeln("hB.hexes[r][c].texture.id = ", hB.hexes[r][c].texture.id);
			
            //writeln(hB.spots.

            //h = asBirdFly(  ) 
	
        }
    }


		
}