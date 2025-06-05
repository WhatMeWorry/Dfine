
module datatypes;

import bindbc.sdl;

//import textures.texture : Texture;

struct Rects
{
    SDL_FRect src;
    SDL_FRect dst;
} 

struct D2 { int w; int h; }
struct F2 { float w; float h; }
struct P2 { float x; float y; }


struct Slide
{
    SDL_Texture  *texture;
    P2           position;
    F2           size;
    int       alpha;  // 0-255
    double    angle;  // 0.0-360.0
}


struct Tile
{
    SDL_Surface  *surface;
    SDL_Texture  *texture;
    Rects rect;
    int       alpha;  // 0-255
    double    angle;  // 0.0-360.0
}

struct Location   // holds a hex's location on a hexboard
{
    int r;  // row of hexboard
    int c;  // column of hexboard
}

struct Active
{
    SDL_Window* window;
    int  windowID;
}

struct Status
{
    Active active;
    bool running;
    bool saveWindowToFile;
    bool leftMouseButton;
}

struct HexBoardSize(I)
{
    I rows;
    I cols;
}

struct ScreenSize(I)
{
    I width;
    I height;
}


struct SDL_Dimensions
{
    int w;
    int h;
}

struct Spot
{
    //@disable this();   // disables default constructor

    Location locale = Location(-1,-1);   // each spot needs to know where it is on the hexboard

    Location[6] neighbors = [Location(-1,-1), Location(-1,-1), 
                             Location(-1,-1), Location(-1,-1), 
                             Location(-1,-1), Location(-1,-1)];  // ignoring edges, each hex has 6 adjoining neighbors
    uint f;
    uint g;
    uint h;
    Location previous = Location(-1,-1);
    uint terrainCost;
}





