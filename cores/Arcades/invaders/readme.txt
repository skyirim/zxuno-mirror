---------------------------------------------------------------------------------
-- Space Invaders Arcade Port to ZX-UNO by Quest 2017 
---------------------------------------------------------------------------------
NOTE: NO ROMS ARE PROVIDED!!! YOU MUST FIN IT YOURSELF AND ADD IT TO THE PROJECT!
---------------------------------------------------------------------------------

Original README:
------------------

This is a simulation model of Space Invaders hardware.

The original source code was downloaded from:
http://fpgaarcade.com/games.htm

In order to run Space Invaders roms the end user must own a legal copy of the game and provide their own roms.
****IMPORTANT: No ROMs are supplied with this package. The end user must supply their own Mame compatible ROMs********

-In order to synthesize in your own ROM place the ROM files in the roms directory. 
-Run the "scripts/build_roms_*.bat" file, this will copy your roms into the build directory. 
-Make sure you have Xilinx ISE Webpack installed and double click on "build\*.xise". The Xise file you select should correspond to what type of hardware you have.
-Synthesize the design to create your own bitfile with your own ROM file included.

In order to to run the generated bit file make sure you have the Papilio Loader installed and associated with *.bit files. Double click on the "*.bit" file.
