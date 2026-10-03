

module sdl_ttf_funcs_with_error_handling;


//import std.stdio : writeln, write, writefln;
//import std.range : empty;  // for aa 
//import core.stdc.stdlib : exit;
import bindbc.sdl: TTF_Font, 
       MIX_Track,
       SDL_GetError;

import datatypes;
import useful_functions : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import breakup;
import magnify;
import std.stdio: writeln;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations

import helper_funcs : displayRect;


TTF_Font* openFont(string file, float fontSize)
{
    TTF_Font* font = TTF_OpenFont(file.toStringz, fontSize);
    writeln("font = ", font);
    if (!font) 
    {
        throw new Exception("TTF_OpenFont failed: " ~ to!string(SDL_GetError()));
    }
    return font;
}



SDL_Surface* renderText_Blended(TTF_Font *font, string text, size_t length, SDL_Color color)
{
    SDL_Surface* surface = TTF_RenderText_Blended(font, toStringz(text), length, color);
    if (surface == null)
    {
        throw new Exception("TTF_OpenFont failed: " ~ to!string(SDL_GetError()));
    }
    return surface;
}