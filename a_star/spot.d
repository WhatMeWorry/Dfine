

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



bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);   
}


//   |\          |  /        |\          |  /        |\          |  /
//   |X\         | /         |X\         | /         |X\         | /
//   |XX\________|/__________|XX\________|/__________|XX\________|/__
//   |  /        |\          |  /         \          |  /        |\ 
//   | /         |X\         | /           \         | /         |X\ 
//   |/          |XX\________|/      2      \________|/          |XX\
//   |\          |  /         \             /        |\          |  /
//   |X\         | /           \           /         |X\         | /
//   |XX\________|/      1      \_________/          |XX\________|/__
//   |  /         \             /        |\          |  /        |\ 
//   | /           \           /         |X\         | /         |X\ 
//   |/      0      \________ /          |XX\________|/          |XX\    
//   |\             /        |\          |  /        |\          |  /
//   | \           /         |X\         | /         |X\         | /
//   |  \________ /__________|XX\________|/__________|XX\________|/__


void moveSouthWest(ref HexPosition h)
{
    if (isEven(h.column))
    {
        h.row = h.row - 1;
		
		if (h.row == -1)
		    h.row = 0;  // this takes care of a corner case on bottom 
                        // edge of hexboard when row can become negative 1

        h.column = h.column - 1;   
    }	
    else
    {
        h.column = h.column - 1;   	    
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
            


int calculateLength(HexPosition a, HexPosition b)
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
	
        //writeln("delta.run = ", delta.run);	
        //writeln("delta.rise = ", delta.rise);
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
    writeln("ODD==========================");
    if ((quad == 1) || (quad == 2))
	{
        Slope delta; 
        int length;
	
        delta.run = abs(a.column - b.column);
        delta.rise = abs(a.row - b.row);

        //int hexesToCutOff = delta.run / 2;  // did not need a float	
        int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float	
		
        //writeln("delta.run = ", delta.run);	
        //writeln("delta.rise = ", delta.rise);
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


void quadOne(HexPosition a, HexPosition b)
{
    Slope delta; 
    int length;
	
    delta.run = abs(a.column - b.column);
    delta.rise = abs(a.row - b.row);

    int hexesToCutOff = delta.run / 2;  // did not need a float	
	
    writeln("delta.run = ", delta.run);	
    writeln("delta.rise = ", delta.rise);
    writeln("hexesToCutOff = ", hexesToCutOff);
	
    if (delta.rise <= hexesToCutOff)
        length = delta.run;  
    else
        length = delta.run + abs(delta.rise - hexesToCutOff);
    writeln("lengh = ", length);
}
















void nileDelta(HexPosition a, HexPosition b)
{
    if (a.row.isEven)
        write("(even,");
    else
        write("(odd,");
		
    if (a.column.isEven)
        writeln("even)");
    else
        writeln("odd)");


    writeln("delta row: ", abs(a.row - b.row));   
    writeln("delta column: ", abs(a.column - b.column));

    if (b.row.isEven)
        write("(even,");
    else
        write("(odd,");
		
    if (b.column.isEven)
        writeln("even)");
    else
        writeln("odd)");

    HexPosition delta;
	
	delta.column = a.column - b.column;
		
    if (delta.column < 0)
        writeln("hex is to the right of starting hex");
    else if (delta.column > 0)
        writeln("hex is to the left of starting hex");
    else
        writeln("hex is in the same column as starting hex");
   		
    writeln("****************************");
}


uint asTheBirdFlys( HexPosition begin, HexPosition end)
{
    //writeln("****************************");

    Slope delta; 
    int length;

    //writeln("begin hex = ", begin, "   end hex = ", end);

    if (begin == end)
    {
        writeln("selected END HEX is same as START HEX");
        return 0;
    }
	
    writeln("begin (", begin.row, ", ", begin.column, ")   end (", end.row, ",", end.column, ")" );	
	
    if (begin.column.isOdd())
    {
        writeln("begin.column ", begin.column, " is odd");
        // make the beginning odd column even by moving is over to the left.
        // Since this is a hexboard, it is a southwest move. Or (0,-1) which is keep row the same, but 
        // subtract one from the column.

        moveSouthWest(begin);
		
        moveSouthWest(end);		

        writeln("begin (", begin.row, ", ", begin.column, ")   end (", end.row, ",", end.column, ")" );			
    }


                                 //              r,c       r,c
    if (begin.column.isEven())   // Worked with (0,0) and (3,0).  So both even and odd rows works so long as column is even.
    {
        if ( (begin.row <= end.row) && (begin.column <= end.column))
        {
            //writeln("start in lower left, end in upper right");	
        }
        if ( (begin.row >= end.row) && (begin.column >= end.column))
        {
            //writeln("start in upper right, end in lower left left");
            writeln("REVERSI");	
            HexPosition temp;
		    temp = begin;
		    begin = end;
		    end = temp;
        }	

        delta.run = abs(begin.column - end.column);
	
        delta.rise = abs(begin.row - end.row);  // r for rows (not rise or run)
	
        int hexesToCutOff = delta.run / 2;  // did not need a float	
	
        writeln("delta.run = ", delta.run);	
        writeln("delta.rise = ", delta.rise);
        writeln("hexesToCutOff = ", hexesToCutOff);
	
        if (delta.rise <= hexesToCutOff)
        {
            length = delta.run;  
        }
        else
        {
            length = delta.run + abs(delta.rise - hexesToCutOff);
        }
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





/*  THIS WORKED FOR EVEN COLUMNS

    if ((quad == 1) || (quad == 2))
	{
        Slope delta; 
        int length;
	
        delta.run = abs(a.column - b.column);
        delta.rise = abs(a.row - b.row);

        int hexesToCutOff = delta.run / 2;  // did not need a float	
	
        //writeln("delta.run = ", delta.run);	
        //writeln("delta.rise = ", delta.rise);
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
		
        int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float	

        writeln("hexesToCutOff = ", hexesToCutOff);	

        if (delta.rise <= hexesToCutOff)
            length = delta.run;  
        else
            length = delta.run + abs(delta.rise - hexesToCutOff);	
        return length;
    }	
	
*/






