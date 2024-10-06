
module hexmath;

import std.stdio;

/+ Unit tests can be run in this module with the following commands:
rdmd -main -unittest hexmath.d
or
rdmd -main -unittest hexmath.d
.\hexmath.exe
+/

bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);   
}

unittest
{
    //assert(isOdd(-2), "-2 is even");
    assert(isOdd(-1), "-1 is odd");
    assert(isEven(0), "0 is even");
    assert(isOdd(1),  "1 is odd");
    assert(isEven(2), "2 is even");
    //assert(false, "force the triggering of this assert");
}


enum Direction { horizontal, vertical } 

     /+   note: all vertical segments are same size. 
     | \         | /         | \         | /         | \         | / |
     |  \________|/          |  \________|/          |  \________|/__|
     |  /        |\          |  /        |\          |  /        |\  |
     | /         | \         | /         | \         | /         | \ |
     |/          |  \____|___|/          |  \________|/  |       |  \|    
     |\ |    |   |  /|   |   |\  |   |   |  /|       |\  |   |   |  /|
     | \|    |   | / |   |   | \ |   |   | / |   |   | \ |   |   | / |
     |  \____|___|/__|___|___|  \|___|___|/__|___|___|  \|___|___|/__|
     | 1|  2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |10|| 11|12 |13 |14 |15 | 16|
     +/

float computeHexWidthToFitInWindow(uint rows, uint cols, Direction dir )
{
    immutable float lengthNDC = 2.0;  // width of any given NDC system is always 2.0 units.  (-1.0 to 1.0)
    float hexWidth;
    
    if (dir == Direction.horizontal)
    {
        float totalSegments = (cols * 3) + 1;
        float widthPerSegment = lengthNDC / totalSegments;
        hexWidth = 4.0 * widthPerSegment;  // 4 segments equal a hex diameter
    }
    else
    {
        float heightPerHex = lengthNDC / rows;
        hexWidth = heightPerHex / 0.866;
    }
    writeln(hexWidth);
    
    return hexWidth;
}


unittest
{
    assert(computeHexWidthToFitInWindow(1, 1, Direction.horizontal ) == 2.0f, "This assert failed");
    assert(computeHexWidthToFitInWindow(3, 3, Direction.horizontal ) == 0.8f, "This assert failed");
    assert(computeHexWidthToFitInWindow(2, 2, Direction.horizontal ) == 1.14286f, "This assert failed");    
}