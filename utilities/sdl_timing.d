
//    https://thenumb.at/cpp-course/sdl2/08/08.html

module utilities.sdl_timing;


import bindbc.sdl;
import std.stdio;
/+
SDL Provides a simple but convenient API for timing. Timing has many applications, including FPS calculation 
and capping, profiling what parts of your program take the most time, and any simulations that should be based 
on time, such as physics and animation.

The most basic form of timing is SDL_GetTicks(). This function simply returns the number of ticks that have elapsed 
since SDL was initialized. One tick is one millisecond, a tolerable resolution for physics simulation and animation.

Ticks are always increasing—SDL doesn't provide a way to time between intervals, pause the global timer, or anything 
like that. However, all these features are relatively straightforward to implement yourself. For example, you could 
create a timing class that manages separate and pause-able timers. All you really need is what SDL gives you; the 
global tick timer.

For example, to time an interval in ticks, simply request the time at the start and end...

+/

void timeIntervalInTicks()
{
    uint start = SDL_GetTicks();  //SDL defines one tick as one millisecond

    // Do long operation
    SDL_Delay(2_115);             // the number of milliseconds to delay.
    
    uint end = SDL_GetTicks();    // A thousand ticks is one second

    float secondsElapsed = (end - start) / 1000.0f;
    
    writeln("secondsElapsed = ", secondsElapsed);
}


/+
what if you want to time sub-millisecond operations, or want more precision than simply a thousandth 
of a second? This is where SDL_GetPerformanceCounter() comes in. The performance counter is a 
system-specific high-resolution timer, usually on the scale of micro- or nano- seconds.

Because the performance counter is system specific, you don't actually know what the resolution is. 
Hence, the function SDL_GetPerformanceFrequency(): it gives you the number of performance counter ticks 
per second. Otherwise, this system is used in exactly the same way as ticks. To time an interval more 
precisely, capture the starting and ending performance counter values.

+/

void timeIntervalInPerformanceMode()
{
    ulong start = SDL_GetPerformanceCounter();

    SDL_Delay(777);  // the number of milliseconds to delay.      

    ulong end = SDL_GetPerformanceCounter();

    float secondsElapsed = (end - start) / cast(float) SDL_GetPerformanceFrequency();
    writeln("secondsElapsed = ", secondsElapsed);
}


/+
A common application of timing is to calculate the FPS, or frames per second, your program is running at. 
A frame is simply one iteration of your main game or program loop. Hence, timing it is quite straightforward: 
log the time at the start and end of each frame. Then, in some form output the elapsed time or its inverse (the FPS).
+/


void frameRate()
{
    while (true) 
    {
        ulong start = SDL_GetPerformanceCounter();

        // Do event loop
        // Do physics loop
        // Do rendering loop
        SDL_Delay(16);

        ulong end = SDL_GetPerformanceCounter();

        float elapsed = (end - start) / cast(float) SDL_GetPerformanceFrequency();
        writeln("Current FPS: ", 1.0f / elapsed );
    }

}


/+
Capping Frame Rate
Aside from performance profiling, you may want to calculate your FPS in order to cap it. Capping your FPS is useful 
because if you try to update the screen too many times per second, frames will start drawing on top of each other—this 
is screen tearing. Further, capping your FPS allows your program to not use all CPU resources given to it, freeing the 
user's computer to work on other tasks. Although ideally, those extra resources can be put towards improving gameplay 
or graphics.

Capping your FPS is quite simple: just subtract your frame time from your desired time and wait out the difference 
with SDL_Delay(). However, this function only takes delay in milliseconds—unfortunately, you cannot cap your FPS with 
very much precision. (At least with SDL—look at std::chrono for more.)

You will usually want to cap your FPS to 60, as this is by far the most common refresh rate. This means 
spending 16 and 2/3 milliseconds per frame. Note that you can easily change this cap.
+/

void cappingFrameRate()
{
    while (true) 
    {
        ulong start = SDL_GetPerformanceCounter();

        // Do event loop
        // Do physics loop
        // Do rendering loop

        ulong end = SDL_GetPerformanceCounter();

        float elapsedMS = (end - start) / (cast(float) SDL_GetPerformanceFrequency() * 1000.0f);

        // Cap to 60 FPS
        import std.math : floor;
        SDL_Delay( cast(uint) floor(16.666f - elapsedMS) );
        writeln("hello there");
    }

}