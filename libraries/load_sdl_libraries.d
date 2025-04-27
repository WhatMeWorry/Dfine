   
// If absent, the module name is taken to be the same name (stripped of path and
// extension) of the source file name.

module libraries.load_sdl_libraries;
 
import bindbc.sdl;

import sdl_ttf;
import sdl_image;
import bindbc.loader.sharedlib;

//import bindbc.sdl.ttf;
//import bindbc.sdl.image;

import std.stdio;
import std.file;
import std.path;
import std.string;

   struct Version 
    { 
        int compiled; 
        int linked; 
    } 


void load_sdl_libraries()
{
    //SDL_version v;
    
    writeln("Inside load_sdl_libraries");

    Version versions;

    versions.compiled = SDL_VERSION;    // hardcoded version from SDL headers
    
    writeln("versions.compiled = ", versions.compiled);
    
    //versions.linked = SDL_GetVersion(); // version reported by linked library
    
    //writeln("versions.linked = SDL_GetVersion");

    writefln("Compiled against SDL version: %d.%d.%d", 
           SDL_VERSIONNUM_MAJOR(versions.compiled), 
           SDL_VERSIONNUM_MINOR(versions.compiled), 
           SDL_VERSIONNUM_MICRO(versions.compiled));
           
    //writefln("Linked SDL version: %d.%d.%d", 
    //       SDL_VERSIONNUM_MAJOR(versions.linked),
    //       SDL_VERSIONNUM_MINOR(versions.linked),
    //       SDL_VERSIONNUM_MICRO(versions.linked));

   writeln("AFTER");
    
    
    

    //string appPath = dirName(thisExePath());

    string fullPathCurrentExecutable = thisExePath();

    writeln("fullPathCurrentExecutable = ", fullPathCurrentExecutable);

    string parentDirectoryOfThisPath = dirName(fullPathCurrentExecutable);

    writeln("parentDirectoryOfThisPath = ", parentDirectoryOfThisPath);

    string pathToLibs = parentDirectoryOfThisPath ~ `\` ~ "libraries" ~ `\`;
    writeln("pathToLibs = ", pathToLibs);


    string pathAndFileName = pathToLibs ~ "SDL3.dll";
    
    auto sdl = loadSDL(pathAndFileName.toStringz());
    writeln("loadSDL returned: ", sdl);
    
    //SDL_GetVersion(&v);
    //writeln("SDL version loaded is: ", v.major, ".", v.minor, ".", v.patch);


    auto sdlInit = SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS);
    writeln("SDL_Init returned (0 is success): ", sdlInit);


    pathAndFileName = pathToLibs ~ "SDL3_image.dll";
    auto image = loadSDLImage(pathAndFileName.toStringz());
    
    writeln("loadSDLImage returned: ", image); 
    //SDL_IMAGE_VERSION(&v);
    //writeln("Image version loaded is: ", v.major, ".", v.minor, ".", v.patch);
    
    /+
    There is no explicit IMG_Init() equivalent. The IMG_Load() function, which loads images, automatically initializes the necessary image loaders if they haven't already been initialized. This means you can directly use IMG_Load() to load images without needing to call a separate initialization function
    +/
    
    //auto imageInit = IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
    //writeln("IMG_init returned (0 is failure): ", imageInit);

    pathAndFileName = pathToLibs ~ "SDL3_ttf.dll";
    //auto ttf = loadSDLTTF(pathAndFileName.toStringz());
    //writeln("loadSDLTTF returned: ", ttf);
    
    //SDL_TTF_VERSION(&v);
    
    //writeln("TTF version loaded is: ", v.major, ".", v.minor, ".", v.patch);
    //auto ttfInit = TTF_Init();
    //writeln("TTF_Init returned: (0 is success): ", ttfInit);


    pathAndFileName = pathToLibs ~ "SDL3_mixer.dll";
    //auto mixer = loadSDLMixer(pathAndFileName.toStringz());
    //writeln("loadSDLMixer returned: ", mixer); 
    
    //SDL_MIXER_VERSION(&v);
    //writeln("MIXER version loaded is: ", v.major, "x", v.minor, ".", v.patch);
 
    //auto mixerInit = Mix_Init(MIX_INIT_FLAC | MIX_INIT_MOD | MIX_INIT_MP3 | MIX_INIT_OGG);
    //writeln("Mix_Init returned: ", mixerInit);

    //if( Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 1024 ) < 0 )
    {
        //writeln("SDL_mixer could not initialize! SDL_mixer Error: %s\n", Mix_GetError() );
    }

    pathAndFileName = pathToLibs ~ "SDL3_net.dll";
    //auto net = loadSDLNet(pathAndFileName.toStringz());
    //writeln("loadSDLNet returned: ", net);
}