
module audio;

import bindbc.sdl: SDL_Window, SDL_Renderer, SDL_AudioStream;
import bindbc.sdl: MIX_Mixer, MIX_Audio, MIX_LoadAudio, MIX_CreateMixerDevice, SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, SDL_GetError;

import std.string: toStringz;
import core.stdc.stdio: printf;

import useful_functions : getFullPathToExecuableFile;
import std.stdio: writeln;

SDL_Window *window = null;
SDL_Renderer *renderer = null;

SDL_AudioStream *stream = null;


void audioForay()
{
   string pathToExec = getFullPathToExecuableFile();

   string pathToAudioFiles = pathToExec ~ `\sounds`;


    MIX_Mixer *mixer = null;

    
    mixer = MIX_CreateMixerDevice(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, null);
    
    string pathToAudioFile = pathToAudioFiles ~ `\can_pop.wav`;
    
    writeln("pathToAudioFile = ", pathToAudioFile);
    
    MIX_Audio *wavAudio = MIX_LoadAudio(mixer, toStringz(pathToAudioFile), false);

    if (!wavAudio) 
    {
        //writeln("Failed to load WAV", SDL_GetError());
        printf("SDL Error: %s\n", SDL_GetError()); 
    }
    writeln("WavAudio was successfully loaded");
    










}

/+
static Uint8 *wav_data = NULL;
static Uint32 wav_data_len = 0;

/* This function runs once at startup. */
SDL_AppResult SDL_AppInit(void **appstate, int argc, char *argv[])
{
    SDL_AudioSpec spec;
    char *wav_path = NULL;

    SDL_SetAppMetadata("Example Audio Load Wave", "1.0", "com.example.audio-load-wav");

    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) {
        SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    /* we don't _need_ a window for audio-only things but it's good policy to have one. */
    if (!SDL_CreateWindowAndRenderer("examples/audio/load-wav", 640, 480, SDL_WINDOW_RESIZABLE, &window, &renderer)) {
        SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }
    SDL_SetRenderLogicalPresentation(renderer, 640, 480, SDL_LOGICAL_PRESENTATION_LETTERBOX);

    /* Load the .wav file from wherever the app is being run from. */

    SDL_asprintf(&wav_path, "%ssample.wav", SDL_GetBasePath());  /* allocate a string of the full file path */

    if (!SDL_LoadWAV(wav_path, &spec, &wav_data, &wav_data_len))
{
        SDL_Log("Couldn't load .wav file: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    SDL_free(wav_path);  /* done with this string. */

    /* Create our audio stream in the same format as the .wav file. It'll convert to what the audio hardware wants. */

    stream = SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &spec, NULL, NULL);
    if (!stream)
{
        SDL_Log("Couldn't create audio stream: %s", SDL_GetError());
        return SDL_APP_FAILURE;
    }

    /* SDL_OpenAudioDeviceStream starts the device paused. You have to tell it to start! */

    SDL_ResumeAudioStreamDevice(stream);

    return SDL_APP_CONTINUE;  /* carry on with the program! */
}


SDL_AppResult SDL_AppEvent(void *appstate, SDL_Event *event)
{
    if (event->type == SDL_EVENT_QUIT) {
        return SDL_APP_SUCCESS;  /* end the program, reporting success to the OS. */
    }
    return SDL_APP_CONTINUE;  /* carry on with the program! */
}

/* This function runs once per frame, and is the heart of the program. */
SDL_AppResult SDL_AppIterate(void *appstate)
{
    /* see if we need to feed the audio stream more data yet.
       We're being lazy here, but if there's less than the entire wav file left to play,
       just shove a whole copy of it into the queue, so we always have _tons_ of
       data queued for playback. */
 
    if (SDL_GetAudioStreamQueued(stream) < (int)wav_data_len)
{
        /* feed more data to the stream. It will queue at the end, and trickle out as the hardware needs more data. */
        SDL_PutAudioStreamData(stream, wav_data, wav_data_len);
    }

    /* we're not doing anything with the renderer, so just blank it out. */
    SDL_RenderClear(renderer);
    SDL_RenderPresent(renderer);

    return SDL_APP_CONTINUE;  /* carry on with the program! */
}

/* This function runs once at shutdown. */
void SDL_AppQuit(void *appstate, SDL_AppResult result)
{
    SDL_free(wav_data);  /* strictly speaking, this isn't necessary because the process is ending, but it's good policy. */
    /* SDL will clean up the window/renderer for us. */
}


+/