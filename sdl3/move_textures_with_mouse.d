
module move_textures_with_mouse;

import bindbc.sdl: SDL_Delay, SDL_Window, SDL_Renderer;
import bindbc.sdl;

import std.string: toStringz;
import core.stdc.stdio: printf;

import useful_functions : getFullPathToExecuableFile;
import std.stdio: writeln;

SDL_Window *window = null;
SDL_Renderer *renderer = null;

 
import std.stdio;
import std.string : toStringz;

import sdl_funcs_with_error_handling;



// Structure representing our draggable textures
struct DraggableTexture 
{
    SDL_Texture* texture;
    SDL_FRect rect;
    float offsetX;
    float offsetY;
    bool selected;
}


void drawThickerBorderAroundRect(SDL_Renderer* renderer, const ref SDL_FRect rect, float thickness = 3.0)
{
    // Calculate and draw the 4 border rects (sides) to create the border
    
    SDL_SetRenderDrawColor(renderer, 255, 255, 0, SDL_ALPHA_OPAQUE);

    // Top border piece
    SDL_FRect topBorder = SDL_FRect(rect.x - thickness, 
                                    rect.y - thickness, 
                                    rect.w + (thickness * 2), 
                                    thickness);
                                    
    SDL_RenderFillRect(renderer, &topBorder);

    // Bottom border piece
    SDL_FRect botBorder = SDL_FRect(rect.x - thickness, 
                                    rect.y + rect.h, 
                                    rect.w + (thickness * 2), 
                                    thickness);
                                    
    SDL_RenderFillRect(renderer, &botBorder);
    
    // Left border piece
    SDL_FRect leftBorder = SDL_FRect(rect.x - thickness, 
                                     rect.y, 
                                     thickness, 
                                     rect.h);
                                     
    SDL_RenderFillRect(renderer, &leftBorder);

    // Right border piece
    SDL_FRect rightBorder = SDL_FRect(rect.x + rect.w, 
                                      rect.y,
                                      thickness, 
                                      rect.h);
                                      
    SDL_RenderFillRect(renderer, &rightBorder);

}



/+
 Draw a yellow outline frame around an existing target rectangle.
 
 Params:
    renderer = The active SDL_Renderer context.
    existingRect = The baseline rectangle to surround.
    padding = The gap distance between the existing rect and the frame.
+/

void drawBorderAroundRect(SDL_Renderer* renderer, const ref SDL_FRect rect, float padding = 1.0)
{
    // Calculate the frame dimensions slightly larger than the existing rect
    SDL_FRect borderRect;
    borderRect.x = rect.x - padding;
    borderRect.y = rect.y - padding;
    borderRect.w = rect.w + (padding * 2.0);
    borderRect.h = rect.h + (padding * 2.0);

    // Set the renderer draw color to Yellow (RGBA: 255, 255, 0, 255)
    SDL_SetRenderDrawColor(renderer, 255, 255, 0, SDL_ALPHA_OPAQUE);

    // Draw the unfilled outline frame around the rectangle
    SDL_RenderRect(renderer, &borderRect);
}


void moveTexturesWithMouse()
{
    // Create window and renderer simultaneously (SDL3 feature)
    SDL_Window* window = null;
    SDL_Renderer* renderer = null;

    createWindowAndRenderer("SDL3 Dlang Interactive Textures", 800, 600, cast(SDL_WindowFlags) 0, &window, &renderer); 


    // Create 2 solid-colored textures to interact with
    DraggableTexture[2] items;

    // Item 1: Red Rectangle
    SDL_Surface* surf1 = createSurface(120, 120, SDL_PIXELFORMAT_RGBA8888);
    fillSurfaceRect(surf1, null, mapRGBA(getPixelFormatDetails(SDL_PIXELFORMAT_RGBA8888), null, 230, 50, 50, 255));
    items[0].texture = createTextureFromSurface(renderer, surf1);
    items[0].rect = SDL_FRect(150, 200, 120, 120);
    SDL_DestroySurface(surf1);

    // Item 2: Blue Rectangle
    SDL_Surface* surf2 = createSurface(150, 100, SDL_PIXELFORMAT_RGBA8888);
    fillSurfaceRect(surf2, null, mapRGBA(getPixelFormatDetails(SDL_PIXELFORMAT_RGBA8888), null, 50, 120, 230, 255));
    items[1].texture = createTextureFromSurface(renderer, surf2);
    items[1].rect = SDL_FRect(450, 220, 150, 100);
    SDL_DestroySurface(surf2);

    scope(exit) 
    {
        SDL_DestroyTexture(items[0].texture);
        SDL_DestroyTexture(items[1].texture);
    }

    bool running = true;
    int currentSelected = -1; // -1 means no texture is currently being dragged

    float scale = 1.0f;
    float scaleSpeed = 0.1f;
    float delta = 0.0;

    bool pending_single_click = false;
    ulong single_click_timestamp = 0;
    
    const ulong DOUBLE_CLICK_DELAY_MS = 300; // Match or slightly exceed OS threshold if needed



    // Main Loop
    while (running) 
    {
        SDL_Event event;
        while (SDL_PollEvent(&event)) 
        {
            //writeln("Event just triggered. This can be bursty");
            switch (event.type) 
            {
                case SDL_EVENT_QUIT:
                    running = false;
                    break;
                
                case SDL_EVENT_KEY_DOWN:
                    if (event.key.key == SDLK_F1)
                        delta = 0.5;
                    if (event.key.key == SDLK_F2)
                        delta = 1.0;
                    if (event.key.key == SDLK_F3)
                        delta = 5.0;
                    if (event.key.key == SDLK_F4)
                        delta = 10.0;
                    break;

                case SDL_EVENT_MOUSE_BUTTON_DOWN:
                    if (event.button.button == SDL_BUTTON_LEFT) 
                    {
                        // Check targets from front-to-back (reverse loop) so topmost items get selected first
                        //for (int i = cast(int)items.length - 1; i >= 0; i--) 
                        foreach_reverse(int i, ref item; items)
                        {
                            float mx = event.button.x;
                            float my = event.button.y;
                            
                            // Check if the click is inside the texture's bounding box
                            if (mx >= item.rect.x && mx <= item.rect.x + item.rect.w &&
                                my >= item.rect.y && my <= item.rect.y + item.rect.h) 
                            {
                                writeln("i = ", i, " item.selected = ", item.selected);
                                currentSelected = i;
                                
                                //item.selected = true;
                                item.selected = !item.selected;
                                
                                // Store the offset relative to the texture's origin to avoid "snapping"
                                item.offsetX = mx - item.rect.x;
                                item.offsetY = my - item.rect.y;
                                break;
                            }
                        }

                        if (event.button.clicks == 1)
                        {
                            // Flag that a single click might be happening, but wait to see if a second arrives
                            pending_single_click = true;
                            single_click_timestamp = SDL_GetTicks();
                        }
                        else if (event.button.clicks == 2) 
                        {
                            // A double click was detected by SDL3! Cancel the single click.
                            pending_single_click = false;
                            //ExecuteDoubleClickAction();
                            writeln("Double Click Detected");
                        }

                    }
                    break;

                case SDL_EVENT_MOUSE_BUTTON_UP:
                    if (event.button.button == SDL_BUTTON_LEFT) 
                    {
                        currentSelected = -1; // Release selection
                    }
                    break;

                case SDL_EVENT_MOUSE_WHEEL:  // mouse scrolling
                    // event.wheel.y contains scroll movement (> 0 up, < 0 down)
                    float wheelDirection = event.wheel.y;
                    
                    writeln("wheelDirection = ", event.wheel.y);

                    scale += wheelDirection * scaleSpeed;

                    // Keep scale within reasonable bounds
                    if (scale < 0.1f) scale = 0.1f;
                    if (scale > 10.0f) scale = 10.0f;
                    
                    //writeln("scale = ", scale);
 
                    // scale > 1.0 means to grow in size
                    // scale < 1.0 means to shrink in size

                    foreach(ref item; items) 
                    {
                        if (item.selected)
                        {
                             //item.rect.w = item.rect.w * scale;
                             //item.rect.h = item.rect.h * scale;
                             item.rect.w = item.rect.w + (delta * -wheelDirection);
                             item.rect.h = item.rect.h + (delta * -wheelDirection);
                        }
                    }

                    break;

                case SDL_EVENT_MOUSE_MOTION:
                    if (currentSelected != -1) 
                    {
                        // Update coordinate positions fluidly matching mouse coordinates
                        items[currentSelected].rect.x = event.motion.x - items[currentSelected].offsetX;
                        items[currentSelected].rect.y = event.motion.y - items[currentSelected].offsetY;
                    }

                    SDL_MouseMotionEvent mouseMove = event.motion;

                    //writefln("Mouse Moved -> Absolute X: %s, Y: %s | Relative dX: %s, dY: %s",
                    //         mouseMove.x,  mouseMove.y, mouseMove.xrel, mouseMove.yrel);
                    break;

                default:
                    break;
            }
        }

        // The following block must be outside the event loop (in your main update loop), check if the single click timed out
        // because the event loop "while (SDL_PollEvent(&event))" can be quite bursty. So there can be long periods
        // of time where the if (pending_single_click &&... would not be executed. So single click detection
        // would be at the mercy of other events occurring

        if (pending_single_click && (SDL_GetTicks() - single_click_timestamp > DOUBLE_CLICK_DELAY_MS)) 
        {
            pending_single_click = false;
            //ExecuteSingleClickAction();
            writeln("Single Click Detected");
        }

        // --- Render Target Rendering Pipeline ---
        // Clear background with soft gray color
        setRenderDrawColor(renderer, 40, 40, 45, 255);
        
        renderClear(renderer);

        // Draw textures
        foreach(item; items) 
        {
            // SDL3 uses SDL_RenderTexture with subpixel precision floating pointers (SDL_FRect)
            renderTexture(renderer, item.texture, null, &item.rect);

            if (item.selected)
            {
                drawBorderAroundRect(renderer, item.rect, 1.0);
                
                //drawThickerBorderAroundRect(renderer, item.rect, 3.0);
            }
            
        }

        // Swap back buffer to screen output
        SDL_RenderPresent(renderer);
    }
}

/+
Windows has a time frame for when two mouse clicks are considered double-clicks

Windows uses a default time frame of 500 milliseconds (half a second) between two clicks to register them as a double-click
User Adjustable: You can customize the double-click speed in Windows through the Mouse Properties settings in the Control Panel.
API Limits: Programmatically via Microsoft Learn, the system double-click time can generally be adjusted or queried using functions 
like SetDoubleClickTime and GetDoubleClickTime, with a hard cap up to 5,000 milliseconds

Do Apple Macs use a time frame to register two clicks as a double-click, and you can adjust this speed in your system settings

Default Timing: macOS sets the default double-click speed to approximately 500 milliseconds (half a second)
Adjusting the Speed: You can change how fast or slow two clicks need to be to register as a double-click

Linux systems have a default double-click time frame of 400 milliseconds on major desktop environments like GNOME and KDE
+/
