
// Set is a user created data type which acts as a A* set container. This set holds 
// A* nodes which consist of a Location and its cost.  The set provides four functions:
// addTo(node), node = removeMin(), empty() or notEmpty().  Retrieving nodes always result
// in the node being removed from the set and will always result in the smallest cost
// node being returned. In cases of ties, order should be considered random.

module set;

import std.container.rbtree;
import std.stdio;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes : Location;


struct SetNode
{
    this(Location locale, uint f) 
    {
        this.locale = locale;
        this.f = f;
    }
    Location locale;  
    uint f;
    
    bool opEquals(SetNode other) const 
    {
        return (this.locale.r == other.locale.r) && 
               (this.locale.c == other.locale.c) &&
               (this.f == other.f);
    }
}




struct Set
{
    void addTo(SetNode node)  // add element to set
    {
        rbt.insert(node);          // add to red black tree, rbt
        aa[node.locale] = node.f;  // add to associative array, aa
        writeln("rbt.length = ", rbt.length);
    }
    
    bool isIn(SetNode node)
    {
        //return (node.locale in aa);  // "key1" in arr)
        if (node.locale in aa)
            return true;
        else
            return false;
    }
    
    bool isNotIn(SetNode node)
    {
        return (node.locale !in aa);
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

    SetNode removeMin()
    {
        SetNode min = rbt.front; // get the front of the rbt which holds smallest f value
        rbt.removeFront;         // and remove it from the rbt
        aa.remove(min.locale);   // also remove the node from the associative array
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
        writeln("-------------------------------");
        foreach(node; rbt) 
        {
            writeln("node: ", node);
        }
        writeln("-------------------------------");
    }
    //  value[key] aa
    uint[Location] aa;  // associative array will hold the Location portion of the node

    auto rbt = new RedBlackTree!(SetNode, "a.f < b.f", true);    // true: allowDuplicates
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

SetNode n1 = SetNode( Location(1,2),   33);  
SetNode n2 = SetNode( Location(3,4),   20);  // duplicate
SetNode n3 = SetNode( Location(5,6),    7);
SetNode n4 = SetNode( Location(7,8),   11);
SetNode n5 = SetNode( Location(9,10),  20);  // duplicate
SetNode n6 = SetNode( Location(11,12), 97);
SetNode n7 = SetNode( Location(13,14), 20);  // duplicate
SetNode n8 = SetNode( Location(13,14),  1);

s.addTo(n1);
s.display;
s.addTo(n2);
s.display;
s.addTo(n3);
s.display;
s.addTo(n4);
s.display;
s.addTo(n5);
s.display;
s.addTo(n6);
s.display;
s.addTo(n7);
s.display;
s.addTo(n8);


s.display;


SetNode n;
while( s.isNotEmpty() ) 
{
    n = s.removeMin();
    writeln("removeMin returned ", n);
    writeln("s.isEmpty() = ", s.isEmpty());
}
writeln("s.isEmpty() = ", s.isEmpty());

SetNode n9a = SetNode( Location(15,16), 25);  // duplicate
SetNode n9b = SetNode( Location(15,16), 25);

assert(n9a == n9b);   // test opEquals


s.addTo(n1);
s.addTo(n2);
s.addTo(n3);
s.addTo(n4);
s.addTo(n5);
s.addTo(n6);
s.addTo(n7);
s.addTo(n8);



}

