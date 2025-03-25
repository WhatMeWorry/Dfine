


module bag;

import std.container.rbtree;
import std.stdio;
import std.range : empty;  // for aa 
import core.stdc.stdlib : exit;
import datatypes : Location;


struct BagNode
{
    this(Location locale, uint f) 
    {
        this.locale = locale;
        this.f = f;
    }
    Location locale;  
    uint f;
}

void setName(Bag s, string n)  // DOES NOT WORK
{ s.name = n; 
  writeln("Setting name with s.name"); 
}
/+
void addTo(BagNode node, Bag s)  // add element to set
{
    writeln("s = ",s);
    
    s.aa[node.locale] = node.f;  // add to associative array, aa
    s.rbt.insert(node);          // add to red black tree, rbt
    writeln("s.aa.length = ", s.aa.length);
} 
+/

/+
void display(Bag s)
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
+/

// can be called with: if (element.isIn(set)) 

bool isIn(BagNode node, Bag s)
{
    return ((node.locale in s.aa) ? true : false);                    // in returns a uint* so
}                                                                     // needs ternary opertor

bool isNotIn(BagNode node, Bag s) { return (node.locale !in s.aa); }  // !in returns a bool

struct Bag
{   
    void addTo(BagNode node)  // add element to set
    {
        this.rbt.insert(node);          // add to red black tree, rbt
        this.aa[node.locale] = node.f;  // add to associative array, aa
    }
    /+
    bool isIn(BagNode node)
    {
        return ((node.locale in aa) ? true : false);
    }

    bool isNotIn(BagNode node) { return (node.locale !in aa); }

    bool isEmpty()
    {
        if (aa.empty)
        {
            if (rbt.empty)
                { return true; }  // both are empty
            writeln("aa is empty;  is not empty: out of sync");
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

    BagNode removeMin()
    {
        BagNode min = rbt.front; // get the front of the rbt which holds smallest f value
        rbt.removeFront;         // and remove it from the rbt
        aa.remove(min.locale);   // also remove the node from the associative array
        return min;
    }
     +/
    
    void display()
    {
        writeln("---------- Bag ", this.name, " ----------");
        writeln("Associative Array of bag has length ", this.aa.length);
        foreach(keyValuePair; this.aa.byKeyValue()) 
        {
            writeln("Key: ", keyValuePair.key, ", Value: ", keyValuePair.value);
        }
        writeln("red black tree of bag has length ", this.rbt.length);
        foreach(node; this.rbt) 
        {
            writeln("node: ", node);
        }
        writeln("-----------------------------------------");
    }
    
    
    void setName(string n)  // WORKS
    { this.name = n; 
      writeln("Setting name with this.name"); 
    }
    
    //  value[key] aa
    uint[Location] aa;  // associative array will hold the Location portion of the node

    auto rbt = new RedBlackTree!(BagNode, "a.f < b.f", true);    // true: allowDuplicates
    
    string name;
}


struct Sack
{   
    void addTo(BagNode node)  // add element to set
    {
        this.rbt.insert(node);          // add to red black tree, rbt
        this.aa[node.locale] = node.f;  // add to associative array, aa
    }
    /+

     +/
    
    void display()
    {
        writeln("Associative Array of bag has length ", this.aa.length);
        foreach(keyValuePair; this.aa.byKeyValue()) 
        {
            writeln("Key: ", keyValuePair.key, ", Value: ", keyValuePair.value);
        }
        writeln("red black tree of bag has length ", this.rbt.length);
        foreach(node; this.rbt) 
        {
            writeln("node: ", node);
        }
    }
    
    
    void setName(string n)  // WORKS
    { this.name = n; 
      writeln("Setting name with this.name"); 
    }
    
    //  value[key] aa
    uint[Location] aa;  // associative array will hold the Location portion of the node

    auto rbt = new RedBlackTree!(BagNode, "a.f < b.f", true);    // true: allowDuplicates
    
    string name;
}




/+
rdmd -main -unittest bag.d
+/


unittest
{

Bag open;
Sack closed;

open.setName("open");
closed.setName("closed");

writeln("open bag = ", open);
writeln("closed bag = ", closed);

open.display();
closed.display;


// Note: node make sure the key, "Location", is unique in all nodes below. This constraint
// will always exist in the A* algorithm



BagNode n1 = BagNode( Location(1,2),   33);  
BagNode n2 = BagNode( Location(3,4),   20);  // duplicate
BagNode n3 = BagNode( Location(3,6),    7);
BagNode n4 = BagNode( Location(3,8),   11);
BagNode n5 = BagNode( Location(9,10),  20);  // duplicate
BagNode n6 = BagNode( Location(11,12), 97);
BagNode n7 = BagNode( Location(13,14), 20);  // duplicate
BagNode n8 = BagNode( Location(15,16),  1);


open.addTo(n1);
open.addTo(n2);
open.addTo(n3);
open.addTo(n4);
closed.addTo(n5);
closed.addTo(n6);
closed.addTo(n7);
closed.addTo(n8);


open.display();
closed.display;

writeln("open bag = ", open);
writeln("closed bag = ", closed);
/+

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
    


BagNode n;
while ( s.isNotEmpty() ) 
{
    n = s.removeMin();
    writeln("removeMin returned ", n);
}

writeln("Bag should now be empty");
s.display;

writeln("s.isEmpty() = ", s.isEmpty());


BagNode n9a = BagNode( Location(15,16), 25);  // duplicate
BagNode n9b = BagNode( Location(15,16), 25);

assert(n9a == n9b);   // test opEquals
+/

}

