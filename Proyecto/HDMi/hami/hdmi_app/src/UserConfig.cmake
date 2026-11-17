set(USER_COMPILE_SOURCES
"hdmi_example_anim.c"
"zybo_z7_hdmi/display_ctrl.c"
"zybo_z7_hdmi/dynclk.c"
"platform.c"
"kidcade_game/game.c"
"kidcade_game/gfx.c"
"kidcade_game/input.c"
"kidcade_game/audio.c"
)

set(USER_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}")
set(USER_COMPILE_DEFINITIONS "")
set(USER_COMPILE_OPTIONS " -Wall -O2 -g")

set(USER_LINK_LIBRARIES "")
set(USER_LINK_DIRECTORIES "")
set(USER_LINK_OPTIONS "")
set(USER_LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/lscript.ld")