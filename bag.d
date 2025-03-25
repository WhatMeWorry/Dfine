
module bag;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln;
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


class Bag
{
    enum allowDuplicates = true;

    this(string n)
    {
        name = n;             
        rbt = new RedBlackTree!(BagNode, "a.f < b.f", allowDuplicates); 
    }

    void addTo(BagNode node)
    {
        // in operator determines whether a given key exists in the associative array

        if (node.locale in aa) {
            writeln("This node: ", node, " is already in the associative array");
            exit(-1);
        }
    
        this.rbt.insert(node);          // add to red black tree, rbt
        this.aa[node.locale] = node.f;  // add to associative array, aa
    }

    BagNode removeMin()
    {
        BagNode min = rbt.front; // get the front of the rbt which holds smallest f value
        rbt.removeFront;         // and remove it from the rbt
        aa.remove(min.locale);   // also remove the node from the associative array
        return min;
    }
    
    /+
    bool isIn(BagNode node)
    {
        return ((node.locale in aa) ? true : false);
    }

    bool isNotIn(BagNode node) { return (node.locale !in aa); }
    +/
    
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

    
    
    
    void display()
    {
        writeln("======= Bag: ", name, " =======");
        writeln("associative array of ", this.name, " has length ", aa.length);
        foreach(keyValuePair; aa.byKeyValue()) 
        {
            writeln("Key: ", keyValuePair.key, ", Value: ", keyValuePair.value);
        }
        writeln("red black tree of ", this.name, " has length ", this.rbt.length);
        foreach(node; rbt) 
        {
            writeln("node: ", node);
        }
    }

    string name;

    uint[Location] aa;  // associative array

    // https://forum.dlang.org/post/qajaymhfxjlmwmdnbktm@forum.dlang.org

    // "You would think that this would create a new instance every time that the 
    // struct is instantiated.
    // Unfortunately what it does in fact do, is create a RedBlackTree instance at 
    // compiletime, emit it into the binary, and assign its reference as the default 
    // initializer of the rbt field."

    // auto rbt = new RedBlackTree!(Node, "a.f < b.f", allowDuplicates);

    RedBlackTree!(BagNode, "a.f < b.f", allowDuplicates) rbt;
}


/+
rdmd -main -unittest bag.d
+/

unittest
{
/+
Bag paper = new Bag("Brown");
Bag cloth = new Bag("Green");


paper.addTo( BagNode(Location(1,2),   33) );
paper.addTo( BagNode(Location(3,4),   20) );  // duplicate
paper.addTo( BagNode(Location(3,6),    7) );
paper.addTo( BagNode(Location(3,8),   11) );

cloth.addTo( BagNode(Location(9,10),  20) );  // duplicate
cloth.addTo( BagNode(Location(11,12), 97) );
cloth.addTo( BagNode(Location(13,14), 20) );  // duplicate
cloth.addTo( BagNode(Location(16,15),  1) );
cloth.addTo( BagNode(Location(16,16), 85) );


paper.display;
cloth.display;
+/


/+
Bag identical = new Bag("Entire_Node_Identical");

identical.addTo( BagNode(Location(1,2),   33) );
identical.addTo( BagNode(Location(1,2),   33) );
identical.addTo( BagNode(Location(1,2),   33) );

identical.display;
+/

/+                         INVALID!
using duplicates = true
======= Bag: Entire_Node_Identical =======
associative array of Entire_Node_Identical has length 1
Key: Location(1, 2), Value: 33
red black tree of Entire_Node_Identical has length 3
node: BagNode(Location(1, 2), 33)
node: BagNode(Location(1, 2), 33)
node: BagNode(Location(1, 2), 33)

                           MIGHT WORK?
using duplicates = false
======= Bag: Entire_Node_Identical =======
associative array of Investigate has length 1
Key: Location(1, 2), Value: 33
red black tree of Investigate has length 1
node: BagNode(Location(1, 2), 33)
+/



/+
Bag justf = new Bag("JustFCost");

justf.addTo( BagNode(Location(1,2),   33) );
justf.addTo( BagNode(Location(11,23), 33) );
justf.addTo( BagNode(Location(23,11), 33) );

justf.display;
+/

/+
using duplicates = true          WORKS
======= Bag: JustFCost =======
associative array of JustFCost has length 3
Key: Location(1, 2), Value: 33
Key: Location(11, 23), Value: 33
Key: Location(23, 11), Value: 33
red black tree of JustFCost has length 3
node: BagNode(Location(1, 2), 33)
node: BagNode(Location(11, 23), 33)
node: BagNode(Location(23, 11), 33)

using duplicates = false         INVALID  red black tree should have 
======= Bag: JustFCost =======            had all 3 nodes in container.
associative array of JustFCost has length 3
Key: Location(1, 2), Value: 33
Key: Location(11, 23), Value: 33
Key: Location(23, 11), Value: 33
red black tree of JustFCost has length 1
node: BagNode(Location(1, 2), 33)
+/

Bag open = new Bag("Open");
Bag close = new Bag("Closed");


open.addTo( BagNode(Location(1,2),   33) );
open.addTo( BagNode(Location(3,4),   20) );  // duplicate
open.addTo( BagNode(Location(3,6),    7) );
open.addTo( BagNode(Location(3,8),   11) );
open.addTo( BagNode(Location(9,10),  20) );  // duplicate
open.addTo( BagNode(Location(11,12), 97) );
open.addTo( BagNode(Location(13,14), 20) );  // duplicate
open.addTo( BagNode(Location(16,15),  1) );
open.addTo( BagNode(Location(16,16), 85) );
// open.addTo( BagNode(Location(16,16), 85) );  // should fails which it does


open.display;

while (open.isNotEmpty)
{
    BagNode min = open.removeMin();
    writeln("min = ", min);
}

if (open.isEmpty)
    writeln("open is empty");


close.display;












}


