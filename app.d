

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

import breakup;



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
    
    //breakup1();
    //trimFileIfPixelsAreNotEven();
    //hugePNGfileIntoQuadPNGfiles();
    
    //assembleQuadFilesItoOnePNGfile();
    
    //zoomAnImage;
    zoom_grok;
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






