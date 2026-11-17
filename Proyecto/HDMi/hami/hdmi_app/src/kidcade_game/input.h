/* input.h - input layer. The game only sees these IN_* actions,
 * so any device (buttons, joystick, keyboard...) can be plugged in
 * by editing input.c only.
 */
#ifndef INPUT_H_INCLUDED
#define INPUT_H_INCLUDED

#include <stdint.h>

#define IN_LEFT  0x01
#define IN_RIGHT 0x02
#define IN_UP    0x04
#define IN_DOWN  0x08
#define IN_OK    0x10

/* Enable input sources here (1 = on).
 * With everything off, the game plays itself in DEMO mode. */
#define INPUT_USE_BUTTONS  0   /* Zybo buttons via axi_gpio_0 (btns_4bits) */
#define INPUT_USE_JOYSTICK 0   /* see joystick_read() in input.c */

void     input_init(void);
uint32_t input_read(void);   /* bitmask of IN_* currently held down */

#endif
