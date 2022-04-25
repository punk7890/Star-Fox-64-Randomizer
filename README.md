# Star-Fox-64-Randomizer
A Star Fox 64 randomizer with a variety of options. Coded entirely in ASM and is hardware compatible.
# Beta Version Notice
This is currently in beta. Expect bugs. Please report any you may find.
# Setting Up:

1. Grab the latest beta: https://github.com/punk7890/Star-Fox-64-Randomizer/releases

2. Expansion pack (or 8MB set on emulators).

3. An US 1.0 version of the game. NOTE: The game dump *needs* to be in Big Endian byte order or patching the ROM cannot be done (you'll get an error in the ROM extracting tool). If you get an error, you can try byteswapping your ROM with this online tool: https://hack64.net/tools/swapper.php

4. xdeltaUI https://www.romhacking.net/utilities/598/

5. xdaniel's SF64toolkit https://github.com/xdanieldzd/ozmav/tree/master/sf64toolkit (or precompiled: https://drive.google.com/file/d/1Sz1Z5G3CKK7WAetVAo0GxX92_nNQn0sN/view?usp=sharing )


# Patching:

1. Move your SF64 V1.0 (U) rom into the SF64toolkit folder and open SF64toolkit then type (without quotes) "loadrom ROMNAME".

2. Type "extractfiles", hit enter key, then type "createrom NFXE\layout.txt", hit enter key.

3. Your rebuilt ROM should be in NFXE\rebuilt.z64

4. Open xdeltaUI and apply "rando.xdelta" to your rebuilt ROM.

In some cases, like on Project 64, the emulator will need to be set to use Interpreter Core in order to access the randomizer menu. Likely the prefered emulator would be Mupen for this mod as it appears to run at full speed.
# Changing Options
Once the patch is applied, press L button at the main menu to toggle options on or off. Use the D-Pad Up / Down to move the white cursor on the left side of the screen. Press A to change the state of an option.
# The Options (April 23 2022)

Page 1 Options:

![STARFOX64_0000](https://user-images.githubusercontent.com/90301698/165075452-478e0a64-df55-4002-bc80-a70ca15cba74.png)


* RANDOM PLANETS: Enables randomized planets. Note: this will turn off MARATHON MODE and CHOOSE PLANETS if on.
* RANDOM ITEMS: All item spawns will be random.
* ALLOW SAME PLANETS: Allows the same planets to be selected. If this option is off, and RANDOM PLANETS is on, this will skip previous levels completed. Note: this will be disabled in MARATHON MODE and CHOOSE PLANETS.
* RANDOM ENGINE COLORS: Cycles through different back engine colors.
* RANDOM AMBIENT COLORS: Changes parts of the level ambient colors.
* RANDOM REFLECTION COLORS: Changes reflection ambient colors of certain map objects and ships.
* RANDOM WARP CHANCE: Chances of starting Meteo and Sector X in their warp space is 50/50.
* RANDOM EXPERT: Chances of the level being in expert or regular mode is 50/50.
* RANDOM MUSIC: Takes a random music ID when a music change occurs.
* MARATHON MODE: Forces the game in planet order of blue path > yellow path > Training Mode > Red path and ends on Venom 2. Player stats will be kept, however the end screen planet order will not be. Note: This will turn off RANDOM PLANETS, ALLOW SAME PLANETS, and CHOOSE PLANETS if on.
* MEDALS AND EXPERT: Player automatically obtains all medals and unlocks expert mode. If turned off, you must return to the title screen for it to take effect then erase your save data.
* SKIP PLANET INTROS: Skips the breiffing text in the planet selection screen.
* RAINBOW BOMBS: Bomb color changes to multicolors.
* ONE HIT KO: Player dies in one hit.
* RANDOM PORTRAITS: Speaking character portraits will be randomized based on the level ID.
* RANDOM DIALOG: Random character voice lines and text.
* CHOOSE PLANETS: Allows the player to select planets with the L button in the planet selection screen. Note: This will turn off RANDOM PLANETS, ALLOW SAME PLANETS, and MARATHON MODE if on.
* BOSS RUSH MODE: Plays through all bosses in the game in order of blue path > yellow path > red path. There will be a "SCORE" counter on-screen that counts down for as long as you are in the level and then will be added to the "TOTAL" counter for your overall total score, including hits made in the level. The score for all stages except venoms will start counting down from 10,000. Entering Venom will start the player at Venom 1 > Tunnels 1 > Surface > Tunnels 2. The initial score counter starts at 30,000 and will take your final score once the player defeats brain andross and then exits the tunnels. If the player completes a stage in expert mode, they will gain +200 points added to final score. Pressing the L button when in the pause menu will open an item menu. Players can spend points to give themselves health, lasers, etc. Use the D-Pad to navigate.

Page 2 Options:

![STARFOX64_0004](https://user-images.githubusercontent.com/90301698/165075583-c330b0a6-4e96-4553-ad5a-37bccacc5850.png)


* STARTING BOMBS: Changes the player's starting bomb count.
* STARTING LIVES: Changes the player's starting live count.
* STARTING LASER: Changes the player's starting laser type.
* DEBUG CHEATS: While these will disrupt normal game-play, these were added to test various parts of the randomizer.

Note: The player must have entered at least one planet at some point during the game session for these to work.

    L + R + C-Left = 99 lives.
    L + R + C-Right = 9 bombs.
    L + R + C-Up = Complete level (may not work correctly in some cases).
    L + R + C-Down = Restore health and wings.
    L + R + B = Kills the player.
    L + R + A = Add Hypers.
    L (Hold) + Z (Tap): Enables or disables extra damage hyper lasers (bosses only).
    L (Hold) + D-Pad Left (Tap) = Invincibility.
    L (Hold) + D-Pad Right (Tap) = Enable or disable debug text display.
    D-Pad Up + C-Up + Start = Reset to title screen.
   
* EXTRA STAR WOLFS: Star Wolf will spawn on Katina once the UFO appears and always be enabled on Bolse.
* DRUNK MODE: Logic for camera behaviour changes for a more disoriented feel.
* RANDOM DEATH ITEM: Randomly selects an item per level that will kill the player if collected.
* TRIPPY MAP COLORS: Mostly the same as random reflection and ambient colors, however this version actively changes.
* SPINNING FOX: Fox will start spinning when the player turns.
