/* audio.h - sound effects layer. The game calls audio_play(); the
 * actual hardware output is left as three hooks in audio.c.
 */
#ifndef AUDIO_H_INCLUDED
#define AUDIO_H_INCLUDED

typedef enum {
    SND_MOVE,
    SND_CORRECT,
    SND_WRONG,
    SND_GAMEOVER,
    SND_COUNT
} Sound;

void audio_init(void);
void audio_play(Sound s);
void audio_update(void);   /* call once per frame (60 Hz) */

#endif
