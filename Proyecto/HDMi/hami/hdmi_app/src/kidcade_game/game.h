/* game.h - "Atrapa el resultado" (catch the answer).
 *
 * A sum or subtraction appears at the top. Three numbers fall, one per
 * lane. Move the basket left/right to catch the correct result.
 * With no input source enabled, the game plays itself (DEMO).
 */
#ifndef GAME_H_INCLUDED
#define GAME_H_INCLUDED

#include <stdint.h>

void game_init(void);

/* Advance one frame (call at 60 Hz) and draw it into fb. */
void game_frame(uint32_t *fb, int width, int height, int stride_bytes);

#endif
