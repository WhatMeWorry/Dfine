
// Set is a user created data type which acts as a A* set container. This set holds 
// A* nodes which consist of a Location and its cost.  The set provides four functions:
// addTo(node), node = removeMin(), empty() or notEmpty().  Retrieving nodes always result
// in the node being removed from the set and will always return the smallest cost node.
// In cases of ties, order should be considered random.

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

void setName(Set s, string n)
{ s.name = n; 
  writeln("SETTING NAME"); }

void addTo(SetNode node, Set s)  // add element to set
{
    writeln("s = ",s);
    
    s.aa[node.locale] = node.f;  // add to associative array, aa
    s.rbt.insert(node);          // add to red black tree, rbt
    writeln("s.aa.length = ", s.aa.length);
} 

void display(Set s)
{
    writeln("===========================================");
    writeln("Associative Array of set has length ", s.aa.length);
    foreach(keyValuePair; s.aa.byKeyValue()) 
        { writeln("Key: ", keyValuePair.key, ", Value: ", keyValuePair.value); }
    writeln("red black tree of set has length ", s.rbt.length);
    foreach(node; s.rbt) 
    { writeln("node: ", node); }
    writeln("===========================================");
}

// can be called with: if (element.isIn(set)) 

bool isIn(SetNode node, Set s)  // is node in set?
{
    // condition ? value_if_true : value_if_false
    // return (a > b) ? a : b;
    return ((node.locale in s.aa) ? true : false);  // in returns a uint* so needs ternary opertor
}

bool isNotIn(SetNode node, Set s) { return (node.locale !in s.aa); }  // !in returns a bool

struct Set
{   /+
    void addTo(SetNode node)  // add element to set
    {
        rbt.insert(node);          // add to red black tree, rbt
        aa[node.locale] = node.f;  // add to associative array, aa
    } +/
    
    bool isIn(SetNode node)
    {
        return ((node.locale in aa) ? true : false);   // "key" in associative array
    }

    bool isNotIn(SetNode node) { return (node.locale !in aa); }
    

    bool isEmpty()
    {
        if (aa.empty)
        {
            if (rbt.empty)
                { return true; }  // both are empty
            writeln("aa is empty; red black tree is not empty: out of sync");
            exit(-1);
        }
        else
        {
            if (!rbt.empty)
                { return false; } // both are not empty
            writeln("aa is not empty; red black tree is empty: out of sync");
            exit(-1);
        }
    }
    
    bool isNotEmpty() { return (!isEmpty); }

    SetNode removeMin()
    {
        SetNode min = rbt.front; // get the front of the rbt which holds smallest f value
        rbt.removeFront;         // and remove it from the rbt
        aa.remove(min.locale);   // also remove the node from the associative array
        return min;
    }
     
    /+
    void display()
    {
        writeln("----------snapshot start ----------------");
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
        writeln("----------snapshot end   ----------------");
    }
    +/
    //  value[key] aa
    uint[Location] aa;  // associative array will hold the Location portion of the node

    auto rbt = new RedBlackTree!(SetNode, "a.f < b.f", true);    // true: allowDuplicates
    
    string name;
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

// Note: node make sure the key, "Location", is unique in all nodes below. This constraint
// will always exist in the A* algorithm


SetNode n1 = SetNode( Location(1,2),   33);  
SetNode n2 = SetNode( Location(3,4),   20);  // duplicate
SetNode n3 = SetNode( Location(3,6),    7);
SetNode n4 = SetNode( Location(3,8),   11);
SetNode n5 = SetNode( Location(9,10),  20);  // duplicate
SetNode n6 = SetNode( Location(11,12), 97);
SetNode n7 = SetNode( Location(13,14), 20);  // duplicate
SetNode n8 = SetNode( Location(15,16),  1);
SetNode n0;

s.addTo(n1);
s.addTo(n2);
s.addTo(n3);
s.addTo(n4);
s.addTo(n5);
s.addTo(n6);
s.addTo(n7);
s.addTo(n8);


s.display;

// UFCS calls
if (n1.isIn(s))
    writeln("n1 node is in set s");
    
if (n8.isIn(s))
    writeln("n8 node is in set s");
    
if (n0.isIn(s))
    writeln("n0 node is in set s"); 
else
    writeln("n0 node is NoT in set s"); 

// non UFCS calls

if (s.isIn(n1))
    writeln("n1 node is in set s");
    
if (s.isIn(n0))
    writeln("n0 node is in set s"); 
else
    writeln("n0 node is NoT in set s"); 
    


SetNode n;
while ( s.isNotEmpty() ) 
{
    n = s.removeMin();
    writeln("removeMin returned ", n);
}

writeln("Set should now be empty");
s.display;

writeln("s.isEmpty() = ", s.isEmpty());


SetNode n9a = SetNode( Location(15,16), 25);  // duplicate
SetNode n9b = SetNode( Location(15,16), 25);

assert(n9a == n9b);   // test opEquals


}

