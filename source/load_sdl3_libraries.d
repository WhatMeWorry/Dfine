

// If absent, the module name is taken to be the same name (stripped of path and
// extension) of the source file name.

module libraries.load_sdl3_libraries;


import std.stdio: writeln, write;
import bindbc.sdl: loadSDL, loadSDLImage, loadSDLMixer, loadSDLTTF, loadSDLNet,
                   SDL_GetVersion, IMG_Version, MIX_Version, TTF_Version, NET_Version,
                   SDL_VERSIONNUM_MAJOR, SDL_VERSIONNUM_MINOR, SDL_VERSIONNUM_MICRO,
                   SDL_INIT_VIDEO, SDL_Init, SDL_Quit;

import bindbc.loader: LoadMsg;

version (Windows)
{
    import bindbc.loader: setCustomLoaderSearchPath;  // function only implemented for Windows
}

import loader = bindbc.loader.sharedlib;

import std.file: thisExePath;
import std.path: dirName;
import std.process: environment;
import std.string: toStringz, fromStringz;


import core.stdc.stdlib : exit;

// satellite libraries of SDL3 core
// The auxillary libraries will only work if SDL3 core is loaded. So this is not optional

enum SDL3Flags 
{
    SDL3_Core  = 1 << 0,  // 00000001 (1)
    SDL3_Image = 1 << 1,  // 00000010 (2)
    SDL3_Mixer = 1 << 2,  // 00000100 (4)
    SDL3_ttf =   1 << 3,  // 00001000 (8)
    SDL3_Net =   1 << 4,  // 00010000 (16)
    UNUSED_A =   1 << 5,  // 00100000
    UNUSED_B =   1 << 6,  // 01000000
    UNUSED_C =   1 << 7,  // 10000000
}

alias SDL3_CORE  = SDL3Flags.SDL3_Core;
alias SDL3_IMAGE = SDL3Flags.SDL3_Image;
alias SDL3_MIXER = SDL3Flags.SDL3_Mixer;
alias SDL3_TTF   = SDL3Flags.SDL3_ttf;
alias SDL3_NET   = SDL3Flags.SDL3_Net;

SDL3Flags SDL3_ALL = (SDL3_CORE | SDL3_IMAGE | SDL3_MIXER | SDL3_TTF | SDL3_NET);


void load_sdl3_libraries(SDL3Flags chosen)
{
    auto SDL3_Core_selected = (chosen & SDL3_CORE);
    auto SDL3_Image_selected = (chosen & SDL3_IMAGE);    
    auto SDL3_Mixer_selected = (chosen & SDL3_MIXER); 
    auto SDL3_Net_selected = (chosen & SDL3_NET); 
    auto SDL3_Ttf_selected = (chosen & SDL3_TTF);        

    if (!SDL3_Core_selected)
    {
        writeln("SDL3_CORE library is required for any of the auxillary libraries (Image, Mixer, TTF, Net) to work");
        exit(-1);
    }

    // If you are using a modern version of BindBC, you should use LoadMsg from the loader
    // library instead of SDLSupport. The load functions now returns a LoadMsg enum value of 
    // success, noLibrary, or badLibrary

    string exeNameAndFullPath;
    string pathToLibraries;
    string parentDirectoryOfExe;
    string lib;
    
    exeNameAndFullPath = thisExePath(); // return the full path of the current executable
                                        // this executable is (by default) the same as its package name 
                                        // or else specified by the targetName attribute in dub.sdl 

    parentDirectoryOfExe = dirName(exeNameAndFullPath);  // returns the parent directory of path 

    version (Windows)
    {   /+
        pathToLibraries = parentDirectoryOfExe ~ `\libraries\`;  // This works.
        string currentEnvPATH = environment.get("PATH");         // get the existing PATH variable and
        environment["PATH"] = currentEnvPATH ~ pathToLibraries;  // append to PATH environment variable
    
        string newEnvPATH = environment.get("PATH");
        foreach (path; newEnvPATH.splitter(';'))
        {
            writeln(path);
        }
        +/
        
        setCustomLoaderSearchPath("libraries");  // This works and is more elegant than altering PATH
    }

    version (linux)
    {
        pathToLibraries = parentDirectoryOfExe ~ `/libraries/`;	    
    }


    //==============================================================================================
    //==================================== SDL3 Core ===============================================
    //==============================================================================================

    version (Windows)
    {
        LoadMsg sdlStatus = loadSDL("SDL3.dll");
    }

    version (linux)
    {
        lib = pathToLibraries ~ "libSDL3.so.0.4.16";
        LoadMsg sdlStatus = loadSDL(lib.toStringz);
    }

    if (sdlStatus == LoadMsg.success) 
    {
        // const int compiled = SDL_VERSION;            // hardcoded number from SDL headers
        const int linkedVersion = SDL_GetVersion();    // reported by linked SDL library

        writeln("SDL3 version: ", SDL_VERSIONNUM_MAJOR(linkedVersion), ".", 
                                  SDL_VERSIONNUM_MINOR(linkedVersion), ".", 
                                  SDL_VERSIONNUM_MICRO(linkedVersion),
                                  " shared library successfully loaded");
    }
    else
    {
        foreach(info; loader.errors)
        {
            writeln("Error:", fromStringz(info.error), " - ", fromStringz(info.message));
        }
    }


    //=============================================================================================
    //======================================= SDL3 Image ==========================================
    //=============================================================================================

    if (SDL3_Image_selected)
    {
        version (Windows)
        {
            LoadMsg imgStatus = loadSDLImage("SDL3_image.dll");  // This works
        }
 
        version (linux)
        {
            lib = pathToLibraries ~ "libSDL3_image.so.0.4.4";
            LoadMsg imgStatus = loadSDLImage(lib.toStringz);
        }
 
        if (imgStatus == LoadMsg.success) 
        {
            int imageVersion = IMG_Version();  // reported by linked SDL Image Library

            writeln("SDL3_Image version ", SDL_VERSIONNUM_MAJOR(imageVersion), ".", 
                                           SDL_VERSIONNUM_MINOR(imageVersion), ".", 
                                           SDL_VERSIONNUM_MICRO(imageVersion),
                                           " shared library successfully loaded");
        }
        else
        {
            foreach(info; loader.errors)
            {
                writeln("Error:", fromStringz(info.error), " - ", fromStringz(info.message));
            }
        } 
    }

    //==============================================================================================
    //====================================== SDL Mixer =============================================
    //==============================================================================================
    
    if (SDL3_Mixer_selected)
    {
        version (Windows)
        {
            LoadMsg mixStatus = loadSDLMixer("SDL3_mixer.dll");
        }
    
        version (linux)
        {
            lib = pathToLibraries ~ "libSDL3_mixer.so.0.2.4";    
            LoadMsg mixStatus = loadSDLMixer(lib.toStringz);
        }

        if (mixStatus == LoadMsg.success) 
        {
            int mixVersion = MIX_Version();  // this gets the version loaded at runtime

            writeln("SDL3_Mixer version ", SDL_VERSIONNUM_MAJOR(mixVersion), ".", 
                                           SDL_VERSIONNUM_MINOR(mixVersion), ".", 
                                           SDL_VERSIONNUM_MICRO(mixVersion),
                                           " shared library successfully loaded");
        }
        else
        {
            foreach(info; loader.errors)
            {
                writeln("Error:", fromStringz(info.error), " - ", fromStringz(info.message));
            }
        }
    }

    //==============================================================================================
    //==================================== SDL Net =================================================
    //==============================================================================================

    if (SDL3_Net_selected)
    {
        version (Windows)
        {
            LoadMsg netStatus = loadSDLNet("SDL3_net.dll");
        }
    
        version (linux)
        {
            lib = pathToLibraries ~ "libSDL3_net.so.0.2.0";	
            LoadMsg netStatus = loadSDLNet(lib.toStringz);
        }

        if (netStatus == LoadMsg.success) 
        {
            int netVersion = NET_Version();  // this gets the version loaded and running at runtime

            writeln("SDL3_NET version ", SDL_VERSIONNUM_MAJOR(netVersion), ".", 
                                         SDL_VERSIONNUM_MINOR(netVersion), ".", 
                                         SDL_VERSIONNUM_MICRO(netVersion),
                                         " shared library successfully loaded"); 
        }
        else
        {
            foreach(info; loader.errors)
            {
                writeln("Error:", fromStringz(info.error), " - ", fromStringz(info.message));
            }
        } 
    }

    //==============================================================================================
    //===================================== SDL TTF ================================================
    //==============================================================================================
    
    if (SDL3_Ttf_selected)
    {
        version (Windows)
        {
            LoadMsg ttfStatus = loadSDLTTF("SDL3_ttf.dll");
        }
    
        version (linux)
        {
            lib = pathToLibraries ~ "libSDL3_ttf.so.0.2.2";			
            LoadMsg ttfStatus = loadSDLTTF(lib.toStringz);
        }

        if (ttfStatus == LoadMsg.success) 
        {
            int ttfVersion = TTF_Version();  // this gets the version loaded and running at runtime

            writeln("SDL3_TTF version ", SDL_VERSIONNUM_MAJOR(ttfVersion), ".", 
                                         SDL_VERSIONNUM_MINOR(ttfVersion), ".", 
                                         SDL_VERSIONNUM_MICRO(ttfVersion),
                                         " shared library successfully loaded"); 
        }
        else
        {
            foreach(info; loader.errors)
            {
                writeln("Error:", fromStringz(info.error), " - ", fromStringz(info.message));
            }
        } 
    }


	/+
	> dub build
    Starting Performing "debug" build using /usr/bin/dmd for x86_64.
    Building bindbc-common 1.0.5: building configuration [noBC]
    Building bindbc-loader 1.1.5: building configuration [noBC]
    Building bindbc-sdl 2.4.2: building configuration [dynamic]
	
Error: undefined identifier `SDL_PropertiesID`
	
../../../.dub/packages/bindbc-sdl/2.4.2/bindbc-sdl/source/sdl_net.d-mixin-73(87,101): Error: undefined identifier `SDL_PropertiesID`
    alias _pNET_CreateClient = extern(C) NET_StreamSocket* function(NET_Address* address, ushort port, SDL_PropertiesID props);


file
./sdl/properties.d:alias SDL_PropertiesID = uint;



both the ../sdl_ttf.d: and /sdl_mixer.d have this import:

import sdl.properties: SDL_PropertiesID;
+/


/+ In order to get SDL Net to be loaded successfully, add the following line (after the line:  static if(sdlNetVersion):
   import sdl.properties: SDL_PropertiesID;  // ADDED MYSELF
   in file:
   \home\<user>\.dub\packages\bindbc-sdl\2.4.2\bindbc-sdl\source\sdl_net.d
+/


}