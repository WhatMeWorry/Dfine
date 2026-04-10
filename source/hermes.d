
module hermes;

import std.stdio : writeln;

struct Location
{
    int x;
    int y;
}

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

bool isIn(BagNode node, Bag b)
{
    writeln("isIn outside class. BagNode, Bag");
    return ((node.locale in b.aa) ? true : false);
}

bool isIn(Bag b, BagNode node)  
{
    writeln("isIn outside class. Bag, BagNode");  // Well, it compiles.  
    return ((node.locale in b.aa) ? true : false);
}

class Bag
{
    this(string n) { name = n; }

    void add(BagNode node)
    {
        aa[node.locale] = node.f;
    }

    bool isIn(BagNode node) 
    {
        writeln("isIn inside class.BagNode");
        return ((node.locale in aa) ? true : false); 
    }

    string name;
    uint[Location] aa;  // associative array
}


/+
rdmd -main -unittest hermes.d
+/

unittest
{
Bag plastic = new Bag("Lady");

BagNode b1 = BagNode(Location(1,2), 33);

plastic.add( b1 );

if (plastic.isIn(b1))  // method inside class
    writeln("item, ", b1, " is in the ", plastic.name, " Bag");
writeln();

if (b1.isIn(plastic))  // nethod outside of class
    writeln("item, ", b1, " is in the ", plastic.name, " Bag");
writeln();

if (isIn(plastic, b1)) // 
    writeln("item, ", b1, " is in the ", plastic.name, " Bag");
writeln();

if (isIn(b1, plastic)) // 
    writeln("item, ", b1, " is in the ", plastic.name, " Bag");

}


