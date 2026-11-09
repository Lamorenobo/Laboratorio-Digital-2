/* gfx.h - tiny 2D graphics layer for the Zybo Z7 HDMI frame buffer.
 *
 * The game draws on a small 160x120 canvas (one byte per pixel, palette
 * colours). gfx_blit() scales it up to the real HDMI resolution
 * (x4 at 640x480, x6 at 1280x720, x7 at 1440x900) and centres it.
 */
#ifndef GFX_H_INCLUDED
#define GFX_H_INCLUDED

#include <stdint.h>

#define CANVAS_W 160
#define CANVAS_H 120

/* Frame buffer pixel format: 32 bits, 0x00RRGGBB (York HDMI driver).
 * If green and blue appear swapped on the monitor, use instead:
 *   #define GFX_RGB(r,g,b) ((uint32_t)(((r) << 16) | ((b) << 8) | (g)))
 */
#define GFX_RGB(r, g, b) ((uint32_t)(((r) << 16) | ((g) << 8) | (b)))

/* Palette indices */
enum {
    C_BLACK, C_WHITE, C_SKY, C_GRASS, C_YELLOW, C_RED, C_GREEN,
    C_BLUE, C_ORANGE, C_PURPLE, C_BROWN, C_GRAY, C_DARK, C_PINK,
    C_NUM
};

void gfx_clear(uint8_t c);
void gfx_rect(int x, int y, int w, int h, uint8_t c);
void gfx_char(int x, int y, char ch, int scale, uint8_t c);
void gfx_text(int x, int y, const char *s, int scale, uint8_t c);
int  gfx_text_width(const char *s, int scale);
void gfx_heart(int x, int y, uint8_t c);

/* Copy the canvas to an HDMI frame buffer (scaled and centred). */
void gfx_blit(uint32_t *fb, int width, int height, int stride_bytes);

#endif
