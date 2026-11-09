/**
 * Example of using the Digilent display drivers for Zybo Z7 HDMI output, with animation
 * Russell Joyce, 11/03/2019
 * Ian Gray, 15/02/2026 - Updated for Xilinx 2025.1 tools
 */

#include <stdio.h>
#include <xil_types.h>
#include "xil_cache.h"
#include "xparameters.h"
#include "zybo_z7_hdmi/display_ctrl.h"
#include "kidcade_game/game.h"
// #include "zybo_z7_hdmi/display_ctrl.h"

// Frame size (based on 1440x900 resolution, 32 bits per pixel)
#define MAX_FRAME (1440*900)
#define FRAME_STRIDE (1440*4)

DisplayCtrl dispCtrl; // Display driver struct
u32 frameBuf[DISPLAY_NUM_FRAMES][MAX_FRAME] __attribute__((aligned(0x20))); // Frame buffers for video data
void *pFrames[DISPLAY_NUM_FRAMES]; // Array of pointers to the frame buffers

int main(void) {
	// Initialise an array of pointers to the 2 frame buffers
	int i;
	for (i = 0; i < DISPLAY_NUM_FRAMES; i++)
		pFrames[i] = frameBuf[i];

	// Initialise the display controller
	DisplayInitialize(&dispCtrl, XPAR_HDMI_AXI_VDMA_0_BASEADDR, XPAR_XVTC_0_BASEADDR, XPAR_HDMI_AXI_DYNCLK_0_BASEADDR, pFrames, FRAME_STRIDE);

	// Start with the first frame buffer (of two)
	DisplayChangeFrame(&dispCtrl, 0);

	// Set the display resolution
	DisplaySetMode(&dispCtrl, &VMODE_1440x900);

	// Enable video output
	DisplayStart(&dispCtrl);

	printf("\n\r");
	printf("HDMI output enabled\n\r");
	printf("Current Resolution: %s\n\r", dispCtrl.vMode.label);
	printf("Pixel Clock Frequency: %.3fMHz\n\r", dispCtrl.pxlFreq);
	printf("Starting animation loop...\n\r");

   game_init();
   while (1) {
       u32 next = (dispCtrl.curFrame + 1) % DISPLAY_NUM_FRAMES;
       game_frame((u32 *)dispCtrl.framePtr[next],
                  dispCtrl.vMode.width, dispCtrl.vMode.height,
                  dispCtrl.stride);
       Xil_DCacheFlush();
       DisplayChangeFrame(&dispCtrl, next);
       DisplayWaitForSync(&dispCtrl);
   }
}