
import std.container : RedBlackTree;
import std.stdio;
import honeycomb : Location;



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