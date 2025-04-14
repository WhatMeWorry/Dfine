
module hex;

import textures.texture : Texture;

/+ Longhand template declaration...

template MyStruct(T)
{
    struct MyStruct
    {
        T x;
        T y;
    }
}

struct MyStruct(T)
{
    T x;
    T y;
}
+/

struct Point2D(T)
{
    T x;
    T y;
}

struct HexPoints(U, V)   // these points are the same. just expressed in different coordinate systems
{
    Point2D!(U)[6] ndc;  // normalized device coordinates
    Point2D!(V)[6] sc;   // screen coordinates
}

struct Point(U, V)
{
    Point2D!(U) ndc;
    Point2D!(V) sc;
}



/+
           h   e_______________d              a, b, c, d, e, f = defining points of hex
               /               \
              /                 \             g = hex center
             /                   \
            /                     \           h = where texture overlay is positioned
          f/           g           \c
           \                       /
            \                     /
             \                   /
              \                 /
               \_______________/
               a               b
+/


struct Hex(W, X)
{
    HexPoints!(W, X) points;       // each hex has 6 vertices
    Point!(W, X)     center;       // each hex has one center
    
    Point!(W, X)     texturePoint; // each hex has conceptual rectangle overlay positioned at the                     
                                   // left corner as target rectangle for texture application   
    Texture[]        textures;     // each 
}



unittest
{
    import std;
    Hex!(float, int) hex;   // template instantiation
    writeln("hex = ", hex);
    hex.points.ndc[3].x = .377f;
    hex.center.ndc.x = 34.3453466666f;   
    writeln("hex = ", hex);       

}
