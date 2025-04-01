
// Bag is a user created data type used by the A* algorithm. This set holds 
// A* nodes which consist of a Location and its cost.  The set provides four functions:
// add(node), node = removeMin(), empty() or notEmpty(). Retrieving nodes will
// return the smallest cost node and remove it from the bag. In cases of ties, order 
// should be considered random.

module bag;

import std.container.rbtree : RedBlackTree;  // template
import std.stdio : writeln, write;
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

// in returns uint* use ternary operator to return bool

bool isIn(BagNode node, Bag b)
{
    return ((node.locale in b.aa) ? true : false);
}


bool isNotIn(BagNode node, Bag b)
{
    return ((node.locale !in b.aa) ? true : false);
}


class Bag
{
    enum duplicatesAllowed = true;

    this(string n)
    {
        name = n;             
        rbt = new RedBlackTree!(BagNode, "a.f < b.f", duplicatesAllowed); 
    }

    void add(BagNode node)
    {
        // in operator determines whether a given key exists in the associative array

        if (node.locale in aa)  // Is this really a problem?
        {
            writeln("This node: ", node, " is already in the ");
            writeln("associative array of bag ", this.name);
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

    bool isIn(BagNode node)
    {
        return ((node.locale in aa) ? true : false); // in returns uint*
    }                                                // use ternary operator
                                                     // to return bool
    bool isNotIn(BagNode node) 
    {
        return (node.locale !in aa);  // !in returns bool
    }

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

    bool isNotEmpty() 
    {
        return (!isEmpty);
    }

    void display()
    {
        writeln("------- Bag: ", name, " -------");
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
        writeln("------------------------------");
    }

    void displayTiny()
    {
        writeln("In displayTiny: Current State of Bag", this.name);
        if ( this.aa.length != this.rbt.length )
            { writeln("Bag ", this.name, " is out of sync");  exit(-1); }
        write("Bag ", this.name, " = ");
        foreach(node; rbt) 
        {   
            write("(", node.locale.r, ",", node.locale.c, ")", node.f, "  ");
        }
        writeln("");
    }

    string name;

    uint[Location] aa;  // associative array

    // https://forum.dlang.org/post/qajaymhfxjlmwmdnbktm@forum.dlang.org

    // "You would think that this would create a new instance every time that the 
    // struct is instantiated.
    // Unfortunately what it does in fact do, is create a RedBlackTree instance at 
    // compiletime, emit it into the binary, and assign its reference as the default 
    // initializer of the rbt field."

    // auto rbt = new RedBlackTree!(Node, "a.f < b.f", duplicatesAllowed);  // struct Bag

    RedBlackTree!(BagNode, "a.f < b.f", duplicatesAllowed) rbt;      // Class Bag pointer
}


/+
rdmd -main -unittest bag.d
+/

unittest
{
/+
Bag paper = new Bag("Brown");
Bag cloth = new Bag("Green");


paper.add( BagNode(Location(1,2),   33) );
paper.add( BagNode(Location(3,4),   20) );  // duplicate
paper.add( BagNode(Location(3,6),    7) );
paper.add( BagNode(Location(3,8),   11) );

cloth.add( BagNode(Location(9,10),  20) );  // duplicate
cloth.add( BagNode(Location(11,12), 97) );
cloth.add( BagNode(Location(13,14), 20) );  // duplicate
cloth.add( BagNode(Location(16,15),  1) );
cloth.add( BagNode(Location(16,16), 85) );


paper.display;
cloth.display;
+/


/+
Bag identical = new Bag("Entire_Node_Identical");

identical.add( BagNode(Location(1,2),   33) );
identical.add( BagNode(Location(1,2),   33) );
identical.add( BagNode(Location(1,2),   33) );

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

justf.add( BagNode(Location(1,2),   33) );
justf.add( BagNode(Location(11,23), 33) );
justf.add( BagNode(Location(23,11), 33) );

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


open.add( BagNode(Location(1,2),   33) );
open.add( BagNode(Location(3,4),   20) );  // duplicate
open.add( BagNode(Location(3,6),    7) );
open.add( BagNode(Location(3,8),   11) );
open.add( BagNode(Location(9,10),  20) );  // duplicate
open.add( BagNode(Location(11,12), 97) );
open.add( BagNode(Location(13,14), 20) );  // duplicate
open.add( BagNode(Location(16,15),  1) );
open.add( BagNode(Location(16,16), 85) );
// open.add( BagNode(Location(16,16), 85) );  // should fails which it does


open.display;
open.displayTiny;

while (open.isNotEmpty)
{
    BagNode min = open.removeMin();
    writeln("min = ", min);
}

if (open.isEmpty)
    writeln("open is empty");

close.display;

}


