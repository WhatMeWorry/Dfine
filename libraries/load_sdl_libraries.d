

// If absent, the module name is taken to be the same name (stripped of path and
// extension) of the source file name.

module libraries.load_sdl_libraries;
 
import std.stdio: writeln;
import std.string: toStringz;
import std.file: exists, thisExePath, isFile;
import std.path: dirName;
import std.conv: to;
import core.stdc.stdlib: exit;

import bindbc.sdl: 
    loadSDL, 
	loadSDLImage, 
	SDL_GetVersion, 
	SDL_VERSIONNUM_MAJOR, SDL_VERSIONNUM_MINOR, SDL_VERSIONNUM_MICRO,
	SDL_Init, 
	SDL_INIT_AUDIO, SDL_INIT_VIDEO, SDL_INIT_EVENTS;
	
import bindbc.loader: LoadMsg;


/+
import bindbc.sdl :
    loadSDL,
    SDL_INIT_VIDEO,
    SDL_Init,
    SDL_Quit,
    sdlSupport,
    unloadSDL;
import bindbc.sdl.image :
    IMG_Init,
    IMG_INIT_PNG,
    IMG_Quit,
    loadSDLImage,
    sdlImageSupport,
    unloadSDLImage;
+/

void load_sdl_libraries()
{
    string fullPathCurrentExecutable = thisExePath();  // this is dfi
    
    writeln();
    //writeln("Function: ", __FUNCTION__, " in module ", __MODULE__, " at location ", fullPathCurrentExecutable);
    writeln();

    string parentDirectoryOfThisPath = dirName(fullPathCurrentExecutable);

    //writeln("parentDirectoryOfThisPath = ", parentDirectoryOfThisPath);

    string pathToLibs = parentDirectoryOfThisPath ~ `\` ~ "libraries" ~ `\`;
    //writeln("pathToLibs = ", pathToLibs);
    
    //string pathToImages = parentDirectoryOfThisPath ~ `\` ~ "images";
    //writeln("pathToImages = ", pathToImages);

    string pathAndFileName = pathToLibs ~ "SDL3_3_4_2.dll";    // 2,725 KB  version 3.4.2
    
    //writeln("trying to load SDL3 dynamic link library: ", pathAndFileName);


    /+   
    SDL_Surface *surface; 
    string pngImage = pathToImages ~ `\` ~ "earth1024x1024.png";
    string saveImage = pathToImages ~ `\` ~ "TEST.png";
    writeln("pngImage = ", pngImage);
    surface = SDL_LoadPNG(pngImage.toStringz);
    writeln("surface = ", surface);
    bool rett = SDL_SavePNG(surface, saveImage.toStringz);
    writeln("After SDL_SavePNG");
    +/
	
    LoadMsg ret;    // enum LoadMsg{ success, noLibrary, badLibrary,}  
    
    version(Windows)
    {
        writeln("Loading SDL dll file at:");
		writeln(pathAndFileName);
        ret = loadSDL(pathAndFileName.toStringz());
        if(ret != LoadMsg.success)
        {
            writeln("loadSDL with ", pathAndFileName, "failed");
        }
		//writeln("Searching for SDL on Windows");
    }
    
    // Error if SDL cannot be loaded
    if(ret == LoadMsg.noLibrary)
    {
        writeln("error no library found");    
    }
    if(ret == LoadMsg.badLibrary)
    {
        writeln("Error badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
    }

    int sdlversion = SDL_GetVersion();
    //writeln(sdlversion);
    string msg = "SDL version loaded was: " ~
                 to!string(SDL_VERSIONNUM_MAJOR(sdlversion)) ~ "." ~
                 to!string(SDL_VERSIONNUM_MINOR(sdlversion)) ~ "." ~
                 to!string(SDL_VERSIONNUM_MICRO(sdlversion));
    writeln(msg);  


    auto sdlInit = SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS);
	if (SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS))
    {
        writeln("SDL_Init was successful: ");
    }
    else
    {
        writeln("SDL_Init failed");
    }		


    //===================================================================================
    //                       SDL IMAGE LIBRARY
    //===================================================================================

/+
In the BindBC-SDL library, sdlImageSupport is defined within the sdl_image.d source file 
(specifically at source/sdl_image.d).  It serves as a global instance or an alias for the 
SDLImageSupport enum, which tracks the version of the SDL_image library that has been 
successfully loaded.

// Located in bindbc-sdl/source/bindbc/sdl/image/binddynamic.d or similar
// depending on the specific version/refactor of the library.
enum SDLImageSupport {
    noLibrary,
    badLibrary,
    v2_0_0,
    v2_0_1,
    // ... higher versions
}
+/

// Global variable/instance used to check the loaded version
//SDLImageSupport sdlImageSupport;
    writeln();

    pathAndFileName = pathToLibs ~ "SDL3_image.dll";
 

    if (exists(pathAndFileName))  // returns true for files or directories
    {
        if (isFile(pathAndFileName)) // verify it is actually a file
        {   
            writeln("Found the SDL Image dll file at: ");
			writeln(pathAndFileName);
        }
    }
	
	LoadMsg imgRet = loadSDLImage(pathAndFileName.toStringz());
	
	writeln("imgRet = ", imgRet);


//   https://code.dlang.org/packages/bindbc-sdl

/+
    loader.LoadMsg imageRet;
    writeln("trying to load SDL Image library: ", pathAndFileName);
    
    imageRet = loadSDLImage(pathAndFileName.toStringz());
    
    //auto image = loadSDLImage(pathAndFileName.toStringz());
    //writeln("loadSDLImage returned: ", image); 
  
  		if (imageRet != LoadMsg.success)
		{
			writeln("error loading SDL_image library");
			if (imageRet == LoadMsg.noLibrary)
			{
				writeln("error no SDL_image library found");
			}
			if (imageRet == LoadMsg.badLibrary)
			{
				writeln("Error badLibrary for SDL_image, missing symbols, " ~
						"perhaps an older or very new version is causing the problem?");
			}
		}
		else
		{
			writeln("SDL_image loaded successfully");
		}
+/ 

//   https://github.com/Nathan5563/quark  
/+
    //SDL_IMAGE_VERSION(&v);
    //writeln("Image version loaded is: ", v.major, ".", v.minor, ".", v.patch);
    
    /+
    There is no explicit IMG_Init() equivalent. The IMG_Load() function, which loads images,
    automatically initializes the necessary image loaders if they haven't already been initialized. 
    This means you can directly use IMG_Load() to load images without needing to call a separate 
    initialization function
    +/
    
    //auto imageInit = IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
    //writeln("IMG_init returned (0 is failure): ", imageInit);

    pathAndFileName = pathToLibs ~ "SDL3_ttf.dll";
    auto ttf = loadSDLTTF(pathAndFileName.toStringz());
    writeln("loadSDLTTF returned: ", ttf);
    
    //SDL_TTF_VERSION(&v);
    
    //writeln("TTF version loaded is: ", v.major, ".", v.minor, ".", v.patch);
    //auto ttfInit = TTF_Init();
    //writeln("TTF_Init returned: (0 is success): ", ttfInit);


    pathAndFileName = pathToLibs ~ "SDL3_mixer.dll";
    writeln("pathAndFileName for mixer = ", pathAndFileName);
    auto mixer = loadSDLMixer(pathAndFileName.toStringz());
    writeln("loadSDLMixer returned: ", mixer); 
    
    //SDL_MIXER_VERSION(&v);
    //writeln("MIXER version loaded is: ", v.major, "x", v.minor, ".", v.patch);
 
    //auto mixerInit = Mix_Init(MIX_INIT_FLAC | MIX_INIT_MOD | MIX_INIT_MP3 | MIX_INIT_OGG);
    //writeln("Mix_Init returned: ", mixerInit);

    //if( Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 1024 ) < 0 )
    {
        //writeln("SDL_mixer could not initialize! SDL_mixer Error: %s\n", Mix_GetError() );
    }

    pathAndFileName = pathToLibs ~ "SDL3_net.dll";
    auto net = loadSDLNet(pathAndFileName.toStringz());
    writeln("loadSDLNet returned: ", net);
+/
}