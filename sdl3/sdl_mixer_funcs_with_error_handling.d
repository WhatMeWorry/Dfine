

module sdl_mixer_funcs_with_error_handling;


//import std.stdio : writeln, write, writefln;
//import std.range : empty;  // for aa 
//import core.stdc.stdlib : exit;
import bindbc.sdl: MIX_Mixer, MIX_Audio, MIX_LoadAudio, MIX_CreateMixerDevice, 
       MIX_Track,
       SDL_GetError;

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


// In SDL3_mixer, the choice between MIX_PlayTrack and MIX_PlayAudio comes down to 
// whether you need precise, ongoing control over a sound or if you just want to trigger 
// a quick, unmanaged audio snippet.


/+ 
Fire-and-forget, Temporary track automatically pulled from a reusable pool,
plays static audio from start to finish, cannot be stopped, adjusted, or queried once started
Simple, one-off sounds that shouldn't be interrupted (e.g., "Game Over" narration)
+/

void playAudio(MIX_Mixer *mixer, MIX_Audio *audio)
{
    bool result = MIX_PlayAudio(mixer, audio);
    if (!result)
    {
        throw new Exception("MIX_PlayAudio failed: " ~ to!string(SDL_GetError()));
    }
}

/+
Managed, Track Lifetime: Explicitly created and controlled, Highly customizable 
via SDL_PropertiesID (loops, fading, offsets), (can pause, stop, change volume, or alter position),
Best used for: Background music, looping ambiance, and core gameplay effects
+/

void playTrack(MIX_Track *track, SDL_PropertiesID options)
{
    bool result = MIX_PlayTrack(track, options);
    if (!result)
    {
        throw new Exception("MIX_PlayTrack failed: " ~ to!string(SDL_GetError()));
    }
}



MIX_Track* createTrack(MIX_Mixer *mixer)
{
    MIX_Track *mixTrack = MIX_CreateTrack(mixer);
    if (mixTrack == null)
    {
        throw new Exception("MIX_CreateTrack failed: " ~ to!string(SDL_GetError()));
    }
    return mixTrack;
}


bool setTrackAudio(MIX_Track *track, MIX_Audio *audio)
{
    bool result = MIX_SetTrackAudio(track, audio);
    if (result == false)
    {
        throw new Exception("MIX_SetTrackAudio failed: " ~ to!string(SDL_GetError()));
    }
    return true;
}


bool trackPlaying(MIX_Track *track)
{
    // no mechanism to distinguish errors from non-playing tracks
    if (MIX_TrackPlaying(track))
        return true;
    else
        return false;
}


bool trackPaused(MIX_Track *track)
{
    if (MIX_TrackPaused(track))  // no mechanism to distinguish errors
        return true;
    else
        return false;
}


SDL_PropertiesID createProperties()
{
    SDL_PropertiesID props = SDL_CreateProperties();  // 0 means error
    if (props == 0)
    {
        throw new Exception("SDL_CreateProperties failed: " ~ to!string(SDL_GetError()));
    }
    return props;
}


bool setNumberProperty(SDL_PropertiesID props, string name, long value)
{
    bool result = SDL_SetNumberProperty(props, toStringz(name), value);
    if (result == false)
    {
        throw new Exception("SDL_SetNumberProperty failed: " ~ to!string(SDL_GetError()));
    }
    return true;
}



