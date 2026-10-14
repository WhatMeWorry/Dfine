
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
    int selectedIndex = -1; // -1 means no texture is currently being dragged

    float scale = 1.0f;
    float scaleSpeed = 0.01f;

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

                case SDL_EVENT_MOUSE_MOTION:
                    // event.motion gives you the SDL_MouseMotionEvent struct
                    SDL_MouseMotionEvent mouseMove = event.motion;

                    //writefln("Mouse Moved -> Absolute X: %s, Y: %s | Relative dX: %s, dY: %s",
                    //         mouseMove.x,  mouseMove.y, mouseMove.xrel, mouseMove.yrel);
                    break;

                case SDL_EVENT_MOUSE_BUTTON_DOWN:
                    if (event.button.button == SDL_BUTTON_LEFT) 
                    {
                        // Check targets from front-to-back (reverse loop) so topmost items get selected first
                        //for (int i = cast(int)items.length - 1; i >= 0; i--) 
                        foreach_reverse(int i, item; items)
                        {
                            float mx = event.button.x;
                            float my = event.button.y;
                            
                            // Check if the click is inside the texture's bounding box
                            if (mx >= item.rect.x && mx <= item.rect.x + item.rect.w &&
                                my >= item.rect.y && my <= item.rect.y + item.rect.h) 
                            {
                                selectedIndex = i;
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
                        selectedIndex = -1; // Release selection
                    }
                    break;

                case SDL_EVENT_MOUSE_WHEEL:  // mouse scrolling
                    // event.wheel.y contains scroll movement (> 0 up, < 0 down)
                    float wheelDirection = event.wheel.y;
                    
                    write("wheelDirection = ");
                    if (wheelDirection > 0)
                        writeln("Up");
                    else
                        writeln("Down");
                    
                    scale += wheelDirection * scaleSpeed;

                    // Keep scale within reasonable bounds
                    if (scale < 0.1f) scale = 0.1f;
                    if (scale > 10.0f) scale = 10.0f;
                    
                    writeln("scale = ", scale);
                    if (selectedIndex >= 0)
                    {
                        writeln("item ", selectedIndex, " is selected");
                    }
                    else
                    {
                        writeln("No texture is selected");
                    }
                    // scale > 1.0 means to grow in size
                    // scale < 1.0 means to shrink in size
                    
                    if (selectedIndex == -1)
                    {
                        continue;
                    }

                    //items[selectedIndex].rect.w = items[selectedIndex].rect.w * scale;
                    //items[selectedIndex].rect.h = items[selectedIndex].rect.h * scale;
                    items[selectedIndex].rect.w = items[selectedIndex].rect.w + scale;
                    items[selectedIndex].rect.h = items[selectedIndex].rect.h + scale;
                    break;

/+                case SDL_EVENT_MOUSE_MOTION:
                    if (selectedIndex != -1) 
                    {
                        // Update coordinate positions fluidly matching mouse coordinates
                        items[selectedIndex].rect.x = event.motion.x - items[selectedIndex].offsetX;
                        items[selectedIndex].rect.y = event.motion.y - items[selectedIndex].offsetY;
                    }
                    break; +/

                default:
                    break;
            }
        }
        //writeln("SDL_GetTicks() - single_click_timestamp = ", SDL_GetTicks() - single_click_timestamp);
    
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
        }

        // Swap back buffer to screen output
        SDL_RenderPresent(renderer);
    }
}

/+
Does Windows have a time frame for when two mouse clicks are considered double-clicks

Yes, Windows uses a default time frame of 500 milliseconds (half a second) between two clicks to register them as a double-click
User Adjustable: You can customize the double-click speed in Windows through the Mouse Properties settings in the Control Panel.
API Limits: Programmatically via Microsoft Learn, the system double-click time can generally be adjusted or queried using functions 
like SetDoubleClickTime and GetDoubleClickTime, with a hard cap up to 5,000 milliseconds

Do Apple Macs use a time frame to register two clicks as a double-click, and you can adjust this speed in your system settings

Default Timing: macOS sets the default double-click speed to approximately 500 milliseconds (half a second)
Adjusting the Speed: You can change how fast or slow two clicks need to be to register as a double-click

Linux systems have a default double-click time frame of 400 milliseconds on major desktop environments like GNOME and KDE
+/


/+

what is the most elegant method for allowing SDL3 to differentiate between a single mouse click and a double mouse click


#include <SDL3/SDL.h>

// Variables to track pending single clicks
SDL_bool pending_single_click = SDL_FALSE;
Uint64 single_click_timestamp = 0;
const Uint64 DOUBLE_CLICK_DELAY_MS = 250; // Match or slightly exceed OS threshold if needed

void HandleEvents() 
{
    SDL_Event event;
    while (SDL_PollEvent(&event)) 
    {
        if (event.type == SDL_EVENT_MOUSE_BUTTON_DOWN) 
        {
            if (event.button.button == SDL_BUTTON_LEFT) 
            {
                if (event.button.clicks == 1)
                {
                    // Flag that a single click might be happening, but wait to see if a second arrives
                    pending_single_click = SDL_TRUE;
                    single_click_timestamp = SDL_GetTicks();
                } 
                else if (event.button.clicks == 2) 
                {
                    // A double click was detected by SDL3! Cancel the single click.
                    pending_single_click = SDL_FALSE;
                    ExecuteDoubleClickAction();
                }
            }
        }
    }

    // Outside the event loop (in your main update loop), check if the single click timed out
    if (pending_single_click && (SDL_GetTicks() - single_click_timestamp > DOUBLE_CLICK_DELAY_MS)) {
        pending_single_click = SDL_FALSE;
        ExecuteSingleClickAction();
    }
}
+/

/+

Why This Method Is Elegant

• OS-Level Consistency: SDL3 hooks into the native windowing system's click-counter logic. It 
respects the user's system settings for what constitutes a "double click" speed and spatial tolerance.
• No Manual Math: You do not need to record coordinates and compare x/y deltas yourself to ensure 
the mouse didn't move too far between clicks.
• Solves the Overlap Problem: If your single-click and double-click actions don't conflict (e.g., 
single-click selects an item, double-click opens it), you can completely omit the timer logic and just execute event.button.clicks == 1 instantly.

When to Bypass the Timer

If your application behaves like a standard desktop OS where a double click inherently includes a single click 
(e.g., clicking a file selects it, and double-clicking opens it), you can eliminate the timer entirely and make your code even simpler:


if (event.type == SDL_EVENT_MOUSE_BUTTON_DOWN && event.button.button == SDL_BUTTON_LEFT) {
    if (event.button.clicks == 1) {
        SelectTarget(); // Happens instantly
    } else if (event.button.clicks == 2) {
        OpenTarget();   // Happens right after the second click
    }
}

+/













/+

import core.thread : Thread;
import std.stdio;
import bindbc.sdl; // Assumes bindbc-sdl or similar SDL3 bindings for D

void main()
{
    // Initialize SDL video
    if (!SDL_Init(SDL_INIT_VIDEO))
    {
        writeln("SDL_Init Error: ", SDL_GetError());
        return;
    }
    scope(exit) SDL_Quit();

    // Create a window and renderer
    SDL_Window* window = SDL_CreateWindow("SDL3 D Texture Zoom", 800, 600, SDL_WINDOW_RESIZABLE);
    if (!window)
    {
        writeln("SDL_CreateWindow Error: ", SDL_GetError());
        return;
    }
    scope(exit) SDL_DestroyWindow(window);

    SDL_Renderer* renderer = SDL_CreateRenderer(window, null);
    if (!renderer)
    {
        writeln("SDL_CreateRenderer Error: ", SDL_GetError());
        return;
    }
    scope(exit) SDL_DestroyRenderer(renderer);

    // Create a sample 100x100 RGB/RGBA texture
    float baseW = 100.0f;
    float baseH = 100.0f;
    SDL_Texture* texture = SDL_CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_TARGET,
        cast(int) baseW,
        cast(int) baseH
    );
    if (!texture)
    {
        writeln("SDL_CreateTexture Error: ", SDL_GetError());
        return;
    }
    scope(exit) SDL_DestroyTexture(texture);

    // Draw something onto our texture target so it's visible
    SDL_SetRenderTarget(renderer, texture);
    SDL_SetRenderDrawColor(renderer, 50, 150, 255, 255); // Blue color
    SDL_RenderClear(renderer);
    SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);   // Yellow border/shape
    SDL_FRect innerRect = { 10.0f, 10.0f, 80.0f, 80.0f };
    SDL_RenderFillRect(renderer, &innerRect);
    SDL_SetRenderTarget(renderer, null); // Switch back to window default render target

    // Current destination size and position for the texture
    float scaleFactor = 1.0f;
    float scaleSpeed = 0.1f;

    bool running = true;
    SDL_Event event;

    while (running)
    {
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_QUIT)
            {
                running = false;
            }
            else if (event.type == SDL_EVENT_MOUSE_WHEEL)
            {
                // event.wheel.y contains vertical scroll movement (> 0 up, < 0 down)
                float scrollY = event.wheel.y;
                scaleFactor += scrollY * scaleSpeed;

                // Keep scale within reasonable bounds
                if (scaleFactor < 0.1f) scaleFactor = 0.1f;
                if (scaleFactor > 10.0f) scaleFactor = 10.0f;
            }
        }

        // Calculate destination rect centered on screen
        float destW = baseW * scaleFactor;
        float destH = baseH * scaleFactor;
        float destX = (800.0f - destW) / 2.0f;
        float destY = (600.0f - destH) / 2.0f;
        SDL_FRect destRect = { destX, destY, destW, destH };

        // Clear screen
        SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255);
        SDL_RenderClear(renderer);

        // Render the scaled texture using SDL3's SDL_RenderTexture
        SDL_RenderTexture(renderer, texture, null, &destRect);

        // Present frame
        SDL_RenderPresent(renderer);
    }
}

+/