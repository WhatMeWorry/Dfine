

module distance;

import std.stdio;

// import std.math : ceil, floor;
// import std.math.rounding: floor;
// import std.math.algebraic: abs;
import std.math;
import std.conv : to;

import honeycomb;


struct Slope
{
    int rise;
    int run;
}


uint whatQuadrant(Location a, Location b)
{
    int dR = a.r - b.r;
    int dC = a.c - b.c;

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
int heuristic(Location a, Location b)
{
    if (a == b)
    {
        //writeln("End is same as Start");
        return 0;
    }
    if (a.r == b.r)
    {
        //writeln("On same row");
        return (abs(a.c - b.c));
    }
    if (a.c == b.c)
    {
        //writeln("On same column");
        return (abs(a.r - b.r));
    }

    uint quad = whatQuadrant(a, b);

    if (a.c.isEven)
    {
        if ((quad == 1) || (quad == 2))
        {
            Slope delta; 
            int length;

            delta.run = abs(a.c - b.c);
            delta.rise = abs(a.r - b.r);

            int hexesToCutOff = delta.run / 2;  // did not need a float

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

            delta.run = abs(a.c - b.c);
            delta.rise = abs(a.r - b.r);

            int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);
            return length;
        }
    }

    if (a.c.isOdd)
    {
        if ((quad == 1) || (quad == 2))
        {
            Slope delta; 
            int length;

            delta.run = abs(a.c - b.c);
            delta.rise = abs(a.r - b.r);

            //int hexesToCutOff = delta.run / 2;  // did not need a float
            int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float

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

            delta.run = abs(a.c - b.c);
            delta.rise = abs(a.r - b.r);

            //int hexesToCutOff = to!int(ceil(to!float(delta.run) / 2.0));  // did not need a float
            int hexesToCutOff = delta.run / 2;  // did not need a float

            if (delta.rise <= hexesToCutOff)
                length = delta.run;  
            else
                length = delta.run + abs(delta.rise - hexesToCutOff);
            return length;
        }
    }
    return 0;
}


