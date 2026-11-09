/* game.c - see game.h */
#include "game.h"
#include "gfx.h"
#include "input.h"
#include "audio.h"

#define LANES          3
#define LANE_W         (CANVAS_W / LANES)
#define BAR_H          22
#define ITEM_SIZE      18
#define ITEM_TOP       (BAR_H + 4)
#define BASKET_Y       94
#define BASKET_W       32
#define BASKET_H       10
#define GROUND_Y       108
#define START_LIVES    3
#define FP             16            /* fixed point: 1 px = 16 units   */
#define SPEED_START    6             /* 6/16 px per frame (~3 s fall)  */
#define SPEED_MAX      16            /* 1 px per frame                 */
#define RESULT_FRAMES  45
#define GAMEOVER_FRAMES (60 * 4)
#define DEMO_TIMEOUT   (60 * 20)     /* back to demo after 20 s idle   */

typedef enum { ST_PLAY, ST_RESULT, ST_GAMEOVER } State;

static State    state;
static int      a, b, op_minus, answer;
static int      lane_value[LANES];
static int      item_y;              /* fixed point */
static int      speed;
static int      basket_lane, basket_x;
static int      score, lives;
static int      timer;
static int      last_correct;
static int      demo = 1, idle;
static int      demo_target, demo_react;
static uint32_t prev_in;
static uint32_t frame_count;
static uint32_t rng = 0x12345678u;

/* ------------------------------------------------------------------ */

static uint32_t rnd(void)
{
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
}

static int rnd_range(int n) { return (int)(rnd() % (uint32_t)n); }

static int lane_center(int l) { return l * LANE_W + LANE_W / 2; }

static void int_to_str(int v, char *out)
{
    char tmp[8];
    int n = 0, i = 0;
    if (v <= 0) tmp[n++] = '0';
    while (v > 0 && n < 7) { tmp[n++] = (char)('0' + v % 10); v /= 10; }
    while (n) out[i++] = tmp[--n];
    out[i] = 0;
}

static void text_centered(int y, const char *s, int scale, uint8_t c)
{
    gfx_text((CANVAS_W - gfx_text_width(s, scale)) / 2, y, s, scale, c);
}

/* ------------------------------------------------------------------ */

static void new_round(void)
{
    /* results always 0..9 */
    op_minus = rnd_range(2);
    if (!op_minus) { a = rnd_range(10); b = rnd_range(10 - a); answer = a + b; }
    else           { a = rnd_range(10); b = rnd_range(a + 1);  answer = a - b; }

    int correct_lane = rnd_range(LANES);
    for (int l = 0; l < LANES; l++) {
        if (l == correct_lane) { lane_value[l] = answer; continue; }
        int v, dup;
        do {
            v = rnd_range(10);
            dup = (v == answer);
            for (int k = 0; k < l; k++)
                if (lane_value[k] == v) dup = 1;
        } while (dup);
        lane_value[l] = v;
    }

    /* demo player: usually right, sometimes wrong */
    demo_target = (rnd_range(5) == 0) ? rnd_range(LANES) : correct_lane;
    demo_react  = ITEM_TOP + 10 + rnd_range(30);

    item_y = ITEM_TOP * FP;
    state  = ST_PLAY;
}

static void reset_game(void)
{
    score = 0;
    lives = START_LIVES;
    speed = SPEED_START;
    basket_lane = 1;
    basket_x = lane_center(1);
    new_round();
}

void game_init(void)
{
    input_init();
    audio_init();
    reset_game();
}

/* ------------------------------------------------------------------ */

static void update(void)
{
    uint32_t in = input_read();
    uint32_t pressed = in & ~prev_in;
    prev_in = in;
    frame_count++;

    if (in) {
        if (demo) {                      /* a player arrived */
            demo = 0;
            rng ^= frame_count * 2654435761u;
            if (!rng) rng = 1;
            reset_game();
            pressed = 0;
        }
        idle = 0;
    } else if (!demo && ++idle > DEMO_TIMEOUT) {
        demo = 1;
        reset_game();
    }

    switch (state) {
    case ST_PLAY:
        if (demo) {
            if (item_y / FP > demo_react) basket_lane = demo_target;
        } else {
            if ((pressed & IN_LEFT) && basket_lane > 0) {
                basket_lane--; audio_play(SND_MOVE);
            }
            if ((pressed & IN_RIGHT) && basket_lane < LANES - 1) {
                basket_lane++; audio_play(SND_MOVE);
            }
        }
        item_y += speed;
        if (item_y / FP + ITEM_SIZE >= BASKET_Y) {
            last_correct = (lane_value[basket_lane] == answer);
            if (last_correct) {
                score++;
                if (speed < SPEED_MAX && score % 2 == 0) speed++;
                audio_play(SND_CORRECT);
            } else {
                lives--;
                audio_play(SND_WRONG);
            }
            timer = RESULT_FRAMES;
            state = ST_RESULT;
        }
        break;

    case ST_RESULT:
        if (--timer <= 0) {
            if (lives <= 0) {
                state = ST_GAMEOVER;
                timer = GAMEOVER_FRAMES;
                audio_play(SND_GAMEOVER);
            } else {
                new_round();
            }
        }
        break;

    case ST_GAMEOVER:
        if (timer > 0) timer--;
        if ((demo && timer == 0) ||
            (!demo && timer < GAMEOVER_FRAMES - 60 && pressed))
            reset_game();
        break;
    }

    /* slide the basket towards its lane */
    int target = lane_center(basket_lane);
    if (basket_x < target)      { basket_x += 4; if (basket_x > target) basket_x = target; }
    else if (basket_x > target) { basket_x -= 4; if (basket_x < target) basket_x = target; }

    audio_update();
}

/* ------------------------------------------------------------------ */

static void draw_item(int lane, int y, int value)
{
    int x = lane_center(lane) - ITEM_SIZE / 2;
    gfx_rect(x + 2, y, ITEM_SIZE - 4, ITEM_SIZE, C_YELLOW);
    gfx_rect(x, y + 2, ITEM_SIZE, ITEM_SIZE - 4, C_YELLOW);
    gfx_char(x + (ITEM_SIZE - 10) / 2, y + (ITEM_SIZE - 14) / 2,
             (char)('0' + value), 2, C_DARK);
}

static void draw_basket(void)
{
    int x = basket_x - BASKET_W / 2;
    gfx_rect(x - 2, BASKET_Y - 2, BASKET_W + 4, 3, C_ORANGE);
    gfx_rect(x, BASKET_Y + 1, BASKET_W, BASKET_H - 1, C_BROWN);
    for (int i = 4; i < BASKET_W; i += 6)
        gfx_rect(x + i, BASKET_Y + 3, 2, BASKET_H - 4, C_ORANGE);
}

static void draw(void)
{
    char s[8];

    gfx_clear(C_SKY);
    gfx_rect(0, GROUND_Y, CANVAS_W, CANVAS_H - GROUND_Y, C_GRASS);

    uint8_t bar = C_DARK;
    if (state == ST_RESULT) bar = last_correct ? C_GREEN : C_RED;
    gfx_rect(0, 0, CANVAS_W, BAR_H, bar);

    if (state == ST_GAMEOVER) {
        text_centered(34, "FIN", 4, C_DARK);
        int_to_str(score, s);
        text_centered(72, s, 3, C_PURPLE);
    } else {
        /* operation, e.g. "3+4=?" */
        s[0] = (char)('0' + a);
        s[1] = op_minus ? '-' : '+';
        s[2] = (char)('0' + b);
        s[3] = '=';
        s[4] = (state == ST_RESULT) ? (char)('0' + answer) : '?';
        s[5] = 0;
        text_centered(4, s, 2, C_WHITE);

        for (int i = 0; i < lives; i++)
            gfx_heart(4 + i * 9, 8, C_PINK);

        int_to_str(score, s);
        gfx_text(CANVAS_W - 4 - gfx_text_width(s, 1), 8, s, 1, C_YELLOW);

        for (int l = 1; l < LANES; l++)
            gfx_rect(l * LANE_W, BAR_H, 1, GROUND_Y - BAR_H, C_WHITE);

        if (state == ST_PLAY) {
            for (int l = 0; l < LANES; l++)
                draw_item(l, item_y / FP, lane_value[l]);
        } else {
            draw_item(basket_lane, BASKET_Y - ITEM_SIZE, lane_value[basket_lane]);
        }
        draw_basket();
    }

    if (demo && (frame_count / 30) % 2 == 0)
        text_centered(GROUND_Y + 2, "DEMO", 1, C_WHITE);
}

void game_frame(uint32_t *fb, int width, int height, int stride_bytes)
{
    update();
    draw();
    gfx_blit(fb, width, height, stride_bytes);
}
