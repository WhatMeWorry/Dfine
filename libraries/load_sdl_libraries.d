   
// If absent, the module name is taken to be the same name (stripped of path and 
// extension) of the source file name.  

module libraries.load_sdl_libraries;
 
import bindbc.sdl;  

import std.stdio;
import std.file;
import std.path;
import std.string;

void load_sdl_libraries()
{
    SDL_version v;
	
    //string appPath = dirName(thisExePath());	
	
	string fullPathCurrentExecutable = thisExePath();
	
	writeln("fullPathCurrentExecutable = ", fullPathCurrentExecutable);
  
    string parentDirectoryOfThisPath = dirName(fullPathCurrentExecutable);
	
    writeln("parentDirectoryOfThisPath = ", parentDirectoryOfThisPath);
  
    string pathToLibs = parentDirectoryOfThisPath ~ `\` ~ "libraries" ~ `\`;
	writeln("pathToLibs = ", pathToLibs);
  
  
    string pathAndFileName = pathToLibs ~ "SDL2.dll";
    auto sdl = loadSDL(pathAndFileName.toStringz());
    writeln("loadSDL returned: ", sdl);
    SDL_GetVersion(&v);
    writeln("SDL version loaded is: ", v.major, ".", v.minor, ".", v.patch);
	

    auto sdlInit = SDL_Init(SDL_INIT_EVERYTHING);
    writeln("SDL_Init returned (0 is success): ", sdlInit);


	pathAndFileName = pathToLibs ~ "SDL2_image.dll";
    auto image = loadSDLImage(pathAndFileName.toStringz());
    writeln("loadSDLImage returned: ", image); 
    SDL_IMAGE_VERSION(&v);
    writeln("Image version loaded is: ", v.major, ".", v.minor, ".", v.patch);
    auto imageInit = IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
    writeln("IMG_init returned (0 is failure): ", imageInit);

	pathAndFileName = pathToLibs ~ "SDL2_ttf.dll";
    auto ttf = loadSDLTTF(pathAndFileName.toStringz());
    writeln("loadSDLTTF returned: ", ttf);
    SDL_TTF_VERSION(&v);
    writeln("TTF version loaded is: ", v.major, ".", v.minor, ".", v.patch);
    auto ttfInit = TTF_Init();
    writeln("TTF_Init returned: (0 is success): ", ttfInit);


	pathAndFileName = pathToLibs ~ "SDL2_mixer.dll";
    auto mixer = loadSDLMixer(pathAndFileName.toStringz());
    writeln("loadSDLMixer returned: ", mixer); 
    SDL_MIXER_VERSION(&v);
    writeln("MIXER version loaded is: ", v.major, "x", v.minor, ".", v.patch);
 
    auto mixerInit = Mix_Init(MIX_INIT_FLAC | MIX_INIT_MOD | MIX_INIT_MP3 | MIX_INIT_OGG);							
    writeln("Mix_Init returned: ", mixerInit);
  
    if( Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 1024 ) < 0 )
    {
        writeln("SDL_mixer could not initialize! SDL_mixer Error: %s\n", Mix_GetError() );
    }
	
	pathAndFileName = pathToLibs ~ "SDL2_net.dll";	
    auto net = loadSDLNet(pathAndFileName.toStringz());
    writeln("loadSDLNet returned: ", net);	
	
}