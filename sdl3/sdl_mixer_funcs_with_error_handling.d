

module sdl_mixer_funcs_with_error_handling;


//import std.stdio : writeln, write, writefln;
//import std.range : empty;  // for aa 
//import core.stdc.stdlib : exit;
import bindbc.sdl: MIX_Mixer, MIX_Audio, MIX_LoadAudio, MIX_CreateMixerDevice, SDL_GetError;

import datatypes;
import useful_functions : writeAndPause;
import core.stdc.stdio : printf;
import hexmath : isOdd, isEven;
import breakup;
import magnify;

import std.string : toStringz, fromStringz;  // converts D string to C string
import std.conv : to;           // to!string(c_string)  converts C string to D string 

import bindbc.sdl;  // SDL_* all remaining declarations

import helper_funcs : displayRect;


MIX_Mixer* createMixerDevice(SDL_AudioDeviceID devID)
{
    MIX_Mixer *mixer = MIX_CreateMixerDevice(devID, null);
    if (!mixer) 
    {
        throw new Exception("MIX_CreateMixerDevice failed: " ~ to!string(SDL_GetError()));
    }
    return mixer;
}


MIX_Audio* loadAudio(MIX_Mixer* mixer, string audioFilePath)
{
    //MIX_Audio *wavAudio = MIX_LoadAudio(mixer, toStringz(pathToAudioFile), false);

    MIX_Audio *audio = MIX_LoadAudio(mixer, toStringz(audioFilePath), false);
    if (!audio) 
    {
        throw new Exception("MIX_LoadAudio failed: " ~ to!string(SDL_GetError()));
    }
    return audio;
}


bool playAudio(MIX_Mixer *mixer, MIX_Audio *audio)
{
    bool result = MIX_PlayAudio(mixer, audio);
    if (!result)
    {
        throw new Exception("MIX_PlayAudio failed: " ~ to!string(SDL_GetError()));
    }
    return true;
}

