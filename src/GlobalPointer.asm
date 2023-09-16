

	/* Used for important randomizer variables. Make sure to align your variables if using 8/16 bit values.  */

.n64

.org 0x80400000
.region 0x8000	;No idea how to properly use all 64kb of global pointer space with this compiler, so it's limited to 32kb.

GLOBAL_POINTER:		;top of global pointer
.asciiz "2023-09-15 17:18:57"
.align 4,0

gDebugModeFlag:		;enables a set of test features
.d32 0

gDebugModeFreezeFrameFlag:		
.d32 0

gMaxRandomizerMenus:		;change if more menus are added
.d32 5

gCurrentRandomizerMenu:		;value for what page of the randomizer menu the player is in.
.d32 0

gRandomPlanetsFlag:		;does the user have random planets on
.d32 1

gRandomPlanetsDoneFlag:		;has the player completed x num of levels, if so stop randomizing
.d32 0

gAllowSamePlanetsFlag:
.d32 1

gRandomItemDropsFlag:
.d32 1

gRandomExpertFlag:
.d32 0

gRandomWarpsFlag:
.d32 0

gOneHitKOFlag:
.d32 0

gEnablePlanetSelections:
.d32 0

gMarathonModeFlag:
.d32 0
gMarathonModeAddToCompletedTimesFlag:
.d32 0
gMarathonModeSetPlanetActiveFlag:
.d32 0
gMarathonModeCompletedTimes:
.d32 0
gMarathonModeLevelList:
.d8 0xA ;training
.d8 0x0 ;corn
.d8 0x1 ;met
.d8 0xE ;fort
.d8 0x2 ;SX
.d8 0xC ;Titania
.d8 0x11 ;Bolse
.d8 0x6 ;VE1 
.d8 0x10 ;Katina
.d8 0x7 ;Solar
.d8 0xB ;MacBeth
.d8 0x5 ;SY
.d8 0xD ;Aquas
.d8 0x8 ;Zoness
.d8 0x12 ;SZ
.d8 0x3 ;A6
.align 4,0xFF ;align end flag to 32 bit boundary

gWaitTimer:		;used for special pause state (0x3 freeze game) to increment timer and use checks on. Only used for Marathon Mode.
.d32 0

gExtraStarWolfsFlag:
.d32 0
gWolfsSpawnedFlag:	;used to check if randomizer logic spawned wolf group. Unsets in end scene.
.d32 0

gUnlockAllMedalsAndExpertFlag:		;unlocks medals and expert. turn off in menu then erase save data for a regular game.
.d32 1

gRandomColorsActiveFlag:
.d32 0

gQuickScoreScreensFlag:
.d32 0

gDidQuickScoreScreensFlag:
.d32 0

gRainbowBombsFlag:
.d32 0

gRainbowBombColorSeek:
.d32 0

gRainbowBombColorTable:	;46 bomb colors
.d32 C_RED
.d32 0xFF2000FF
.d32 0xFF4000FF
.d32 0xFF6000FF
.d32 0xFF8000FF
.d32 0xFFA000FF
.d32 0xFFC000FF
.d32 0xFFE000FF
.d32 0xFFFF00FF
.d32 0xC0FF00FF
.d32 0xA0FF00FF
.d32 0x80FF00FF
.d32 0x60FF00FF
.d32 0x40FF00FF
.d32 0x20FF00FF
.d32 C_GREEN
.d32 0x00FF20FF
.d32 0x00FF40FF
.d32 0x00FF60FF
.d32 0x00FF80FF
.d32 0x00FFA0FF
.d32 0x00FFC0FF
.d32 0x00FFE0FF
.d32 0x00FFFFFF
.d32 0x00E0FFFF
.d32 0x00C0FFFF
.d32 0x00A0FFFF
.d32 0x0080FFFF
.d32 0x0060FFFF
.d32 0x0040FFFF
.d32 0x0020FFFF
.d32 C_BLUE
.d32 0x2000FFFF
.d32 0x4000FFFF
.d32 0x6000FFFF
.d32 0x8000FFFF
.d32 0xA000FFFF
.d32 0xC000FFFF
.d32 0xE000FFFF
.d32 0xFF00E0FF
.d32 0xFF00C0FF
.d32 0xFF00A0FF
.d32 0xFF0080FF
.d32 0xFF0060FF
.d32 0xFF0040FF
.d32 0xFF0020FF
.d32 0

gRandomItemDropsSeek:		;table entry seek
.d32 0

gRandomItemDropsTable:		;item ids, leave -1 after last valid entry

	/* Item ID defines */
		@ID_LASER equ 0x142
		@ID_SILVER equ 0x144
		@ID_STAR equ 0x145
		@ID_BOMB equ 0x147
		@ID_LIFE equ 0x14F
		@ID_GOLD equ 0x150
		@ID_REPAIR equ 0x151

.d32 @ID_LASER
.d32 @ID_SILVER
.d32 @ID_STAR
.d32 @ID_BOMB
.d32 @ID_LIFE
.d32 @ID_GOLD
.d32 @ID_REPAIR
.d32 0xFFFFFFFF

gRandomDeathItemFlag:
.d32 0
gRandomDeathItemInGameFlag:		;flag checks for in-game when on Venoms and tunnels. If set, stops randomizing on these levels
.d32 0
gRandomDeathItemCycle:
.d32 0
gRandomDeathItemCurrentItem:
.d32 0
gRandomDeathItemTable:

	/* Item ID defines */
		@ID_CHECKPOINT equ 0x143
		@ID_BLUEWARP equ 0x146
	
.d32 @ID_LASER
.d32 @ID_SILVER
.d32 @ID_STAR
.d32 @ID_BOMB
.d32 @ID_LIFE
.d32 @ID_GOLD
.d32 @ID_REPAIR
.d32 @ID_CHECKPOINT
.d32 @ID_BLUEWARP
.d32 0

gItemDropFunctionHookValue:		;clever ways of creating calls to custom functions that will move around as the code becomes bigger
jal SUB_CustomItemDropFunction
nop
gInitLevelEndVarsHookValue:
jal SUB_CustomEndScreenHook
nop
gRainbowBombsHookValue:
jal SUB_RainbowBombs
nop
gMainMenuTextHookValue:
j SUB_MainMenuText
nop
gRandomPortraitsHookValue:
jal SUB_RandomPortraits
nop
gRandomDialogHookValue:
jal SUB_RandomDialog
nop
gInGameTextHookValue:
jal SUB_InGameText
nop
gRedEngineHookValue:
jal SUB_RedEngineRoutine
nop
gBlueEngineHookValue:
jal SUB_BlueEngineRoutine
nop
gRandomizerMenuHookValue:
jal SUB_RandomizerMenu
nop

gCrashHandlerHookCreated:		;force crash handler screen if game crashed flag
.d32 0

gEndScreenHookCreated:
.d32 0

gSpecialStageFlag:	;1 on (score unlock method), 2 random
.d32 2
gSpecialStageRandomFlag:
.d32 0
gSpecialStageSuperWolfFlag:
.d32 0
gSpecialStageSuperWolfFlag2:
.d32 0
gSpecialStageSuperWolfFlag3:
.d32 0
gSpecialStageBombReadyTimer:
.d32 0
gSpecialStageEndWaitTimer:
.d32 0
gSpecialStageChoosePlanetsFlag:
.d32 0
gSpecialStageBRMMarathonScore:	;total score for boss rush and marathon
.d32 85000
gSpecialStageBRMScore:	;total score for just boss rush
.d32 50000
gSpecialStageBRMBasicScore:	;fixed level score timer for completing the stage
.d32 5000
gSpecialStageMarathonScore: ;total score for just marathon
.d32 2200
gSpecialStageRegularScore:	;total score for regular game mode or random planets. 
.d32 1000

gBossRushModeFlag:
.d32 0
gPlayerLivesNotEqualFlagBRM:
.d32 0
gBRMAddToCompletedTimesFlag:
.d32 0
gBRMAddToCompletedTimes:
.d32 0
gTimerActive:
.d32 0
gTimerScore:
.d32 0
gTimerFinalScore:
.d32 0
gTimerScoreToDisplay:
.d32 0
gLastTimerVenoms:
.d32 0
gLastAND2Timer:
.d32 0
gTunnels2IsDoneFlag:
.d32 0
gBRMVenom1TimeMARATHON:
.d32 32000
gBRMVenom1TimeREGULAR:
.d32 18000
gBRMVenom2TimeREGULAR:
.d32 20500
gTimerScoreREGULAR:
.d32 10000
gBRMExpertAddScore:
.d32 300
gCornFlag:	;0 = Mech all range boss, 1 = ship boss
.d32 0
gLTextWaitTimer:	;timer for press L to open item menu text to render on-screen
.d32 0
gBRMMenuState:	;menu active or not
.d32 0
gBRMMenuCursorValue:
.d32 0
gBRMMaxCursorValue:
.d32 7
gBRMMenuCursorY:
.d32 65
gBRMMenuCursorX:
.d32 68
gBRMMenuCursorYOrgPos:
.d32 65
gBRMMenuCursorXOrgPos:
.d32 68
gBombCost:
.d32 500
gLaserCost:
.d32 800
gQuarterHealthCost:
.d32 2500
gHalfHealthCost:
.d32 3400
g1upCost:
.d32 3000
gRepairCost:
.d32 2100
gShieldCost:
.d32 12000
gShieldTimer:
.d32 512
gOldHealth:
.d32 255
gOldWingHealthR:
.d32 60
gOldWingHealthL:
.d32 60
gOldWingStates:
.d32 0x0202
gBRMLevelList:	;if MA mode is on
;.d8 0xA ;training if MA mode is on
.d8 0x0 ;corn
.d8 0x1 ;met
.d8 0xE ;fort
.d8 0x2 ;SX
.d8 0xC ;Titania
.d8 0x11 ;Bolse
.d8 0x6 ;VE1 
.d8 0x0 ;corn
.d8 0x10 ;Katina
.d8 0x7 ;Solar
.d8 0xB ;MacBeth
.d8 0x5 ;SY
.d8 0xD ;Aquas
.d8 0x8 ;Zoness
.d8 0x12 ;SZ
.d8 0x3 ;A6
.d8 0xFF
.align 4,0xFF

; gMaxLevelList:
; .d32 12

gLevelListSeek:		;used as a ID to load from gLevelList
.d32 0

gLevelList: 	;used for valid planets
.d8 0x0 ;+0 Corneria
.d8 0x1 ;+1 Meteo
.d8 0x2 ;+2 Sector X
.d8 0x5 ;+3 Sector Y
.d8 0x7 ;+4 Solar
.d8 0x8 ;+5 Zoness
.d8 0xB ;+6 Macbeth
.d8 0xC ;+7 Titania
.d8 0xD ;+8 Aquas
.d8 0xE ;+9 Fortuna
.d8 0x10 ;+0xA Katina
.d8 0x12 ;+0xB Sector Z
.d8 0xFF ;+0xC end of list flag
.align 4,0xFF ;align end flag to 32 bit boundary


gLevelA6: 	;exception levels
.d32 0x03
gLevelBO:
.d32 0x11

gPreviousLevelList:		;keeps track of the last 12 levels (or more in the future)
.d32 0xFFFFFFFF
gPreviousLevelList4:
.d32 0xFFFFFFFF
gPreviousLevelList8:
.d32 0xFFFFFFFF

gPlayerLivesNotEqualFlag:	;used for checks if player lives are not equal to gPreviousLives. Sets to true if not equal
.d32 0

gPreviousLives:
.d32 2

gPreviousBombs:
.d32 3

gPreviousLasers:
.d32 0

gPreviousTotalScore:
.d32 0

gPreviousLevel:
.d32 0xFFFFFFFF

gPreviousExpertFlag:
.d32 0

gPreviousWarpFlag:
.d32 0

gDidSoftReset:		;if set, tells randomizer that a soft reset occured.
.d32 0

gRandomDialogFlag:
.d32 1
gRandomDialogSeek:
.d32 0

gRandomPortraitsFlag:
.d32 1
gRandomPortraitSeek:
.d32 0
gRandomPortraitsCurrentBeginAddress:		;used for dynamic portrait loads
.d32 0
gCorneriaPorts:	;portrait IDs per level. Change these to pre-defined values later
.d32 0x41f00000	;8
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x42DC0000
.d32 0x42A00000
gMeteoPorts:	;7
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x42C80000
gFortunaBolseAndVE2Ports:	;14
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x43480000
.d32 0x435c0000
.d32 0x43520000
.d32 0x43660000
.d32 0x43700000
.d32 0x43820000
.d32 0x437a0000
.d32 0x43870000
gKatinaPorts:		;18
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x0
.d32 0x428C0000
.d32 0x42B40000
.d32 0x43480000
.d32 0x435c0000
.d32 0x43520000
.d32 0x43660000
.d32 0x43700000
.d32 0x43820000
.d32 0x437a0000
.d32 0x43870000
.d32 0x432a0000
.d32 0x42200000
.d32 0x42480000
.d32 0x42700000
gSectorXPorts:		;12
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x42200000
.d32 0x432A0000
.d32 0x42480000
.d32 0x43160000
.d32 0x42700000
.d32 0x428C0000
gVenom1LevelPorts:	;6
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x0
.d32 0x42B40000
.d32 0x425c0000
gVenomTunnelPorts:	;14
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x0
.d32 0x428C0000
.d32 0x42B40000	
.d32 0x43700000
.d32 0x43820000
.d32 0x437a0000
.d32 0x43870000
.d32 0x432a0000
.d32 0x42200000
.d32 0x42480000
.d32 0x42700000
gSolorSectorZPorts:	;11
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x42200000
.d32 0x432A0000
.d32 0x42480000
.d32 0x42700000
.d32 0x428C0000
gMacBethPorts:	;12
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x42200000
.d32 0x432A0000
.d32 0x42480000
.d32 0x42700000
.d32 0x428C0000
.d32 0x433e0000
gSectorYPorts:		;7
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x43200000
gAquasAndTitaniaPorts:	;6
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
gArea6Ports:		;9
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x425c0000
.d32 0x42f00000
.d32 0x43340000
gZonessPorts:		;12
.d32 0x41f00000
.d32 0x41A00000
.d32 0x41200000
.d32 0x41f00000
.d32 0x0
.d32 0x42B40000
.d32 0x42200000
.d32 0x432A0000
.d32 0x42480000
.d32 0x42700000
.d32 0x428C0000
.d32 0x43020000

gRandomEngineColorsFlag:
.d32 1
gRandomEngineColorsSeek:
.d32 0
gRandomEngineColorsTable:	;leave zero after last valid entry
.d32 0xff6C00ff ;orange
.d32 0xe72111ff ;red-ish
.d32 0xfff300ff ;yellow
.d32 0x36ff00ff ;light green
.d32 0x00ff93ff ;lime green
.d32 0x00ffffff ;cyan
.d32 0x00cdffff ;lightcyan
.d32 0x0080ffff ;navyblue
.d32 0x000cffff ;deepblue
.d32 0xd800ffff ;purple
.d32 0x9b3affff ;light purple
.d32 0xff00bdff ;pink
.d32 0xff0068ff ;redish pink
.d32 C_RED
.d32 C_GREEN
.d32 C_WHITE
.d32 C_BLACK
.d32 0

gRandomAmbientColors1Flag:
.d32 0
gRandomAmbientColors2Flag:
.d32 0

gRandomMusicFlag:
.d32 0
gRandomMusicSeek:
.d32 0
gRandomMusicTable:		;leave zero after last valid entry
.d32 0x2
.d32 0x3
.d32 0x4
.d32 0x5
.d32 0x6
.d32 0x7
.d32 0x8
.d32 0xA
.d32 0xB
.d32 0xC
.d32 0xE
.d32 0x11
.d32 0x12
.d32 0x13
.d32 0x1C
.d32 0x21
.d32 0x2A
.d32 0x2B
.d32 0x2E
.d32 0x2F
.d32 0x3A
.d32 0x3D
.d32 0x3F
.d32 0x41
.d32 0

gUserMenuColorValue:		;current menu color
.d32 C_PURPLE
gUserMenuColorSeek:		;table seek value
.d32 0
gRandomizerMenuColorTable:		;menu color table. leave 0 after last valid entry
.d32 C_PURPLE
.d32 C_CYAN
.d32 C_GREEN
.d32 C_BLUE
.d32 C_YELLOW
.d32 C_RED
.d32 C_WHITE
.d32 0

gRandomizerPage1MaxOptions:
.d32 10
gRandomizerPage2MaxOptions:
.d32 0
gRandomizerPage3MaxOptions:
.d32 4
gRandomizerPage4MaxOptions:
.d32 7
gMenuCursorValue:		;randomizer menu cursor value
.d32 0
gCursorStartingDefaultX:		;default X pos
.d32 0x27
gCursorStartingDefaultY:		;default Y pos
.d32 0x2C
gCursorStartingX:		;alignment for randomizer cursor
.d32 0x27
gCursorStartingY:		;alignment for randomizer cursor. Increase this by 6 or -6 when moving cursor.
.d32 0x2C
gXposToRender:		;sent as an argument to PrintOnOffText function and reads this value when called
.d32 0
gYposToRender:		;sent as an argument to PrintOnOffText function and reads this value when called
.d32 0
gOnOffLocationToRender:		;sent as an argument to PrintOnOffText function and reads this value when called
.d32 0

gEnduranceModeFlag:
.d32 0
gEnduranceModeTimerEnabledFlag:
.d32 0
gEnduranceModeTimerDisplayFlag:
.d32 0
gEnduranceModeStartingTimer:
.d32 5000
gEnduranceModeCurrentTimer:
.d32 0
gEnduranceModeCurrentTimerGreenZone:
.d32 3500
gEnduranceModeCurrentTimerYellowZone:
.d32 2001
gEnduranceModeCurrentTimerRedZone:
.d32 2000
gEnduranceModeLevelTimerEnableFlag:
.d32 0
gEnduranceModeLevelTimer:
.d32 0
gEnduranceModePreviousHits:		;stores and checks for comparing against current hits
.d32 0
gEnduranceModePreviousBombs:
.d32 3
gEnduranceModeSubtractBombScoreNormal:
.d32 100
gEnduranceModeSubtractBombScoreExpert:
.d32 160
gEnduranceModeAddIfDualLaserScoreNormal:
.d32 160
gEnduranceModeAddIfDualLaserScoreExpert:
.d32 140
gEnduranceModeAddIfHyperLaserScoreNormal:
.d32 200
gEnduranceModeAddIfHyperLaserScoreExpert:
.d32 180
gEnduranceModeRegularScoreTimesNormal:		
.d32 45
gEnduranceModeRegularScoreTimesExpert:		
.d32 40
gEnduranceModeDoneScoreEndSceneFlag:
.d32 0
gEnduranceModePlanetTimerYellowNormal:
.d32 7500
gEnduranceModePlanetTimerRedNormal:
.d32 9000
gEnduranceModePlanetTimerYellowExpert:
.d32 7200
gEnduranceModePlanetTimerRedExpert:
.d32 8500
gEnduranceModePlanetTimerNormalScoreGreenAdd:
.d32 550
gEnduranceModePlanetTimerNormalScoreYellowAdd:
.d32 450
gEnduranceModePlanetTimerNormalScoreRedAdd:
.d32 100
gEnduranceModePlanetTimerExpertScoreGreenAdd:
.d32 300
gEnduranceModePlanetTimerExpertScoreYellowAdd:
.d32 200
gEnduranceModePlanetTimerExpertScoreRedAdd:
.d32 0
gEnduranceModeDonePlanetTimerAddFlag:
.d32 0

gSurvivalModeFlag:
.d32 0

gProtectTheTargetsModeFlag:
.d32 0

.endregion
;.endarea