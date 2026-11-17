/* gfx.c - see gfx.h */
#include "gfx.h"
#include <string.h>

static uint8_t canvas[CANVAS_H][CANVAS_W];

static const uint32_t palette[C_NUM] = {
    [C_BLACK]  = GFX_RGB(0, 0, 0),
    [C_WHITE]  = GFX_RGB(255, 255, 255),
    [C_SKY]    = GFX_RGB(110, 190, 255),
    [C_GRASS]  = GFX_RGB(70, 170, 70),
    [C_YELLOW] = GFX_RGB(255, 220, 40),
    [C_RED]    = GFX_RGB(230, 50, 50),
    [C_GREEN]  = GFX_RGB(40, 200, 80),
    [C_BLUE]   = GFX_RGB(40, 80, 220),
    [C_ORANGE] = GFX_RGB(255, 140, 30),
    [C_PURPLE] = GFX_RGB(150, 70, 200),
    [C_BROWN]  = GFX_RGB(140, 90, 40),
    [C_GRAY]   = GFX_RGB(160, 160, 160),
    [C_DARK]   = GFX_RGB(30, 30, 60),
    [C_PINK]   = GFX_RGB(255, 90, 150),
};

/* 5x7 font: each row is 5 bits, MSB (0x10) = leftmost pixel */
typedef struct { char ch; uint8_t rows[7]; } Glyph;

static const Glyph font[] = {
    {'0', {0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E}},
    {'1', {0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E}},
    {'2', {0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F}},
    {'3', {0x1F, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0E}},
    {'4', {0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02}},
    {'5', {0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E}},
    {'6', {0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E}},
    {'7', {0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08}},
    {'8', {0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E}},
    {'9', {0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C}},
    {'+', {0x00, 0x04, 0x04, 0x1F, 0x04, 0x04, 0x00}},
    {'-', {0x00, 0x00, 0x00, 0x1F, 0x00, 0x00, 0x00}},
    {'=', {0x00, 0x00, 0x1F, 0x00, 0x1F, 0x00, 0x00}},
    {'?', {0x0E, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04}},
    {'D', {0x1C, 0x12, 0x11, 0x11, 0x11, 0x12, 0x1C}},
    {'E', {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F}},
    {'F', {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10}},
    {'I', {0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E}},
    {'M', {0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11}},
    {'N', {0x11, 0x11, 0x19, 0x15, 0x13, 0x11, 0x11}},
    {'O', {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E}},
};

static const uint8_t heart[6] = {0x36, 0x7F, 0x7F, 0x3E, 0x1C, 0x08}; /* 7x6 */

void gfx_clear(uint8_t c)
{
    memset(canvas, c, sizeof canvas);
}

void gfx_rect(int x, int y, int w, int h, uint8_t c)
{
    if (x < 0) { w += x; x = 0; }
    if (y < 0) { h += y; y = 0; }
    if (x + w > CANVAS_W) w = CANVAS_W - x;
    if (y + h > CANVAS_H) h = CANVAS_H - y;
    if (w <= 0 || h <= 0) return;
    for (int j = 0; j < h; j++)
        memset(&canvas[y + j][x], c, (size_t)w);
}

static const uint8_t *glyph_rows(char ch)
{
    for (unsigned i = 0; i < sizeof font / sizeof font[0]; i++)
        if (font[i].ch == ch) return font[i].rows;
    return 0; /* unknown char (or space): draw nothing */
}

void gfx_char(int x, int y, char ch, int scale, uint8_t c)
{
    const uint8_t *r = glyph_rows(ch);
    if (!r) return;
    for (int row = 0; row < 7; row++)
        for (int col = 0; col < 5; col++)
            if (r[row] & (0x10 >> col))
                gfx_rect(x + col * scale, y + row * scale, scale, scale, c);
}

void gfx_text(int x, int y, const char *s, int scale, uint8_t c)
{
    for (; *s; s++, x += 6 * scale)
        gfx_char(x, y, *s, scale, c);
}

int gfx_text_width(const char *s, int scale)
{
    int n = (int)strlen(s);
    return n ? n * 6 * scale - scale : 0;
}

void gfx_heart(int x, int y, uint8_t c)
{
    for (int row = 0; row < 6; row++)
        for (int col = 0; col < 7; col++)
            if (heart[row] & (0x40 >> col))
                gfx_rect(x + col, y + row, 1, 1, c);
}

void gfx_blit(uint32_t *fb, int width, int height, int stride_bytes)
{
    if (width < CANVAS_W || height < CANVAS_H) return;

    int stride = stride_bytes / 4;
    int sx = width / CANVAS_W, sy = height / CANVAS_H;
    int s = sx < sy ? sx : sy;
    int out_h = CANVAS_H * s;
    int ox = (width - CANVAS_W * s) / 2;
    int oy = (height - out_h) / 2;
    uint32_t border = palette[C_BLACK];

    for (int y = 0; y < oy; y++) {
        uint32_t *row = fb + y * stride;
        for (int x = 0; x < width; x++) row[x] = border;
    }

    for (int cy = 0; cy < CANVAS_H; cy++) {
        uint32_t *row = fb + (oy + cy * s) * stride;
        int x = 0;
        for (; x < ox; x++) row[x] = border;
        for (int cx = 0; cx < CANVAS_W; cx++) {
            uint32_t p = palette[canvas[cy][cx]];
            for (int k = 0; k < s; k++) row[x++] = p;
        }
        for (; x < width; x++) row[x] = border;
        for (int k = 1; k < s; k++)               /* repeat the row */
            memcpy(row + k * stride, row, (size_t)width * 4);
    }

    for (int y = oy + out_h; y < height; y++) {
        uint32_t *row = fb + y * stride;
        for (int x = 0; x < width; x++) row[x] = border;
    }
}
