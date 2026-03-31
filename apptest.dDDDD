

module apptest;

import std.stdio;
import libraries.load_sdl_libraries; // (2) took care of undefined symbol (1) below. However, created 
                                     // lld-link: error: undefined symbol: _D9libraries18load_sdl_librariesQuFZv 
                                     // (3) sourcePaths "libraries" in dub.sdl solved the problem
import core.stdc.stdlib : exit;

int main()
{
    writeln("Hello main");
    
    load_sdl_libraries();  // (1) undefined symbol
    
    //SDL_Initialize();

    exit(-1);
 

    return 0;
}






