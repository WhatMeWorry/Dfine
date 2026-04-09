

// If absent, the module name is taken to be the same name (stripped of path and
// extension) of the source file name.

module libraries.load_sdl_libraries;
 
import std.stdio: writeln, write;
import std.string: toStringz;
import std.file: exists, thisExePath, isFile;
import std.path: dirName;
import std.conv: to;
import core.stdc.stdlib: exit;



import bindbc.sdl: 
    loadSDL,
	SDL_GetVersion,
	SDL_VERSIONNUM_MAJOR, SDL_VERSIONNUM_MINOR, SDL_VERSIONNUM_MICRO,
	SDL_Init, 
	SDL_INIT_AUDIO, SDL_INIT_VIDEO, SDL_INIT_EVENTS,
	SDL_Surface;
	
import bindbc.loader: LoadMsg;


/+
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
    string fullPathCurrentExe = thisExePath();  // this is dfi
    
    writeln("Function: ", __FUNCTION__);
    writeln("in module ", __MODULE__);
    writeln("at location ", fullPathCurrentExe);

    string parentDirOfThisPath = dirName(fullPathCurrentExe);

    string pathToLibs = parentDirOfThisPath ~ `\` ~ "libraries" ~ `\`;
  
    string pathAndFileName = pathToLibs ~ "SDL3_3_4_2.dll";    // 2,725 KB  version 3.4.2
	
    LoadMsg result;    // enum LoadMsg{ success, noLibrary, badLibrary,}  
  
    version(Windows)
    {
        writeln("Loading SDL dll file at:");
		writeln(pathAndFileName);
        result = loadSDL(pathAndFileName.toStringz());
        if(result != LoadMsg.success)
        {
            writeln("loadSDL with ", pathAndFileName, "failed");
			exit(-1);
        }
    }
    writeln("Loading SDL dynamic library succeeded");

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
        writeln("SDL_Init was successful");
    }
    else
    {
        writeln("SDL_Init failed");
		exit(-1);
    }	


  
    SDL_Surface *surface; 
	
    string pngImage = pathToImages ~ `\` ~ "earth1024x1024.png";
    string saveImage = pathToImages ~ `\` ~ "TEST.png";
    writeln("pngImage = ", pngImage);
    surface = SDL_LoadPNG(pngImage.toStringz);
    writeln("surface = ", surface);
    bool rett = SDL_SavePNG(surface, saveImage.toStringz);
    writeln("After SDL_SavePNG");
  	


    //===================================================================================
    //                       SDL IMAGE LIBRARY
    //===================================================================================


    // Global variable/instance used to check the loaded version
    //SDLImageSupport sdlImageSupport;

    /+   
    pathAndFileName = pathToLibs ~ "SDL3_image_3_3_4.dll";
 
    if (exists(pathAndFileName))  // returns true for files or directories
    {
        if (isFile(pathAndFileName)) // verify it is actually a file
        {   
            writeln("Found the SDL Image dll file at: ");
			writeln(pathAndFileName);
        }
    }
    writeln("trying to load SDL Image library: ", pathAndFileName);
    
    result = loadSDLImage(pathAndFileName.toStringz());
 
  	if (result != LoadMsg.success)
	{
        writeln("error loading SDL_image library");
        writeln("loadSDLImage returned ", result);
        exit(-1);
	}
	writeln("SDL_image loaded successfully");
    +/   
}