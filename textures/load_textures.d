   

module textures.load_textures;
 
import bindbc.sdl;  

import std.stdio;
import std.file;
import std.path;
import std.string;
import app;   // For Globals
import core.stdc.stdlib;  // for exit()

enum Ids 
{ 
    solidRed,   // 0 
    solidBlue,  // 1
    solidGreen,   
    bricks,
    nops,
    end         // always leave this at end of the enum    
} 

struct TextureEntry 
{ 
    Ids id; 
    string fileName; 
    SDL_Texture *texture; 
}



TextureEntry[] load_textures(Globals g)
{
    if (g.sdl.renderer == null)
    {
        writeln("Must have renderer before we can load textures.");
        exit(1);
    }

    TextureEntry[] textures;
	
    // find the full path to the executable and from there the textures
    // are beneath it in the directory: textures	
        
    string complete = dirName(thisExePath()) ~ `\textures\`;	
	

    TextureEntry t;	
    t.id = Ids.solidRed; 
	t.fileName = "hexRed.png";
    t.texture = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));	
	if(t.texture == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;
    
    t.id = Ids.solidBlue; 
	t.fileName = "hexBlue.png";
    t.texture = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));	
	if(t.texture == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;

    t.id = Ids.solidGreen; 
	t.fileName = "hexGreen.png";
    t.texture = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));	
	if(t.texture == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;
 
    t.id = Ids.bricks; 
	t.fileName = "hexBricks.png";
    t.texture = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));	
	if(t.texture == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;
	
    t.id = Ids.nops; 
	t.fileName = "hexNops.png";
    t.texture = IMG_LoadTexture(g.sdl.renderer, toStringz(complete ~ t.fileName));	
	if(t.texture == null ) { writeln( "Unable to load image ", complete ~ t.fileName); exit(1); }
    textures ~= t;	
	
    foreach(texEntry; textures)
    {
        writeln("texEntry = ", texEntry);
    }

    return textures;
	
}