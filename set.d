
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


module set;

//import std.container : RedBlackTree;
import std.container.rbtree;
import std.stdio;
import std.range : empty;  // for aa 

struct Locale   // holds a hex of a hexboard
{
    int r;  // row of hexboard
    int c;  // column of hexboard
}

struct NodeX
{
    this(Locale location, uint f) 
    {
        this.location = location;
        this.f = f;
    }
    Locale location;  
    uint f;
    
    bool opEquals(NodeX other) const 
    {
        return (this.location.r == other.location.r) && 
               (this.location.c == other.location.c) &&
               (this.f == other.f);
    }
}


// Set is a user created data type which acts as a container. This set holds 
// A* nodes which consist of a location and its cost.  The set provides four functions:
// put(i), i = getMin(), empty() or notEmpty().  Retrieving nodes will always
// result in the minimal cost node beign returned. In cases of ties, no order is 
// guaranteed.

struct Set
{
    //this() 
    //{
    //    writeln("empty constructor");
    //}
    
    void put(NodeX node)  // put node in both rbt and aa
    {                     // put node in both red black tree and associative array
        //openAA[s.location] = s.f;  // from old code
        aa[node.location] = node.f;
        // open.insert(s);           // from old code
        rbt.insert(node);
    }
    
    bool isEmpty()
    {
        if (aa.empty)
        {
            if (rbt.empty)
            {
                return true;
            }
        }
        return false;
    }

    
    NodeX getMin()
    {
        NodeX min = rbt.front;   // get the front of the rbt which holds smallest f value
        rbt.removeFront;         // and remove it from the rbt
        aa.remove(min.location); // also remove the node from the associative array
        return min;
    }
    
    void display()
    {
        foreach(keyValuePair; aa.byKeyValue()) 
        {
            writeln("Key: ", keyValuePair.key, ", Value: ", keyValuePair.value);
        }
        /+
        while(!rbt.empty)
        {
            NodeX e = rbt.front;
            writeln("e = ", e);
            rbt.removeFront;
        }
        +/
    }


    uint[Locale] aa;  // associative array will hold the Locale portion of the node

    auto rbt = new RedBlackTree!(NodeX, "a.f < b.f", true);    // true: allowDuplicates

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

