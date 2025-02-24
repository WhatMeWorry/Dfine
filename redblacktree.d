
/+ Unit tests can be run in this module with the following commands:
rdmd -main -unittest redblacktree.d
or
dmd -main -unittest redblacktree.d
.\redblacktree.exe
or with coverage
dmd -main -unittest -cov redblacktree.d
.\redblacktree.exe
creates a redblacktree.lst file with code coverage statistics
+/


module redblacktree;

//import std.container : RedBlackTree;
import std.container.rbtree;

import std.stdio;

struct Location   // holds a hex of a hexboard
{
    int r;  // row of hexboard
    int c;  // column of hexboard
}

struct Node
{
    this(Location location, uint f) 
    {
        this.location = location;
        this.f = f;
    }
    Location location;  
    uint f;
    
    bool opEquals(Node other) const 
    {
        return (this.location.r == other.location.r) && 
               (this.location.c == other.location.c) &&
               (this.f == other.f);
    }
}


unittest
{
    auto priorQ = new RedBlackTree!(Node, "a.f < b.f", true); // true = duplicates are allowed
    
    Node n1 = Node( Location(1,2), 33);
    Node n2 = Node( Location(3,4), 20);
    Node n3 = Node( Location(5,6), 7);
    Node n4 = Node( Location(7,8), 1);
    Node n5 = Node( Location(9,10), 20);
    Node n6 = Node( Location(11,12), 97);
    Node n7 = Node( Location(13,14), 20);
    
    priorQ.insert(n3);
    priorQ.insert(n2);
    priorQ.insert(n1);    
    priorQ.insert(n4);
    priorQ.insert(n5);
    priorQ.insert(n7);
    priorQ.insert(n6);

    assert(n1 in priorQ);
    assert(n2 in priorQ,);
    assert(n3 in priorQ,);
    assert(n4 in priorQ,);
    assert(n5 in priorQ,);
    assert(n6 in priorQ,);
    assert(n7 in priorQ,);

    Node current;
    
    /+
    while(!priorQ.empty) 
    {
        current = priorQ.front;
        priorQ.removeFront;
        writeln("current = ", current);
    }
    +/
    
    current = priorQ.front;
    assert(current == n4);
    priorQ.removeFront;
    
    current = priorQ.front;
    assert(current == n3);
    priorQ.removeFront;
    
    current = priorQ.front;
    assert(current == n2);
    priorQ.removeFront;
    
    current = priorQ.front;
    assert(current == n5);
    priorQ.removeFront;
    
    current = priorQ.front;
    assert(current == n7);
    priorQ.removeFront;
    
    current = priorQ.front;
    assert(current == n1);
    priorQ.removeFront;

    current = priorQ.front;
    assert(current == n6);
    priorQ.removeFront;

   assert(priorQ.empty);
}

