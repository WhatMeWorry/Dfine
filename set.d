
// Set is a user created data type which acts as a A* set container. This set holds 
// A* nodes which consist of a location and its cost.  The set provides four functions:
// add(node), node = removeMin(), empty() or notEmpty().  Retrieving nodes always results
// in the node being removed from the set  will always result in the smallest cost node being
//  returned. In cases of ties, order is considered random.

module set;

import std.container.rbtree;
import std.stdio;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;

struct Locale   // holds a hex of a hexboard
{
    int r;  // row of hexboard
    int c;  // column of hexboard
}

struct Node
{
    this(Locale location, uint f) 
    {
        this.location = location;
        this.f = f;
    }
    Locale location;  
    uint f;
    
    bool opEquals(Node other) const 
    {
        return (this.location.r == other.location.r) && 
               (this.location.c == other.location.c) &&
               (this.f == other.f);
    }
}




struct Set
{
    void add(Node node)   // add node in both associative array and red black tree
    {
        aa[node.location] = node.f;
        rbt.insert(node);
    }
    
    bool isNotEmpty() { return (!isEmpty); }
    
    bool isEmpty()
    {
        if (aa.empty)
        {
            if (rbt.empty)
            {
                return true;   // both are empty
            }
            writeln("set's associative array is empty but not it's red black tree");
            writeln("they should both be empty. Why are they out of sync?");
            exit(-1);
        }
        else  // aa is not empty
        {
            if (!rbt.empty)
            {
                return false;   // both are not empty
            }
            writeln("set's associative array is not empty but it's red black tree is");
            writeln("they should both be empty. Why are they out of sync?");
            exit(-1);
        }
    }

    Node removeMin()
    {
        Node min = rbt.front;   // get the front of the rbt which holds smallest f value
        rbt.removeFront;         // and remove it from the rbt
        aa.remove(min.location); // also remove the node from the associative array
        return min;
    }

    void display()
    {
        writeln("Associative Array of set has");
        foreach(keyValuePair; aa.byKeyValue()) 
        {
            writeln("Key: ", keyValuePair.key, ", Value: ", keyValuePair.value);
        }
        writeln("red black tree of set has");
        foreach(node; rbt) 
        {
            writeln("node: ", node);
        }
    }

    uint[Locale] aa;  // associative array will hold the Locale portion of the node

    auto rbt = new RedBlackTree!(Node, "a.f < b.f", true);    // true: allowDuplicates
}



/+ Unit tests can be run in this module with the following commands:
rdmd -main -unittest set.d
or
dmd -main -unittest set.d
.\set.exe
or with coverage
dmd -main -unittest -cov set.d
.\set.exe
creates a set.lst file with code coverage statistics
+/


unittest
{
Set s;

Node n1 = Node( Locale(1,2),   33);  
Node n2 = Node( Locale(3,4),   20);  // duplicate
Node n3 = Node( Locale(5,6),    7);
Node n4 = Node( Locale(7,8),   11);
Node n5 = Node( Locale(9,10),  20);  // duplicate
Node n6 = Node( Locale(11,12), 97);
Node n7 = Node( Locale(13,14), 20);  // duplicate
Node n8 = Node( Locale(13,14),  1);

s.add(n1);
s.add(n2);
s.add(n3);
s.add(n4);
s.add(n5);
s.add(n6);
s.add(n7);
s.add(n8);


s.display;


Node n;
while( s.isNotEmpty() ) 
{
    n = s.removeMin();
    writeln("removeMin returned ", n);
}

}

