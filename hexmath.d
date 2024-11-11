
module hexmath;

import std.stdio;
import std.math.operations : isClose;

/+ Unit tests can be run in this module with the following commands:
rdmd -main -unittest hexmath.d
or
dmd -main -unittest hexmath.d
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
    assert(isEven(-2), "-2 is even");
    assert(isOdd(-1), "-1 is odd");
    assert(isEven(0), "0 is even");
    assert(isOdd(1),  "1 is odd");
    assert(isEven(2), "2 is even");
}


enum Direction { horizontal, vertical } 

     /+   note: all vertical segments (1-16) are the same size. Some distortion is 
          caused the inherent limitation of the ascii font. 
     
     | \         | /         | \         | /         | \         | / |
     |  \________|/          |  \________|/          |  \________|/__|
     |  /        |\          |  /        |\          |  /        |\  |
     | /         | \         | /         | \         | /         | \ |
     |/          |  \________|/          |  \________|/          |  \|
     |\  |   |   |  /|   |   |\  |   |   |  /|   |   |\  |   |   |  /|
     | \ |   |   | / |   |   | \ |   |   | / |   |   | \ |   |   | / |
     |  \|___|___|/__|___|___|  \|___|___|/__|___|___|  \|___|___|/__|
     | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |10 | 11|12 |13 |14 |15 | 16|
     
   -1.0                             0.0                             1.0
         _________      __________      
        /         \    /          \    
       /           \  /            \ 
      /___hexWidth__\/___hexWidth___\  
      \             /\              /
       \           /  \            /
        \_________/    \__________/
     
     +/

float hexWidthToFitWindow(uint rows, uint cols, Direction direction )
{
    immutable float lengthNDC = 2.0;  // width and height of NDC system is always 2.0 units.  (-1.0 to 1.0)
    float hexWidth;
    
    if (direction == Direction.horizontal)
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

    return hexWidth;
}


unittest
{   
    // Horizontal fit

    assert(hexLengthToFitWindow(1, 1, Direction.horizontal).isClose(2.0f), "unit test failed");
    assert(hexLengthToFitWindow(2, 2, Direction.horizontal).isClose(1.14286f), "unit test failed");
    assert(hexLengthToFitWindow(3, 3, Direction.horizontal).isClose(0.8f), "unit test failed");
    assert(hexLengthToFitWindow(5, 5, Direction.horizontal).isClose(0.5f), "unit test failed");
    assert(hexLengthToFitWindow(25, 25, Direction.horizontal).isClose(0.105263f), "unit test failed");
    assert(hexLengthToFitWindow(999, 999, Direction.horizontal).isClose(0.00266845f), "unit test failed");
    
    assert(hexLengthToFitWindow(999, 1, Direction.horizontal).isClose(2.0f), "unit test failed");
    assert(hexLengthToFitWindow(1, 999, Direction.horizontal).isClose(0.00266845f), "unit test failed");

    // Vertical fit

    assert(hexLengthToFitWindow(1, 1, Direction.vertical).isClose(2.30947f), "unit test failed");
    assert(hexLengthToFitWindow(2, 2, Direction.vertical).isClose(1.15473f), "unit test failed");
    assert(hexLengthToFitWindow(3, 3, Direction.vertical).isClose(0.769823), "unit test failed");
    assert(hexLengthToFitWindow(5, 5, Direction.vertical).isClose(0.461894f), "unit test failed");
    assert(hexLengthToFitWindow(25, 25, Direction.vertical).isClose(0.0923788f), "unit test failed");
    assert(hexLengthToFitWindow(999, 999, Direction.vertical).isClose(0.00231178f), "unit test failed");

    assert(hexLengthToFitWindow(999, 1, Direction.vertical).isClose(0.00231178f), "unit test failed");
    assert(hexLengthToFitWindow(1, 999, Direction.vertical).isClose(2.30947f), "unit test failed");
 
}