
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
    SDL_FillSurfaceRect(surf1, null, mapRGBA(SDL_GetPixelFormatDetails(SDL_PIXELFORMAT_RGBA8888), null, 230, 50, 50, 255));
    items[0].texture = createTextureFromSurface(renderer, surf1);
    items[0].rect = SDL_FRect(150, 200, 120, 120);
    SDL_DestroySurface(surf1);

    // Item 2: Blue Rectangle
    SDL_Surface* surf2 = createSurface(150, 100, SDL_PIXELFORMAT_RGBA8888);
    SDL_FillSurfaceRect(surf2, null, mapRGBA(SDL_GetPixelFormatDetails(SDL_PIXELFORMAT_RGBA8888), null, 50, 120, 230, 255));
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

    float scaleFactor = 1.0f;
    float scaleSpeed = 0.1f;

    // Main Loop
    while (running) 
    {
        SDL_Event event;
        while (SDL_PollEvent(&event)) 
        {
            switch (event.type) 
            {
                case SDL_EVENT_QUIT:
                    running = false;
                    break;

                case SDL_EVENT_MOUSE_BUTTON_DOWN:
                    if (event.button.button == SDL_BUTTON_LEFT) 
                    {
                        // Check targets from front-to-back (reverse loop) so topmost items get selected first
                        for (int i = cast(int)items.length - 1; i >= 0; i--) 
                        {
                            float mx = event.button.x;
                            float my = event.button.y;
                            
                            // Check if the click is inside the texture's bounding box
                            if (mx >= items[i].rect.x && mx <= items[i].rect.x + items[i].rect.w &&
                                my >= items[i].rect.y && my <= items[i].rect.y + items[i].rect.h) 
                            {
                                selectedIndex = i;
                                // Store the offset relative to the texture's origin to avoid "snapping"
                                items[i].offsetX = mx - items[i].rect.x;
                                items[i].offsetY = my - items[i].rect.y;
                                break;
                            }
                        }
                    }
                    break;

                case SDL_EVENT_MOUSE_BUTTON_UP:
                    if (event.button.button == SDL_BUTTON_LEFT) 
                    {
                        selectedIndex = -1; // Release selection
                    }
                    break;

                case SDL_EVENT_MOUSE_WHEEL:
                    // event.wheel.y contains vertical scroll movement (> 0 up, < 0 down)
                    float wheelDirection = event.wheel.y;
                    scaleFactor += wheelDirection * scaleSpeed;

                    // Keep scale within reasonable bounds
                    if (scaleFactor < 0.1f) scaleFactor = 0.1f;
                    if (scaleFactor > 10.0f) scaleFactor = 10.0f;
                    write("wheelDirection = ");
                    if (wheelDirection > 0)
                        writeln("Up");
                    else
                        writeln("Down");
                    writeln("scaleFactor = ", scaleFactor);

                    break;

                case SDL_EVENT_MOUSE_MOTION:
                    if (selectedIndex != -1) 
                    {
                        // Update coordinate positions fluidly matching mouse coordinates
                        items[selectedIndex].rect.x = event.motion.x - items[selectedIndex].offsetX;
                        items[selectedIndex].rect.y = event.motion.y - items[selectedIndex].offsetY;
                    }
                    break;

                default:
                    break;
            }
        }

        // --- Render Target Rendering Pipeline ---
        // Clear background with soft gray color
        setRenderDrawColor(renderer, 40, 40, 45, 255);
        
        renderClear(renderer);

        // Draw textures
        foreach (/+ref+/ item; items) 
        {
            // SDL3 uses SDL_RenderTexture with subpixel precision floating pointers (SDL_FRect)
            renderTexture(renderer, item.texture, null, &item.rect);
        }

        // Swap back buffer to screen output
        SDL_RenderPresent(renderer);
    }
}

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