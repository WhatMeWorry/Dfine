
module redblacktree;

import std.container : RedBlackTree;
import std.stdio;
//import honeycomb : Location;

struct Location   // holds a hex of a hexboard
{
    int r;  // row in hexboard
    int c;  // column of hexboard
}

struct Node
{
    this(Location locaction, uint f) 
    {
        this.location = location;
        this.f = f;
    }
    Location location;  
    uint f;
}


unittest
{
    auto priorQ = new RedBlackTree!(Node, "a.f < b.f", true); 
    Node n1 = Node( Location(1,2), 33);
    Node n2 = Node( Location(3,4), 20);
    Node n3 = Node( Location(5,6), 7);
    writeln("priority Queue priorQ = ", priorQ);
    writeln(priorQ);
    writeln(priorQ.front); 
    
    //assert(hexWidthToFitWindow(1, 1, Direction.horizontal).isClose(2.0f), "unit test failed");
    //assert(hexWidthToFitWindow(2, 2, Direction.horizontal).isClose(1.14286f), "unit test failed");

}

//int main()
void placeHolder() 
{
auto priorQ = new RedBlackTree!(Node, "a.f < b.f", true); // true: allowDuplicates

Node n1 = Node( Location(1,2), 33);
Node n2 = Node( Location(3,4), 20);
Node n3 = Node( Location(5,6), 7);
Node n4 = Node( Location(7,8), 1);
Node n5 = Node( Location(9,10), 20);
Node n6 = Node( Location(11,12), 97);

Node current;

writeln("Before inserts into RedBlackTree");

writeln("priorQ = ", priorQ);

priorQ.insert(n3);
priorQ.insert(n2);
priorQ.insert(n1);
priorQ.insert(n4);
priorQ.insert(n5);

writeln("After 5 Node inserts into RedBlackTree");

writeln("priorQ = ", priorQ);

writeln("---------------------------------");

while(!priorQ.empty) 
{
    current = priorQ.front;
    priorQ.removeFront;
    writeln("current = ", current);
}

priorQ.insert(n5);
priorQ.insert(n4);
priorQ.insert(n3);
priorQ.insert(n2);
priorQ.insert(n1);


writeln("priorQ.length = ", priorQ.length);


// https://dlang.org/phobos/std_container_rbtree.html#.RedBlackTree.opBinaryRight
// https://dlang.org/spec/operatoroverloading.html#binary

if (n3 in priorQ)
{
    writeln("n3 is in the RedBlackTree ");
}

if (n6 !in priorQ)
{
    writeln("n6 is not in the RedBlackTree ");
}


while(!priorQ.empty) 
{
    current = priorQ.front;
    writeln("current = ", current);
    priorQ.removeFront;
}


}