

module textures.texture;

import bindbc.sdl;  

import std.stdio;
import std.file;
import std.path;
import std.string;
import app;   // For Globals
import core.stdc.stdlib;  // for exit()

import windows.simple_directmedia_layer;

enum Ids 
{ 
    solidRed,   // 0 
    solidBlue,  // 1
    solidGreen,
    solidBrown,
    solidBlack,
    solidWhite,
    blackDot,
    //bricks,
    //nops,
    none = -1,
    end         // always leave this at end of the enum    
} 

struct Texture 
{ 
    Ids id;
    string fileName;
    SDL_Texture *ptr;
}



Texture[] load_textures(Globals g)
{
    if (g.sdl.renderer == null)
    {
        writeln("Must have renderer before we can load textures.");
        exit(1);
    }

    Texture[] textures;

    // find the full path to the executable and from there the textures
    // are beneath it in the directory: textures
        
    string complete = dirName(thisExePath()) ~ `\textures\`;


    Texture t;
    t.id = Ids.solidRed; 
    t.fileName = "hexRed.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;
    
    t.id = Ids.solidBlue; 
    t.fileName = "hexBlue.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.solidGreen; 
    t.fileName = "hexGreen.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.solidBrown; 
    t.fileName = "hexBrown.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.solidBlack; 
    t.fileName = "hexBlack.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.solidWhite; 
    t.fileName = "hexWhite.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.blackDot; 
    t.fileName = "blackDot.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

/+
    t.id = Ids.bricks; 
    t.fileName = "hexBricks.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.nops; 
    t.fileName = "hexNops.png";
    t.ptr = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));
    if(t.ptr == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;
+/
    foreach(texEntry; textures)
    {
        //writeln("texEntry = ", texEntry);
    }

    return textures;

}