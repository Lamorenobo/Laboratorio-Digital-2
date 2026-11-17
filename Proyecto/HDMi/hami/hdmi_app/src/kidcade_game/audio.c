/* audio.c - see audio.h */
#include "audio.h"
#include <stdint.h>

typedef struct { uint16_t freq_hz; uint16_t frames; } Beep;

static const Beep beeps[SND_COUNT] = {
    [SND_MOVE]     = { 880,  3},
    [SND_CORRECT]  = {1320, 10},
    [SND_WRONG]    = { 220, 18},
    [SND_GAMEOVER] = { 150, 40},
};

static int remaining;

/* ------------------------------------------------------------------ */
/* Hardware hooks - implement these when you add audio hardware.      */
/* Options: a PWM / square-wave block in the PL driving a buzzer or   */
/* a Pmod AMP2, or the Zybo Z7 on-board audio codec (I2S).            */
/* ------------------------------------------------------------------ */
static void hw_init(void)
{
    /* TODO */
}

static void hw_tone_on(uint16_t freq_hz)
{
    (void)freq_hz; /* TODO: start a square wave at freq_hz */
}

static void hw_tone_off(void)
{
    /* TODO: stop the tone */
}

/* ------------------------------------------------------------------ */

void audio_init(void)
{
    hw_init();
    remaining = 0;
}

void audio_play(Sound s)
{
    if (s >= SND_COUNT) return;
    hw_tone_on(beeps[s].freq_hz);
    remaining = beeps[s].frames;
}

void audio_update(void)
{
    if (remaining > 0 && --remaining == 0)
        hw_tone_off();
}
