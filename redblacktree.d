
import std.container : RedBlackTree;
import std.stdio;

struct Location {
    int x;  
    int y;
}

struct Node{
    this(Location loc, uint f) {
        this.loc = loc;
        this.f = f;
    }
    Location loc;  
    uint f;
}



//int main()
int placeHolder() 
{
auto priorQ = new RedBlackTree!(Node, "a.f < b.f", true); // true: allowDuplicates

Node n1 = Node( Location(1,2), 33);
Node n2 = Node( Location(3,4), 20);
Node n3 = Node( Location(5,6), 7);
Node n4 = Node( Location(7,8), 1);
Node n5 = Node( Location(9,10), 20);
Node current;

priorQ.insert(n3);
priorQ.insert(n2);
priorQ.insert(n1);
priorQ.insert(n4);
priorQ.insert(n5);

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

while(!priorQ.empty) 
{
    current = priorQ.front;
    priorQ.removeFront;
    writeln("current = ", current);
}


return 0;
}