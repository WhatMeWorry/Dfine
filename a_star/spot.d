

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


struct HexSlope
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



uint asTheBirdFlys( Location begin, Location finish)
{
    writeln("****************************");

    //writeln("begin = ", begin);
    //writeln("finish = ", finish);	

    Location delta;
 
    // delta columns and delta rows are perfect. This is when start, end = { (0,0) to (w, h) } 
	//                                                or when start, end = { (w,h) to (0, 0) } 

    delta.c = abs(begin.c - finish.c);
    delta.r = abs(begin.r - finish.r);

    //writeln("delta.c = ", delta.c);   
    //writeln("delta.r = ", delta.r);   

    HexSlope slope; 

	slope.rise = delta.r;	
	slope.run = delta.c;

    writeln("slope.rise = ", slope.rise);
    writeln("slope.run  = ", slope.run);   
 
    int length;
	
    writeln("slope.rise * 0.866 = ", slope.rise * 0.866);
    writeln("slope.run *  0.75 = ", slope.run * 0.75);	

 
    if (slope.rise * 0.866 > slope.run * 0.75)
	{
        writeln("rise > run");
	    //writeln("delta.r = ", delta.r);	
        //delta.r 	 
    }

    // The slope of 30 degrees goes in lock step with the length of the run (delta.c)  
    // For every 2 hexes of run, we get 1 hex closer to the end of the rise (delta.r)

    //float howManyPairs = delta.c / 2.0;


	
    //length = slope.run + (slope.rise - to!int(floor(howManyPairs)));	


    // Unlike square game boards (chess, checkers) if moving horizontal and vertically
    // is 1.0, then moving diagonally is 1.4
	
    length = slope.rise + slope.run;

    //writeln("howManyPairs = ", howManyPairs);      	
	
    //writeln("length = ", length);  
	

    //int angle30 = to!int( ceil(to!float(delta.c) / 2.0) );	

    //writeln("angle30 len = ", angle30);
	
    //delta.y = abs(a.y - b.y) - 1;	

    //writeln("delta cols = ", delta.c);
	
    //writeln("delta rows = ", delta.r);	

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