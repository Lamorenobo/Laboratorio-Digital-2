/* input.c - see input.h */
#include "input.h"

/* ------------------------------------------------------------------ */
/* Buttons: axi_gpio_0, channel 1 = btns_4bits                         */
/* ------------------------------------------------------------------ */
#if INPUT_USE_BUTTONS
#include "xparameters.h"
#include "xgpio.h"

#define BTN_CHANNEL 1

/* Which button bit does what. Change to match your board/wiring. */
#define BTN_BIT_RIGHT 0x1
#define BTN_BIT_DOWN  0x2
#define BTN_BIT_UP    0x4
#define BTN_BIT_LEFT  0x8

static XGpio btn_gpio;

static void buttons_init(void)
{
#ifndef SDT
    XGpio_Initialize(&btn_gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
#else
    XGpio_Initialize(&btn_gpio, XPAR_AXI_GPIO_0_BASEADDR);
#endif
    XGpio_SetDataDirection(&btn_gpio, BTN_CHANNEL, 0xF); /* all inputs */
}

static uint32_t buttons_read(void)
{
    uint32_t raw = XGpio_DiscreteRead(&btn_gpio, BTN_CHANNEL);
    uint32_t in = 0;
    if (raw & BTN_BIT_LEFT)  in |= IN_LEFT;
    if (raw & BTN_BIT_RIGHT) in |= IN_RIGHT;
    if (raw & BTN_BIT_UP)    in |= IN_UP | IN_OK;
    if (raw & BTN_BIT_DOWN)  in |= IN_DOWN;
    return in;
}
#endif

/* ------------------------------------------------------------------ */
/* Joystick: not implemented yet                                       */
/* ------------------------------------------------------------------ */
#if INPUT_USE_JOYSTICK
static void joystick_init(void)
{
    /* TODO: initialise your joystick (e.g. Pmod JSTK2 over SPI,
     * or an analog stick read with the XADC). */
}

static uint32_t joystick_read(void)
{
    /* TODO: read the position, apply a dead zone and convert it to
     * IN_LEFT / IN_RIGHT / IN_UP / IN_DOWN (and IN_OK for its button). */
    return 0;
}
#endif

/* ------------------------------------------------------------------ */

void input_init(void)
{
#if INPUT_USE_BUTTONS
    buttons_init();
#endif
#if INPUT_USE_JOYSTICK
    joystick_init();
#endif
}

uint32_t input_read(void)
{
    uint32_t in = 0;
#if INPUT_USE_BUTTONS
    in |= buttons_read();
#endif
#if INPUT_USE_JOYSTICK
    in |= joystick_read();
#endif
    return in;
}
