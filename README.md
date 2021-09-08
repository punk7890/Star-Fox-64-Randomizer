# Star-Fox-64-Randomizer
A Star Fox 64 randomizer with a variety of options. Hardware compatible.
# Beta Version Notice
This is currently in beta. Expect bugs. Please report any you may find.
# Setting Up:

1. Expansion pack (or 8MB set on emulators).

2. An US 1.0 version of the game. NOTE: The game dump *needs* to be in Big Endian byte order or patching the ROM cannot be done (you'll get an error in the ROM extracting tool).

3. xdeltaUI https://www.romhacking.net/utilities/598/

4. xdaniel's SF64toolkit https://github.com/xdanieldzd/ozmav/tree/master/sf64toolkit (or precompiled: https://drive.google.com/file/d/1Sz1Z5G3CKK7WAetVAo0GxX92_nNQn0sN/view?usp=sharing )



# Patching:

1. Move your SF64 V1.0 (U) rom into the SF64toolkit folder and open SF64toolkit then type (without quotes) "loadrom ROMNAME".

2. Type "extractfiles", hit enter key, then type "createrom NFXE\layout.txt", hit enter key.

3. Your rebuilt ROM should be in NFXE\rebuilt.z64

4. Open xdeltaUI and apply "rando.xdelta" to your rebuilt ROM.

In some cases, like on Project 64, the emulator will need to be set to use Interpreter Core in order to access the randomizer menu. Likely the prefered emulator would be Mupen for this mod as it appears to run at full speed.
# Changing Options
Once the patch is applied, press L button at the main menu to toggle options on or off. Use the D-Pad Up / Down to move the white cursor on the left side of the screen. Press A to change the state of an option.
