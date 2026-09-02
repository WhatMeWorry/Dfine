

module app;

import std.stdio;
import bindbc.sdl;  
import bindbc.loader;
import loader = bindbc.loader.sharedlib;  // from Mike Shah working repo

// don't need a bindbc.sdl.image import
    


import std.string: toStringz;
import std.file: exists;

import libraries.load_sdl_libraries; // (2) took care of undefined symbol (1) below. However, created 
                                     // lld-link: error: undefined symbol: _D9libraries18load_sdl_librariesQuFZv 
                                     // (3) sourcePaths "libraries" in dub.sdl solved the problem
import core.stdc.stdlib : exit;

int main()
{

	
	//import loader = bindbc.loader.sharedlib;
    
    // If you are using a modern version of BindBC, you should use LoadMsg from the loader
    // library instead of checking against SDLSupport values like noLibrary or badLibrary
    // The load function now returns a LoadMsg enum value

    // https://www.youtube.com/watch?v=GXntBf0Xns8

    LoadMsg sdlStatus = LoadMsg.noLibrary;  // initialized       enum LoadMsg{ success, noLibrary, badLibrary} 

    version (linux)
    {
        sdlStatus = loadSDL();  // default version probably from the package manager

        // Pass the explicit filename of your shared library
		
        //string libPath = "/usr/lib/libSDL3.so.0.4.14";  // this works! by getting where the linux package mgr installed it

        //string libPath = "/usr/lib/libSDL3.so";   // this also works 

        // string libPath = "/usr/lib/libSDL3.so.0";   // this works too

        //string libPath = "./libraries/libSDL3.so.0.4.14";  // this gets the shared library stored within the project itself. 
                                                                            // It's relative to the root of the project. hence the dot.

        // sdlStatus = loadSDL(libPath.ptr);   // explicit
    }
    
    version (Windows)
    {
        import std.file: exists, thisExePath, isFile;
        string fullPathOfExe = thisExePath();  // this executable is by default the same as its package name 
                                               // or else specified by the targetName attribute in dub.sdl 
    
        writeln("Function: ", __FUNCTION__);
        writeln("in module ", __MODULE__);
        writeln("at location ", fullPathOfExe);

        import std.path: dirName;
        string parentDirOfThisPath = dirName(fullPathOfExe);

        string pathToLibs = parentDirOfThisPath ~ `\` ~ "libraries" ~ `\`;
  
        string pathAndFileName = pathToLibs ~ "SDL3_3_4_2.dll";    // 2,725 KB  version 3.4.2
    
        writeln("pathAndFileName = ", pathAndFileName);
        import std.string: toStringz;
        //sdlStatus = loadSDL(pathAndFileName.toStringz());
        sdlStatus = loadSDL(pathAndFileName.ptr);
    }
   

    if (sdlStatus == LoadMsg.success) 
    {
        writeln("SDL3 shared library successfully loaded");

        const int linkedVersion = SDL_GetVersion();    // reported by linked SDL library

        writeln("SDL3-", SDL_VERSIONNUM_MAJOR(linkedVersion), ".", 
                         SDL_VERSIONNUM_MINOR(linkedVersion), ".", 
                         SDL_VERSIONNUM_MICRO(linkedVersion));
    }
    else if ( sdlStatus == LoadMsg.noLibrary) 
    {
        writeln("The SDL3 shared library (.dll or .so) could not be found");
        exit(-1);
    } 
    else if (sdlStatus == LoadMsg.badLibrary) 
    {
       writeln("One or more symbols failed to load (version mismatch)");
       exit(-1);
    }



    //===================================================================================
    //                       SDL IMAGE LIBRARY
    //===================================================================================
  
    LoadMsg imgStatus = LoadMsg.noLibrary;
  
    version (Windows)
	{
        pathAndFileName = pathToLibs ~ "SDL3_image_3_4_4.dll";
 
        if (exists(pathAndFileName))  // returns true for files or directories
        {
            if (isFile(pathAndFileName)) // verify it is actually a file
            {   
                writeln("Found the SDL Image dll file at: ");
			    writeln(pathAndFileName);
            }
        }
        writeln("trying to load SDL Image library: ", pathAndFileName);
    
        imgStatus = loadSDLImage(pathAndFileName.ptr);
    }     
 
    version (linux)
    {
        imgStatus = loadSDLImage();  // get from package manager???  
		 
        string pathAndFileName = "./libraries/" ~ "libSDL3_image.so.0.4.4"; 
		 writeln("pathAndFileName = ", pathAndFileName);
		 if (exists(pathAndFileName))
		     writeln("FILE EXISTS");
		 
        imgStatus = loadSDLImage(pathAndFileName.toStringz); 
		
    }
 
 
    if (imgStatus == LoadMsg.success) 
    {
        writeln("SDL3_Image shared library successfully loaded");

        int  imageVersion = IMG_Version();            // reported by linked SDL Image Library
		
        writeln("SDL3_Image-", SDL_VERSIONNUM_MAJOR(imageVersion), ".", 
                                           SDL_VERSIONNUM_MINOR(imageVersion), ".", 
                                           SDL_VERSIONNUM_MICRO(imageVersion));
    }
    else if (imgStatus == LoadMsg.noLibrary) 
    {
        writeln("The SDL3_Image shared library (.dll or .so) could not be found");
        exit(-1);
    } 
    else if (imgStatus == LoadMsg.badLibrary) 
    {
       writeln("One or more symbols failed to load (version mismatch)");
       exit(-1);
    }
  

/+  
how to build the libSDL3_image.so
   
tar -xf SDL3_image-3.4.4.tar.gz
cd SDL3_image-3.4.4
mkdir build && cd build
cmake .. -DBUILD_SHARED_LIBS=ON
make
sudo make install

-- Installing: /usr/local/lib/libSDL3_image.so.0.4.4
-- Installing: /usr/local/lib/libSDL3_image.so.0
-- Installing: /usr/local/lib/libSDL3_image.so
+/


//===================================================================================
//                       SDL MIXER LIBRARY
//===================================================================================

    LoadMsg mixStatus = LoadMsg.noLibrary;

    version (linux)
    {
        //Status = loadSDLMixer();  // get from package manager???  
		 
        pathAndFileName = "./libraries/" ~ "libSDL3_mixer.so.0.2.4"; 
		writeln("pathAndFileName = ", pathAndFileName);
		if (exists(pathAndFileName))
        {
		    writeln("FILE EXISTS");
        }
		
        mixStatus = loadSDLMixer(pathAndFileName.toStringz);
		
    }
 
    version (Windows)
    {
        //Status = loadSDLMixer();  // get from package manager???  
		 
        pathAndFileName = "./libraries/" ~ "libSDL3_mixer.so.0.2.4"; 
		writeln("pathAndFileName = ", pathAndFileName);
		if (exists(pathAndFileName))
        {
		    writeln("FILE EXISTS");
        }
		
        mixStatus = loadSDLMixer(pathAndFileName.toStringz);
		
    }
 
 
 
 
 
 
 
 
 
 
 
 
 
    if (mixStatus == LoadMsg.success) 
    {
        writeln("SDL Mixer shared library successfully loaded");		
	
        // Get the version running at runtime
		//int mixVersion = MIX_Version();
		
        //printf("Running with SDL_mixer version: %d.%d.%d\n", linked->major, linked->minor, linked->patch);
		
		//writeln("mixVersion = ", mixVersion);		
		
		/+
        writeln("SDL3_Mixer-", SDL_VERSIONNUM_MAJOR(mixVersion), ".", 
                               SDL_VERSIONNUM_MINOR(mixVersion), ".", 
                               SDL_VERSIONNUM_MICRO(mixVersion));   +/
		


    }
    else if (mixStatus == LoadMsg.noLibrary) 
    {
        writeln("The SDL3_Image shared library (.dll or .so) could not be found");
        exit(-1);
    } 
    else if (mixStatus == LoadMsg.badLibrary) 
    {
       writeln("One or more symbols failed to load (version mismatch)");
       exit(-1);
    }













    // Now you can safely call SDL3 functions
    if (SDL_Init(SDL_INIT_VIDEO)) 
    {
        writeln("Quitting program");
        
        // Your SDL3 code here...

        SDL_Quit();
    }

	
	/+
Once installed, the shared object files are placed in your system's standard library directory. 
You can find the exact path to libSDL3.so by running:bash
find /usr/lib/ -name "libSDL3.so*"	
	
find /usr/lib/ -name "libSDL3.so*"

/usr/lib/libSDL3.so.0.4.14
/usr/lib/libSDL3.so
/usr/lib/libSDL3.so.0
	
    libSDL3.so.0.4.14   is the Real Name (the actual binary file containing the compiled code and data). The numbers 0.4.14 represent 
                                 the major, minor, and patch release versions of the library.

    libSDL3.so.0   is the SONAME (Shared Object Name). It is typically a symbolic link pointing to the real file 
	                      (libSDL3.so.0.4.14), used by the system at runtime to guarantee binary interface (ABI) compatibility
	
	libSDL3.so  is the Linker Name (or development name). It is a symbolic link without version numbers, used by compilers and linkers 
	                  (gcc, ld) when you compile a new program.
	
	+/
	
	
	
	bool ok = SDL_Init(SDL_INIT_VIDEO);
	if (!ok)
    {
	    writeln("SDL_Init failed");
    }

//    load_sdl_libraries();  // (1) undefined symbol
    
    //SDL_Initialize();

    //exit(-1);
	
 	//SDL_Quit();

    return 0;
}



















/+

/// Simple example of a SDL application that creates multiple windows

/+
https://wiki.libsdl.org/SDL2/MigrationGuide#Overview_of_new_features

For 2D graphics, SDL 1.2 offered a concept called "surfaces," which were memory buffers of pixels.
In SDL 2.0, Surfaces are always in system RAM now, and are always operated on by the CPU, so we want to get away from there.
What you want, if possible, is the new SDL_Texture.

There are very few reasons for using SDL_Surfaces for rendering these days. 
SDL_Renderer and its SDL_Texture is a much better performing choice if you don't need CPU side 
access to individual pixels.

What’s the difference between Texture and Surface?

Surface is stored in RAM and drawing is performed on the CPU. Texture is stored in Video RAM (GPU RAM) and drawing is 
performed by the GPU. If you need best performance, use textures only, because GPU can render things million times 
faster than the CPU.

you don’t need to use surfaces at all. You can create texture using the SDL_CreateTexture 17 function and render anything 
on it. If you need to load image e.g. from file and store it in the form of texture, you can do it via IMG_LoadTexture. 
SDL will do everything for you internally.


Should each hex board have an associated windows/screen???  YES. That's what we will do.
+/

module app;


import utilities.sdl_timing;
import utilities.displayinfo : display_info;
import utilities.save_window_to_file;
import hexboard;
import select_hex;
import hexmath;
import hex;
import windows.simple_directmedia_layer;
import libraries.load_sdl_libraries;
import textures.texture;
import a_star.spot;
import datatypes : Location, Status;
import windows.events : handleEvents;


import std.conv : roundTo;
import std.stdio : writeln;
import core.stdc.stdlib : exit;
import a_star.spot : writeAndPause;

// SDL = Simple Directmedia Layer
import bindbc.sdl : SDL_Window, SDL_Renderer;
import bindbc.sdl : IMG_SavePNG;
import bindbc.sdl;  // SDL_* all remaining declarations
import bindbc.loader;


//import breakup;
//import magnify;
//import standalone_demos;
//import tutorials;
//import helper_funcs;
//import cork_board;
//import trimmer;
import quad_tree;


/+
SDL coordinates, like most graphic engine coordinates, start at the top left corner of 
the screen/window. The more you go down the screen the more Y increases and as you go 
across to the right the X increases.

If you want an image in the top left corner set X to 0 and Y to 0

Screen coordinates

(0,0)
  +---------------------------------+
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  |                                 |
  +---------------------------------+ 
                          (maxWidth, maxHeight)


In SDL, SDL_window is used to create a window, while SDL_surface is used to draw to the window
SDL_window is used to create a window and set flags such as fullscreen, OpenGL, hidden, or obscured.
SDL_window is a struct that holds all info about the itself: size, position, borders etc.
SDL_surface is used to abstract an area for drawing, such as loaded images. SDL_surface is a collection 
of pixels used for software rendering, also known as blitting.
SDL_Surface is used in software rendering. (SDL_Surface is obsolete)
SDL_Texture on the other hand, is used in a hardware rendering, textures are stored in VRAM
SDL_Renderer is a struct that handles all rendering. It is tied to a SDL_Window so it can only render 
within that SDL_Window. It also keeps track the settings related to the rendering.
+/

 
Globals!(int) mini;  // put all the global variables together in one place

Globals!(int) big;

Globals!(int)*[int] holder; // hold pointers to the Globals instances indexed by windowID
                       // Since this is only a pointer, changes to the Globals can be made
                       // without updating the entries in this associated array

HexBoard!(real, int)[int] boards; // hold pointers to the HexBoard instances indexed by windowID
                            // Since this is only a pointer, changes to the HexBoard can be made
                            // without updating the entries in this associated array

int main()
{
    writeln("Hello main");
    load_sdl_libraries(); 
    
    SDL_Initialize();

    //no_renderer_02();  // ESC to exit
	
	quadrophenia();
	exit(-1);
    
    //trimEdges();
    exit(-1);
    
    //corkboard();  // done
    exit(-1);
    
/+
    splitTooLargeFile("5", 1, 2);
    exit(-1);
    
    SDL_Surface* kyle = assembleTilesIntoOneFile("1_", 1, 2);
    exit(-1);

    //copying_textures_to_surface();

    //copying_surface_to_surface();
    
    just_a_window();
    
    two_windows_and_surfaces();  // done
    exit(-1);

    smallest_sdl_texture_program();
    exit(-1);
    
    no_renderer_02();
    exit(-1);
    
    smallest_texture_with_rect();
    exit(-1);

    mini_and_main_maps();
    exit(-1);

+/
    //two_windows_and_surfaces();  // done
    exit(-1);
    
    

    //change_texture_access();
    exit(-1);


    //smallest_texture_with_rect();
    exit(-1);
    
    //two_windows_and_surfaces();
    exit(-1);
    
    //change_texture_access();

    

    //smallest_renderer_01();
    //exit(-1);
    
    //smallest_texture_01a();
    //exit(-1);
    
    //smallest_texture_01b();
    
    //no_renderer_02();
    //exit(-1);
    
    //surface_no_implicit_scaling_03();
    //exit(-1);
    
    //surface_explicit_scaling_04();
    //exit(-1);
    
    //texture_implicit_scaling_05();
    exit(-1);
    
    //tutorial_4();
    //exit(-1);
    
    //tutorial_5();
    //exit(-1);
    
    //mosaic();
    exit(-1);
    
    //ThreeSurfacesAndOneStreamingTexure();
    exit(-1);
    
    //LightBoard();
    exit(-1);

    //enlargeAndReduce();
    exit(-1);

    //magnifyImage();
    exit(-1);

    //composingImage();
    exit(-1);
    
    //trackerCamera();
    
    //rotateAndScale();
    
    //fromGithub();
    exit(-1);
    
    //display_info();
    
    // timeIntervalInTicks();
    // timeIntervalInPerformanceMode();
    // frameRate();
    // cappingFrameRate();

    big.sdl.screen.width  = 900;
    big.sdl.screen.height = 900;
    big.sdl.board.rows = 25;  // 10
    big.sdl.board.cols = 25;  // 10

    mini.sdl.screen.width  = 400;
    mini.sdl.screen.height = 400;
    mini.sdl.board.rows = 100;  // 50
    mini.sdl.board.cols = 100;  // 50


    float miniHexWidth = hexWidthToFitNDCwindow(mini.sdl.board.rows,
                                                mini.sdl.board.cols,
                                                Orientation.horizontal);

    float bigHexWidth = hexWidthToFitNDCwindow(big.sdl.board.rows, 
                                               big.sdl.board.cols, 
                                               Orientation.horizontal);

    auto h = HexBoard!(real, int)(miniHexWidth,
                                  mini.sdl.board.rows,
                                  mini.sdl.board.cols);

    auto h2 = HexBoard!(real, int)(bigHexWidth,
                                   big.sdl.board.rows,
                                   big.sdl.board.cols);

    //auto h = HexBoard!(double,int)(hexWidth, rows, cols); // WORKS!
    //auto h = HexBoard!(float, int)(hexWidth, rows, cols);  // WORKS!

    h.convertNDCoordsToScreenCoords(mini.sdl.screen.width, mini.sdl.screen.height);

    h2.convertNDCoordsToScreenCoords(big.sdl.screen.width, big.sdl.screen.height);

    h.convertLengthsFromNDCtoSC(mini.sdl.screen.width, mini.sdl.screen.height);

    h2.convertLengthsFromNDCtoSC(big.sdl.screen.width, big.sdl.screen.height);

    // https://github.com/BindBC/bindbc-sdl/issues/53   
    // https://github.com/ichordev/bindbc-sdl/blob/74390eedeb7395358957701db2ede6b48a8d0643/source/bindbc/sdl/config.d#L12
    
    //SDL_Window * SDL_CreateWindow(const char *title, int w, int h, SDL_WindowFlags flags);

    mini.sdl = createSDLwindow("Mini Map", mini.sdl.screen.width,
                                           mini.sdl.screen.height);  // screen or pixel width x height

    big.sdl = createSDLwindow("Main Map", big.sdl.screen.width,
                                          big.sdl.screen.height);  // screen or pixel width x height
                                         
                                         
                                         
                                         
                                         
                                         
    int top;  int left;  int bottom; int right;                                   
    int ret = SDL_GetWindowBordersSize(mini.sdl.window, &top, &left, &bottom, &right);
                                         
    writeln("top = ", top, "  left = ", left, "  bottom = ", bottom, "  right = ", right);
                                         
    SDL_Rect displayBounds;
    SDL_GetDisplayBounds(0, &displayBounds); // 0 is the primary display

    writeln("displayBounds = ", displayBounds);

    SDL_Rect displayUsableBounds;
    SDL_GetDisplayUsableBounds(0, &displayUsableBounds); // 0 is the primary display

    writeln("displayUsableBounds = ", displayUsableBounds);
    
    SDL_SetWindowPosition(mini.sdl.window, 0, top);  // Adjust window so its border is on screen
                                         
                                         
    SDL_SetWindowPosition(big.sdl.window, mini.sdl.screen.width, top);  // position big window to right of mini


    writeln("big.sdl.renderer = ", big.sdl.renderer);

    holder[mini.sdl.windowID] = &mini;
    holder[big.sdl.windowID] = &big;

    h.setRenderOfHexboard(mini.sdl.renderer);  // MUST BE DONE BEFORE PUTTING IN AA (associative array)
    h2.setRenderOfHexboard(big.sdl.renderer); 

    boards[mini.sdl.windowID] = h;
    boards[big.sdl.windowID] = h2;


    mini.textures = load_textures(mini);
    big.textures = load_textures(big);

    h.drawHexBoard(mini);
    h2.drawHexBoard(big);

    h.setHexboardTexturesAndTerrain(mini);
    h2.setHexboardTexturesAndTerrain(big);

    h.displayHexTextures();
    h2.displayHexTextures();

    //writeAndPause("hit any key to contiue");


    // https://thenumb.at/cpp-course/sdl2/03/03.html

    SDL_Event event;
    
    Status status;
    status.running = true;
    status.saveWindowToFile = false;

    while(status.running)
    {
        while(SDL_PollEvent(&event) != 0)
        {
            handleEvents(event, status);

            if (status.saveWindowToFile)  // SDLK_F1 was pressed
            {
                // what is the currently active window?
                Globals!(int)* currentWindow = holder[status.active.windowID];

                //writeln("currentWindow.sdl.windowID = ", currentWindow.sdl.windowID);
                saveWindowToFile(currentWindow);
                status.saveWindowToFile = false;
            }
            
            if (status.leftMouseButton)
            {
                // what window are we curretly in
                
                writeln("status.active.windowID = ", status.active.windowID);
                
                Globals!(int)* currentWindow = holder[status.active.windowID];

                writeln("currentWindow.sdl.renderer = ", currentWindow.sdl.renderer);
                writeln("C h2.renderer = ", h2.renderer);

                HexBoard!(real, int) currentBoard = boards[status.active.windowID];

                writeln("currentBoard.renderer = ", currentBoard.renderer);
                writeln("D h2.renderer = ", h2.renderer);
                
                currentBoard.displayHexTextures();
                
                
                float mx;  // in SDL2 mouse click returned ints.  SDL3 returns floats 
                float my;
                SDL_GetMouseState(&mx,&my);
                
                currentBoard.mouseClick.sc.x = cast (int) mx;
                currentBoard.mouseClick.sc.y = cast (int) my;
                
                //SDL_GetMouseState(cast (int *) &currentBoard.mouseClick.sc.x, 
                //                  cast (int *) &currentBoard.mouseClick.sc.y);

                writeln(currentBoard.mouseClick.sc.x, ", ", currentBoard.mouseClick.sc.y);
                
                // Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)

                currentBoard.convertScreenCoordinatesToNormalizedDeviceCoordinates(currentWindow.sdl.screen.width, 
                                                                                   currentWindow.sdl.screen.height);

                writeln(currentBoard.mouseClick.ndc.x, ", ", currentBoard.mouseClick.ndc.y);
                
                if (currentBoard.getHexMouseClickedOn())
                {
                    writeln("currentBoard.selectedHex = ", currentBoard.selectedHex);

                    alias I = typeof(currentBoard.integerType);
                    I x = currentBoard.selectedHex.row;   I y = currentBoard.selectedHex.col;

                    Location first;  
                    Location last; 

                    first.r = 0;
                    first.c = 0;

                    last.r = x; 
                    last.c = y;

                    findShortestPathCodingTrain( currentBoard, currentWindow, first, last );

                    currentBoard.displayHexTextures();
                    
                    SDL_RenderPresent(currentWindow.sdl.renderer);
                }

                status.leftMouseButton = false;
            }
            /+
            switch(event.type)
            {
                case SDL_KEYDOWN:

                    if( event.key.keysym.sym == SDLK_DELETE )
                    {
                        writeln("SDLK_DELETE used to just clear out all hex textures");
                        h.clearHexBoard();
                        h.drawHexBoard(mini);
                    }

                    if( event.key.keysym.sym == SDLK_F1 )
                    {
                        import std.process : executeShell;
                        //executeShell("cls");

                        h.setHexboardTexturesAndTerrain(mini);

                        writeln("after setHexboardTexturesAndTerrain");

                        //h.displayHexTextures();

                        import std.datetime.stopwatch;
                        auto watch = StopWatch(AutoStart.no);
                        watch.start();
                        //                                          millisecond 
                        // units = weeks days hours minutes seconds msecs usecs hnsecs nsecs
                        //                                                microsecond

                        Location begin;
                        Location end;

                        begin.r = 0;
                        begin.c = 0;

                        end.r = h.lastRow;
                        end.c = h.lastColumn;

                        //findShortestPathCodingTrain( h, mini, begin, end );

                        writeln(watch.peek()); 

                        //h.displayHexTextures();
                    }
                    break;

                case SDL_MOUSEBUTTONDOWN:

                    if( event.button.button == SDL_BUTTON_LEFT )
                    {
                        SDL_GetMouseState(cast (int *) &h.mouseClick.sc.x, cast (int *) &h.mouseClick.sc.y);

                        //writeln(h.mouseClick.sc.x, ", ", h.mouseClick.sc.y);

                        // Convert a mouse click screen coordinates (integer numbers) to normalized device coordinates (float)

                        h.convertScreenCoordinatesToNormalizedDeviceCoordinates(mini.sdl.screen.width, mini.sdl.screen.height);

                        //writeln(h.mouseClick.ndc.x, ", ", h.mouseClick.ndc.y);

                        if (h.getHexMouseClickedOn())
                        {
                            writeln("h.selectedHex = ", h.selectedHex);

                            alias I = typeof(h.integerType);
                            I x = h.selectedHex.row;   I y = h.selectedHex.col;

                            Location first;  
                            Location last; 

                            first.r = 0;
                            first.c = 0;

                            last.r = x; 
                            last.c = y;

                            import std.datetime.stopwatch;
                            auto watch = StopWatch(AutoStart.no);
                            watch.start();
                            //                                          millisecond  hecto-nanosecond
                            // units = weeks days hours minutes seconds msecs usecs hnsecs nsecs
                            //                                                microsecond  nanosecond

                            //findShortestPathCodingTrain( h, mini, first, last );

                            writeln(watch.peek());

                            /+
                            h.setHexesHorizontally(g, end, 7, Ids.solidRed);
                            h.setHexesVertically(g, end, 5, Ids.solidBlue);
                            h.setHexesSouthWestByNorthEast(g, end, 7, Ids.solidWhite);
                            h.setHexesNorthWestBySouthEast(g, end, 7, Ids.solidGreen);
                            h.setHexesEast(g, end, 7, Ids.solidRed);
                            h.setHexesWest(g, end, 7, Ids.solidRed);
                            h.setHexesNorth(g, end, 7, Ids.solidRed);
                            h.setHexesNorthEast(g, end, 7, Ids.solidBlue);
                            h.setHexesSouthEast(g, end, 7, Ids.solidGreen);
                            h.setHexesSouth(g, end, 7, Ids.solidBrown);
                            h.setHexesNorthWest(g, end, 7, Ids.solidBlack);
                            h.setHexesSouthWest(g, end, 7, Ids.solidWhite);
                            +/

                            //h.displayHexTextures();

                            Point2D!(I)[4] t;

                            t[0].x = h.hexes[x][y].points.sc[0].x;
                            t[0].y = h.hexes[x][y].points.sc[0].y; 
                            t[1].x = h.hexes[x][y].points.sc[1].x;
                            t[1].y = h.hexes[x][y].points.sc[1].y;
                            t[2].x = h.hexes[x][y].points.sc[3].x;
                            t[2].y = h.hexes[x][y].points.sc[3].y; 
                            t[3].x = h.hexes[x][y].points.sc[4].x;
                            t[3].y = h.hexes[x][y].points.sc[4].y;

                            //writeln(t);

                            SDL_RenderDrawLine( mini.sdl.renderer, t[0].x, t[0].y, t[1].x, t[1].y);
                            SDL_RenderDrawLine( mini.sdl.renderer, t[1].x, t[1].y, t[2].x, t[2].y);
                            SDL_RenderDrawLine( mini.sdl.renderer, t[2].x, t[2].y, t[3].x, t[3].y);
                            SDL_RenderDrawLine( mini.sdl.renderer, t[3].x, t[3].y, t[0].x, t[0].y);
                        }
                    }
                    break;

                default: break;
            } +/
        }
        //SDL_RenderPresent(mini.sdl.renderer);
        //SDL_RenderPresent(big.sdl.renderer);
    }
    return 0;
}




+/

