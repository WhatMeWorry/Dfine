
module datatypes;

import bindbc.sdl;

//import textures.texture : Texture;


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





